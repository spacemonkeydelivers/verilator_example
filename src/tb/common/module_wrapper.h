#ifndef MODULE_WRAPPER_H_MXDW4CPL
#define MODULE_WRAPPER_H_MXDW4CPL

#include <memory>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "types.h"

template <typename ModuleT>
class ModuleWrapper
{
public:
    typedef ModuleT module_t;

    ModuleWrapper (const std::string& trace_name);
    virtual ~ModuleWrapper();

    size_t    get_tick   () const;
    module_t& get_module () const;
    void reset();
    void tick();

private:
    size_t tick_count_ = 0;
    std::shared_ptr<module_t>      module_;
    std::unique_ptr<VerilatedVcdC> trace_;
};

template<typename T>
void ModuleWrapper<T>::reset()
{
    module_->reset_i = LEVEL_HIGH;
    tick();
    module_->reset_i = LEVEL_LOW;
}


template<typename T>
inline size_t    ModuleWrapper<T>::get_tick   () const
{
    return tick_count_;
}

template<typename T>
inline T& ModuleWrapper<T>::get_module () const
{
    return *module_;
}

template<typename T>
void ModuleWrapper<T>::tick()
{
    ++tick_count_;
    module_->clk_i = LEVEL_LOW;
    module_->eval();

    if (trace_)
        trace_->dump(10 * tick_count_ - 2);

    module_->clk_i = LEVEL_HIGH;
    module_->eval();

    if (trace_)
        trace_->dump(10 * tick_count_);

    module_->clk_i = LEVEL_LOW;
    module_->eval();

    if (trace_) {
        trace_->dump(10 * tick_count_ + 5);
        trace_->flush();
    }
}
template<typename T>
ModuleWrapper<T>::~ModuleWrapper()
{
    if (trace_)
        trace_->close();
}
template<typename T>
ModuleWrapper<T>::ModuleWrapper(const std::string& trace_name)
    :module_(std::make_shared<T>())
{
    if (!trace_name.empty()) {
        Verilated::traceEverOn(true);
        trace_ = std::make_unique<VerilatedVcdC>();
        module_->trace(trace_.get(), 99);
        trace_->open(trace_name.c_str());
        if (!trace_->isOpen()) {
            throw std::runtime_error(
               "could not create vcd trace <" + trace_name + ">"
            );
        }
    }
}

#endif /* end of include guard: MODULE_WRAPPER_H_MXDW4CPL */

