#include <iostream>
#include "testbench.h"

int main(int argc, char **argv, char **env) 
{
	Verilated::commandArgs(argc, argv);
	CounterTb<true> tb(100000);
	std::cout << "Result is: " << tb.Check() << std::endl;
	return 0;
}
