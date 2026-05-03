import numpy as np
import h5py
import matplotlib.pyplot as plt
import os
from pathlib import Path
import matplotlib

matplotlib.use("Agg") 
BASE = Path("data/multi_particles")  # adjust if needed


def get_density_value(d):
    return float(d.split("_")[1])


def get_L_value(L):
    return int(L.split("_")[1])


# =========================================================
# 🔍 FIND ALL MERGED FILES
# =========================================================

merged_files = list(BASE.rglob("L_*_merged.h5"))

if len(merged_files) == 0:
    raise ValueError("No merged H5 files found")


# =========================================================
# 🧠 GROUP FILES BY RATE FOLDER
# (everything above L_*)
# =========================================================

groups = {}

for fpath in merged_files:
    L_dir = fpath.parent           # .../L_64
    rate_dir = L_dir.parent        # .../flip_1_hop_0_5

    groups.setdefault(rate_dir, []).append(fpath)

# =========================================================
# 🚀 PROCESS EACH RATE GROUP
# =========================================================

for rate_dir, files in groups.items():
    if len(files) < 2:
        continue

    print(f"\n=== Processing rate: {rate_dir} ===")

    graph_root = rate_dir / "graphs"
    graph_root.mkdir(exist_ok=True)

    # sort files by L
    files = sorted(files, key=lambda x: get_L_value(x.parent.name))

    # collect all densities
    all_densities = set()

    file_data = []

    for fpath in files:
        with h5py.File(fpath, "r") as f:

            L_key = list(f.keys())[0]   # only one L per file
            densities = [
                d for d in f[L_key].keys()
                if d != "density_sweep"
            ]

            all_densities.update(densities)
            file_data.append((fpath, L_key))

    densities_sorted = sorted(all_densities, key=get_density_value)

    # =====================================================
    # 📊 LOOP OVER DENSITIES
    # =====================================================

    for density in densities_sorted:

        print(f"  Density {density}")

        density_dir = graph_root / density

        # =========================
        # CLUSTER PDF
        # =========================
        plt.figure(figsize=(7, 5))
        valid_count = 0
        for fpath, L_key in file_data:

            L_val = get_L_value(L_key)

            with h5py.File(fpath, "r") as f:

                if density not in f[L_key]:
                    continue

                d_group = f[L_key][density]

                if "cluster_sizes" not in d_group:
                    continue

                sizes = d_group["cluster_sizes"][:]
                pdf = d_group["cluster_pdf"][:]

                plt.plot(sizes, pdf, marker='o', label=f"L={L_val}")
                valid_count += 1

        # skip plot if < 2 curves
        if valid_count < 2:
            plt.close()
        else:
            density_dir.mkdir(exist_ok=True)
            plt.xlabel("Cluster Size")
            plt.ylabel("PDF")
            plt.title(f"Cluster PDF | {density}")
            plt.legend()
            plt.xscale("log")
            plt.yscale("log")
            plt.savefig(density_dir / "cluster_pdf_overlay.png")
            plt.close()
        # =========================
        # WELL PDF
        # =========================
        plt.figure(figsize=(7, 5))

        valid_count = 0

        for fpath, L_key in file_data:

            L_val = get_L_value(L_key)

            with h5py.File(fpath, "r") as f:

                if density not in f[L_key]:
                    continue

                d_group = f[L_key][density]

                if "well_depths" not in d_group:
                    continue

                sizes = d_group["well_depths"][:]
                pdf = d_group["well_pdf"][:]

                sizes_scaled = sizes/L_val

                plt.plot(sizes_scaled, pdf, marker='o', label=f"L={L_val}")
                valid_count += 1

        # skip if < 2 curves
        if valid_count < 2:
            plt.close()
        else:
            density_dir.mkdir(exist_ok=True)
            plt.xlabel("Well Depth")
            plt.ylabel("PDF")
            plt.title(f"Well PDF | {density}")
            plt.legend()
            plt.xscale("log")
            plt.yscale("log")
            plt.savefig(density_dir / "well_pdf_overlay.png")
            plt.close()

print("\n✅ Done (multi-L overlay)")