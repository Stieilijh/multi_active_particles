program test_ergodic

   use mod_precision
   use mod_time_avg
   use mod_ensemble_avg
   implicit none

   integer(i4) :: L
   real(dp)    :: density
   character(len=256) :: filename

   L = 64
   density = 0.15_dp

   filename = "data/multi_particles/ergodic_test.h5"

   print *, "Running time average..."
   call run_time_avg( &
      L, density, 1.0_dp, &
      2000, 10, 2000, &
      .true., 0.5_dp, 1.0_dp, 0.2_dp, &
      filename, 0)

   print *, "Running ensemble average..."
   call run_ensemble_avg( &
      L, density, 1.0_dp, &
      2000, 2000, &
      .true., 0.5_dp, 1.0_dp, 0.2_dp, &
      filename, 1)

   print *, "Data written to:", trim(filename)

end program
