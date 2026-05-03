program test_observables
   use mod_precision
   use mod_observables
   implicit none

   integer(i4), dimension(4) :: interface = [0, 2, 0, 2]
   integer(i4), dimension(6) :: lattice   = [1, -1, 0, 1, 0, -1]

   real(dp) :: mean, width, density, pf
   real(dp), parameter :: tol = 1.0e-12_dp

   ! Expected values
   ! interface = [0,2,0,2]
   ! mean = 1
   ! width = sqrt(<h^2> - <h>^2)
   ! <h^2> = (0+4+0+4)/4 = 2
   ! width = sqrt(2 - 1) = 1

   ! lattice = [1,-1,0,1,0,-1]
   ! density = 4/6
   ! puller fraction = 2/4 = 0.5

   mean    = get_mean_height(interface)
   width   = get_width(interface)
   density = get_density(lattice)
   pf      = get_puller_fraction(lattice)

   if (abs(mean - 1.0_dp) > tol) then
      stop "FAIL: mean height"
   end if

   if (abs(width - 1.0_dp) > tol) then
      stop "FAIL: width"
   end if

   if (abs(density - (4.0_dp/6.0_dp)) > tol) then
      stop "FAIL: density"
   end if

   if (abs(pf - 0.5_dp) > tol) then
      stop "FAIL: puller fraction"
   end if

   print*, "PASS: observables"

end program test_observables
