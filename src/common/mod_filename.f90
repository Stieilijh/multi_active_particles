module mod_filename
   use mod_precision
   implicit none
contains

!===========================================================
! Main filename builder
!===========================================================
   function get_filename(L, density_id, density, puller_fraction, &
      hopping_rate, flipping_rate, volume_exclusion) result(path)

      integer(i4), intent(in) :: L, density_id
      real(dp), intent(in)    :: density
      real(dp), intent(in)    :: puller_fraction
      real(dp), intent(in)    :: hopping_rate, flipping_rate
      logical, intent(in)     :: volume_exclusion

      character(len=512) :: path
      character(len=64)  :: ve_str, pf_str, rate_str
      character(len=32)  :: rate_val

!-----------------------------------
! Volume exclusion
!-----------------------------------
      if (volume_exclusion) then
         ve_str = "volume_exclusion"
      else
         ve_str = "no_volume_exclusion"
      end if

!-----------------------------------
! Puller fraction (clean formatting)
!-----------------------------------
      pf_str = "puller_fraction_" // trim(format_rate(puller_fraction))

!-----------------------------------
! Rate naming (your convention)
!-----------------------------------
      if (flipping_rate > hopping_rate) then
         rate_val = format_rate(hopping_rate)
         rate_str = "flip_1_hop_" // trim(rate_val)

      else if (hopping_rate > flipping_rate) then
         rate_val = format_rate(flipping_rate)
         rate_str = "hop_1_flip_" // trim(rate_val)

      else
         rate_str = "hop_1_flip_1"
      end if

!-----------------------------------
! Full path
!-----------------------------------
      write(path,'("data/multi_particles/",A,"/",A,"/",A,"/L_",I0,"/dens/L_",I0,"_d_",I2.2,".h5")') &
         trim(ve_str), trim(pf_str), trim(rate_str), L, L, density_id

   end function get_filename


!===========================================================
! Format float → clean string
! Examples:
! 1.000 → "1"
! 0.100 → "0_1"
! 0.010 → "0_01"
! 0.700 → "0_7"
!===========================================================
   function format_rate(x) result(str)
      use mod_precision
      real(dp), intent(in) :: x
      character(len=32) :: str
      character(len=32) :: temp
      integer :: i, last

! write with sufficient precision
      write(temp,'(F6.3)') x   ! e.g. 0.100, 0.700, 1.000

! left adjust
      temp = adjustl(temp)

! find last non-zero
      last = len_trim(temp)
      do i = last, 1, -1
         if (temp(i:i) == '0') then
            last = last - 1
         else
            exit
         end if
      end do

! remove trailing dot if exists
      if (temp(last:last) == '.') last = last - 1

! extract clean string
      str = temp(1:last)

! replace dot with underscore
      call replace_dot(str)

   end function format_rate


!===========================================================
! Replace '.' → '_'
!===========================================================
   subroutine replace_dot(str)
      character(len=*), intent(inout) :: str
      integer :: i

      do i = 1, len_trim(str)
         if (str(i:i) == ".") str(i:i) = "_"
      end do
   end subroutine replace_dot
   subroutine ensure_directory_exists(filepath, rank)
      use iso_fortran_env
      implicit none

      character(len=*), intent(in) :: filepath
      integer, intent(in) :: rank

      character(len=512) :: dir
      character(len=600) :: cmd
      integer :: i, istat

!-----------------------------------
! extract directory path
!-----------------------------------
      dir = filepath

      do i = len_trim(filepath), 1, -1
         if (filepath(i:i) == "/") then
            dir = filepath(1:i-1)
            exit
         end if
      end do

!-----------------------------------
! only rank 0 tries to create
!-----------------------------------
      if (rank == 0) then

#ifdef _WIN32
         write(cmd,'(A,A,A)') 'mkdir "', trim(dir), '"'
#else
         write(cmd,'(A,A)') "mkdir -p ", trim(dir)
#endif

         call execute_command_line(trim(cmd), exitstat=istat)

         if (istat /= 0) then
            write(*,*) "ERROR: Failed to create directory:"
            write(*,*) trim(dir)
            write(*,*) "Please create it manually."
            stop 1
         end if

      end if

   end subroutine ensure_directory_exists
end module mod_filename
