import h5py
import numpy as np
import matplotlib.pyplot as plt
import os

FILE = "data/multi_particles/density_sweep_time_avg_trial_lab_2.h5"
OUT = "graphs/multi_particles/trial_lab_2/width_vs_time"

os.makedirs(OUT, exist_ok=True)


def get_density_value(d):
    return float(d.split("_")[1])


def get_L_value(L):
    return int(L.split("_")[1])


with h5py.File(FILE, "r") as f:

    for L in sorted(f.keys(), key=get_L_value):

        L_val = get_L_value(L)
        L_folder = os.path.join(OUT, f"L_{L_val}")
        os.makedirs(L_folder, exist_ok=True)

        for density in sorted(f[L].keys(), key=get_density_value):

            rho = get_density_value(density)

            all_runs = []

            for run_key in f[L][density].keys():
                width = f[L][density][run_key]["width"][:]   # (time,)
                all_runs.append(width)

            width_avg = np.mean(all_runs, axis=0)

            time = np.arange(len(width_avg))

            plt.figure(figsize=(8, 5))
            plt.plot(time, width_avg)

            plt.xlabel("Time")
            plt.ylabel("Interface width")
            plt.title(f"Width vs Time (L={L_val}, density={rho})")
            plt.grid()
            plt.xscale("log")
            plt.yscale("log")

            save_path = os.path.join(
                L_folder,
                f"density_{rho:.3f}.png"
            )

            plt.savefig(save_path)
            print("Saved:", save_path)

            plt.close()
