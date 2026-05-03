from pathlib import Path
import subprocess
import os
import json
from concurrent.futures import ProcessPoolExecutor, as_completed

BASE = Path("data/multi_particles")

REWRITE_TARGETS = {"L_512", "L_1024"}

# 🔥 adjust this depending on your machine
MAX_WORKERS = os.cpu_count() // 2


def load_status(path):
    if path.exists():
        with open(path, "r") as f:
            return json.load(f)
    return {
        "rewrite_done": False,
        "merge_done": False,
        "analysis_done": False,
        "graphs_done": False
    }


def save_status(path, status):
    with open(path, "w") as f:
        json.dump(status, f, indent=4)


def process_dens_dir(dens_dir):
    try:
        parent = dens_dir.parent
        L_name = parent.name

        print(f"\n=== Processing {dens_dir} ===")

        status_file = dens_dir / "pipeline_status.json"
        status = load_status(status_file)

        files = list(dens_dir.glob("*.h5"))
        if not files:
            return f"⚠️ No files in {dens_dir}"

        env = os.environ.copy()

        # =========================================================
        # 🔁 REWRITE (ONLY for selected L)
        # =========================================================
        if L_name in REWRITE_TARGETS:

            if not status["rewrite_done"]:
                print(f"🔧 Rewriting {dens_dir}...")

                for f in files:
                    env["FILE"] = str(f)

                    subprocess.run(
                        ["python3", "analysis/rewrite_h5.py"],
                        env=env,
                        check=True
                    )

                status["rewrite_done"] = True
                save_status(status_file, status)

            else:
                print(f"⏩ Rewrite already done ({dens_dir})")

        else:
            status["rewrite_done"] = True
            save_status(status_file, status)

        # =========================================================
        # 🔗 MERGE
        # =========================================================
        merged_file = parent / f"{L_name}_merged.h5"

        if not status["merge_done"]:
            print(f"🔗 Merging {dens_dir}...")

            env["INPUT_DIR"] = str(dens_dir)
            env["OUTPUT"] = str(merged_file)

            subprocess.run(
                ["python3", "analysis/merge_h5.py"],
                env=env,
                check=True
            )

            status["merge_done"] = True
            save_status(status_file, status)
            print("Merging complete!")

        # =========================================================
        # 📊 ANALYSIS
        # =========================================================
        if not status["analysis_done"]:
            print(f"📊 Analysis {dens_dir}...")

            env["FILE"] = str(merged_file)

            subprocess.run(
                ["python3", "analysis/analysis.py"],
                env=env,
                check=True
            )

            status["analysis_done"] = True
            save_status(status_file, status)

        # =========================================================
        # 📈 GRAPHS
        # =========================================================
        if not status["graphs_done"]:
            print(f"📈 Graphs {dens_dir}...")

            subprocess.run(
                ["python3", "analysis/rel_pos_graphs.py"],
                env=env,
                check=True
            )

            status["graphs_done"] = True
            save_status(status_file, status)

        return f"✅ Done {dens_dir}"

    except subprocess.CalledProcessError as e:
        return f"❌ Failed {dens_dir}: {e}"


# =========================================================
# 🔥 PARALLEL EXECUTION
# =========================================================


dens_dirs = []

for d in BASE.rglob("dens"):
    if any(d.glob("*.h5")):   # only keep dirs with actual files
        dens_dirs.append(d)

with ProcessPoolExecutor(max_workers=MAX_WORKERS) as executor:

    futures = [executor.submit(process_dens_dir, d) for d in dens_dirs]

    for future in as_completed(futures):
        print(future.result())


# =========================================================
# 📊 OVERLAY PDFs (ACROSS L)
# =========================================================

print("\n📊 Generating overlay PDFs across L...")

try:
    subprocess.run(
        ["python3", "analysis/overlay_pdfs.py"],
        check=True
    )
    print("✅ Overlay PDFs done")
except subprocess.CalledProcessError as e:
    print(f"❌ Overlay step failed: {e}")

print("\n✅ ALL DONE")