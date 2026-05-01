module mod_observables
   use mod_precision
   implicit none
contains

   function get_mean_height(interface) result(mean_height)
      integer(i8), intent(in) :: interface(:)
      real(dp) :: mean_height

      mean_height = real(sum(interface), dp) / real(size(interface), dp)
   end function get_mean_height


   function get_width(interface) result(width)
      integer(i8), intent(in) :: interface(:)
      real(dp) :: width, mean
      real(dp), allocatable :: diff(:)

      mean = real(sum(interface), dp) / real(size(interface), dp)

      allocate(diff(size(interface)))
      diff = real(interface, dp) - mean

      width = sqrt(sum(diff*diff) / real(size(interface), dp))

      deallocate(diff)
   end function get_width


   function get_density(lattice) result(density)
      integer(i4), intent(in) :: lattice(:)
      real(dp) :: density

      density = real(count(lattice /= 0_i4), dp) / real(size(lattice), dp)
   end function get_density


   function get_puller_fraction(lattice) result(pf)
      integer(i4), intent(in) :: lattice(:)
      real(dp) :: pf

      pf = real(count(lattice == 1_i4), dp) / &
         real(count(lattice /= 0_i4), dp)
   end function get_puller_fraction


   function get_inst_current(hops_left, hops_right, L) result(current)
      integer(i8), intent(in) :: hops_left, hops_right
      integer(i4), intent(in) :: L
      real(dp) :: current

      current = real(hops_right - hops_left, dp) / real(L, dp)
   end function get_inst_current


   function get_inst_current_interval(hops_left, hops_right, L, interval) result(current)
      integer(i8), intent(in) :: hops_left, hops_right
      integer(i4), intent(in) :: L
      integer(i4), intent(in) :: interval
      real(dp) :: current

      current = real(hops_right - hops_left, dp) / real(L * interval, dp)
   end function get_inst_current_interval

end module mod_observables
