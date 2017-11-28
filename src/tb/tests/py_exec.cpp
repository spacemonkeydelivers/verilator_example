#include "../common/module_wrapper.h"
#include "../router/tb_router.h"

#include <Python.h>

#include <Vmodel.h>

#include <iostream>

bool py_exec(int argc, char * argv[])
{
    (void)argc;(void)argv;

    std::cout << "initializing DUT\n";
    //TODO: parse arguments, get limits and names
    ModuleWrapper<Vmodel> dut(std::string("dump.vcd"));

    std::cout << "initializing python environment\n";

    //Py_SetProgramName(argv[0]);  /* optional but recommended */
    Py_Initialize();
    PyRun_SimpleString("from time import time,ctime\n"
                       "print('\tToday is', ctime(time()))\n");
    Py_Finalize();

    std::cout << "bye-bye! burn in hell\n";

    return true;
}

static TB_Router::CallRegistrator reg("py_exec", {
    std::string("run custom python script"),
    py_exec
});


