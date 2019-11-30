
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <cctype>

//__device__ std::string d_content;
//__device__ int d_result[26];
//__device__ int d_content_length;

int content_length;

int main()
{
	std::string abcString = "abcdefghijklmnopqrstuvwxyz";
	int h_result[26];

	for (int i = 0; i < 26; i++)
	{
		h_result[i] = 0;
	}
	
	std::ifstream ifs("text.txt");
	std::string content((std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));
	std::transform(content.begin(), content.end(), content.begin(), [](unsigned char c) { return std::tolower(c); });
	
	content_length = content.size();

	//CPU solution
	for (int i = 0; i < content_length; i++)
	{
		if ('a' <= content[i] && content[i] <= 'z')
		{
			for (int j = 0; j < 26; j++)
			{
				if (content[i] == abcString[j])
				{
					h_result[j]++;
				}
			}
		}
	}

	std::cout << "CPU result:" << std::endl;
	for (int i = 0; i < 26; i++)
	{
		std::cout << abcString[i] << ": " << h_result[i] << std::endl;
	}

	std::cin.ignore();
	return 0;
}

__device__ char d_content[8000000];
__device__ char d_abc[26];
__device__ int d_result[26];

__global__ void gpu_solution() {
	int i = threadIdx.x * blockIdx.x;

	if ('a' <= d_content[i] && d_content[i] <= 'z')
	{
		for (int j = 0; j < 26; j++)
		{
			if (d_abc[j] == d_content[i])
			{
				d_result[j]++;
			}
		}
	}
}
