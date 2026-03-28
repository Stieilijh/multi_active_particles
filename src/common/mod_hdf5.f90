module mod_hdf5
   use hdf5
   use mod_precision
   implicit none

   integer(hid_t) :: file_id
   integer(hid_t) :: group_L, group_density, group_run

   integer(hid_t) :: d_mean, d_width, d_current
   integer(hid_t) :: d_flips, d_hops_l, d_hops_r
   integer(hid_t) :: d_interface

contains

!========================================================
   subroutine check_error(error,msg)
      integer,intent(in) :: error
      character(*),intent(in) :: msg
      if(error /= 0) then
         print *, "HDF5 ERROR:", trim(msg)
         stop
      end if
   end subroutine
!========================================================

   subroutine open_or_create_group(parent,name,gid)

      integer(hid_t),intent(in) :: parent
      character(*),intent(in) :: name
      integer(hid_t),intent(out) :: gid

      integer :: error
      logical :: exists

      call h5lexists_f(parent,trim(name),exists,error)
      call check_error(error,"check group exists")

      if(exists) then
         call h5gopen_f(parent,trim(name),gid,error)
      else
         call h5gcreate_f(parent,trim(name),gid,error)
      end if

      call check_error(error,"open/create group "//trim(name))

   end subroutine

!========================================================

   subroutine open_or_create_dataset_real(parent,name,space,dset)

      integer(hid_t),intent(in) :: parent,space
      character(*),intent(in) :: name
      integer(hid_t),intent(out) :: dset

      integer :: error
      logical :: exists

      call h5lexists_f(parent,trim(name),exists,error)
      call check_error(error,"check dataset exists")

      if(exists) then
         call h5dopen_f(parent,trim(name),dset,error)
      else
         call h5dcreate_f(parent,trim(name),H5T_NATIVE_DOUBLE,space,dset,error)
      end if

      call check_error(error,"open/create dataset "//trim(name))

   end subroutine

!========================================================

   subroutine open_or_create_dataset_int(parent,name,space,dset)

      integer(hid_t),intent(in) :: parent,space
      character(*),intent(in) :: name
      integer(hid_t),intent(out) :: dset

      integer :: error
      logical :: exists

      call h5lexists_f(parent,trim(name),exists,error)
      call check_error(error,"check dataset exists")

      if(exists) then
         call h5dopen_f(parent,trim(name),dset,error)
      else
         call h5dcreate_f(parent,trim(name),H5T_NATIVE_INTEGER,space,dset,error)
      end if

      call check_error(error,"open/create dataset "//trim(name))

   end subroutine

!========================================================

   subroutine hdf5_open(filename,L,density,run_id,n_samples,Lsize)

      character(*),intent(in) :: filename
      integer(i4),intent(in) :: L,run_id,n_samples,Lsize
      real(dp),intent(in) :: density

      integer :: error
      character(len=64) :: name
      logical :: exists

      call h5open_f(error)
      call check_error(error,"h5open")

      inquire(file=filename,exist=exists)

      if(exists) then
         call h5fopen_f(filename,H5F_ACC_RDWR_F,file_id,error)
      else
         call h5fcreate_f(filename,H5F_ACC_TRUNC_F,file_id,error)
      end if
      call check_error(error,"open file")

      write(name,'("L_",I0)') L
      call open_or_create_group(file_id,name,group_L)

      write(name,'("density_",F6.3)') density
      call open_or_create_group(group_L,name,group_density)

      write(name,'("run_",I0)') run_id
      call open_or_create_group(group_density,name,group_run)

      call create_datasets(group_run,n_samples,Lsize)

   end subroutine

!========================================================

   subroutine create_datasets(parent,n_samples,L)

      integer(hid_t),intent(in) :: parent
      integer(i4),intent(in) :: n_samples,L

      integer :: error
      integer(hid_t) :: space1,space2
      integer(hsize_t) :: dims1(1),dims2(2)

      dims1=[n_samples]
      dims2=[n_samples,L]

      call h5screate_simple_f(1,dims1,space1,error)
      call check_error(error,"create space1")

      call open_or_create_dataset_real(parent,"mean",space1,d_mean)
      call open_or_create_dataset_real(parent,"width",space1,d_width)
      call open_or_create_dataset_real(parent,"current",space1,d_current)

      call open_or_create_dataset_int(parent,"flips",space1,d_flips)
      call open_or_create_dataset_int(parent,"hops_left",space1,d_hops_l)
      call open_or_create_dataset_int(parent,"hops_right",space1,d_hops_r)

      call h5sclose_f(space1,error)

      call h5screate_simple_f(2,dims2,space2,error)
      call check_error(error,"create space2")

      call open_or_create_dataset_int(parent,"interface",space2,d_interface)

      call h5sclose_f(space2,error)

   end subroutine

!========================================================

   subroutine write_scalar_real(dset,i,value)

      integer(hid_t),intent(in) :: dset
      integer(i4),intent(in) :: i
      real(dp),intent(in) :: value

      integer :: error
      integer(hid_t) :: filespace,memspace
      integer(hsize_t) :: start(1),count(1)
      real(dp) :: buf(1)

      buf=[value]
      start=[i-1]
      count=[1]

      call h5dget_space_f(dset,filespace,error)
      call check_error(error,"get space")

      call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,start,count,error)
      call check_error(error,"select hyperslab")

      call h5screate_simple_f(1,count,memspace,error)

      call h5dwrite_f(dset,H5T_NATIVE_DOUBLE,buf,count,error, &
         file_space_id=filespace,mem_space_id=memspace)
      call check_error(error,"write scalar real")

      call h5sclose_f(filespace,error)
      call h5sclose_f(memspace,error)

   end subroutine

!========================================================

   subroutine write_scalar_int(dset,i,value)

      integer(hid_t),intent(in) :: dset
      integer(i4),intent(in) :: i,value

      integer :: error
      integer(hid_t) :: filespace,memspace
      integer(hsize_t) :: start(1),count(1)
      integer(i4) :: buf(1)

      buf=[value]
      start=[i-1]
      count=[1]

      call h5dget_space_f(dset,filespace,error)
      call check_error(error,"get space")

      call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,start,count,error)
      call check_error(error,"select hyperslab")

      call h5screate_simple_f(1,count,memspace,error)

      call h5dwrite_f(dset,H5T_NATIVE_INTEGER,buf,count,error, &
         file_space_id=filespace,mem_space_id=memspace)
      call check_error(error,"write scalar int")

      call h5sclose_f(filespace,error)
      call h5sclose_f(memspace,error)

   end subroutine

!========================================================

   subroutine write_row(dset,i,row)

      integer(hid_t),intent(in) :: dset
      integer(i4),intent(in) :: i
      integer(i4),intent(in) :: row(:)

      integer :: error
      integer(hid_t) :: filespace,memspace
      integer(hsize_t) :: start(2),count(2)

      start=[i-1,0]
      count=[1,size(row)]

      call h5dget_space_f(dset,filespace,error)
      call check_error(error,"get space")

      call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,start,count,error)
      call check_error(error,"select hyperslab")

      call h5screate_simple_f(2,count,memspace,error)

      call h5dwrite_f(dset,H5T_NATIVE_INTEGER,row,count,error, &
         file_space_id=filespace,mem_space_id=memspace)
      call check_error(error,"write row")

      call h5sclose_f(filespace,error)
      call h5sclose_f(memspace,error)

   end subroutine

