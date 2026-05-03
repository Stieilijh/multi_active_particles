import numpy as np
import h5py
import matplotlib.pyplot as plt
import os

FILE = os.environ.get("FILE", "default_path_here")

if FILE is None:
    raise ValueError("FILE environment variable not set")
    
def get_density_value(d):
    return float(d.split("_")[1])


def get_L_value(L):
    return int(L.split("_")[1])


base_dir = os.path.dirname(FILE)
graph_root = os.path.join(base_dir, "graphs")
os.makedirs(graph_root, exist_ok=True)


with h5py.File(FILE, "r") as f:

    for L in sorted(f.keys(), key=get_L_value):

        print(f"\nProcessing {L}")
        L_val = get_L_value(L)

        densities_keys = [k for k in f[L].keys() if k != "density_sweep"]

        for density in sorted(densities_keys, key=get_density_value):

            rho_expected = get_density_value(density)

            density_dir = os.path.join(graph_root, density)
            os.makedirs(density_dir, exist_ok=True)

            occ_blocks = []
            JL_blocks = []
            JR_blocks = []

            for run_key in f[L][density].keys():

                if not run_key.startswith("run"):
                    continue

                run = f[L][density][run_key]

                if "lattice" not in run:
                    continue

                lattice = run["lattice"][:]
                JL = run["J (Left)"][:]
                JR = run["J (Right)"][:]

                if lattice.ndim == 1:
                    lattice = lattice[np.newaxis, :]
                    JL = JL[np.newaxis, :]
                    JR = JR[np.newaxis, :]

                occ = (lattice != 0)

                if occ.shape[0] == L_val:
                    occ = occ.T
                    JL = JL.T
                    JR = JR.T

                occ_blocks.append(occ)
                JL_blocks.append(JL)
                JR_blocks.append(JR)

            if len(occ_blocks) == 0:
                continue

            occ_time = np.concatenate(occ_blocks, axis=0)
            JL_time = np.concatenate(JL_blocks, axis=0)
            JR_time = np.concatenate(JR_blocks, axis=0)

            # ===== EXACTLY 100 TIME LAYERS =====
            indices = np.linspace(0, occ_time.shape[0] - 1, 100, dtype=int)

            occ_time = occ_time[indices]
            JL_time = JL_time[indices]
            JR_time = JR_time[indices]

            # ===== DENSITY CHECK (COMPACT) =====
            tolerance = 0.02
            errors = []

            for t in range(occ_time.shape[0]):
                rho_measured = np.sum(occ_time[t]) / L_val
                rel_error = abs(rho_measured - rho_expected) / rho_expected
                errors.append(rel_error)

            max_error = np.max(errors)

            if max_error < tolerance:
                print(f"{density}: ✅ PASSED (max error = {max_error:.4f})")
            else:
                print(f"{density}: ❌ FAILED (max error = {max_error:.4f})")

            x = np.arange(L_val) / L_val

            # ===== OCCUPATION =====
            plt.figure(figsize=(7, 5))
            y_idx, x_idx = np.where(occ_time)
            plt.scatter(x[x_idx], y_idx, s=1)
            plt.savefig(os.path.join(density_dir, "occupation.png"))
            plt.close()

            # ===== TOTAL CURRENT =====
            plt.figure(figsize=(7, 5))
            move_mask = (JL_time != 0) | (JR_time != 0)
            y_idx, x_idx = np.where(move_mask)
            plt.scatter(x[x_idx], y_idx, s=1)
            plt.savefig(os.path.join(density_dir, "current_total.png"))
            plt.close()

            # ===== LEFT vs RIGHT =====
            plt.figure(figsize=(7, 5))
            yL, xL = np.where(JL_time != 0)
            yR, xR = np.where(JR_time != 0)
            plt.scatter(x[xL], yL, s=1, label="Left")
            plt.scatter(x[xR], yR, s=1, label="Right")
            plt.legend()
            plt.savefig(os.path.join(density_dir, "current_lr.png"))
            plt.close()

print("\n✅ Done")
