module mod_mc_step
   use mod_precision
   use mod_rng
   implicit none

contains

   subroutine active_step(interface,lattice,L,&
      volume_exclusion,p_right,hopping_rate,flipping_rate,&
      flips,hops,hops_left,hops_right,sample,j_left,j_right)
      integer(i4),intent(inout)::interface(:),lattice(:),j_left(:),j_right(:)
      integer(i4),intent(in)::L
      logical,intent(in)::volume_exclusion,sample
      real(dp),intent(in)::p_right,hopping_rate,flipping_rate
      integer(i4),intent(out)::flips,hops,hops_left,hops_right
      integer(i4)::attempts ,i,rand_site,new_site, &
         particle_type,left,right,h,h_right,h_left
      real(dp)::rand_var

      flips = 0_i4
      hops = 0_i4;hops_left=0_i4;hops_right=0_i4
      attempts = int(L/min(hopping_rate,flipping_rate),i4)

      do i = 1,attempts
         rand_site = random_int(L)
         rand_var = random_uniform()
         particle_type = lattice(rand_site)

         if (particle_type == 0 ) cycle

         left = modulo(rand_site-2,L)+1
         right = modulo(rand_site,L)+1

         h = interface(rand_site)
         h_left = interface(left)
         h_right = interface(right)
         ! FLIPPING FIRST
         ! Puller
         if (particle_type ==1) then
            ! Valley
            if (h<h_left .and. h<h_right) then
               if (rand_var<flipping_rate) then
                  interface(rand_site)= h+2
                  h=h+2_i4
                  flips = flips +1_i4
                  cycle
               end if
            end if
         end if
         ! Pusher
         if (particle_type ==-1) then
            ! Hill
            if (h>h_left .and. h>h_right) then
               if (rand_var<flipping_rate) then
                  interface(rand_site)= h-2
                  h=h-2_i4
                  flips = flips +1_i4
                  cycle
               end if
            end if
         end if

         ! If flipping did not occur then hopping can occur
         ! HOPPING
         if (rand_var>=hopping_rate) cycle
         new_site =  rand_site
         ! Puller
         if (particle_type==1)then
            if(h>h_left .and. h>h_right) then ! Hill
               if(random_uniform()<p_right)then ! Randomly choose direction
                  new_site = right
               else
                  new_site = left
               end if
            else if(h>h_right .and. h_left> h)then
               new_site = right! SLope down to right
            else if(h>h_left .and. h_right>h)then
               new_site = left ! Slope down to left
            end if
         else ! Pusher
            if(h<h_left .and. h<h_right) then ! Valley
               if(random_uniform()<p_right)then ! Randomly choose direction
                  new_site = right
               else
                  new_site = left
               end if
            else if(h<h_right .and. h_left< h)then
               new_site = right! SLope up to right
            else if(h<h_left .and. h_right<h)then
               new_site = left ! Slope up to left
            end if
         end if
         if (new_site/=rand_site .and. ((.not. volume_exclusion)&
            .or.lattice(new_site)==0))then
            lattice(rand_site)=0 ! Vacate
            lattice(new_site) = particle_type ! Move
            hops=hops+1_i4
            if(new_site==left)then
               if(sample) j_left(rand_site) = particle_type
               hops_left=hops_left+1_i4
            else
               if(sample) j_right(rand_site) = particle_type
               hops_right=hops_right+1_i4
            end if
         end if
      end do


   end subroutine active_step

end module mod_mc_step
