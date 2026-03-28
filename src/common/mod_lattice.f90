module mod_lattice
   use mod_precision
   use mod_rng
   implicit none

contains

   function init_lattice(L_in, density_in, fraction_pullers_in) result(lattice)

      integer(i4), intent(in) :: L_in
      real(dp), intent(in) :: density_in, fraction_pullers_in

      integer(i4), allocatable :: lattice(:)
      integer(i4), allocatable :: positions(:)
      integer(i4) :: i, j, tmp
      integer(i4) :: no_of_particles, no_of_pullers, no_of_pushers

      allocate(lattice(L_in))
      lattice = 0

      ! number of particles
      no_of_particles = nint(real(L_in,dp) * density_in, i4)
      no_of_pullers = nint(real(no_of_particles,dp) * fraction_pullers_in, i4)
      no_of_pushers = no_of_particles - no_of_pullers

      ! positions 1..L
      allocate(positions(L_in))
      positions = [(i, i=1,L_in)]

      ! Fisher–Yates shuffle
      do i = L_in, 2, -1
         j = random_int(i)
         tmp = positions(i)
         positions(i) = positions(j)
         positions(j) = tmp
      end do

      ! fill pullers
      do i = 1, no_of_pullers
         lattice(positions(i)) = 1
      end do

      ! fill pushers
      do i = no_of_pullers+1, no_of_particles
         lattice(positions(i)) = -1
      end do

   end function init_lattice


end module mod_lattice
