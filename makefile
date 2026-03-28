test_rng:
	gfortran -O3 -fopenmp -Jobj -Iobj \
	src/common/mod_precision.f90 \
	src/common/mod_rng.f90 \
	tests/test_rng.f90 \
	-o bin/test_rng.out