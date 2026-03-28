module mod_precision
   implicit none
! 64 bit floating point
   integer , parameter :: dp = selected_real_kind(15,307)
! 32 bit integer
   integer , parameter :: i4 = selected_real_kind(9)
end module mod_precision
