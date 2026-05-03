module mod_interface
   use mod_precision
   use mod_rng
   implicit none

contains
   function init_interface(L) result(interface)
      integer(i4),intent(in)::L
      integer(i4),allocatable::interface(:)
      allocate(interface(L))
      interface(1:L:2) = 1
      interface(2:L:2) = 0
   end function init_interface
end module mod_interface
