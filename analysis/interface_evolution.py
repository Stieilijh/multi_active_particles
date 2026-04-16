import h5py
import numpy as np
import matplotlib.pyplot as plt
import os

FILE = "data/multi_particles/density_sweep_time_avg.h5"
OUT = "graphs/trial_1/interface_plots_2"

os.makedirs(OUT, exist_ok=True)

TARGET_L = 1024


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

            run_key = sorted(f[L][density].keys())[0]
            data = f[L][density][run_key]["interface"][:]  # (L , time)

            data = data.T   # now (time , L)

            n_times = data.shape[0]
            x = np.arange(data.shape[1])

            indices = np.linspace(0, n_times-1, 5, dtype=int)

            plt.figure(figsize=(9, 5))

            for i, idx in enumerate(indices):
                plt.plot(x, data[idx]-np.mean(data[idx]), label=f"t={idx}")

            plt.xlabel("Position")
            plt.ylabel("Height")
            plt.title(f"Interface evolution (L={TARGET_L}, density={rho})")
            plt.legend(ncol=2, fontsize=8)
            plt.grid()

            save_name = f"L_{TARGET_L}_density_{rho:.3f}.png"
            save_path = os.path.join(OUT, save_name)

            plt.savefig(save_path)
            print("Saved:", save_path)
            plt.close()
