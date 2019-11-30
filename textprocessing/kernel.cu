
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <fstream>

int main()
{
	std::ifstream ifs("text.txt");
	std::string content((std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));

	std::cout << content;

	std::cin.ignore();
	return 0;
}
