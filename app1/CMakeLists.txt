#cmake_minimum_required(VERSION 2.8)
#project(app CXX)


set(LIB_NAME app1)
set(USER_LIB "/users/adesoa/dev")
set(ADIOS2_INCLUDE_DIRS "${USER_LIB}/install/ADIOS2/include")
set(ADIOS2_INC "${USER_LIB}/install/ADIOS2/lib64")
set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${ADIOS2_INC} )


find_package( MPI REQUIRED)
include_directories( ${MPI_CXX_INCLUDE_PATH} )

find_library(ADIOS2_LIB NAMES adios2 libadios2)
include_directories(${ADIOS2_INCLUDE_DIRS})
if(NOT ADIOS2_LIB)
  message(STATUS "adios2 library not found")
else()
  message(STATUS "adios2 library was found")
endif()

find_library(ADIOS2_F NAMES adios2_f libadios2_f)
include_directories("${ADIOS2_INCLUDE_DIRS}/adios2/fortran")
if(NOT ADIOS2_F)
  message(STATUS "adios2_f library not found")
else()
  message(STATUS "adios2_f library was found")
endif()

#add_definitions(-DADIOS2_HAVE_MPI)

add_executable(${LIB_NAME} app1.cc)
target_link_libraries( ${LIB_NAME}  ${MPI_CXX_LIBRARIES} ${ADIOS2_LIB})

add_executable(app1_2d app1_2d.cc)
target_link_libraries(app1_2d  ${MPI_CXX_LIBRARIES} ${ADIOS2_LIB})

add_executable(app1_2d_f app1.F90 functions.F90)
target_link_libraries(app1_2d_f  ${MPI_CXX_LIBRARIES} ${ADIOS2_F})
set_target_properties(app1_2d_f PROPERTIES
  LINKER_LANGUAGE Fortran
)


INSTALL(TARGETS ${LIB_NAME}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION ${PROJECT_BINARY_DIR}
        ARCHIVE DESTINATION ${PROJECT_BINARY_DIR})
install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR})


