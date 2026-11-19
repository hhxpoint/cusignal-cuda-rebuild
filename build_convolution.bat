@echo off
call "D:\develop_tool\VS\VC\Auxiliary\Build\vcvarsall.bat" x64

set INCLUDE=D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0\ucrt;%INCLUDE%

cd /d D:\cusignal-branch-23.10\cusignal-branch-23.10

nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\convolution\_convolution.cu -odir python\cusignal\convolution\

echo Done
pause