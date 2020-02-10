program app1
    use mpi
    use adios2
    use functions

    implicit none

    real, dimension(:), allocatable :: field
    !resize to a 4 by 2 matrix
    real :: density(4,2) = reshape((/26,22,35,12,5,67,39,17/), (/4,2/))

    integer :: inx, irank, isize 
    integer :: ierr = 0
    ! Launch MPI
    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, irank, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, isize, ierr)

    call write_density(density, ierr)

    print *, 'app1_f done'
    call MPI_Finalize(ierr)

end program app1
