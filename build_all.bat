@echo off
call "D:\develop_tool\VS\VC\Auxiliary\Build\vcvarsall.bat" x64

set INCLUDE=D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0\ucrt;%INCLUDE%

cd /d D:\cusignal-branch-23.10\cusignal-branch-23.10

echo Building Convolution kernels...
REM Note: convolution uses thrust/complex.h which has MSVC compatibility issues
REM The .cu file includes crt/host_config.h which requires additional MSVC paths
if not exist python\cusignal\convolution mkdir python\cusignal\convolution
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\convolution\_convolution.cu -o python\cusignal\convolution\_convolution.fatbin 2>nul || echo [SKIPPED] Convolution compilation failed - thrust compatibility issue

echo Building Filtering kernels (upfirdn)...
REM Note: upfirdn uses thrust/complex.h
if not exist python\cusignal\filtering mkdir python\cusignal\filtering
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_upfirdn.cu -o python\cusignal\filtering\_upfirdn.fatbin 2>nul || echo [SKIPPED] upfirdn compilation failed

echo Building Filtering kernels (sosfilt)...
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_sosfilt.cu -o python\cusignal\filtering\_sosfilt.fatbin 2>nul || echo [ERROR] sosfilt failed

echo Building Filtering kernels (channelizer)...
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_channelizer.cu -o python\cusignal\filtering\_channelizer.fatbin 2>nul || echo [ERROR] channelizer failed

echo Building IO kernels (reader)...
REM Note: reader uses thrust/complex.h
if not exist python\cusignal\io mkdir python\cusignal\io
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\io\_reader.cu -o python\cusignal\io\_reader.fatbin 2>nul || echo [SKIPPED] reader compilation failed

echo Building IO kernels (writer)...
REM Note: writer uses thrust/complex.h
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\io\_writer.cu -o python\cusignal\io\_writer.fatbin 2>nul || echo [SKIPPED] writer compilation failed

echo Building Peak Finding kernels...
if not exist python\cusignal\peak_finding mkdir python\cusignal\peak_finding
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\peak_finding\_peak_finding.cu -o python\cusignal\peak_finding\_peak_finding.fatbin 2>nul || echo [ERROR] peak_finding failed

echo Building Spectral kernels...
if not exist python\cusignal\spectral_analysis mkdir python\cusignal\spectral_analysis
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\spectral_analysis\_spectral.cu -o python\cusignal\spectral_analysis\_spectral.fatbin 2>nul || echo [ERROR] spectral failed

echo.
echo ========================================
echo Build Summary:
echo ========================================
dir /s python\cusignal\*.fatbin 2>nul | findstr /i "fatbin"

echo.
echo All kernels build attempt completed!
pause