# Specify the minimum version for CMake
cmake_minimum_required(VERSION 2.8.3)

# Project's name
project(verilated_example)

# Set the output folder where your program will be created
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/lib)

set(VERILATOR_FLAGS "--trace")
set(VERILATOR_FLAGS_POST "-Wno-lint")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -Wall -g")

find_package (PythonLibs REQUIRED)
include_directories(SYSTEM "${PYTHON_INCLUDE_DIR}")
find_package (Boost REQUIRED)
include_directories(SYSTEM "${Boost_INCLUDE_DIR}")
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
)
if (VERILATOR_FLAGS MATCHES "trace")
    set(VERILATED_SOURCE_LIST ${VERILATED_SOURCE_LIST} verilated_vcd_c.cpp)
endif()

foreach(src ${VERILATED_SOURCE_LIST})
    set(VERILATED_SOURCES ${VERILATED_SOURCES} ${VERILATOR_INCLUDE}/${src})
endforeach()

add_library(${VERILATOR_LIBRARY} STATIC ${VERILATED_SOURCES})
#============================

#TODO: use latest verilator to be able to change top lvl module params
set(RTL_SRC_PATH ${CMAKE_SOURCE_DIR}/src/rtl)
set(RTL_MODEL_BUILD_PATH ${CMAKE_BINARY_DIR}/rtl_model_build)
set(MODULE_NAME "top")

separate_arguments(VERILATOR_ARGS_LIST WINDOWS_COMMAND "${VERILATOR_FLAGS}")
separate_arguments(VERILATOR_ARGS_POST_LIST WINDOWS_COMMAND "${VERILATOR_FLAGS_POST}")
#TODO: handle multiple verilator_args in one string

file(MAKE_DIRECTORY ${RTL_MODEL_BUILD_PATH})
file(GLOB RTL_SRC_FILES
     ${RTL_SRC_PATH}/*.v
)

set(VERILOG_OUTPUT_LIB "${RTL_MODEL_BUILD_PATH}/Vmodel__ALL.a")

if (NOT DEFINED MEM_FILE)
    set(MEM_FILE "${CMAKE_SOURCE_DIR}/test_prog.txt")
endif()

message(STATUS "MEM_FILE: '${MEM_FILE}'")

add_custom_command(
    OUTPUT ${VERILOG_OUTPUT_LIB}
    DEPENDS ${RTL_SRC_FILES}
    COMMAND ${VERILATOR_BIN} ${VERILATOR_ARGS_LIST}
        -GMEM_FILE="${MEM_FILE}"
        -Wall
        -cc
        -Mdir ${RTL_MODEL_BUILD_PATH}
        ${RTL_SRC_FILES}
        --top-module ${MODULE_NAME}
        ${VERILATOR_ARGS_POST_LIST}
        --prefix Vmodel
    COMMAND cd ${RTL_MODEL_BUILD_PATH} && make -f Vmodel.mk
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    VERBATIM
)
set_directory_properties(PROPERTY
    ADDITIONAL_MAKE_CLEAN_FILES
    ${RTL_MODEL_BUILD_PATH})

add_custom_target(
    Vmodel ALL
    DEPENDS "${VERILOG_OUTPUT_LIB}"
    WORKING_DIRECTORY "${RTL_MODEL_BUILD_PATH}"
)

include_directories(${RTL_MODEL_BUILD_PATH})

# Set a list of sources
set(TESTBENCH_SRC src/tb/main.cpp
                  src/tb/router/tb_router.cpp
                  src/tb/tests/py_exec.cpp
                  src/tb/tests/basic.cpp)

include_directories(${CMAKE_SOURCE_DIR}/include)
add_executable(${PROJECT_NAME} ${TESTBENCH_SRC})
add_dependencies(${PROJECT_NAME} Vmodel)

target_link_libraries(${PROJECT_NAME}
    ${VERILATOR_LIBRARY}
    ${VERILOG_OUTPUT_LIB}
    ${PYTHON_LIBRARIES}
)
