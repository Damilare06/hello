program app1
  use mpi
  use adios2
  use functions

  implicit none

  real, dimension(:), allocatable :: myDens, field
  integer :: inx, irank, isize, i , comm
  integer :: ierr = 0
  ! Launch MPI
  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, irank, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, isize, ierr)

  ! Density variables
  inx = 10
  allocate( myDens(inx) )
  allocate( field(inx) )

  do i=1,inx
  myDens(i) = (10.0 * irank) + i - 1
  end do

  call write_density(myDens, isize, irank, inx, ierr)
  call read_field(field, isize, irank, inx, ierr)

  if( allocated(myDens) ) deallocate(myDens)
  if( allocated(field) ) deallocate(field)

  print *, 'app1_f done'
  call MPI_Finalize(ierr)

end program app1
