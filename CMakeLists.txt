# Specify the minimum version for CMake
cmake_minimum_required(VERSION 2.8.3)

# Project's name
project(verilated_example)

# Set the output folder where your program will be created
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -Wall -g")

# find verilator ============
find_program(VERILATOR_BIN verilator)

find_path(VERILATOR_INCLUDE verilated.h
    PATH_SUFFIXES verilator/include
    HINTS /usr/share
)

if (${VERILATOR_BIN} MATCHES "NOTFOUND" OR ${VERILATOR_INCLUDE} MATCHES "NOTFOUND")
    message(FATAL_ERROR "Could not find verilator.")
endif()

include_directories(SYSTEM ${VERILATOR_INCLUDE})
include_directories(SYSTEM ${VERILATOR_INCLUDE}/vltstd/)
#============================

# compile verilator lib =====
set(VERILATOR_LIBRARY verilated)
set(VERILATED_SOURCE_LIST
    verilated.cpp
    verilated_save.cpp
    verilated_vcd_c.cpp
)

foreach(src ${VERILATED_SOURCE_LIST})
    set(VERILATED_SOURCES ${VERILATED_SOURCES} ${VERILATOR_INCLUDE}/${src})
endforeach()

add_library(${VERILATOR_LIBRARY} STATIC ${VERILATED_SOURCES})
#============================

#TODO: use latest verilator to be able to change top lvl module params
set(RTL_SRC_PATH ${CMAKE_SOURCE_DIR}/src/rtl)
set(BUILD_PATH ${CMAKE_BINARY_DIR}/build)
set(MODULE_NAME "top")
set(VERILATOR_FLAGS "--trace")
set(VERILATOR_FLAGS_POST "-Wno-lint")

separate_arguments(VERILATOR_ARGS_LIST WINDOWS_COMMAND "${VERILATOR_FLAGS}")
separate_arguments(VERILATOR_ARGS_POST_LIST WINDOWS_COMMAND "${VERILATOR_FLAGS_POST}")
#TODO: handle multiple verilator_args in one string

file(MAKE_DIRECTORY ${BUILD_PATH})
file(GLOB RTL_SRC_FILES
     ${RTL_SRC_PATH}/*.vh
     ${RTL_SRC_PATH}/*.v
)

set(VERILATED_MODULE_FILES Vtop.cpp Vtop.h Vtop_top.cpp Vtop_wb_ram__pi1.cpp Vtop__Dpi.cpp Vtop__Trace.cpp Vtop__Trace__Slow.cpp Vtop__Syms.cpp)
foreach(source ${VERILATED_MODULE_FILES})
    set(VERILOG_OUTPUT_SOURCES ${VERILOG_OUTPUT_SOURCES} ${BUILD_PATH}/${source})
endforeach()
set_source_files_properties(${VERILOG_OUTPUT_SOURCES} PROPERTIES GENERATED 1)

if (NOT DEFINED MEM_FILE)
    set(MEM_FILE "${CMAKE_SOURCE_DIR}/test_prog.txt")
endif()

add_custom_command(
    OUTPUT ${VERILOG_OUTPUT_SOURCES}
    DEPENDS ${RTL_SRC_FILES}
    COMMAND ${VERILATOR_BIN} ${VERILATOR_ARGS_LIST} -I./
        -GMEM_FILE="${MEM_FILE}"
        -Wall
        --exe
        -cc
        -Mdir ${BUILD_PATH}
        ${RTL_SRC_FILES}
        --top-module ${MODULE_NAME}
        ${VERILATOR_ARGS_POST_LIST}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    VERBATIM
)
include_directories(${BUILD_PATH})
add_library(V${MODULE_NAME} STATIC ${VERILOG_OUTPUT_SOURCES})

# Set a list of sources
set(TESTBENCH_SRC src/tb/main.cpp)

include_directories(${CMAKE_SOURCE_DIR}/include)
add_executable(${PROJECT_NAME} ${TESTBENCH_SRC})
target_link_libraries(${PROJECT_NAME} ${VERILATOR_LIBRARY} V${MODULE_NAME})
