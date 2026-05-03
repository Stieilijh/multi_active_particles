import numpy as np
import h5py
from scipy.stats import linregress
from numba import njit
from multiprocessing import Pool, cpu_count

import os

FILE = os.environ.get("FILE", "default_path_here")

def get_density_value(d):
    return float(d.split("_")[1])


def get_L_value(L):
    return int(L.split("_")[1])


@njit
def smooth_interface(interface):
    L = len(interface)
    smooth = np.zeros(L)
    for i in range(L):
        smooth[i] = (interface[(i-1)%L] + interface[i] + interface[(i+1)%L]) / 3.0
    return smooth


@njit
def get_well_depths_numba(interface):
    L = len(interface)
    smooth = smooth_interface(interface)
    depths = []

    for i in range(L):
        left = (i - 1) % L
        right = (i + 1) % L

        if not (smooth[i] < smooth[left] and smooth[i] < smooth[right]):
            continue

        j = left
        while not (smooth[j] > smooth[(j-1)%L] and smooth[j] > smooth[(j+1)%L]):
            j = (j - 1) % L
        left_peak = smooth[j]

        j = right
        while not (smooth[j] > smooth[(j-1)%L] and smooth[j] > smooth[(j+1)%L]):
            j = (j + 1) % L
        right_peak = smooth[j]

        depth = int(round(min(left_peak, right_peak) - smooth[i]))
        if depth >= 2:
            depths.append(depth)

    return depths, smooth


def process_config(config):
    return get_well_depths_numba(config)


def moving_avg(x, window):
    return np.array([np.mean(x[i:i+window]) for i in range(len(x)-window+1)])


def running_mean(x):
    return np.cumsum(x) / np.arange(1, len(x)+1)


def get_cluster_sizes_periodic(config):
    clusters = []
    count = 0
    for v in config:
        if v != 0:
            count += 1
        else:
            if count > 0:
                clusters.append(count)
                count = 0
    if count > 0:
        clusters.append(count)

    if len(clusters) > 1 and (config[0] != 0 and config[-1] != 0):
        clusters[0] += clusters[-1]
        clusters.pop()

    return clusters


pool = Pool(cpu_count())

