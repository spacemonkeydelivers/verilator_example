#ifndef TB_ROUTER_H_UJZDPWTL
#define TB_ROUTER_H_UJZDPWTL


#include <unordered_map>
#include <string>

class TB_Router
{
public:
    typedef bool (*callable_t)(int argc, char* argv[]);

    struct call_info_s
    {
        std::string help;
        callable_t  call;
    };

    class CallRegistrator
    {
    public:
        CallRegistrator(const std::string& name,
                        call_info_s call_info);
    };

    std::string print_help      () const;
    callable_t  find_route      (const std::string& name) const;

    bool        register_route  (const std::string& name, call_info_s route);

    static TB_Router& instance();
private:
    TB_Router() = default;

    std::unordered_map<std::string, call_info_s> registered_calls_;
};

#endif /* end of include guard: TB_ROUTER_H_UJZDPWTL */