!========================================================

   subroutine hdf5_write_sample(i,mean,width,current, &
      flips,hops_left,hops_right,interface)

      integer(i4),intent(in)::i
      real(dp),intent(in)::mean,width,current
      integer(i4),intent(in)::flips,hops_left,hops_right
      integer(i4),intent(in)::interface(:)

      call write_scalar_real(d_mean,i,mean)
      call write_scalar_real(d_width,i,width)
      call write_scalar_real(d_current,i,current)

      call write_scalar_int(d_flips,i,flips)
      call write_scalar_int(d_hops_l,i,hops_left)
      call write_scalar_int(d_hops_r,i,hops_right)

      call write_row(d_interface,i,interface)

   end subroutine

!========================================================

   subroutine hdf5_close()

      integer :: error

      call h5dclose_f(d_mean,error)
      call h5dclose_f(d_width,error)
      call h5dclose_f(d_current,error)
      call h5dclose_f(d_flips,error)
      call h5dclose_f(d_hops_l,error)
      call h5dclose_f(d_hops_r,error)
      call h5dclose_f(d_interface,error)

      call h5gclose_f(group_run,error)
      call h5gclose_f(group_density,error)
      call h5gclose_f(group_L,error)

      call h5fclose_f(file_id,error)
      call h5close_f(error)

   end subroutine

end module mod_hdf5
