program test_time_avg

   use mod_precision
   use mod_time_avg
   implicit none

   integer(i4) :: L
   real(dp)    :: density, puller_fraction
   integer(i4) :: eq_steps, interval_steps, num_samples
   logical     :: volume_exclusion
   real(dp)    :: p_right, hopping_rate, flipping_rate
   integer(i4) :: run_id
   character(len=256) :: filename

   L = 32
   density = 0.4_dp
   puller_fraction = 0.5_dp

   eq_steps = 20
   interval_steps = 5
   num_samples = 10

   volume_exclusion = .true.
   p_right = 0.5_dp

   hopping_rate = 0.0_dp
   flipping_rate = 0.0_dp

   run_id = 0
   filename = "data/multi_particles/test_time_avg.h5"

   call run_time_avg( &
      L, density, puller_fraction, &
      eq_steps, interval_steps, num_samples, &
      volume_exclusion, p_right, &
      hopping_rate, flipping_rate, &
      filename, run_id)

   print *, "time avg test done"

end program
