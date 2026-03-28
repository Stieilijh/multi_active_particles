module mod_observables
   use mod_precision
   implicit none
contains

   function get_mean_height(interface) result(mean_height)
      integer(i4),intent(in)::interface(:)
      real(dp)::mean_height
      if(size(interface)==0) stop "ERROR in GET_HEIGHT : INTERFACE SIZE IS 0"
      mean_height= real(sum(interface),dp)/real(size(interface),dp)
   end function get_mean_height


   function get_width(interface) result(width)
      integer(i4),intent(in)::interface(:)
      real(dp)::width,mean
      if(size(interface)==0) stop "ERROR in GET_WIDTH : INTERFACE SIZE IS 0"
      mean = real(sum(interface),dp)/real(size(interface),dp)
      width = sqrt(sum(real(interface,dp)*real(interface,dp))/real(size(interface),dp) - mean*mean)
   end function get_width


   function get_density(lattice) result(density)
      integer(i4),intent(in)::lattice(:)
      real(dp)::density
      if(size(lattice)==0) stop "ERROR in GET_DENSITY : LATTICE SIZE IS 0"
      density =  real(count(lattice/=0_i4),dp)/real(size(lattice),dp)
   end function get_density


   function get_puller_fraction(lattice) result(pf)
      integer(i4),intent(in)::lattice(:)
      real(dp)::pf
      if(size(lattice)==0) stop "ERROR in GET_PF : LATTICE SIZE IS 0"
      if(count(lattice/=0_i4)==0) stop "ERROR in GET_PF : NO PARTICLES IN THE LATTICE"
      pf = real(count(lattice==1_i4),dp)/real(count(lattice/=0_i4),dp)
   end function get_puller_fraction
end module mod_observables
