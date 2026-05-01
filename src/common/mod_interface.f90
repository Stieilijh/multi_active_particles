module mod_interface
   use mod_precision
   implicit none

contains

   function init_interface(L) result(interface)
      integer(i4), intent(in) :: L
      integer(i8), allocatable :: interface(:)
      allocate(interface(L))
      interface(1:L:2) = 1_i8
      interface(2:L:2) = 0_i8
   end function init_interface
end module mod_interface
