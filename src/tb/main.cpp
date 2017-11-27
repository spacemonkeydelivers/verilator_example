#include "router/tb_router.h"

int main(int argc, char **argv) 
{
    //TODO: parse cmdln, print help if no route is requested
    std::string requested_route = "base_run";

    TB_Router::callable_t route =
        TB_Router::instance().find_route(requested_route);

    if (!route) {
        throw std::runtime_error("could not find <" + requested_route + ">");
    }
    route(argc, argv);
	return 0;
}
