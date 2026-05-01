program run_density_sweep

   use mod_precision
   use mod_time_avg
   use omp_lib
   implicit none

   ! -------- simulation parameters --------
   integer(i4), parameter :: nL = 1
   integer(i4), dimension(nL) :: L_list = [128]

   integer(i4), parameter :: ndens = 20
   real(dp) :: densities(ndens)

   integer(i4) :: iL, id
   integer(i4) :: run_id

   ! -------- model parameters --------
   real(dp) :: density
   real(dp) :: puller_fraction
   real(dp) :: p_right
   real(dp) :: hopping_rate
   real(dp) :: flipping_rate
   logical  :: volume_exclusion

   ! -------- averaging parameters --------
   integer(i4) :: eq_steps
   integer(i4) :: interval_steps
   integer(i4) :: num_samples

   character(len=256) :: filename

   ! ---------- values ----------
   eq_steps       = 1000
   interval_steps = 50
   num_samples    = 500

   puller_fraction = 1.0_dp
   p_right         = 0.5_dp
   hopping_rate    = 1.0_dp
   flipping_rate   = 0.1_dp
   volume_exclusion = .true.

   filename = "data/multi_particles/tests/density_sweep_test.h5"
   call seed_rng(1234)
   ! ---------- density sweep ----------

   do id = 1, ndens
      densities(id) = real(0.05_dp * real(id,dp),dp)
   end do

   run_id = 0

   print *
   print *, "===== STARTING RUN ====="
   print *

   do iL = 1, nL

      print *
      print *, "===================================="
      print *, "Running L =", L_list(iL)
      print *, "===================================="
      do id = 1, ndens

         density = densities(id)

         print *
         print *, "L =", L_list(iL), " density =", density
         print *, "run id =", run_id

         call run_time_avg( &
            L_list(iL), density, puller_fraction, &
            eq_steps, interval_steps, num_samples, &
            volume_exclusion, p_right, &
            hopping_rate, flipping_rate, &
            filename, run_id)

         run_id = run_id + 1

      end do

   end do

   print *
   print *, "===== DENSITY SWEEP RUN COMPLETE ====="

end program
