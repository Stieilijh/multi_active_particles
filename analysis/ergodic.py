import h5py
import numpy as np

FILE = "data/multi_particles/ergodic_test.h5"


def dataset_mean(arr):
    return np.mean(arr)


def percent(a, b):
    return abs(a - b) / max(abs(a), abs(b)) * 100


with h5py.File(FILE, "r") as f:

    for L in f.keys():
        for density in f[L].keys():

            group = f[L][density]

            # ---------- time average ----------
            time = group["run_0"]

            w_time = dataset_mean(time["width"][:])
            c_time = dataset_mean(time["current"][:])
            f_time = dataset_mean(time["flips"][:])
            hl_time = dataset_mean(time["hops_left"][:])
            hr_time = dataset_mean(time["hops_right"][:])

            # ---------- ensemble ----------
            w_e, c_e, f_e, hl_e, hr_e = [], [], [], [], []

            for run in group.keys():
                if run == "run_0":
                    continue

                g = group[run]

                w_e.append(dataset_mean(g["width"][:]))
                c_e.append(dataset_mean(g["current"][:]))
                f_e.append(dataset_mean(g["flips"][:]))
                hl_e.append(dataset_mean(g["hops_left"][:]))
                hr_e.append(dataset_mean(g["hops_right"][:]))

            w_ens = np.mean(w_e)
            c_ens = np.mean(c_e)
            f_ens = np.mean(f_e)
            hl_ens = np.mean(hl_e)
            hr_ens = np.mean(hr_e)

            print("\n==============================")
            print(f"{L} {density}")
            print("==============================")

            print("WIDTH")
            print(" time avg    :", w_time)
            print(" ensemble    :", w_ens)
            print(" diff (%)    :", percent(w_time, w_ens))
            print()

            print("CURRENT")
            print(" time avg    :", c_time)
            print(" ensemble    :", c_ens)
            print(" diff (%)    :", percent(c_time, c_ens))
            print()

            print("FLIPS")
            print(" time avg    :", f_time)
            print(" ensemble    :", f_ens)
            print(" diff (%)    :", percent(f_time, f_ens))
            print()

            print("HOPS LEFT")
            print(" time avg    :", hl_time)
            print(" ensemble    :", hl_ens)
            print(" diff (%)    :", percent(hl_time, hl_ens))
            print()

            print("HOPS RIGHT")
            print(" time avg    :", hr_time)
            print(" ensemble    :", hr_ens)
            print(" diff (%)    :", percent(hr_time, hr_ens))
            print()

            # helpful diagnostic
            drift_time = hr_time - hl_time
            drift_ens = hr_ens - hl_ens

            print("DRIFT (hopsR - hopsL)")
            print(" time avg    :", drift_time)
            print(" ensemble    :", drift_ens)
            print(" diff (%)    :", percent(drift_time, drift_ens))
