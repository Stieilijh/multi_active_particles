import h5py
import numpy as np
import matplotlib.pyplot as plt
import os

FILE = "data/multi_particles/density_sweep_time_avg.h5"
OUT = "graphs/trial_1/interface_plots_avg"

os.makedirs(OUT, exist_ok=True)

TARGET_L = 1024
N_BINS = 2


def get_density_value(d):
    return float(d.split("_")[1])


def get_L_value(L):
    return int(L.split("_")[1])


with h5py.File(FILE, "r") as f:

    for L in f.keys():

        if get_L_value(L) != TARGET_L:
            continue

        for density in sorted(f[L].keys(), key=get_density_value):

            rho = get_density_value(density)

            all_runs = []

            for run_key in f[L][density].keys():
                d = f[L][density][run_key]["interface"][:].T
                all_runs.append(d)

            data = np.mean(all_runs, axis=0)

            n_times = data.shape[0]
            x = np.arange(data.shape[1])

            bins = np.linspace(0, n_times, N_BINS + 1, dtype=int)

            plt.figure(figsize=(9, 5))

            for i in range(N_BINS):
                start = bins[i]
                end = bins[i+1]

                avg_interface = np.mean(data[start:end], axis=0)

                # remove drift (optional but recommended)
                avg_interface -= np.mean(avg_interface)

                plt.plot(x, avg_interface, label=f"bin {i+1}")

            plt.xlabel("Position")
            plt.ylabel("Height (mean-subtracted)")
            plt.title(f"Time-averaged interface (L={TARGET_L}, density={rho})")
            plt.legend(ncol=2, fontsize=8)
            plt.grid()

            save_name = f"L_{TARGET_L}_density_{rho:.3f}.png"
            save_path = os.path.join(OUT, save_name)

            plt.savefig(save_path)
            print("Saved:", save_path)

            plt.show()
            plt.close()
