import h5py
import numpy as np

FILE = "data/multi_particles/volume_exclusion/puller_fraction_1_0/hop_1_flip_0_1/L_1024/L_1024_flip_0_1.h5"

with h5py.File(FILE, "r+") as f:

    for L_key in f.keys():
        L_group = f[L_key]

        for d_key in L_group.keys():
            d_group = L_group[d_key]

            for run_key in d_group.keys():
                run_group = d_group[run_key]

                if "interface" not in run_group:
                    print(f"Skipping {L_key}/{d_key}/{run_key} (no interface)")
                    continue

                dset = run_group["interface"]
                interface = dset[()]

                # (L, samples)
                mean = np.mean(interface, axis=0)
                width = np.std(interface, axis=0)

                if "mean" in run_group:
                    del run_group["mean"]
                if "width" in run_group:
                    del run_group["width"]

                run_group.create_dataset("mean", data=mean)
                run_group.create_dataset("width", data=width)

                print(f"Updated {L_key}/{d_key}/{run_key}")
