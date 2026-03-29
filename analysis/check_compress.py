import h5py

filename = "data/multi_particles/test_ensemble.h5"


def check_compression(name, obj):
    if isinstance(obj, h5py.Dataset):
        print(f"\nDataset: {name}")
        print(" shape:", obj.shape)
        print(" dtype:", obj.dtype)
        print(" compression:", obj.compression)
        print(" compression_opts:", obj.compression_opts)
        print(" chunks:", obj.chunks)


with h5py.File(filename, "r") as f:
    f.visititems(check_compression)
