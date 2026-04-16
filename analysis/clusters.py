import h5py
import numpy as np
import matplotlib.pyplot as plt
import os

FILE = "data/multi_particles/density_sweep_time_avg_trial_lab_2.h5"
OUT = "graphs/cluster_plots_2"

os.makedirs(OUT, exist_ok=True)


def get_density_value(d):
    return float(d.split("_")[1])


def get_L_value(L):
    return int(L.split("_")[1])


# ---------- periodic cluster finder ----------
def get_cluster_sizes_periodic(config):

    clusters = []
    count = 0

    for v in config:
        if v == 1:
            count += 1
        else:
            if count > 0:
                clusters.append(count)
                count = 0

    if count > 0:
        clusters.append(count)

    # periodic merge
    if len(clusters) > 1 and config[0] == 1 and config[-1] == 1:
        clusters[0] += clusters[-1]
        clusters.pop()

    return clusters


with h5py.File(FILE, "r") as f:

    for L in sorted(f.keys(), key=get_L_value):

        L_val = get_L_value(L)
        L_folder = os.path.join(OUT, f"L_{L_val}")
        os.makedirs(L_folder, exist_ok=True)

        for density in sorted(f[L].keys(), key=get_density_value):

            rho = get_density_value(density)
            all_clusters = []

            for run_key in f[L][density].keys():

                run = f[L][density][run_key]

                # take ALL samples automatically
                data = run["lattice"][:]   # shape (N , L)

                # handle single snapshot case
                if data.ndim == 1:
                    data = data[np.newaxis, :]

                for config in data:
                    all_clusters.extend(
                        get_cluster_sizes_periodic(config)
                    )

            if len(all_clusters) == 0:
                print(f"No clusters for L={L_val}, rho={rho}")
                continue

            clusters = np.array(all_clusters)

            sizes, counts = np.unique(clusters, return_counts=True)
            prob = counts / counts.sum()

            plt.figure()
            plt.plot(sizes, prob, marker='o')
            plt.xlabel("Cluster size")
            plt.ylabel("P(size)")
            plt.title(f"L={L_val}, density={rho}")
            plt.grid()

            save_name = f"density_{rho:.3f}.png"
            save_path = os.path.join(L_folder, save_name)

            plt.savefig(save_path)
            print("Saved:", save_path)

           # plt.show()   # <-- show also
            plt.close()
