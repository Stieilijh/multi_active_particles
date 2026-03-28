module mod_hdf5
   use hdf5
   use mod_precision
   implicit none

   integer(hid_t) :: file_id
   integer(hid_t) :: d_mean, d_width, d_current
   integer(hid_t) :: d_flips, d_hops_l, d_hops_r
   integer(hid_t) :: d_interface

contains

   subroutine hdf5_open(filename, n_samples, L)

      character(*),intent(in) :: filename
      integer(i4),intent(in)  :: n_samples, L

      integer :: error
      integer(hsize_t) :: dims1(1), dims2(2)
      integer(hid_t) :: space1, space2

      call h5open_f(error)
      call h5fcreate_f(filename, H5F_ACC_TRUNC_F, file_id, error)

      dims1 = [n_samples]
      dims2 = [n_samples, L]

      call h5screate_simple_f(1, dims1, space1, error)
      call h5screate_simple_f(2, dims2, space2, error)

      call h5dcreate_f(file_id,"mean",H5T_NATIVE_DOUBLE,space1,d_mean,error)
      call h5dcreate_f(file_id,"width",H5T_NATIVE_DOUBLE,space1,d_width,error)
      call h5dcreate_f(file_id,"current",H5T_NATIVE_DOUBLE,space1,d_current,error)

      call h5dcreate_f(file_id,"flips",H5T_NATIVE_INTEGER,space1,d_flips,error)
      call h5dcreate_f(file_id,"hops_left",H5T_NATIVE_INTEGER,space1,d_hops_l,error)
      call h5dcreate_f(file_id,"hops_right",H5T_NATIVE_INTEGER,space1,d_hops_r,error)

      call h5dcreate_f(file_id,"interface",H5T_NATIVE_INTEGER,space2,d_interface,error)

      call h5sclose_f(space1,error)
      call h5sclose_f(space2,error)

   end subroutine


   subroutine write_scalar_real(dset, i, value)

      integer(hid_t),intent(in) :: dset
      integer(i4),intent(in)    :: i
      real(dp),intent(in)       :: value

      integer :: error
      integer(hid_t) :: filespace, memspace
      integer(hsize_t) :: start(1), count(1)
      real(dp) :: buffer(1)

      buffer(1) = value
      start = [i-1]
      count = [1]

      call h5dget_space_f(dset, filespace, error)
      call h5sselect_hyperslab_f(filespace, H5S_SELECT_SET_F, start, count, error)

      call h5screate_simple_f(1, count, memspace, error)

      call h5dwrite_f(dset, H5T_NATIVE_DOUBLE, buffer, count, error, &
         file_space_id=filespace, mem_space_id=memspace)

      call h5sclose_f(filespace,error)
      call h5sclose_f(memspace,error)

   end subroutine


   subroutine write_scalar_int(dset, i, value)

      integer(hid_t),intent(in) :: dset
      integer(i4),intent(in)    :: i
      integer(i4),intent(in)    :: value

      integer :: error
      integer(hid_t) :: filespace, memspace
      integer(hsize_t) :: start(1), count(1)
      integer(i4) :: buffer(1)

      buffer(1) = value
      start = [i-1]
      count = [1]

      call h5dget_space_f(dset, filespace, error)
      call h5sselect_hyperslab_f(filespace, H5S_SELECT_SET_F, start, count, error)

      call h5screate_simple_f(1, count, memspace, error)

      call h5dwrite_f(dset, H5T_NATIVE_INTEGER, buffer, count, error, &
         file_space_id=filespace, mem_space_id=memspace)

      call h5sclose_f(filespace,error)
      call h5sclose_f(memspace,error)

   end subroutine


   subroutine write_row(dset, i, row)

      integer(hid_t),intent(in) :: dset
      integer(i4),intent(in)    :: i
      integer(i4),intent(in)    :: row(:)

      integer :: error
      integer(hid_t) :: filespace, memspace
      integer(hsize_t) :: start(2), count(2)

      start = [i-1, 0]
      count = [1, size(row)]

      call h5dget_space_f(dset, filespace, error)
      call h5sselect_hyperslab_f(filespace, H5S_SELECT_SET_F, start, count, error)

      call h5screate_simple_f(2, count, memspace, error)

      call h5dwrite_f(dset, H5T_NATIVE_INTEGER, row, count, error, &
         file_space_id=filespace, mem_space_id=memspace)

      call h5sclose_f(filespace,error)
      call h5sclose_f(memspace,error)

   end subroutine


   subroutine hdf5_write_sample(i, mean, width, current, &
      flips, hops_left, hops_right, &
      interface)

      integer(i4),intent(in) :: i
      real(dp),intent(in)    :: mean, width, current
      integer(i4),intent(in) :: flips, hops_left, hops_right
      integer(i4),intent(in) :: interface(:)

      call write_scalar_real(d_mean, i, mean)
      call write_scalar_real(d_width, i, width)
      call write_scalar_real(d_current, i, current)

      call write_scalar_int(d_flips, i, flips)
      call write_scalar_int(d_hops_l, i, hops_left)
      call write_scalar_int(d_hops_r, i, hops_right)

      call write_row(d_interface, i, interface)

   end subroutine


   subroutine hdf5_close()

      integer :: error

      call h5dclose_f(d_mean,error)
      call h5dclose_f(d_width,error)
      call h5dclose_f(d_current,error)

      call h5dclose_f(d_flips,error)
      call h5dclose_f(d_hops_l,error)
      call h5dclose_f(d_hops_r,error)

      call h5dclose_f(d_interface,error)

      call h5fclose_f(file_id,error)
      call h5close_f(error)

   end subroutine

end module mod_hdf5
