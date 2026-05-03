from pathlib import Path
import subprocess
import os

BASE = Path("data/multi_particles")

for dens_dir in BASE.rglob("dens"):

    files = list(dens_dir.glob("*.h5"))
    if not files:
        continue

    print(f"\n=== Processing {dens_dir} ===")

    parent = dens_dir.parent
    L_name = parent.name  # e.g. L_1024

    merged_file = parent / f"{L_name}_merged.h5"

    # ---------------- MERGE ----------------
    env = os.environ.copy()
    env["INPUT_DIR"] = str(dens_dir)
    env["OUTPUT"] = str(merged_file)

    subprocess.run(["python3", "analysis/merge_h5.py"], env=env, check=True)

    # ---------------- ANALYSE ----------------
    env["FILE"] = str(merged_file)
    subprocess.run(["python3", "analysis/analysis.py"], env=env, check=True)

    # ---------------- GRAPHS ----------------
    subprocess.run(["python3", "analysis/rel_pos_graphs.py"], env=env, check=True)

print("\n✅ ALL DONE")
