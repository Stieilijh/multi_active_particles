program test_ergodic

   use mod_precision
   use mod_time_avg
   use mod_ensemble_avg
   implicit none

   integer(i4) :: L
   real(dp)    :: density, puller_fraction
   integer(i4) :: eq_steps, interval_steps, num_samples
   integer(i4) :: num_runs
   logical     :: volume_exclusion
   real(dp)    :: p_right, hopping_rate, flipping_rate
   character(len=256) :: filename

   L = 32
   density = 0.5_dp
   puller_fraction = 1.0_dp

   eq_steps = 1000
   interval_steps = 10
   num_samples = 2000

   num_runs = 2000

   volume_exclusion = .true.
   p_right = 0.5_dp
   hopping_rate = 1.0_dp
   flipping_rate = 0.1_dp

   filename = "data/multi_particle/ergodic_test.h5"

   print *, "Running time average..."
   call run_time_avg( &
      L, density, puller_fraction, &
      eq_steps, interval_steps, num_samples, &
      volume_exclusion, p_right, &
      hopping_rate, flipping_rate, &
      filename, 0)

   print *, "Running ensemble average..."
   call run_ensemble_avg( &
      L, density, puller_fraction, &
      eq_steps, num_runs, &
      volume_exclusion, p_right, &
      hopping_rate, flipping_rate, &
      filename)

   print *, "Ergodic test finished"

end program
