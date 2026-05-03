program test_mc_step
   use mod_precision
   use mod_interface
   use mod_lattice
   use mod_mc_step
   implicit none

   integer(i4),parameter :: L=50
   integer(i4) :: flips,hops,h_left,h_right
   integer(i4) :: particles_before, particles_after
   integer(i4) :: max_jump
   integer(i4),allocatable :: interface(:), lattice(:),j_left(:),j_right(:)
   integer(i4),allocatable :: interface_old(:), lattice_old(:)

   interface = init_interface(L)
   lattice = init_lattice(L,0.4_dp,0.5_dp)

   interface_old = interface
   lattice_old = lattice

   allocate(j_left(L));allocate(j_right(L))
   j_left =0;j_right =0


   particles_before = count(lattice /= 0)

   call active_step(interface,lattice,L,.true.,0.5_dp,1.0_dp,0.1_dp,&
   flips,hops,h_left,h_right,.false.,j_left,j_right)

   particles_after = count(lattice /= 0)

   ! ---------- TEST 1: particle conservation ----------
   if (particles_before /= particles_after) then
      stop "FAIL: particle number not conserved"
   end if

   ! ---------- TEST 2: valid lattice values ----------
   if (any(lattice /= -1 .and. lattice /= 0 .and. lattice /= 1)) then
      stop "FAIL: invalid lattice value"
   end if

   ! ---------- TEST 3: interface jump only +-2 ----------
   max_jump = maxval(abs(interface - interface_old))
   if (max_jump > 2) then
      stop "FAIL: interface jump too large"
   end if

   ! ---------- TEST 4: only local particle movement ----------
   ! crude check: number of changed sites <= 2*hops
   if (count(lattice /= lattice_old) > 2*hops) then
      stop "FAIL: illegal particle movement"
   end if

   ! -------------TEST 5 : total hops = h_left + h_right -------
   if(hops/=(h_left+h_right))then
      stop "FAIL : total hops /= h_left + h_right"
   end if
   print*, "PASS: mc_step"

end program test_mc_step
