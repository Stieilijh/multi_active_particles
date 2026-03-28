program test_time_avg

   use mod_precision
   use mod_time_avg
   implicit none

   integer :: L
   real(dp) :: density
   real(dp) :: puller_fraction
   integer :: eq_steps
   integer :: interval_steps
   integer :: num_samples
   logical :: volume_exclusion
   real(dp) :: p_right
   real(dp) :: hopping_rate
   real(dp) :: flipping_rate
   character(len=256) :: filename
   ! deterministic parameters
   L = 32
   density = 0.0_dp
   puller_fraction = 0.0_dp

   eq_steps = 10
   interval_steps = 5
   num_samples = 20

   volume_exclusion = .true.
   p_right = 0.5_dp

   hopping_rate = 0.0_dp
   flipping_rate = 0.0_dp

   filename = "data/multi_particles/test.h5"

   call run_time_avg( &
      L, density, puller_fraction, &
      eq_steps, interval_steps, num_samples, &
      volume_exclusion, p_right, &
      hopping_rate, flipping_rate ,filename)

end program
