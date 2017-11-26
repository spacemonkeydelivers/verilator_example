#include <functional>
#include <cstdint>
#include <cassert>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include <Vmodel.h>

template<class Module, bool TraceOn = false>
class Testbench
{
public:
	typedef uint64_t Counter;
	static const unsigned LEVEL_HIGH = 1;
	static const unsigned LEVEL_LOW  = 0;

	Testbench(Counter num) : m_clockToRun(num)
	{
		m_core = new Module;
		assert(m_core && "Failed to instantiate verilated module");
		if (TraceOn)
		{
			Verilated::traceEverOn(true);
			TraceOpen("dump.vcd");
		}
		Reset();
	}

	virtual ~Testbench()
	{
		if (TraceOn)
		{
			TraceClose();
		}
		delete m_core;
		m_core = nullptr;
	}

	// Perform reset of a module
	virtual void Reset()
	{
		m_core->reset_i = LEVEL_HIGH;
		this->Tick();
		m_core->reset_i = LEVEL_LOW;
	}

	// Perform a single clock tick
	virtual void Tick()
	{
		// TODO: there is a magic for VCD dumps as ZipCPU did
		m_curClock++;
		m_core->clk_i = LEVEL_LOW;
		m_core->eval();
		if (TraceOn && m_trace)
		{
			m_trace->dump(10 * m_curClock - 2);
		}
		m_core->clk_i = LEVEL_HIGH;
		m_core->eval();
		if (TraceOn && m_trace)
		{
			m_trace->dump(10 * m_curClock);
		}
		m_core->clk_i = LEVEL_LOW;
		m_core->eval();
		if(TraceOn && m_trace)
		{
			m_trace->dump(10 * m_curClock + 5);
			m_trace->flush();
		}
	}

	virtual bool Run(std::function<bool(void)> callback)
	{
		while(!Done())
		{
			Tick();
		}
		bool result = callback();
		return result;
	}

	// Check if test is done
	virtual bool Done() const
	{
		return (m_clockToRun && (m_clockToRun <= m_curClock));
	}

private:
	void TraceOpen(const char* trace)
	{
		m_trace = new VerilatedVcdC;
		assert(m_trace && "Failed to instantiate VCD file");
		m_core->trace(m_trace, 99);
		m_trace->open(trace);
	}

	void TraceClose()
	{
		assert(m_trace && "Trace should be opened");
		m_trace->close();
		m_trace = nullptr;
	}

protected:
	Counter m_clockToRun = 0; ///< how many clocks design should run
	Counter m_curClock = 0;   ///< current clock number
	Module* m_core = nullptr; ///< module instance
	VerilatedVcdC *m_trace = nullptr; ///< struct for VCD dumps
};

// TODO: get parameters from verilated module
template <bool TraceOn>
class CounterTb : public Testbench<Vmodel, TraceOn>
{
	typedef Testbench<Vmodel, TraceOn> TB;
	using typename Testbench<Vmodel, TraceOn>::Counter;
public:
	CounterTb(Counter num) : TB(num) {}

	bool Check()
	{
		std::function<bool(void)> check = std::bind(&CounterTb::CheckFunc, this);
		return TB::Run(check);
	}

private:
	bool CheckFunc() const
	{
		return (true);
	}
};
