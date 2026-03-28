test_rng:
	gfortran -O3 -fopenmp -Jobj -Iobj \
	src/common/mod_precision.f90 \
	src/common/mod_rng.f90 \
	tests/test_rng.f90 \
	-o bin/test_rng.out

test_interface:
	gfortran -O3 -fopenmp -Jobj -Iobj \
	src/common/mod_precision.f90 \
	src/common/mod_rng.f90 \
	src/common/mod_interface.f90 \
	tests/test_interface.f90 \
	-o bin/test_interface.out

test_lattice:
	gfortran -O3 -fopenmp -Jobj -Iobj \
	src/common/mod_precision.f90 \
	src/common/mod_rng.f90 \
	src/common/mod_lattice.f90 \
	tests/test_lattice.f90 \
	-o bin/test_lattice.out

test_mc_step:
	gfortran -O3 -fopenmp -Jobj -Iobj \
	src/common/mod_precision.f90 \
	src/common/mod_rng.f90 \
	src/common/mod_lattice.f90 \
	src/common/mod_interface.f90 \
	src/common/mod_mc_step.f90 \
	tests/test_mc_step.f90 \
	-o bin/test_mc_step.out

test_observables:
	gfortran -O3 -fopenmp -Jobj -Iobj \
	src/common/mod_precision.f90 \
	src/common/mod_observables.f90 \
	tests/test_observables.f90 \
	-o bin/test_observables.out