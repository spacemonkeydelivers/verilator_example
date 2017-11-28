#include "router/tb_router.h"

#include <iostream>

int main(int argc, char **argv) 
{
    std::string requested_route = "base_run";

    if (argc <= 1) {
        std::cout << "the help (its dangereous to code alone):\n";
        std::cout << TB_Router::instance().print_help();
        return 0;
    }
    //for now
    requested_route = argv[argc - 1];

    TB_Router::callable_t route =
        TB_Router::instance().find_route(requested_route);

    if (!route) {
        throw std::runtime_error("could not find <" + requested_route + ">");
    }
    route(argc, argv);

	return 0;
}
