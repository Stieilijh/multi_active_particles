module mod_mc_step
   use mod_precision
   use mod_rng
   implicit none

contains

   subroutine active_step(interface, lattice, L, &
      volume_exclusion, p_right, hopping_rate, flipping_rate, &
      flips, hops, hops_left, hops_right, sample, j_left, j_right)

      integer(i8), intent(inout) :: interface(:)
      integer(i4), intent(inout) :: lattice(:)
      integer(i8), intent(inout) :: j_left(:), j_right(:)

      integer(i4), intent(in) :: L
      logical, intent(in) :: volume_exclusion, sample
      real(dp), intent(in) :: p_right, hopping_rate, flipping_rate

      integer(i8), intent(out) :: flips, hops, hops_left, hops_right

      integer(i8) :: attempts, i
      integer(i4) :: rand_site, new_site, particle_type, left, right
      integer(i8) :: h, h_left, h_right
      real(dp) :: rand_var

      flips = 0_i8
      hops = 0_i8
      hops_left = 0_i8
      hops_right = 0_i8

      attempts = int(real(L,dp)/min(hopping_rate,flipping_rate), i8)

      do i = 1, attempts

         rand_site = random_int(L)
         rand_var = random_uniform()
         particle_type = lattice(rand_site)

         if (particle_type == 0_i4) cycle

         left  = modulo(rand_site-2, L) + 1
         right = modulo(rand_site,   L) + 1

         h = interface(rand_site)
         h_left = interface(left)
         h_right = interface(right)

         ! ===== FLIPPING =====
         if (particle_type == 1_i4) then
            if (h < h_left .and. h < h_right) then
               if (rand_var < flipping_rate) then
                  interface(rand_site) = h + 2_i8
                  flips = flips + 1_i8
                  cycle
               end if
            end if
         end if

         if (particle_type == -1_i4) then
            if (h > h_left .and. h > h_right) then
               if (rand_var < flipping_rate) then
                  interface(rand_site) = h - 2_i8
                  flips = flips + 1_i8
                  cycle
               end if
            end if
         end if

         ! ===== HOPPING =====
         if (rand_var >= hopping_rate) cycle

         new_site = rand_site

         if (particle_type == 1_i4) then
            if (h > h_left .and. h > h_right) then
               if (random_uniform() < p_right) then
                  new_site = right
               else
                  new_site = left
               end if
            else if (h > h_right .and. h_left > h) then
               new_site = right
            else if (h > h_left .and. h_right > h) then
               new_site = left
            end if
         else
            if (h < h_left .and. h < h_right) then
               if (random_uniform() < p_right) then
                  new_site = right
               else
                  new_site = left
               end if
            else if (h < h_right .and. h_left < h) then
               new_site = right
            else if (h < h_left .and. h_right < h) then
               new_site = left
            end if
         end if

         if (new_site /= rand_site .and. ((.not. volume_exclusion) .or. lattice(new_site) == 0_i4)) then

            lattice(rand_site) = 0_i4
            lattice(new_site)  = particle_type

            hops = hops + 1_i8

            if (new_site == left) then
               if (sample) j_left(rand_site) = particle_type
               hops_left = hops_left + 1_i8
            else
               if (sample) j_right(rand_site) = particle_type
               hops_right = hops_right + 1_i8
            end if
         end if

      end do

   end subroutine active_step

end module mod_mc_step
