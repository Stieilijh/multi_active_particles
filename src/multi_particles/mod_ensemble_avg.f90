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
      hopping_rate,flipping_rate,filename,start_run_id)

      integer(i4),intent(in)::L,eq_steps,num_runs,start_run_id
      logical,intent(in)::volume_exclusion
      real(dp),intent(in)::density,puller_fraction,p_right
      real(dp),intent(in)::hopping_rate,flipping_rate
      character(len=*),intent(in)::filename

      integer(i4),allocatable :: lattice(:)
      integer(i8),allocatable :: interface(:)

      integer(i8)::flips,hops,hops_left,hops_right
      integer(i4)::run,i

      real(dp)::mean_h,width,current

      ! dummy arrays (needed for active_step signature)
      integer(i8),allocatable :: j_left(:), j_right(:)
      allocate(j_left(L), j_right(L))
      j_left = 0_i8
      j_right = 0_i8

      do run = 1 , num_runs

         lattice   = init_lattice(L,density,puller_fraction)
         interface = init_interface(L)

         do i = 1 , eq_steps
            call active_step(interface,lattice,L,&
               volume_exclusion,p_right,hopping_rate,flipping_rate,&
               flips,hops,hops_left,hops_right,.false.,j_left,j_right)
         end do

         call hdf5_open(filename, L, density, run+start_run_id, 1, L, &
            eq_steps, 0, &
            p_right, hopping_rate, flipping_rate, &
            volume_exclusion, puller_fraction)

         mean_h = get_mean_height(interface)
         width  = get_width(interface)
         current= get_inst_current(hops_left,hops_right,L)

         call hdf5_write_sample(1, mean_h, width, current, &
            flips, hops_left, hops_right, &
            interface,lattice,j_left,j_right)

      end do

      call hdf5_close()

   end subroutine

end module mod_ensemble_avg
