import h5py
import numpy as np
import os
FILE = os.environ.get("FILE")

if FILE is None:
    raise ValueError("FILE environment variable not set")

print(f"Rewriting file: {FILE}")
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
