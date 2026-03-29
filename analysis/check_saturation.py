import numpy as np
import h5py
import matplotlib.pyplot as plt

filename = "data/multi_particles/density_sweep_time_avg.h5"

plt.figure(figsize=(7, 5))

with h5py.File(filename, "r") as f:

    for L in sorted(f.keys(), key=lambda x: int(x.split("_")[1])):

        if not L == "L_128":
            continue
        densities = []
        width_std = []
        width_mean = []

        for density in sorted(f[L].keys(),
                              key=lambda x: float(x.split("_")[1])):

            run = list(f[L][density].keys())[0]

            width = np.array(f[L][density][run]["width"])

            # discard transient (first 30%)
            cut = int(0.3 * len(width))
            width_ss = width[cut:]

            mean = np.mean(width_ss)
            std = np.std(width_ss)

            densities.append(float(density.split("_")[1]))
            width_std.append(std)
            width_mean.append(mean)

        plt.plot(densities, width_std, marker='o', label=L)
        # plt.plot(densities, width_mean, marker='o', label=L)

plt.xlabel("Density")
plt.ylabel("Std(width)")
# plt.ylabel("Mean(width)")
plt.title("Width saturation check")
plt.legend(title="System size")
plt.show()
