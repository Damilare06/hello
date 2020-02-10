#include<iostream>
#include<vector>
#include<assert.h>
#include<adios2.h>
#include<mpi.h>
#include<numeric>

void read_density(float * & foo);

int main(int argc, char *argv[])
{
  int rank , size, step = 0;

  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);   
  float * dens = NULL;
  read_density(dens);

  MPI_Barrier(MPI_COMM_WORLD);

  if(!rank )
  {
  //  assert (density[0][0] == (float)0);
    std::cout << "The first density value is " << dens[0] << "\n";
    std::cout << "The 4th density value is " << dens[3] << "\n";
    std::cout << "xgc proxy done\n";
  }

  delete[] dens;
  MPI_Finalize();
  return 0;
}


void read_density(float * &dens)
{

  try
  {
    std::cout << " start reading\n";
    adios2::ADIOS adios(MPI_COMM_WORLD, adios2::DebugON);
    adios2::IO IO = adios.DeclareIO("gcIO");
    IO.SetEngine("Sst");
    IO.SetParameters({{"DataTransport","RDMA"},  {"OpenTimeoutSecs", "360"}});

    adios2::Engine Reader = IO.Open("dens.bp", adios2::Mode::Read);
    Reader.BeginStep();
    adios2::Variable<float> cdens = IO.InquireVariable<float>("gdens");
    auto height = cdens.Shape()[0];
    auto width = cdens.Shape()[1];
    std::cout << "Incoming variable is of size " << height << " by "<< width << std::endl;


    const adios2::Dims start{0, 0};
    const adios2::Dims count{height, width};
    const adios2::Box<adios2::Dims> sel(start, count);
    dens = new float[height * width];

    cdens.SetSelection(sel);
    Reader.Get<float>(cdens, dens);
    Reader.EndStep();

    Reader.Close();
    std::cout << " done reading\n";
  }
  catch (std::invalid_argument &e)
  {
    std::cout << "Invalid argument exception, STOPPING PROGRAM from rank \n";
    std::cout << e.what() << "\n";
  }
  catch (std::ios_base::failure &e)
  {
    std::cout << "IO System base failure exception, STOPPING PROGRAM from rank \n";
    std::cout << e.what() << "\n";
  }
  catch (std::exception &e)
  {
    std::cout << "Exception, STOPPING PROGRAM from rank \n";
    std::cout << e.what() << "\n";
  }
}
