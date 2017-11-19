macro(verilator_include)
    find_path(VERILATOR_INCLUDE verilated.h
        PATH_SUFFIXES verilator/include
        HINTS /usr/share
    )
    include_directories(SYSTEM ${VERILATOR_INCLUDE})
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
    #TODO: handle multiple verilator_args in one string

    file(GLOB RTL_SRC_FILES
      ${src_path}/*.vh
      ${src_path}/*.v
    )
    
    set(VERILATED_MODULE_FILES
        V${module_name}.cpp
        V${module_name}__Syms.cpp
        V${module_name}.h
        V${module_name}__Syms.h
        V${module_name}__Trace.cpp
        V${module_name}__Trace__Slow.cpp
    )
    
    set(VERILATED_MODULE_HEADERS_PATH ${build_path}/generated/include)
    set(VERILOG_OUTPUT_SOURCES "")
    
    foreach(source ${VERILATED_MODULE_FILES})
        set(VERILOG_OUTPUT_SOURCES ${VERILOG_OUTPUT_SOURCES}
            ${build_path}/${source})
        MESSAGE( STATUS ${build_path}/${source})
    endforeach()
    
    add_custom_command(
        OUTPUT ${VERILOG_OUTPUT_SOURCES}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${build_path}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${VERILATED_MODULE_HEADERS_PATH}
        COMMAND verilator ${verilator_args}
            -Wall
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
