program test_ergodic

   use mod_precision
   use mod_time_avg
   use mod_ensemble_avg
   implicit none

   ! ---------------- PARAMETERS ----------------
   integer(i4) :: L
   real(dp)    :: density
   real(dp)    :: puller_fraction

   integer(i4) :: eq_steps
   integer(i4) :: interval_steps
   integer(i4) :: num_samples
   integer(i4) :: num_runs

   logical     :: volume_exclusion
   real(dp)    :: p_right
   real(dp)    :: hopping_rate
   real(dp)    :: flipping_rate

   integer(i4) :: time_run_id
   integer(i4) :: ensemble_start_id

   character(len=256) :: filename

   ! ---------------- SET VALUES ----------------
   L = 16
   density = 0.5_dp
   puller_fraction = 1.0_dp

   eq_steps = 2000
   interval_steps = 100
   num_samples = 5000
   num_runs = 5000

   volume_exclusion = .true.
   p_right = 0.5_dp
   hopping_rate = 1.0_dp
   flipping_rate = 0.1_dp

   time_run_id = 0
   ensemble_start_id = 1

   filename = "data/multi_particles/ergodic_test.h5"

   ! ---------------- RUN ----------------
   print *, "Running time average..."
   call run_time_avg( &
      L, density, puller_fraction, &
      eq_steps, interval_steps, num_samples, &
      volume_exclusion, p_right, &
      hopping_rate, flipping_rate, &
      filename, time_run_id)

   print *, "Running ensemble average..."
   call run_ensemble_avg( &
      L, density, puller_fraction, &
      eq_steps, num_runs, &
      volume_exclusion, p_right, &
      hopping_rate, flipping_rate, &
      filename, ensemble_start_id)

   print *, "Data written to:", trim(filename)

end program
