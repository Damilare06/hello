#include<iostream>
#include<vector>
#include<assert.h>
#include<adios2.h>
#include<mpi.h>
#include<numeric>

using twoD_vec = std::vector<std::vector<float>>; 
void read_density(float * & foo);
void write_field(const twoD_vec &field, int rank, int size);

int main(int argc, char *argv[])
{
  int rank , size, step = 0;
  twoD_vec density = {{0.0},{0.0}};

  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);   
  float * dens = NULL;
  read_density(dens);
  delete[] dens;

  MPI_Barrier(MPI_COMM_WORLD);

/*  if( !rank )
  {
    assert (density[0][0] == (float)0);
    std::cout << "The asserted first density value is " << density[0][0] << "\n";
    std::cout << "xgc proxy done\n";
  }*/

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

    adios2::Engine Reader = IO.Open("/lore/adesoa/dev/hello/dens.bp", adios2::Mode::Read);
    Reader.BeginStep();
    if(Reader) std::cout << "1.0" << std::endl;
    adios2::Variable<float> cdens = IO.InquireVariable<float>("gdens");
    if(cdens) std::cerr << "1.1" << std::endl;
    auto height = cdens.Shape()[0];
    std::cerr << "1.2" << std::endl;
    auto width = cdens.Shape()[1];
    std::cout << "Incoming variable is of size " << height << " by "<< width << std::endl;


    const adios2::Dims start{0, 0};
    std::cerr << "1.3" << std::endl;
    const adios2::Dims count{height, width};
    std::cerr << "1.4" << std::endl;
    const adios2::Box<adios2::Dims> sel(start, count);
    std::cerr << "1.5" << std::endl;
    dens = new float[height * width];
    std::cerr << "1.6" << std::endl;

    cdens.SetSelection(sel);
    std::cerr << "1.7" << std::endl;
    Reader.Get<float>(cdens, dens);
    std::cerr << "1.8" << std::endl;
    Reader.EndStep();
    std::cerr << "1.9" << std::endl;

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
