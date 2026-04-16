import h5py
import numpy as np
import matplotlib.pyplot as plt

FILE = "data/multi_particles/L_1024_density_sweep.h5"


def get_density_value(d):
    return float(d.split("_")[1])


def get_L_value(L):
    return int(L.split("_")[1])


with h5py.File(FILE, "r") as f:

    for L in sorted(f.keys(), key=get_L_value):

        L_val = get_L_value(L)

        densities = []
        width_rel = []
        flips_avg = []
        hopsL_avg = []
        hopsR_avg = []

        for density in sorted(f[L].keys(), key=get_density_value):

            run_key = list(f[L][density].keys())[0]
            run = f[L][density][run_key]

            densities.append(get_density_value(density))

            # ---- width mean ----
            width_mean = np.mean(run["width"][:])

            # ---- mean height ----
            interface = run["interface"][:]   # (L , time)
            mean_height = np.mean(interface)

            # ---- relative width ----
            width_rel.append(width_mean)

            flips_avg.append(np.mean(run["flips"][:]))
            hopsL_avg.append(np.mean(run["hops_left"][:]))
            hopsR_avg.append(np.mean(run["hops_right"][:]))

        densities = np.array(densities)

        # -------- RELATIVE WIDTH vs DENSITY --------
        plt.figure()
        plt.plot(densities, width_rel, marker='o')
        plt.xlabel("Density")
        plt.ylabel("Relative Width (W / ⟨h⟩)")
        plt.title(f"Relative Width vs Density (L={L_val})")
        plt.grid()

        # -------- OTHER OBSERVABLES --------
        plt.figure()
        plt.plot(densities, flips_avg, marker='o', label="Flips")
        plt.plot(densities, hopsL_avg, marker='o', label="Hops Left")
        plt.plot(densities, hopsR_avg, marker='o', label="Hops Right")

        plt.xlabel("Density")
        plt.ylabel("Average value")
        plt.title(f"Flips / Hops vs Density (L={L_val})")
        plt.legend()
        plt.grid()

plt.show()
