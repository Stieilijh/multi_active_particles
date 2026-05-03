module mod_rng
   use mod_precision
   !use omp_lib
   implicit none
contains

   subroutine seed_rng(base_seed)
      integer(i4),intent(in) :: base_seed
      integer(i4)::seed_array_size,i!,thread_id
      integer(i4),allocatable::seed_array(:)

      call random_seed(size = seed_array_size)
      allocate(seed_array(seed_array_size))

      !thread_id = omp_get_thread_num()

      do i =1,seed_array_size
         !seed_array(i) = base_seed+37*i+1000*thread_id
         seed_array(i) = base_seed+37*i
      end do

      call random_seed(put = seed_array)
      deallocate (seed_array)
   end subroutine seed_rng

   function random_uniform() result(r)
      real(dp)::r
      call random_number(r)
   end function random_uniform

   function random_int(L) result(N)
      integer(i4), intent(in)::L
      integer(i4)::N
      real(dp)::r
      call random_number(r)
      N = floor(r*L)+1
   end function random_int
end module mod_rng
