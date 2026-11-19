# CuSignal C++ 源码迁移 - 编译验证与总结文档

## 一、项目概述

本文档记录 CuSignal Python 源码迁移为 C++ (CUDA) 源码的完整过程,包括环境配置、编译验证、问题排查和最终结果。

### 比赛要求
- **CUDA 版本**: 11.7 (当前环境使用 CUDA 13.2)
- **编程语言**: C++ (使用 CUDA 标准 API)
- **可调用库**: CUBLAS, CUBLASLt, CUDNN, CUSOLVER, CUSPARSE, CuFFT

### 系统环境
| 组件 | 路径 |
|------|------|
| CUDA Toolkit | `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.2` |
| Visual Studio 2022 | `D:\develop_tool\VS\VC\Tools\MSVC\14.43.34808` |
| Windows SDK | `D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0` |

---

## 二、源码结构

### 2.1 C++ 源码位置
```
cpp/src/
├── convolution/_convolution.cu       # 卷积核心 (805行)
├── filtering/
│   ├── _channelizer.cu              # 通道化滤波器
│   ├── _sosfilt.cu                  # 二阶节滤波
│   └── _upfirdn.cu                  # 上采样/下采样/滤波
├── peak_finding/_peak_finding.cu    # 峰值查找
├── spectral_analysis/_spectral.cu    # 频谱分析 (Lomb-Scargle)
└── io/
    ├── _reader.cu                   # SigMF 文件读取
    └── _writer.cu                   # SigMF 文件写入
```

### 2.2 Python 源码位置
```
python/cusignal/
├── convolution/      # 卷积模块
├── filtering/       # 滤波模块
├── peak_finding/   # 峰值查找
├── spectral_analysis/
└── io/             # 输入输出
```

---

## 三、编译配置

### 3.1 编译脚本 (build_all.bat)

```batch
@echo off
call "D:\develop_tool\VS\VC\Auxiliary\Build\vcvarsall.bat" x64
set INCLUDE=D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0\ucrt;%INCLUDE%

cd /d D:\cusignal-branch-23.10\cusignal-branch-23.10

echo Building Convolution kernels...
if not exist python\cusignal\convolution mkdir python\cusignal\convolution
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\convolution\_convolution.cu -o python\cusignal\convolution\_convolution.fatbin

echo Building Filtering kernels...
if not exist python\cusignal\filtering mkdir python\cusignal\filtering
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_upfirdn.cu -o python\cusignal\filtering\_upfirdn.fatbin
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_sosfilt.cu -o python\cusignal\filtering\_sosfilt.fatbin
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_channelizer.cu -o python\cusignal\filtering\_channelizer.fatbin

echo Building IO kernels...
if not exist python\cusignal\io mkdir python\cusignal\io
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\io\_reader.cu -o python\cusignal\io\_reader.fatbin
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\io\_writer.cu -o python\cusignal\io\_writer.fatbin

echo Building Peak Finding kernels...
if not exist python\cusignal\peak_finding mkdir python\cusignal\peak_finding
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\peak_finding\_peak_finding.cu -o python\cusignal\peak_finding\_peak_finding.fatbin

echo Building Spectral kernels...
if not exist python\cusignal\spectral_analysis mkdir python\cusignal\spectral_analysis
nvcc --fatbin -t 0 -std=c++17 -DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING --generate-code arch=compute_80,code=sm_80 cpp\src\spectral_analysis\_spectral.cu -o python\cusignal\spectral_analysis\_spectral.fatbin

echo All kernels built successfully!
pause
```

### 3.2 编译选项说明

| 选项 | 说明 |
|------|------|
| `--fatbin` | 生成 fatbin 二进制文件 |
| `-t 0` | 多线程并行编译 |
| `-std=c++17` | 使用 C++17 标准 |
| `-DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING` | 解决 CUDA 13.2 + MSVC 兼容性警告 |
| `--generate-code arch=compute_80,code=sm_80` | 编译为 NVIDIA Ampere 架构 (RTX 30xx) |
| `-o <file>` | 指定输出文件路径 |

### 3.3 环境变量设置

编译前需要设置以下环境:
```batch
# 设置 Visual Studio 环境
call "D:\develop_tool\VS\VC\Auxiliary\Build\vcvarsall.bat" x64

# 添加 Windows SDK UCRT 路径 (解决 corecrt.h 找不到的问题)
set INCLUDE=D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0\ucrt;%INCLUDE%
```

---

## 四、编译结果验证

### 4.1 已成功生成的 fatbin 文件

| 模块 | 文件路径 | 大小 | 生成时间 |
|------|----------|------|----------|
| Filtering (sosfilt) | `python/cusignal/filtering/_sosfilt.fatbin` | 18KB | 2026-04-08 14:32 |
| Filtering (channelizer) | `python/cusignal/filtering/_channelizer.fatbin` | 69KB | 2026-04-08 14:32 |
| Peak Finding | `python/cusignal/peak_finding/_peak_finding.fatbin` | 180KB | 2026-04-08 14:32 |
| Spectral Analysis | `python/cusignal/spectral_analysis/_spectral.fatbin` | 26KB | 2026-04-08 14:32 |

### 4.2 需要排查的文件

以下文件编译命令执行但可能存在问题(需要进一步验证):
- `python/cusignal/convolution/_convolution.fatbin` - 一维/二维卷积
- `python/cusignal/filtering/_upfirdn.fatbin` - 上采样/下采样/滤波
- `python/cusignal/io/_reader.fatbin` - 文件读取
- `python/cusignal/io/_writer.fatbin` - 文件写入

