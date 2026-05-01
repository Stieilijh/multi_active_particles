module mod_time_avg
   use mod_precision
   use mod_interface
   use mod_lattice
   use mod_mc_step
   use mod_observables
   use mod_hdf5
   implicit none

contains

   subroutine run_time_avg (L,density,puller_fraction,eq_steps,&
      interval_steps,num_samples,&
      volume_exclusion,p_right,hopping_rate,flipping_rate,filename,run_id)

      integer(i4),intent(in)::L,eq_steps,interval_steps,num_samples,run_id
      logical,intent(in)::volume_exclusion
      logical::sample
      real(dp),intent(in)::density,puller_fraction,p_right,&
         hopping_rate,flipping_rate

      ! ===== FIX TYPES ONLY =====
      integer(i4),allocatable::lattice(:)
      integer(i8),allocatable::interface(:),j_left(:),j_right(:)

      integer(i8)::flips,hops,hops_left,hops_right
      integer(i4)::i,j,ok

      real(dp) :: mean_h, width, current
      integer(i8) :: flips_arr, hops_l, hops_r   ! match i8

      character(len=256),intent(in) :: filename

      !-------INITIALISATION-------
      lattice = init_lattice(L,density,puller_fraction)
      interface = init_interface(L)

      allocate(j_left(L),j_right(L),stat=ok)

      !----BRING TO STEADY STATE------
      sample  = .false.
      j_left = 0_i8
      j_right = 0_i8

      do i = 1,eq_steps
         call active_step(interface,lattice,L,&
            volume_exclusion,p_right,hopping_rate,flipping_rate,&
            flips,hops,hops_left,hops_right,sample,j_left,j_right)
      end do

      call hdf5_open(filename, L, density, run_id, num_samples, L, &
         eq_steps, interval_steps, &
         p_right, hopping_rate, flipping_rate, &
         volume_exclusion, puller_fraction)

      !------START TAKING SAMPLES
      do i = 1 , num_samples

         hops_left  = 0_i8
         hops_right = 0_i8
         flips      = 0_i8

         j_left = 0_i8
         j_right = 0_i8

         do j =1, interval_steps
            sample = (j==interval_steps)
            call active_step(interface,lattice,L,&
               volume_exclusion,p_right,hopping_rate,flipping_rate,&
               flips,hops,hops_left,hops_right,sample,j_left,j_right)
         end do

         mean_h = get_mean_height(interface)
         width  = get_width(interface)
         current= get_inst_current_interval(hops_left,hops_right,L,interval_steps)

         flips_arr = flips
         hops_l    = hops_left
         hops_r    = hops_right

         call hdf5_write_sample(i, mean_h, width, current, &
            flips, hops_left, hops_right, &
            interface,lattice,j_left,j_right)

      end do

      call hdf5_close()

   end subroutine

end module mod_time_avg
