#include "tb_router.h"
#include <stdexcept>

TB_Router& TB_Router::instance()
{
    static TB_Router self;
    return self;
}
std::string TB_Router::print_help() const
{
    throw std::runtime_error("print help not implemented");
}
TB_Router::callable_t  TB_Router::find_route(const std::string& name) const
{
    callable_t result = nullptr;
    auto it = registered_calls_.find(name);
    if (it != registered_calls_.end()) {
        return it->second.call;
    }
    return result;
}
bool  TB_Router::register_route(const std::string& name, call_info_s info)
{
    bool result;
    std::tie(std::ignore, result) = registered_calls_.insert({name, info});
    if (!result) {
        //TODO: log error
    }
    return result;
}
TB_Router::CallRegistrator::CallRegistrator(const std::string& name,
                                            call_info_s call_info)
{
    TB_Router::instance().register_route(name, call_info);
}

