
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <cctype>
#include <ctime>

#define N 8000000
#define M 26

//__device__ std::string d_content;
//__device__ int d_result[26];
//__device__ int d_content_length;

int content_length;

__device__ char d_content[N];
__device__ char d_abc[M];
__device__ int d_result[M];

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

int main()
{
	std::string abcString = "abcdefghijklmnopqrstuvwxyz";
	int h_result[M];

	for (int i = 0; i < M; i++)
	{
		h_result[i] = 0;
	}
	
	std::ifstream ifs("text.txt");
	std::string content((std::istreambuf_iterator<char>(ifs)), (std::istreambuf_iterator<char>()));
	std::transform(content.begin(), content.end(), content.begin(), [](unsigned char c) { return std::tolower(c); });
	
	content_length = content.size();

	clock_t begin = clock();

	//CPU solution
	for (int i = 0; i < content_length; i++)
	{
		if ('a' <= content[i] && content[i] <= 'z')
		{
			for (int j = 0; j < M; j++)
			{
				if (content[i] == abcString[j])
				{
					h_result[j]++;
				}
			}
		}
	}

	clock_t end = clock();
	double elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;

	std::cout << "CPU result: " << elapsed_secs << std::endl;
	for (int i = 0; i < 26; i++)
	{
		std::cout << abcString[i] << ": " << h_result[i] << std::endl;
	}

	//h_result[M];

	//GPU solution

	begin = clock();

	cudaMemcpyToSymbol(d_content, &content, N, sizeof(char) * N);
	cudaMemcpyToSymbol(d_abc, &abcString, M, sizeof(char) * M);
	cudaMemcpyToSymbol(d_result, h_result, M, sizeof(int) * M);

	int block_size = N / 512;
	int temp = block_size * 512;

	if (N - temp != 0)
	{
		block_size++;
	}

	gpu_solution <<<block_size, 512 >>> ();

	cudaMemcpyFromSymbol(&content, d_content, N, sizeof(char) * N);
	cudaMemcpyFromSymbol(&abcString, d_abc, M, sizeof(char) * M);
	cudaMemcpyFromSymbol(h_result, d_result, M, sizeof(int) * M);
	cudaDeviceSynchronize();

	end = clock();
	elapsed_secs = double(end - begin) / CLOCKS_PER_SEC;

	std::cout << "GPU result: " << elapsed_secs << std::endl;
	for (int i = 0; i < 26; i++)
	{
		std::cout << abcString[i] << ": " << h_result[i] << std::endl;
	}

	std::cin.ignore();
	return 0;
}
