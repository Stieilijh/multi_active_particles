program test_filename
   use mod_precision
   use mod_filename
   implicit none

   character(len=512) :: fname, expected

!-----------------------------------
! TEST 1
!-----------------------------------
   fname = get_filename(1024, 1, 0.05_dp, 1.0_dp, 1.0_dp, 0.1_dp, .true.)
   expected = "data/multi_particles/volume_exclusion/puller_fraction_1/hop_1_flip_0_1/L_1024/dens/L_1024_d_01.h5"
   call check("TEST 1", fname, expected)

!-----------------------------------
! TEST 2
!-----------------------------------
   fname = get_filename(256, 5, 0.25_dp, 0.5_dp, 1.0_dp, 0.1_dp, .false.)
   expected = "data/multi_particles/no_volume_exclusion/puller_fraction_0_5/hop_1_flip_0_1/L_256/dens/L_256_d_05.h5"
   call check("TEST 2", fname, expected)

!-----------------------------------
! TEST 3 (flip dominant)
!-----------------------------------
   fname = get_filename(128, 3, 0.15_dp, 0.8_dp, 1.0_dp, 0.9_dp, .true.)
   expected = "data/multi_particles/volume_exclusion/puller_fraction_0_8/hop_1_flip_0_9/L_128/dens/L_128_d_03.h5"
   call check("TEST 3", fname, expected)

!-----------------------------------
! TEST 4 (hop dominant)
!-----------------------------------
   fname = get_filename(128, 3, 0.15_dp, 0.8_dp, 0.9_dp, 0.1_dp, .true.)
   expected = "data/multi_particles/volume_exclusion/puller_fraction_0_8/hop_1_flip_0_1/L_128/dens/L_128_d_03.h5"
   call check("TEST 4", fname, expected)

!-----------------------------------
! TEST 5 (equal rates)
!-----------------------------------
   fname = get_filename(512, 10, 0.5_dp, 1.0_dp, 1.0_dp, 1.0_dp, .true.)
   expected = "data/multi_particles/volume_exclusion/puller_fraction_1/hop_1_flip_1/L_512/dens/L_512_d_10.h5"
   call check("TEST 5", fname, expected)

!-----------------------------------
! TEST 6 (tricky decimal)
!-----------------------------------
   fname = get_filename(64, 7, 0.35_dp, 0.33_dp, 1.0_dp, 0.33_dp, .false.)
   expected = "data/multi_particles/no_volume_exclusion/puller_fraction_0_33/hop_1_flip_0_33/L_64/dens/L_64_d_07.h5"
   call check("TEST 6", fname, expected)

contains

   subroutine check(label, got, expected)
      character(len=*), intent(in) :: label, got, expected

      print *, "-----------------------------"
      print *, trim(label)
      print *, "   got:      ", trim(got)
      print *, "   expected: ", trim(expected)

      if (trim(got) == trim(expected)) then
         print *, "   ✔ PASS"
      else
         print *, "   ✘ FAIL"
      end if
   end subroutine check

end program test_filename
