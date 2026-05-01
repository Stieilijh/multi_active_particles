module mod_precision
   implicit none
! 64 bit floating point
   integer , parameter :: dp = selected_real_kind(15,307)
! 32 bit integer
   integer , parameter :: i4 = selected_int_kind(9)
! 64-bit integer
   integer , parameter :: i8 = selected_int_kind(18)
end module mod_precision
