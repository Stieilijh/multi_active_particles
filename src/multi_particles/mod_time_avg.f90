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
      real(dp),intent(in)::density,puller_fraction,p_right,&
         hopping_rate,flipping_rate
      integer(i4),allocatable::lattice(:),interface(:)
      integer(i4)::flips,hops,hops_left,hops_right,i,j


      real(dp) :: mean_h, width, current
      integer(i4) :: flips_arr, hops_l, hops_r
      character(len=256),intent(in) :: filename
      !-------INITIALISATION-------
      lattice = init_lattice(L,density,puller_fraction)
      interface = init_interface(L)
      !----BRING TO STEADY STATE------
      do i = 1,eq_steps
         call active_step(interface,lattice,L,&
            volume_exclusion,p_right,hopping_rate,flipping_rate,&
            flips,hops,hops_left,hops_right)
      end do
      call hdf5_open(filename, L, density, run_id, num_samples, L)
      !------START TAKING SAMPLES
      do i = 1 , num_samples

         hops_left  = 0
         hops_right = 0
         flips      = 0

         do j =1, interval_steps
            call active_step(interface,lattice,L,&
               volume_exclusion,p_right,hopping_rate,flipping_rate,&
               flips,hops,hops_left,hops_right)
         end do

         mean_h = get_mean_height(interface)
         width  = get_width(interface)
         current= get_inst_current_interval(hops_left,hops_right,L,interval_steps)

         flips_arr = flips
         hops_l    = hops_left
         hops_r    = hops_right
         call hdf5_write_sample(i, mean_h, width, current, &
            flips, hops_left, hops_right, &
            interface)
      end do
      call hdf5_close()
   end subroutine run_time_avg
end module mod_time_avg
