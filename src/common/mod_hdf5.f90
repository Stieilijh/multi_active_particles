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
      call check_error(error,"group exists")

      if(exists) then
         call h5gopen_f(parent,trim(name),gid,error)
      else
         call h5gcreate_f(parent,trim(name),gid,error)
      end if

      call check_error(error,"open group "//trim(name))
   end subroutine

!========================================================
! compressed dataset creation
!========================================================

   subroutine create_dataset_real(parent,name,dims,rank,dset)

      integer(hid_t),intent(in) :: parent
      character(*),intent(in) :: name
      integer(hsize_t),intent(in) :: dims(:)
      integer,intent(in) :: rank
      integer(hid_t),intent(out) :: dset

      integer :: error
      integer(hid_t) :: space,dcpl
      integer(hsize_t) :: chunk(size(dims))

      call h5screate_simple_f(rank,dims,space,error)
      call check_error(error,"space")

      call h5pcreate_f(H5P_DATASET_CREATE_F,dcpl,error)

      chunk = dims
      chunk(1) = min(dims(1),100)

      call h5pset_chunk_f(dcpl,rank,chunk,error)
      call h5pset_deflate_f(dcpl,4,error)

      call h5dcreate_f(parent,name,H5T_NATIVE_DOUBLE,space,dset,error,dcpl)

      call h5pclose_f(dcpl,error)
      call h5sclose_f(space,error)

   end subroutine

!========================================================

   subroutine create_dataset_int(parent,name,dims,rank,dset)

      integer(hid_t),intent(in) :: parent
      character(*),intent(in) :: name
      integer(hsize_t),intent(in) :: dims(:)
      integer,intent(in) :: rank
      integer(hid_t),intent(out) :: dset

      integer :: error
      integer(hid_t) :: space,dcpl
      integer(hsize_t) :: chunk(size(dims))

      call h5screate_simple_f(rank,dims,space,error)
      call check_error(error,"space")

      call h5pcreate_f(H5P_DATASET_CREATE_F,dcpl,error)

      chunk = dims
      chunk(1) = min(dims(1),100)

      call h5pset_chunk_f(dcpl,rank,chunk,error)
      call h5pset_deflate_f(dcpl,4,error)

      call h5dcreate_f(parent,name,H5T_NATIVE_INTEGER,space,dset,error,dcpl)

      call h5pclose_f(dcpl,error)
      call h5sclose_f(space,error)

   end subroutine

!========================================================
! attributes (metadata)
!========================================================

   subroutine write_int_attr(loc,name,value)
      integer(hid_t),intent(in) :: loc
      character(*),intent(in) :: name
      integer,intent(in) :: value

      integer :: error
      integer(hid_t) :: space,attr
      integer(hsize_t) :: dims(1)

      dims=[1]

      call h5screate_simple_f(1,dims,space,error)
      call h5acreate_f(loc,name,H5T_NATIVE_INTEGER,space,attr,error)
      call h5awrite_f(attr,H5T_NATIVE_INTEGER,value,dims,error)

      call h5aclose_f(attr,error)
      call h5sclose_f(space,error)
   end subroutine

!========================================================

   subroutine write_real_attr(loc,name,value)
      integer(hid_t),intent(in) :: loc
      character(*),intent(in) :: name
      real(dp),intent(in) :: value

      integer :: error
      integer(hid_t) :: space,attr
      integer(hsize_t) :: dims(1)

      dims=[1]

      call h5screate_simple_f(1,dims,space,error)
      call h5acreate_f(loc,name,H5T_NATIVE_DOUBLE,space,attr,error)
      call h5awrite_f(attr,H5T_NATIVE_DOUBLE,value,dims,error)

      call h5aclose_f(attr,error)
      call h5sclose_f(space,error)
   end subroutine

!========================================================

   subroutine hdf5_open(filename,L,density,run_id,n_samples,Lsize, &
      eq_steps,interval_steps)

      character(*),intent(in) :: filename
      integer(i4),intent(in) :: L,run_id,n_samples,Lsize
      integer(i4),intent(in) :: eq_steps,interval_steps
      real(dp),intent(in) :: density

      integer :: error
      character(len=64) :: name
      logical :: exists
      integer(hsize_t) :: dims1(1),dims2(2)

      call h5open_f(error)

      inquire(file=filename,exist=exists)

      if(exists) then
         call h5fopen_f(filename,H5F_ACC_RDWR_F,file_id,error)
      else
         call h5fcreate_f(filename,H5F_ACC_TRUNC_F,file_id,error)
      end if

      write(name,'("L_",I0)') L
      call open_or_create_group(file_id,name,group_L)

      write(name,'("density_",F6.3)') density
      call open_or_create_group(group_L,name,group_density)

      write(name,'("run_",I0)') run_id
      call open_or_create_group(group_density,name,group_run)

! store metadata
      call write_int_attr(group_run,"L",L)
      call write_real_attr(group_run,"density",density)
      call write_int_attr(group_run,"eq_steps",eq_steps)
      call write_int_attr(group_run,"interval_steps",interval_steps)
      call write_int_attr(group_run,"num_samples",n_samples)

! create datasets
      dims1=[n_samples]
      dims2=[n_samples,Lsize]

      call create_dataset_real(group_run,"mean",dims1,1,d_mean)
      call create_dataset_real(group_run,"width",dims1,1,d_width)
      call create_dataset_real(group_run,"current",dims1,1,d_current)

      call create_dataset_int(group_run,"flips",dims1,1,d_flips)
      call create_dataset_int(group_run,"hops_left",dims1,1,d_hops_l)
      call create_dataset_int(group_run,"hops_right",dims1,1,d_hops_r)

      call create_dataset_int(group_run,"interface",dims2,2,d_interface)

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
      call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,start,count,error)
      call h5screate_simple_f(1,count,memspace,error)

      call h5dwrite_f(dset,H5T_NATIVE_DOUBLE,buf,count,error, &
         file_space_id=filespace,mem_space_id=memspace)

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
      call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,start,count,error)
      call h5screate_simple_f(1,count,memspace,error)

      call h5dwrite_f(dset,H5T_NATIVE_INTEGER,buf,count,error, &
         file_space_id=filespace,mem_space_id=memspace)

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
      call h5sselect_hyperslab_f(filespace,H5S_SELECT_SET_F,start,count,error)
      call h5screate_simple_f(2,count,memspace,error)

      call h5dwrite_f(dset,H5T_NATIVE_INTEGER,row,count,error, &
         file_space_id=filespace,mem_space_id=memspace)

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
