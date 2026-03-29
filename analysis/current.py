import numpy as np
import h5py
import matplotlib.pyplot as plt

filename = "data/multi_particles/density_sweep_time_avg.h5"

plt.figure(figsize=(7, 5))

with h5py.File(filename, "r") as f:

    for L in sorted(f.keys(), key=lambda x: int(x.split("_")[1])):
        if L == "L_128" or L == "L_256":
            continue
        densities = []
        avg_currents = []

        for density in sorted(f[L].keys(),
                              key=lambda x: float(x.split("_")[1])):

            run = list(f[L][density].keys())[0]

            current = np.array(f[L][density][run]["current"])

            cut = int(0.3 * len(current))   # discard transient
            avg = np.mean(current[cut:])

            densities.append(float(density.split("_")[1]))
            avg_currents.append(avg)

        plt.plot(densities, avg_currents, marker='o', label=L)

plt.xlabel("Density")
plt.ylabel("Average current")
plt.title("Current vs density")
plt.legend()
plt.show()
