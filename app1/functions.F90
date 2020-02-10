module functions
  use adios2
  use mpi

  implicit none

  public :: gdensWriter, engine, adios
  type(adios2_adios) :: adios
  type(adios2_engine) :: gdensWriter, engine

contains


  subroutine write_density(density, isize, irank, inx, ierr)

    integer, intent(in):: irank, isize, inx
    integer, intent(inout):: ierr
    real, dimension(:), intent(in) :: density
    integer(kind=8), dimension(1) :: shape_dims, start_dims, count_dims
    type(adios2_adios) :: adios
    type(adios2_io) :: gdensIO
    type(adios2_variable) :: bp_gdens
    type(adios2_variable), pointer ::  var

    ! Variable dimensions
    shape_dims(1) = isize * inx
    start_dims(1) = irank * inx
    count_dims(1) = inx

    call adios2_init(adios, MPI_COMM_SELF, adios2_debug_mode_on, ierr)

    call adios2_declare_io(gdensIO, adios, "gcIO", ierr)

    call adios2_define_variable(bp_gdens, gdensIO, "bp_gdens", adios2_type_real, 1, &
      shape_dims, start_dims, count_dims, adios2_constant_dims, ierr)
    if(bp_gdens%valid ) then
      print *, ' variable declaration succeeded'
    else
      print *, 'something wrong with variable declaration'

    endif

    call adios2_set_engine(gdensIO, "SST", ierr)

    write (*, *) irank, " rank for send density has engine type: ", gdensIO%engine_type
    if (TRIM(gdensIO%engine_type) /= 'SST') stop 'Wrong engine_type'


    call adios2_open(gdensWriter, gdensIO, "gdens.bp", adios2_mode_write, ierr)

    call adios2_begin_step(gdensWriter, ierr)

    call adios2_put(gdensWriter, bp_gdens, density, ierr)

    call adios2_end_step(gdensWriter, ierr)

    call adios2_close(gdensWriter, ierr)

    call adios2_finalize(adios, ierr)

  end subroutine write_density




  subroutine read_field(data, isize, irank, inx, ierr)
    use mpi
    use adios2

    implicit none

    integer, intent(in) :: inx, irank, isize
    integer, intent(inout) :: ierr
    integer(kind=8), dimension(1) :: sel_start, sel_count
    real, dimension(:), allocatable :: data

    ! adios2 handlers
    type(adios2_adios):: adios
    type(adios2_io):: cfieldIO
    type(adios2_variable):: bp_cfield

    call adios2_init(adios, MPI_COMM_SELF, adios2_debug_mode_on, ierr)

    call adios2_declare_io(cfieldIO, adios, "cgIO", ierr)

    call adios2_set_engine(cfieldIO, "SST", ierr)

    write (*, *) irank, " rank for receiving field has engine type: ", cfieldIO%engine_type
    if (TRIM(cfieldIO%engine_type) /= 'SST') stop 'Wrong engine_type'

    call adios2_open(engine, cfieldIO, "cfield.bp", adios2_mode_read, ierr)

    call adios2_begin_step(engine, ierr)

    call adios2_inquire_variable(bp_cfield, cfieldIO, 'bp_cfield', ierr)

    if(ierr == adios2_found) then

      sel_start =  irank * inx
      sel_count = inx

      print *, 'cField reader of rank ', irank, ' reading ', sel_count ,' floats, starting from ', sel_start
      call adios2_set_selection(bp_cfield, 1, sel_start, sel_count, ierr)

      call adios2_get(engine, bp_cfield, data, adios2_mode_sync, ierr)

      call adios2_end_step(engine, ierr)

      call adios2_close(engine, ierr)

    call adios2_finalize(adios, ierr)
    end if

  end subroutine read_field


end module 
