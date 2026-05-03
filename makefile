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

test_time_avg:
	h5fc -O3 -march=native -funroll-loops -J obj -I obj \
src/common/mod_precision.f90 \
src/common/mod_rng.f90 \
src/common/mod_lattice.f90 \
src/common/mod_interface.f90 \
src/common/mod_mc_step.f90 \
src/common/mod_observables.f90 \
src/common/mod_hdf5.f90 \
src/multi_particles/mod_time_avg.f90 \
tests/multi_particles/test_time_avg.f90 \
-o bin/test_time_avg && mv *.o obj/


test_ensemble_avg:
	h5fc -O3 -march=native -funroll-loops -J obj -I obj \
src/common/mod_precision.f90 \
src/common/mod_rng.f90 \
src/common/mod_lattice.f90 \
src/common/mod_interface.f90 \
src/common/mod_mc_step.f90 \
src/common/mod_observables.f90 \
src/common/mod_hdf5.f90 \
src/multi_particles/mod_ensemble_avg.f90 \
tests/multi_particles/test_ensemble_avg.f90 \
-o bin/test_ensemble_avg && mv *.o obj 


test_ergodic:
	mkdir -p obj bin
	h5fc -O3 -march=native -funroll-loops -J obj -I obj \
src/common/mod_precision.f90 \
src/common/mod_rng.f90 \
src/common/mod_lattice.f90 \
src/common/mod_interface.f90 \
src/common/mod_mc_step.f90 \
src/common/mod_observables.f90 \
src/common/mod_hdf5.f90 \
src/multi_particles/mod_time_avg.f90 \
src/multi_particles/mod_ensemble_avg.f90 \
tests/multi_particles/test_ergodic.f90 \
-o bin/test_ergodic && mv *.o obj/

run_density_sweep:
	mkdir -p obj bin
	h5fc -O3 -march=native -funroll-loops -J obj -I obj  \
src/common/mod_precision.f90 \
src/common/mod_rng.f90 \
src/common/mod_lattice.f90 \
src/common/mod_interface.f90 \
src/common/mod_mc_step.f90 \
src/common/mod_observables.f90 \
src/common/mod_hdf5.f90 \
src/multi_particles/mod_time_avg.f90 \
tests/multi_particles/run_density_sweep.f90 \
-o bin/run_density_sweep && mv *.o obj/

build_parallel_density_sweep:
	mkdir -p obj bin
	mpif90 -O3 -march=native -funroll-loops -cpp -J obj -I obj \
src/common/mod_precision.f90 \
src/common/mod_rng.f90 \
src/common/mod_lattice.f90 \
src/common/mod_interface.f90 \
src/common/mod_mc_step.f90 \
src/common/mod_observables.f90 \
src/common/mod_filename.f90 \
src/common/mod_hdf5.f90 \
src/multi_particles/mod_time_avg.f90 \
tests/multi_particles/run_parallel_density_sweep.f90 \
-I/usr/include/hdf5/serial \
-L/usr/lib/x86_64-linux-gnu/hdf5/serial \
-lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 \
-lcrypto -lcurl -lpthread -lsz -lz -ldl -lm \
-o bin/run_parallel_density_sweep

run_parallel_density_sweep:
	mpirun --oversubscribe -np 4 bin/run_parallel_density_sweep

test_filename:
	gfortran -O3 -Jobj -Iobj -cpp \
	src/common/mod_precision.f90 \
	src/common/mod_filename.f90 \
	tests/test_filename.f90 \
	-o bin/test_filename.out

analyse_and_log:
	mkdir -p logs
	python3 analysis/master.py 2>&1 | tee logs/pipeline_$$(date +%F_%H-%M-%S).log

clean:
	rm -rf obj/*.mod obj/*.o