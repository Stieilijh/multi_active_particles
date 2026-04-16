import numpy as np
import h5py


FILE = "data/multi_particles/density_sweep_time_avg_trial_lab_2.h5"


def get_density_value(d):
    return float(d.split("_")[1])


def get_L_value(L):
    return int(L.split("_")[1])


# ---------- periodic cluster finder ----------
def get_cluster_sizes_periodic(config):

    clusters = []
    count = 0

    for v in config:
        if v == 1 or v == -1:
            count += 1
        else:
            if count > 0:
                clusters.append(count)
                count = 0

    if count > 0:
        clusters.append(count)

    # periodic merge
    if len(clusters) > 1 and (config[0] == 1 or config[0] == -1) and (config[-1] == 1 or config[0] == -1):
        clusters[0] += clusters[-1]
        clusters.pop()

    return clusters


# ===================================
# MAIN
# ===================================
with h5py.File(FILE, "r+") as f:

    for L in sorted(f.keys(), key=get_L_value):

        print(f"\nProcessing {L}")

        densities = []
        width_all = []
        width_rel = []
        flips_avg = []
        hopsL_avg = []
        hopsR_avg = []
        J_left_avg = []
        J_right_avg = []

        densities_keys = [k for k in f[L].keys() if k != "density_sweep"]

        for density in sorted(densities_keys, key=get_density_value):
            rho = get_density_value(density)
            densities.append(rho)

            all_clusters = []

            width_runs = []
            mean_height_runs = []
            flips_runs = []
            hopsL_runs = []
            hopsR_runs = []
            J_left_runs = []
            J_right_runs = []
            print("dens =", rho)
            # -------- runs --------
            for run_key in f[L][density].keys():
                if not run_key.startswith("run"):
                    continue

                run = f[L][density][run_key]

                # ===== CLUSTERS =====
                data = None
                if "lattice" in run:
                    data = run["lattice"][:]

                    if data.ndim == 1:
                        data = data[np.newaxis, :]

                    for config in data:
                        all_clusters.extend(get_cluster_sizes_periodic(config))

                if data is not None:
                    if data.ndim == 1:
                        data = data[np.newaxis, :]

                    for config in data:
                        all_clusters.extend(get_cluster_sizes_periodic(config))

                # ===== OBS =====
                width_runs.append(np.mean(run["width"][:]))

                interface = run["interface"][:]   # (L, T)
                mean_height_runs.append(np.mean(interface))

                flips_runs.append(np.mean(run["flips"][:]))
                hopsL_runs.append(np.mean(run["hops_left"][:]))
                hopsR_runs.append(np.mean(run["hops_right"][:]))

                if "J (Left)" in run:
                    J_left_runs.append(np.mean(run["J (Left)"][:]))
                if "J (Right)" in run:
                    J_right_runs.append(np.mean(run["J (Right)"][:]))

            # =========================
            # SAVE CLUSTERS (per density)
            # =========================
            if len(all_clusters) > 0:

                clusters = np.array(all_clusters)
                sizes, counts = np.unique(clusters, return_counts=True)
                prob = counts / counts.sum()

                d_group = f[L][density]

                # overwrite safely
                if "cluster_sizes" in d_group:
                    del d_group["cluster_sizes"]
                if "cluster_prob" in d_group:
                    del d_group["cluster_prob"]

                d_group.create_dataset("cluster_sizes", data=sizes)
                d_group.create_dataset("cluster_prob", data=prob)

            else:
                print(f"No clusters for {L}, rho={rho}")

            # =========================
            # AVERAGE OVER RUNS
            # =========================
            width_mean = np.mean(run["width"][:])
            mean_height = np.mean(run["mean"][:])

            width_all.append(width_mean)
            width_rel.append(width_mean / mean_height)

            flips_avg.append(np.mean(flips_runs))
            hopsL_avg.append(np.mean(hopsL_runs))
            hopsR_avg.append(np.mean(hopsR_runs))

            J_left_avg.append(np.mean(J_left_runs) if J_left_runs else np.nan)
            J_right_avg.append(np.mean(J_right_runs)
                               if J_right_runs else np.nan)

        # =============================
        # SAVE DENSITY SWEEP (per L)
        # =============================
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

        print(f"Saved density sweep for {L}")

print("\n✅ Done: everything stored in same HDF5")
