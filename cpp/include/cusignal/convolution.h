#ifndef CUSIGNAL_CONVOLUTION_H
#define CUSIGNAL_CONVOLUTION_H

#include <cstddef>
#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

void convolve_int32(const int32_t* input, int32_t input_size,
                    const int32_t* kernel, int32_t kernel_size,
                    int32_t mode, bool swapped_inputs,
                    int32_t* output, int32_t output_size);

void convolve_int64(const int64_t* input, int32_t input_size,
                    const int64_t* kernel, int32_t kernel_size,
                    int32_t mode, bool swapped_inputs,
                    int64_t* output, int32_t output_size);

void convolve_float32(const float* input, int32_t input_size,
                      const float* kernel, int32_t kernel_size,
                      int32_t mode, bool swapped_inputs,
                      float* output, int32_t output_size);

void convolve_float64(const double* input, int32_t input_size,
                      const double* kernel, int32_t kernel_size,
                      int32_t mode, bool swapped_inputs,
                      double* output, int32_t output_size);

void convolve2d_int32(const int32_t* input, int32_t input_width, int32_t input_height,
                      const int32_t* kernel, int32_t kernel_width, int32_t kernel_height,
                      int32_t S0, int32_t S1,
                      int32_t* output, int32_t output_width, int32_t output_height,
                      int32_t pick);

void convolve2d_float32(const float* input, int32_t input_width, int32_t input_height,
                        const float* kernel, int32_t kernel_width, int32_t kernel_height,
                        int32_t S0, int32_t S1,
                        float* output, int32_t output_width, int32_t output_height,
                        int32_t pick);

void correlate_int32(const int32_t* input, int32_t input_size,
                     const int32_t* kernel, int32_t kernel_size,
                     int32_t mode, bool swapped_inputs,
                     int32_t* output, int32_t output_size);

void correlate_float32(const float* input, int32_t input_size,
                       const float* kernel, int32_t kernel_size,
                       int32_t mode, bool swapped_inputs,
                       float* output, int32_t output_size);

#ifdef __cplusplus
}
#endif

#endif