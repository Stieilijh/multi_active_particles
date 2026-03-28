module mod_ensemble_avg
   use mod_precision
   use mod_interface
   use mod_lattice
   use mod_mc_step
   use mod_observables
   use mod_hdf5
   implicit none

contains

   subroutine run_ensemble_avg(L,density,puller_fraction,eq_steps,&
      num_runs,&
      volume_exclusion,p_right,&
      hopping_rate,flipping_rate,filename)

      integer(i4),intent(in)::L,eq_steps,num_runs
      logical,intent(in)::volume_exclusion
      real(dp),intent(in)::density,puller_fraction,p_right
      real(dp),intent(in)::hopping_rate,flipping_rate
      character(len=*),intent(in)::filename

      integer(i4),allocatable :: lattice(:), interface(:)
      integer(i4)::flips,hops,hops_left,hops_right
      integer(i4)::run,i

      real(dp)::mean_h,width,current

      call hdf5_open(filename, L, density, run, num_runs, L)

      do run = 1 , num_runs

         lattice   = init_lattice(L,density,puller_fraction)
         interface = init_interface(L)

         ! equilibrate
         do i = 1 , eq_steps
            call active_step(interface,lattice,L,&
               volume_exclusion,p_right,hopping_rate,flipping_rate,&
               flips,hops,hops_left,hops_right)
         end do

         ! measure once
         mean_h = get_mean_height(interface)
         width  = get_width(interface)
         current= get_inst_current(hops_left,hops_right,L)

         call hdf5_write_sample(run, mean_h, width, current, &
            flips, hops_left, hops_right, &
            interface)

      end do

      call hdf5_close()

   end subroutine

end module mod_ensemble_avg
