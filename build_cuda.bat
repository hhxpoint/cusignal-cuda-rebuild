@echo off
call "D:\develop_tool\VS\Common7\Tools\VsDevCmd.bat" -host_arch=amd64 -arch=x64

echo Building convolution kernel...
nvcc --fatbin -std=c++17 --expt-extended-lambda --expt-relaxed-constexpr -gencode arch=compute_80,code=sm_80 -gencode arch=compute_86,code=sm_86 -gencode arch=compute_89,code=sm_89 -gencode arch=compute_90,code=sm_90 "D:\cusignal-branch-23.10\cusignal-branch-23.10\cpp\src\convolution\_convolution.cu" -o "D:\cusignal-branch-23.10\cusignal-branch-23.10\python\cusignal\convolution\convolution.fatbin"