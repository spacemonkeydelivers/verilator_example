# Specify the minimum version for CMake
cmake_minimum_required(VERSION 2.8.3)

# Project's name
project(verilated_example)

# Set the output folder where your program will be created
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib)
set(RTL_SRC_PATH ${CMAKE_SOURCE_DIR}/src/rtl)
set(BUILD_PATH ${CMAKE_BINARY_DIR}/build)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -g")
# TODO: use latest verilator to be able to change top lvl module params
set(VERILATOR_FLAGS "--trace")

include(${CMAKE_SOURCE_DIR}/cmake/verilator.cmake)
verilator_include()
create_verilated_module(top ${RTL_SRC_PATH} ${BUILD_PATH} ${VERILATOR_FLAGS})

include_directories(${CMAKE_SOURCE_DIR}/include)

# Set a list of sources
set(TESTBENCH_SRC src/tb/main.cpp)

add_executable(${PROJECT_NAME} ${TESTBENCH_SRC})
target_link_libraries(${PROJECT_NAME} verilator Vtop)
