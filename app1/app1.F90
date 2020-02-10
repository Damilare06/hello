program app1
  use mpi
  use adios2
  use functions

  implicit none

  real, dimension(:), allocatable :: field
  real, dimension(0:3,0:1) :: density
  !real :: density(4,2) = reshape((/1,2,3,4,5,6,7,8/), (/4,2/))
  !REAL,DIMENSION(4,2) :: density = RESHAPE([1,2,3,4,5,6,7,8],[4,2])

  integer :: inx, irank, isize, i , comm
  integer :: ierr = 0
  ! Launch MPI
  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, irank, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, isize, ierr)

  ! Density variables
density(0,0)= 1.0
density(1,0)= 2.0
density(2,0)= 3.0
density(3,0)= 4.0
density(0,1)= 5.0
density(1,1)= 6.0
density(2,1)= 7.0
density(3,1)= 8.0

  call write_density(density, ierr)

  print *, 'app1_f done'
  call MPI_Finalize(ierr)

end program app1
