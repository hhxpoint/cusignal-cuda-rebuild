#include <iostream>
#include <cuda_runtime.h>

__global__ void helloKernel() {
    printf("Hello from GPU!\n");
}

int main() {
    std::cout << "Testing CUDA compilation..." << std::endl;
    
    int deviceCount = 0;
    cudaError_t error = cudaGetDeviceCount(&deviceCount);
    
    if (error != cudaSuccess) {
        std::cout << "CUDA error: " << cudaGetErrorString(error) << std::endl;
        return 1;
    }
    
    std::cout << "Found " << deviceCount << " CUDA device(s)" << std::endl;
    
    for (int i = 0; i < deviceCount; i++) {
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, i);
        std::cout << "Device " << i << ": " << prop.name << std::endl;
        std::cout << "  Compute Capability: " << prop.major << "." << prop.minor << std::endl;
        std::cout << "  Total Global Memory: " << prop.totalGlobalMem / 1024.0 / 1024.0 / 1024.0 << " GB" << std::endl;
    }
    
    return 0;
}