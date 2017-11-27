#include "../common/module_wrapper.h"
#include "../router/tb_router.h"

#include <Vtop.h>

bool basic_run(int argc, char * argv[])
{
    (void)argc;(void)argv;
    //TODO: parse arguments, get limits and names
    ModuleWrapper<Vtop> dut(std::string("dump.vcd"));

    dut.reset();
    const size_t limit = 10000;
    while (dut.get_tick() < limit)
    {
        dut.tick();
    }
    return true;
}

static TB_Router::CallRegistrator reg("base_run", {
    std::string("TODO"),
    basic_run
});

