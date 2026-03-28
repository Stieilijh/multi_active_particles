program test_rng
   use mod_precision
   use mod_rng
   implicit none

   integer(i4),parameter::no_of_bins = 20
   integer(i4),parameter::no_of_samples = 100000

   integer(i4)::i,bin
   real(dp)::r
   integer(i4)::hist(no_of_bins)
   call seed_rng(54321)
   hist =0
   do i =1 , no_of_samples
      r = random_uniform()
      bin = int(r*no_of_bins)+1
      if(bin>no_of_bins)bin=no_of_bins
      hist(bin) = hist(bin)+1
   end do
   print*,"Testing uniform RNG"
   print *, "Bin probability"
   do i =1,no_of_bins
      print *, i , real(hist(i),dp)/no_of_samples
   end do
   print*,"Test integer RNG"
   hist =0
   do i =1,no_of_samples
      bin = random_int(no_of_bins)
      hist(bin)=hist(bin)+1
   end do
   print *, "Bin probability"
   do i =1, no_of_bins
      print *,i,real(hist(i),dp)/no_of_samples
   end do
end program test_rng
