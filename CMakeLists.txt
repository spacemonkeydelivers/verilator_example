macro(verilator_include)
    find_path(VERILATOR_INCLUDE verilated.h
        PATH_SUFFIXES verilator/include
        HINTS /usr/share
    )
    include_directories(SYSTEM ${VERILATOR_INCLUDE})
    include_directories(SYSTEM ${VERILATOR_INCLUDE}/vltstd/)
    set(VERILATOR_SOURCE_LIST
        verilated.cpp
        verilated_save.cpp
        verilated_vcd_c.cpp
    )

    set(VERILATOR_SOURCES "")
    foreach(src ${VERILATOR_SOURCE_LIST})
        set(VERILATOR_SOURCES ${VERILATOR_SOURCES} ${VERILATOR_INCLUDE}/${src})
    endforeach()

    add_library(verilator SHARED ${VERILATOR_SOURCES})

    set(VERILATOR_LIBRARY verilator)
    set_target_properties(
        verilator
        PROPERTIES COMPILE_FLAGS "-std=c++11 -Wall -Werror -g"
    )
endmacro()

macro(create_verilated_module module_name src_path build_path verilator_args)
    separate_arguments(VERILATOR_ARGS_LIST WINDOWS_COMMAND "${verilator_args}")
    #TODO: handle multiple verilator_args in one string

    file(GLOB RTL_SRC_FILES
      ${src_path}/*.vh
      ${src_path}/*.v
    )

    set(VERILATED_MODULE_FILES Vtop.cpp Vtop.h Vtop_top.cpp Vtop_wb_ram.cpp Vtop__Dpi.cpp Vtop__Trace.cpp Vtop__Trace__Slow.cpp Vtop__Syms.cpp)

    set(VERILATED_MODULE_HEADERS_PATH ${build_path}/generated/include)
    set(VERILOG_OUTPUT_SOURCES "")
    foreach(source ${VERILATED_MODULE_FILES})
        set(VERILOG_OUTPUT_SOURCES ${VERILOG_OUTPUT_SOURCES}
            ${build_path}/${source})
    endforeach()

    add_custom_command(
        OUTPUT ${VERILOG_OUTPUT_SOURCES}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${build_path}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${VERILATED_MODULE_HEADERS_PATH}
        COMMAND verilator ${VERILATOR_ARGS_LIST}
            -Wall
            --exe
            -cc
            -Mdir ${build_path}
            ${RTL_SRC_FILES}
            --top-module ${module_name}
        COMMAND ${CMAKE_COMMAND} -E remove ${build_path}/*.mk
        COMMAND ${CMAKE_COMMAND} -E remove ${build_path}/*.d
        COMMAND ${CMAKE_COMMAND} -E remove ${build_path}/*.dat
        COMMAND ${CMAKE_COMMAND} -E copy ${build_path}/*.h ${VERILATED_MODULE_HEADERS_PATH}
        COMMAND ${CMAKE_COMMAND} -E remove ${build_path}/*.h
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
    include_directories(${VERILATED_MODULE_HEADERS_PATH})
    add_library(V${module_name} STATIC ${VERILOG_OUTPUT_SOURCES})
endmacro()

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
set(VERILATOR_FLAGS "--trace -GWIDTH=15 ")

verilator_include()
create_verilated_module(top ${RTL_SRC_PATH} ${BUILD_PATH} ${VERILATOR_FLAGS})

include_directories(${CMAKE_SOURCE_DIR}/include)

# Set a list of sources
set(TESTBENCH_SRC src/tb/main.cpp)

add_executable(${PROJECT_NAME} ${TESTBENCH_SRC})
target_link_libraries(${PROJECT_NAME} verilator Vtop)
