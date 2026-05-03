import h5py
import glob
import os

INPUT_DIR = os.environ.get("INPUT_DIR")
OUTPUT = os.environ.get("OUTPUT")

files = sorted(glob.glob(os.path.join(INPUT_DIR, "*.h5")))

with h5py.File(OUTPUT, "w") as fout:

    for f in files:
        print("Merging", f)

        with h5py.File(f, "r") as fin:

            # copy entire structure
            for key in fin.keys():
                if key not in fout:
                    fin.copy(key, fout)
                else:
                    # merge densities inside L
                    for sub in fin[key].keys():
                        if sub not in fout[key]:
                            fin.copy(f"{key}/{sub}", fout[key])