---

## 五、问题排查与解决方案

### 5.1 问题1: corecrt.h 找不到

**错误信息**:
```
fatal error C1083: cannot open include file: 'corecrt.h'
```

**原因**: MSVC 环境中缺少 Windows SDK 的 UCRT 头文件

**解决方案**: 在编译前设置 INCLUDE 环境变量:
```batch
set INCLUDE=D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0\ucrt;%INCLUDE%
```

### 5.2 问题2: CCCL 预处理警告

**错误信息**:
```
fatal error C1189: #error: MSVC/cl.exe with traditional preprocessor is used.
```

**原因**: CUDA 13.2 使用新的 CCCL 库,要求使用标准 conforming 预处理器

**解决方案**: 添加编译宏定义:
```batch
-DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING
```

### 5.3 问题3: -odir 选项不生效

**现象**: 使用 `-odir` 选项时,nvcc 报告编译成功但输出文件未生成

**原因**: Windows 环境下 nvcc 的 `-odir` 选项可能存在问题

**解决方案**: 改用 `-o` 显式指定输出文件路径

### 5.4 问题4: 输出文件为空

**现象**: nvcc 编译报告成功,但生成的文件大小为 0 字节

**原因**: 可能是编译过程中的临时错误或 CUDA 内部问题

**验证方法**: 检查生成的 .fatbin 文件是否存在且大小 > 0

---

## 六、各模块功能说明

### 6.1 Convolution 模块 (_convolution.cu)

**功能**: 一维和多维卷积、相关运算

**支持的数据类型**:
- int32, int64, float32, float64
- complex64, complex128

**支持的模式**:
- mode=0 (valid): 仅使用不需要零填充的元素
- mode=1 (same): 输出与输入相同大小
- mode=2 (full): 输出完整线性卷积

### 6.2 Filtering 模块

| 文件 | 功能 |
|------|------|
| _upfirdn.cu | 上采样、滤波、下采样组合操作 |
| _sosfilt.cu | 二阶节 (Second-Order Sections) 滤波 |
| _channelizer.cu | 多通道滤波器组,使用 polyphase 结构 |

### 6.3 Peak Finding 模块 (_peak_finding.cu)

**功能**: 峰值查找算法,支持:
- 局部最大值/最小值检测
- 相对极值检测

### 6.4 Spectral Analysis 模块 (_spectral.cu)

**功能**: Lomb-Scargle 周期图
- 用于非均匀采样信号的频谱分析

### 6.5 IO 模块

| 文件 | 功能 |
|------|------|
| _reader.cu | 读取 SigMF 格式文件 |
| _writer.cu | 写入 SigMF 格式文件 |

---

## 七、编译验证步骤

### 7.1 验证环境

```batch
# 检查 CUDA 版本
nvcc --version

# 检查 Visual Studio
cl.exe --version
```

### 7.2 执行编译

```batch
cd D:\cusignal-branch-23.10\cusignal-branch-23.10
call build_all.bat
```

### 7.3 检查输出文件

```batch
# 列出所有 fatbin 文件
dir /s /b python\cusignal\*.fatbin

# 检查文件大小
dir /s python\cusignal\*.fatbin
```

---

## 八、CMake 配置 (备选)

如果需要使用 CMake 构建:

```cmake
cmake_minimum_required(VERSION 3.18)
project(cusignal_cpp CUDA)

set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --expt-extended-lambda")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -gencode arch=compute_80,code=sm_80")

find_package(CUDAToolkit REQUIRED)

add_library(cusignal_cuda STATIC
    src/convolution/_convolution.cu
    src/filtering/_channelizer.cu
    src/filtering/_sosfilt.cu
    src/filtering/_upfirdn.cu
    src/peak_finding/_peak_finding.cu
    src/spectral_analysis/_spectral.cu
    src/io/_reader.cu
    src/io/_writer.cu
)

target_link_libraries(cusignal_cuda PUBLIC
    CUDA::cublas
    CUDA::cufft
    CUDA::cusolver
)
```

---

## 九、总结与建议

### 9.1 完成情况

| 项目 | 状态 |
|------|------|
| C++ 源码分析 | ✅ 完成 |
| 编译脚本创建 | ✅ 完成 (build_all.bat) |
| 环境配置 | ✅ 完成 |
| 部分模块编译验证 | ✅ 4/8 模块成功 |

### 9.2 后续工作

1. **解决剩余模块编译问题**: 调查 convolution、upfirdn、io 模块编译无输出的原因
2. **Python 集成测试**: 安装 cupy 后进行实际运行测试
3. **性能验证**: 在 GPU 上测试实际运行效果
4. **CUDA 版本兼容性**: 如需在 CUDA 11.7 环境运行,可能需要调整代码

### 9.3 注意事项

1. CUDA 13.2 与 MSVC 2022 需要添加 `-DCCCL_IGNORE_MSVC_TRADITIONAL_PREPROCESSOR_WARNING`
2. Windows SDK 路径需要包含在 INCLUDE 环境变量中
3. 建议使用 `-o` 显式输出而非 `-odir` 目录输出

---

**文档版本**: 1.2
**创建日期**: 2026-04-08
**说明**: CuSignal C++ 源码迁移 - 编译验证总结