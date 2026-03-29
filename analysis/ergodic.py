import h5py
import numpy as np
import matplotlib.pyplot as plt

FILE = "data/multi_particles/ergodic_test.h5"


def dataset_mean(arr):
    return np.mean(arr)


def percent(a, b):
    if a == 0 and b == 0:
        return 0.0
    return abs(a - b) / max(abs(a), abs(b)) * 100


with h5py.File(FILE, "r") as f:

    for L in f.keys():
        L_value = int(L.split("_")[1])

        for density in f[L].keys():

            group = f[L][density]

            # ---------- time average ----------
            time = group["run_0"]

            width_time = dataset_mean(time["width"][:])
            flips_time = dataset_mean(time["flips"][:])
            hl_time = dataset_mean(time["hops_left"][:])
            hr_time = dataset_mean(time["hops_right"][:])

            # instantaneous current (old)
            curr_time_inst = dataset_mean(time["current"][:])

            # cumulative current (correct)
            drift_time = np.sum(time["hops_right"][:] - time["hops_left"][:])
            total_time_steps = len(time["hops_left"])
            curr_time_cum = drift_time / (L_value * total_time_steps)

            # ---------- ensemble ----------
            width_e = []
            flips_e = []
            hl_e = []
            hr_e = []
            curr_e_inst = []

            drift_ens_total = 0
            steps_ens_total = 0

            for run in group.keys():
                if run == "run_0":
                    continue

                g = group[run]

                width_e.append(dataset_mean(g["width"][:]))
                flips_e.append(dataset_mean(g["flips"][:]))
                hl_e.append(dataset_mean(g["hops_left"][:]))
                hr_e.append(dataset_mean(g["hops_right"][:]))
                curr_e_inst.append(dataset_mean(g["current"][:]))

                drift_ens_total += np.sum(g["hops_right"]
                                          [:] - g["hops_left"][:])
                steps_ens_total += len(g["hops_left"])

            width_ens = np.mean(width_e)
            flips_ens = np.mean(flips_e)
            hl_ens = np.mean(hl_e)
            hr_ens = np.mean(hr_e)
            curr_ens_inst = np.mean(curr_e_inst)

            curr_ens_cum = drift_ens_total / (L_value * steps_ens_total)

            drift_ens = hr_ens - hl_ens

            # ---------- PRINT ----------
            print("\n==============================")
            print(f"{L} {density}")
            print("==============================")

            print("WIDTH")
            print(" time avg    :", width_time)
            print(" ensemble    :", width_ens)
            print(" diff (%)    :", percent(width_time, width_ens))
            print()

            print("FLIPS")
            print(" time avg    :", flips_time)
            print(" ensemble    :", flips_ens)
            print(" diff (%)    :", percent(flips_time, flips_ens))
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

            print("DRIFT (hopsR - hopsL)")
            print(" time avg    :", drift_time / total_time_steps)
            print(" ensemble    :", drift_ens)
            print(" diff (%)    :", percent(
                drift_time / total_time_steps, drift_ens))
            print()

            print("CURRENT (instantaneous)")
            print(" time avg    :", curr_time_inst)
            print(" ensemble    :", curr_ens_inst)
            print(" diff (%)    :", percent(curr_time_inst, curr_ens_inst))
            print()

            print("CURRENT (cumulative)")
            print(" time avg    :", curr_time_cum)
            print(" ensemble    :", curr_ens_cum)
            print(" diff (%)    :", percent(curr_time_cum, curr_ens_cum))
            print()

            # ---------- PLOT mean height vs time ----------
            height = time["mean"][:]

            plt.figure()
            plt.plot(height)
            plt.xlabel("Sample index")
            plt.ylabel("Mean height")
            plt.title(f"Mean height vs time — {L} {density}")
            plt.tight_layout()

plt.show()
