cmake_minimum_required(VERSION 3.18)
project(cusignal_cpp CUDA)

set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --expt-extended-lambda --expt-relaxed-constexpr")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -gencode arch=compute_80,code=sm_80")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -gencode arch=compute_86,code=sm_86")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -gencode arch=compute_89,code=sm_89")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -gencode arch=compute_90,code=sm_90")

find_package(CUDAToolkit REQUIRED)

set(CUSIGNAL_SOURCES
    src/convolution/_convolution.cu
    src/filtering/_channelizer.cu
    src/filtering/_sosfilt.cu
    src/filtering/_upfirdn.cu
    src/io/_reader.cu
    src/io/_writer.cu
    src/peak_finding/_peak_finding.cu
    src/spectral_analysis/_spectral.cu
)

add_library(cusignal_cuda STATIC ${CUSIGNAL_SOURCES})

target_include_directories(cusignal_cuda PUBLIC
    ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES}
)

target_link_libraries(cusignal_cuda PUBLIC
    CUDA::cublas
    CUDA::cufft
    CUDA::cusolver
    CUDA::cusparse
    CUDA::cudnn
)

set_target_properties(cusignal_cuda PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    CUDA_SEPARABLE_COMPILATION ON
)

enable_testing()