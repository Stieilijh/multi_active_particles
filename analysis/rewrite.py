import h5py
import numpy as np

FILE = "data/multi_particles/L_1024_density_sweep.h5"

with h5py.File(FILE, "r+") as f:

    for L_key in f.keys():
        for d_key in f[L_key].keys():
            for run_key in f[L_key][d_key].keys():

                run_group = f[L_key][d_key][run_key]

                interface = run_group["interface"][:]
                # shape: (num_samples, L)

                # Compute along spatial axis (axis=1)
                mean = np.mean(interface, axis=0)        # shape (num_samples,)
                width = np.std(interface, axis=0)        # shape (num_samples,)

                # overwrite safely
                if "mean" in run_group:
                    del run_group["mean"]
                if "width" in run_group:
                    del run_group["width"]

                run_group.create_dataset("mean", data=mean)
                run_group.create_dataset("width", data=width)

                print(f"Updated {L_key}/{d_key}/{run_key}")
