program test_ensemble_avg

   use mod_precision
   use mod_ensemble_avg
   implicit none

   integer(i4) :: L
   real(dp)    :: density, puller_fraction
   integer(i4) :: eq_steps, num_runs
   logical     :: volume_exclusion
   real(dp)    :: p_right, hopping_rate, flipping_rate
   character(len=256) :: filename

   L = 32
   density = 0.4_dp
   puller_fraction = 0.5_dp

   eq_steps = 20
   num_runs = 5

   volume_exclusion = .true.
   p_right = 0.5_dp

   hopping_rate = 0.0_dp
   flipping_rate = 0.0_dp

   filename = "data/multi_particles/tests/test_ensemble.h5"

   call run_ensemble_avg( &
      L, density, puller_fraction, &
      eq_steps, num_runs, &
      volume_exclusion, p_right, &
      hopping_rate, flipping_rate, &
      filename,1)

   print *, "ensemble avg test done"

end program
