program run_parallel_density_sweep

   use mod_precision
   use mod_time_avg
   use mod_rng
   use mpi
   implicit none

   integer :: ierr, rank, size

   ! -------- simulation parameters --------
   integer(i4), parameter :: nL = 1!5
   integer(i4), dimension(nL) :: L_list = [512]
   !integer(i4), dimension(nL) :: L_list = [128,256,512,1024,2048]

   integer(i4), parameter :: ndens = 20
   real(dp) :: densities(ndens)

   integer(i4) :: iL, id, job, total_jobs
   integer(i4) :: L
   real(dp) :: density

   ! -------- model parameters --------
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

!-----------------------------------
! MPI init
!-----------------------------------
   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

!-----------------------------------
! seed RNG per rank
!-----------------------------------
   call seed_rng(1234 + rank*100)

!-----------------------------------
! parameters
!-----------------------------------
   eq_steps       = 15000
   interval_steps = 500
   num_samples    = 10000
   puller_fraction = 1.0_dp
   p_right         = 0.5_dp
   hopping_rate    = 0.1_dp
   flipping_rate   = 1.0_dp
   volume_exclusion = .true.

!-----------------------------------
! density values
!-----------------------------------
   do id = 1, ndens
      densities(id) = 0.05_dp * real(id,dp)
   end do

   total_jobs = nL * ndens

!-----------------------------------
! job loop
!-----------------------------------
   do job = rank, total_jobs-1, size

      iL = job / ndens + 1
      id = mod(job, ndens) + 1

      L = L_list(iL)
      density = densities(id)


      write(filename,'("data/multi_particles/volume_exclusion/puller_fraction_1_0/hop_1_flip_0_1/L_1024/dens/L_",I0,"_d_",I2.2,".h5")') &
         L, id

      print *, "rank", rank, " L=", L, " density=", density

      call run_time_avg( &
         L, density, puller_fraction, &
         eq_steps, interval_steps, num_samples, &
         volume_exclusion, p_right, &
         hopping_rate, flipping_rate, &
         filename, 0)

   end do

   call MPI_Finalize(ierr)

end program