with h5py.File(FILE, "r+") as f:

    for L in sorted(f.keys(), key=get_L_value):

        print(f"\nProcessing {L}")
        L_val = get_L_value(L)

        densities = []
        width_all = []
        width_rel = []
        flips_avg = []
        hopsL_avg = []
        hopsR_avg = []
        J_left_avg = []
        J_right_avg = []
        slopes_per_density = []
        height_per_flip_all = []

        densities_keys = [
            k for k in f[L].keys()
            if isinstance(f[L][k], h5py.Group)
            and any(sub.startswith("run") for sub in f[L][k].keys())
        ]

        for density in sorted(densities_keys, key=get_density_value):

            rho = get_density_value(density)
            densities.append(rho)

            all_clusters = []
            all_wells = []

            width_runs = []
            mean_height_runs = []
            flips_runs = []
            hopsL_runs = []
            hopsR_runs = []
            J_left_runs = []
            J_right_runs = []

            interval_steps = None

            # 🔴 NEW: collect smooth for ALL samples
            smooth_all = []

            for run_key in f[L][density].keys():
                if not run_key.startswith("run"):
                    continue

                run = f[L][density][run_key]

                if interval_steps is None:
                    interval_steps = run.attrs["interval_steps"]

                width_arr = run["width"][:]
                flips_arr = run["flips"][:]
                hopsL_arr = run["hops_left"][:]
                hopsR_arr = run["hops_right"][:]

                width_runs.append(np.mean(width_arr))
                flips_runs.append(np.mean(flips_arr))
                hopsL_runs.append(np.mean(hopsL_arr))
                hopsR_runs.append(np.mean(hopsR_arr))

                # ===== DIAGNOSTICS =====
                n_samples = len(width_arr)
                window = max(10, int(0.2 * n_samples))

                width_ma = moving_avg(width_arr, window)
                width_rm = running_mean(width_arr)

                width_mean_val = np.mean(width_arr)
                width_rel_fluct = (
                    np.std(width_arr) / width_mean_val
                    if width_mean_val != 0 else np.nan
                )

                if "width_moving_avg" in run:
                    del run["width_moving_avg"]
                run.create_dataset("width_moving_avg", data=width_ma)

                if "width_running_mean" in run:
                    del run["width_running_mean"]
                run.create_dataset("width_running_mean", data=width_rm)

                run.attrs["width_rel_fluct"] = width_rel_fluct

                if "current" in run:
                    current_arr = run["current"][:]

                    current_ma = moving_avg(current_arr, window)
                    current_rm = running_mean(current_arr)

                    current_mean_val = np.mean(current_arr)
                    current_rel_fluct = (
                        np.std(current_arr) / current_mean_val
                        if current_mean_val != 0 else np.nan
                    )

                    if "current_moving_avg" in run:
                        del run["current_moving_avg"]
                    run.create_dataset("current_moving_avg", data=current_ma)

                    if "current_running_mean" in run:
                        del run["current_running_mean"]
                    run.create_dataset("current_running_mean", data=current_rm)

                    run.attrs["current_rel_fluct"] = current_rel_fluct

                # ===== CLUSTERS =====
                if "lattice" in run:
                    data = run["lattice"][:]
                    if data.ndim == 1:
                        data = data[np.newaxis, :]
                    if data.shape[0] == L_val:
                        data = data.T

                    for config in data:
                        all_clusters.extend(get_cluster_sizes_periodic(config))

                # ===== WELLS + SMOOTH STORAGE =====
                if "interface" in run:
                    data = run["interface"][:]
                    if data.ndim == 1:
                        data = data[:, np.newaxis]

                    configs = [data[:, t].copy() for t in range(data.shape[1])]
                    results = pool.map(process_config, configs)

                    for depths, smooth in results:
                        all_wells.extend(depths)
                        smooth_all.append(smooth)

                mean_height_runs.append(run["mean"][:])

                if "J (Left)" in run:
                    J_left_runs.append(np.mean(run["J (Left)"][:]))
                if "J (Right)" in run:
                    J_right_runs.append(np.mean(run["J (Right)"][:]))

            # ===== SAVE SMOOTHED INTERFACE =====
            d_group = f[L][density]

            if len(smooth_all) > 0:
                smooth_arr = np.array(smooth_all)  # (samples, L)
                smooth_arr = smooth_arr.T          # (L, samples)

                if "smoothed_interface" in d_group:
                    del d_group["smoothed_interface"]

                d_group.create_dataset("smoothed_interface", data=smooth_arr)

            # ===== SAVE PDFs =====
            if len(all_clusters) > 0:
                sizes, counts = np.unique(all_clusters, return_counts=True)
                pdf = counts / counts.sum()

                if "cluster_sizes" in d_group:
                    del d_group["cluster_sizes"]
                if "cluster_pdf" in d_group:
                    del d_group["cluster_pdf"]

                d_group.create_dataset("cluster_sizes", data=sizes)
                d_group.create_dataset("cluster_pdf", data=pdf)

            if len(all_wells) > 0:
                sizes, counts = np.unique(all_wells, return_counts=True)
                pdf = counts / counts.sum()

                if "well_depths" in d_group:
                    del d_group["well_depths"]
                if "well_pdf" in d_group:
                    del d_group["well_pdf"]

                d_group.create_dataset("well_depths", data=sizes)
                d_group.create_dataset("well_pdf", data=pdf)

            # ===== COMPUTE =====
            width_mean = np.mean(width_runs)
            mean_height_avg = np.mean([np.mean(m) for m in mean_height_runs])
            flips_mean = np.mean(flips_runs)

            width_all.append(width_mean)
            width_rel.append(width_mean / mean_height_avg)
            flips_avg.append(flips_mean)

            hopsL_avg.append(np.mean(hopsL_runs))
            hopsR_avg.append(np.mean(hopsR_runs))

            J_left_avg.append(np.mean(J_left_runs) if J_left_runs else np.nan)
            J_right_avg.append(np.mean(J_right_runs) if J_right_runs else np.nan)

            avg_mean_height = np.mean(mean_height_runs, axis=0)
            slope, *_ = linregress(np.arange(len(avg_mean_height)), avg_mean_height)

            height_per_flip = (slope * L_val) / (flips_mean * interval_steps)
            height_per_flip = float(np.asarray(height_per_flip).reshape(-1)[0])

            slopes_per_density.append(slope)
            height_per_flip_all.append(height_per_flip)

            # ===== PRINT =====
            tick = "✅"
            cross = "❌"

            print(
                f"rho={rho:.3f} | "
                f"cluster_pdf={tick if len(all_clusters)>0 else cross} | "
                f"well_pdf={tick if len(all_wells)>0 else cross} | "
                f"h/flip={height_per_flip:.3f} ({tick if abs(height_per_flip-2)<0.1 else cross})"
            )

        # ===== SAVE SWEEP =====
        L_group = f[L]
        if "density_sweep" in L_group:
            del L_group["density_sweep"]

        sweep = L_group.create_group("density_sweep")

        sweep.create_dataset("densities", data=np.array(densities))
        sweep.create_dataset("width", data=np.array(width_all))
        sweep.create_dataset("width_rel", data=np.array(width_rel))
        sweep.create_dataset("flips", data=np.array(flips_avg))
        sweep.create_dataset("hops_left", data=np.array(hopsL_avg))
        sweep.create_dataset("hops_right", data=np.array(hopsR_avg))
        sweep.create_dataset("J_left", data=np.array(J_left_avg))
        sweep.create_dataset("J_right", data=np.array(J_right_avg))
        sweep.create_dataset("slope_of_mean_height_vs_density", data=np.array(slopes_per_density))
        sweep.create_dataset("height_change_per_flip", data=np.array(height_per_flip_all))

        print(f"Saved density sweep for {L}")

pool.close()
pool.join()

print("\n✅ Done")
