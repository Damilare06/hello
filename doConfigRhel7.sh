#/bin/bash -x

# edit these params
CXX=mpicxx
FTN=mpif90

cmake $1 \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_Fortran_COMPILER=$FTN \
      -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_INSTALL_PREFIX=$PWD/install \
#      ${CONFIG_PARAMS}

