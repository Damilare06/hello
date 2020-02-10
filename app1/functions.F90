module functions
  use adios2
  use mpi

  implicit none

  public :: Writer, adios
  type(adios2_adios) :: adios
  type(adios2_engine) :: Writer 

contains


  subroutine write_density(density, ierr)

    integer, intent(inout):: ierr
    real, dimension(4,2), intent(in) :: density
    integer(kind=8), dimension(2) :: shape_dims, start_dims, count_dims
    type(adios2_adios) :: adios
    type(adios2_io) :: IO
    type(adios2_variable) :: gdens

    ! Variable dimensions
    shape_dims(1) = 4 
    start_dims(1) = 0
    count_dims(1) = 4
    shape_dims(2) = 2
    start_dims(2) = 0
    count_dims(2) = 2

    call adios2_init(adios, MPI_COMM_WORLD, adios2_debug_mode_on, ierr)
    call adios2_declare_io(IO, adios, "gcIO", ierr)

    call adios2_define_variable(gdens, IO, "gdens", adios2_type_real, 2, &
     & shape_dims, start_dims, count_dims, adios2_constant_dims, ierr)
    if(gdens%valid ) then
      print *, ' variable declaration succeeded'
    else
      print *, 'something wrong with variable declaration'
    endif

    call adios2_set_engine(IO, "SST", ierr)
    write (*, *) " send density has engine type: ", IO%engine_type
    if (TRIM(IO%engine_type) /= 'SST') stop 'Wrong engine_type'

    call adios2_open(Writer, IO, "/lore/adesoa/dev/hello/dens.bp", adios2_mode_write, ierr)
    call adios2_begin_step(Writer, adios2_step_mode_append, ierr)
    call adios2_put(Writer, gdens, density, ierr)
    call adios2_end_step(Writer, ierr)
    call adios2_close(Writer, ierr)
    call adios2_finalize(adios, ierr)

  end subroutine write_density

end module 
