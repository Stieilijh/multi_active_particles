program test_lattice
   use mod_precision
   use mod_lattice
   implicit none

   integer(i4)::L = 100_i4,i
   real(dp)::density = 0.88_dp,calculated_density,calculated_pf
   real(dp):: puller_fraction = 0.25_dp
   integer(i4),allocatable::lattice(:)

   lattice = init_lattice(L,density,puller_fraction)
   calculated_density =0.0_dp
   calculated_pf=0.0_dp
   do i=1,L
      if(lattice(i)/=0)then
         if(lattice(i)==1)calculated_pf=calculated_pf+1.0
         calculated_density=calculated_density+1.0
      end if
   end do
   calculated_density=calculated_density/L
   calculated_pf = calculated_pf/(calculated_density*real(L,dp))
   print*,"Lattice for L =",L
   print*,"Density = ",density,"puller_fraction = ",puller_fraction
   print*,lattice
   print*,"Calculated Density from lattice = ",calculated_density
   print*,"Calculated Puller fraction from lattice = ",calculated_pf
end program test_lattice
