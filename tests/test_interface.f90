program test_interface
   use mod_precision
   use mod_interface
   implicit none
   integer(i4),parameter::L=10
   integer(i8),allocatable::interface(:)
   interface = init_interface(L)
   print*,"For L = ",L,"Interface"
   print*,interface
end program test_interface
