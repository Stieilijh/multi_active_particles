module mod_hdf5
   use hdf5
   use mod_precision
   implicit none

   integer(hid_t) :: file_id
   integer(hid_t) :: group_L, group_density, group_run

   integer(hid_t) :: d_mean, d_width, d_current
   integer(hid_t) :: d_flips, d_hops_l, d_hops_r
   integer(hid_t) :: d_interface,d_lattice,d_j_left,d_j_right

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

      if(exists) then
         call h5gopen_f(parent,trim(name),gid,error)
      else
         call h5gcreate_f(parent,trim(name),gid,error)
      end if

      call check_error(error,"group "//trim(name))
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

      call h5pcreate_f(H5P_DATASET_CREATE_F,dcpl,error)

      chunk = dims
      chunk(1) = min(dims(1),100)

      call h5pset_chunk_f(dcpl,rank,chunk,error)
      call h5pset_deflate_f(dcpl,4,error)

      ! 🔧 FIX: use 64-bit integer
      call h5dcreate_f(parent,name,H5T_NATIVE_LLONG,space,dset,error,dcpl)

      call h5pclose_f(dcpl,error)
      call h5sclose_f(space,error)

   end subroutine

!========================================================
! attribute writers
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

   subroutine write_logical_attr(loc,name,value)

      integer(hid_t),intent(in) :: loc
      character(*),intent(in) :: name
      logical,intent(in) :: value

      integer :: error
      integer(hid_t) :: space,attr
      integer(hsize_t) :: dims(1)
      integer :: ivalue

      ivalue = merge(1,0,value)

      dims=[1]

      call h5screate_simple_f(1,dims,space,error)
      call h5acreate_f(loc,name,H5T_NATIVE_INTEGER,space,attr,error)
      call h5awrite_f(attr,H5T_NATIVE_INTEGER,ivalue,dims,error)

      call h5aclose_f(attr,error)
      call h5sclose_f(space,error)

   end subroutine

!========================================================

   subroutine hdf5_open(filename,L,density,run_id,n_samples,Lsize, &
      eq_steps,interval_steps, &
      p_right,hopping_rate,flipping_rate, &
      volume_exclusion,puller_fraction)

      character(*),intent(in) :: filename
      integer(i8),intent(in) :: L,run_id,n_samples,Lsize
      integer(i8),intent(in) :: eq_steps,interval_steps
      real(dp),intent(in) :: density
      real(dp),intent(in) :: p_right,hopping_rate,flipping_rate,puller_fraction
      logical,intent(in) :: volume_exclusion

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

      write(name,'("density_",F0.3)') density
      call open_or_create_group(group_L,name,group_density)

      write(name,'("run_",I0)') run_id
      call open_or_create_group(group_density,name,group_run)

! metadata
      call write_int_attr(group_run,"L",L)
      call write_real_attr(group_run,"density",density)
      call write_int_attr(group_run,"eq_steps",eq_steps)
      call write_int_attr(group_run,"interval_steps",interval_steps)
      call write_int_attr(group_run,"num_samples",n_samples)

      call write_real_attr(group_run,"p_right",p_right)
      call write_real_attr(group_run,"hopping_rate",hopping_rate)
      call write_real_attr(group_run,"flipping_rate",flipping_rate)
      call write_real_attr(group_run,"puller_fraction",puller_fraction)

      call write_logical_attr(group_run,"volume_exclusion",volume_exclusion)

! datasets
      dims1=[n_samples]
      dims2=[n_samples,Lsize]

      call create_dataset_real(group_run,"mean",dims1,1,d_mean)
      call create_dataset_real(group_run,"width",dims1,1,d_width)
      call create_dataset_real(group_run,"current",dims1,1,d_current)

      call create_dataset_int(group_run,"flips",dims1,1,d_flips)
      call create_dataset_int(group_run,"hops_left",dims1,1,d_hops_l)
      call create_dataset_int(group_run,"hops_right",dims1,1,d_hops_r)

      call create_dataset_int(group_run,"interface",dims2,2,d_interface)
      call create_dataset_int(group_run,"lattice",dims2,2,d_lattice)
      call create_dataset_int(group_run,"J (Left) ",dims2,2,d_j_left)
      call create_dataset_int(group_run,"J (Right)",dims2,2,d_j_right)

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
      call h5dclose_f(d_lattice,error)
      call h5dclose_f(d_j_left,error)
      call h5dclose_f(d_j_right,error)

      call h5gclose_f(group_run,error)
      call h5gclose_f(group_density,error)
      call h5gclose_f(group_L,error)

      call h5fclose_f(file_id,error)
      call h5close_f(error)

   end subroutine

end module mod_hdf5
