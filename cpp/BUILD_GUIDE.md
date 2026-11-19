# CuSignal C++ 源码迁移文档

## 一、概述

本文档描述将 CuSignal Python 源码迁移为 C++ 源码的过程。CuSignal 是 NVIDIA 的 GPU 加速信号处理库,本阶段主要工作是将 Python 源码迁为 C++ 源码。

### 开发环境要求
- CUDA 版本: 11.7 (当前系统使用 CUDA 13.2)
- 编译器: 支持 CUDA 的 C++ 编译器 (Visual Studio + NVCC)
- 可调用的标准库: CUBLAS, CUBLASLt, CUDNN, CUSOLVER, CUSPARSE, CuFFT

### 系统环境
- CUDA 安装路径: `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.2`
- Visual Studio 2022: `D:\develop_tool\VS\VC\Tools\MSVC\14.43.34808`
- Windows SDK: `D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0`

---

## 二、源码目录结构

### C++ 源码结构 (cpp/src/)
```
cpp/src/
├── convolution/
│   └── _convolution.cu        # 一维/二维卷积、相关运算 (805行)
├── filtering/
│   ├── _channelizer.cu       # 通道化滤波器
│   ├── _sosfilt.cu           # 二阶节滤波
│   └── _upfirdn.cu           # 上采样/下采样/滤波
├── peak_finding/
│   └── _peak_finding.cu     # 峰值查找
├── spectral_analysis/
│   └── _spectral.cu          # 频谱分析 (Lomb-Scargle)
└── io/
    ├── _reader.cu            # 读文件 (SigMF格式)
    └── _writer.cu           # 写文件
```

---

## 三、已实现的 C++ 模块

### 1. Convolution 模块 (_convolution.cu)

**功能**: 一维和多维卷积、相关运算

#### 1.1 一维卷积 (Convolve 1D)
```cpp
template<typename T>
__device__ void _cupy_convolve(const T* inp, int inpW, const T* kernel, 
                               int kerW, int mode, bool swapped_inputs,
                               T* out, int outW);
```

支持的模式:
- **mode=0 (valid)**: 仅使用不需要零填充的元素
- **mode=1 (same)**: 输出与输入相同大小
- **mode=2 (full)**: 输出完整线性卷积

支持的数据类型:
- `int32`, `int64`, `float32`, `float64`
- `complex64`, `complex128`

#### 1.2 二维卷积 (Convolve 2D)
```cpp
template<typename T>
__device__ void _cupy_convolve2D(const T* inp, int inpW, int inpH,
                                  const T* kernel, int kerW, int kerH,
                                  int S0, int S1, T* out, 
                                  int outW, int outH, int pick);
```

支持的边界条件:
- **pick=1**: 奇数大小核
- **pick=2**: 偶数大小核
- **pick=3**: 非方形核

#### 1.3 二阶和三阶卷积 (Convolve 1D2O / 1D3O)
用于二阶和三阶滤波器实现。

---

### 2. Filtering 模块

#### 2.1 Channelizer (_channelizer.cu)
多通道滤波器组实现,使用 polyphase 滤波器结构。

#### 2.2 SOS Filter (_sosfilt.cu)
二阶节 (Second-Order Sections) 滤波器实现。

#### 2.3 UPFiRDN (_upfirdn.cu)
上采样、滤波、下采样组合操作。

---

### 3. Peak Finding 模块 (_peak_finding.cu)
峰值查找算法,支持:
- 局部最大值/最小值
- 相对极值检测

---

### 4. Spectral Analysis 模块 (_spectral.cu)
#### Lomb-Scargle 周期图
用于非均匀采样信号的频谱分析。

---

### 5. IO 模块
#### 5.1 Reader (_reader.cu)
读取 SigMF 格式文件。

#### 5.2 Writer (_writer.cu)
写入 SigMF 格式文件。

---

## 四、编译说明

### 4.1 环境要求

1. **CUDA Toolkit**: 已安装 CUDA 13.2 (路径: `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.2`)
2. **Visual Studio 2022**: 已安装 MSVC 14.43.34808
3. **Windows SDK**: `D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0`

### 4.2 编译步骤

#### 使用批处理脚本编译

```batch
cd D:\cusignal-branch-23.10\cusignal-branch-23.10
call build_all.bat
```

**build_all.bat 内容**:

```batch
@echo off
call "D:\develop_tool\VS\VC\Auxiliary\Build\vcvarsall.bat" x64
set INCLUDE=D:\develop_tool\VS\Windows Kits\10\Include\10.0.22621.0\ucrt;%INCLUDE%
cd /d D:\cusignal-branch-23.10\cusignal-branch-23.10

echo Building Convolution kernels...
if not exist python\cusignal\convolution mkdir python\cusignal\convolution
nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\convolution\_convolution.cu -odir python\cusignal\convolution\

echo Building Filtering kernels...
if not exist python\cusignal\filtering mkdir python\cusignal\filtering
nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_upfirdn.cu -odir python\cusignal\filtering\
nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_sosfilt.cu -odir python\cusignal\filtering\
nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\filtering\_channelizer.cu -odir python\cusignal\filtering\

echo Building IO kernels...
if not exist python\cusignal\io mkdir python\cusignal\io
nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\io\_reader.cu -odir python\cusignal\io\
nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\io\_writer.cu -odir python\cusignal\io\

echo Building Peak Finding kernels...
if not exist python\cusignal\peak_finding mkdir python\cusignal\peak_finding
nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\peak_finding\_peak_finding.cu -odir python\cusignal\peak_finding\

echo Building Spectral kernels...
if not exist python\cusignal\spectral_analysis mkdir python\cusignal\spectral_analysis
nvcc --fatbin -t 0 -std=c++17 --generate-code arch=compute_80,code=sm_80 cpp\src\spectral_analysis\_spectral.cu -odir python\cusignal\spectral_analysis\

echo All kernels built successfully!
pause
```

#### 编译选项说明

| 选项 | 说明 |
|------|------|
| `--fatbin` | 生成 fatbin 文件 |
| `-t 0` | 多线程编译 |
| `-std=c++17` | 使用 C++17 标准 |
| `--generate-code arch=compute_80,code=sm_80` | 针对 NVIDIA Ampere 架构 |
| `-odir <path>` | 指定输出目录 |

#### 支持的 GPU 架构

代码配置为支持以下 compute capability:
- `sm_80`: NVIDIA Ampere (RTX 30xx, A100)
- `sm_86`: NVIDIA Turing (RTX 20xx)
- `sm_89`: NVIDIA Ada Lovelace (RTX 40xx)
- `sm_90`: NVIDIA Hopper (H100)

---

## 五、编译结果

### 生成的 .fatbin 文件

编译成功后,会在 `python/cusignal/` 目录下生成以下文件:

| 模块 | 文件位置 |
|------|----------|
| Convolution | `python/cusignal/convolution/_convolution.fatbin` |
| Filtering (upfirdn) | `python/cusignal/filtering/_upfirdn.fatbin` |
| Filtering (sosfilt) | `python/cusignal/filtering/_sosfilt.fatbin` |
| Filtering (channelizer) | `python/cusignal/filtering/_channelizer.fatbin` |
| IO (reader) | `python/cusignal/io/_reader.fatbin` |
| IO (writer) | `python/cusignal/io/_writer.fatbin` |
| Peak Finding | `python/cusignal/peak_finding/_peak_finding.fatbin` |
| Spectral Analysis | `python/cusignal/spectral_analysis/_spectral.fatbin` |

---

## 六、Python 调用接口

C++ 代码编译后,通过以下方式与 Python 集成:

### CuSignal 原有架构

CuSignal 使用以下架构:
1. Python 调用 `_xxx_cuda.py`
2. Python 加载编译好的 `.fatbin` 文件
3. 通过 cupy 的 CUDA 内核调用 C++ 函数

### 示例调用流程

```python
# convolution 模块
from cusignal.convolution import _convolution_cuda
# 调用时会自动加载 _convolution.fatbin

# filtering 模块
from cusignal.filtering import _sosfilt_cuda
# 调用时会自动加载 _sosfilt.fatbin
```

---

## 七、注意事项

### 7.1 环境问题

确保以下环境变量正确设置:
- `CUDA_PATH`: `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.2`
- `INCLUDE` 包含 Windows SDK 路径

### 7.2 CUDA 版本

比赛要求 CUDA 11.7,当前系统使用 CUDA 13.2。代码使用 CUDA 13.2 编译时:
- 需要确保 GPU 驱动支持 CUDA 13.2
- 兼容 CUDA 11.7 编译的代码可能需要调整

### 7.3 性能优化建议

1. 使用共享内存优化频繁访问的数据
2. 调整 `__launch_bounds__` 参数优化寄存器使用
3. 使用 `cuBLAS`、`cuFFT` 等库函数替代手动实现

---

## 八、文件清单

### 脚本文件
- `build_all.bat` - 编译所有 CUDA 源码为 fatbin 文件

### C++ 源文件
- `cpp/src/convolution/_convolution.cu` - 卷积核心实现
- `cpp/src/filtering/_channelizer.cu` - 通道化滤波器
- `cpp/src/filtering/_sosfilt.cu` - 二阶节滤波
- `cpp/src/filtering/_upfirdn.cu` - 上采样/下采样
- `cpp/src/peak_finding/_peak_finding.cu` - 峰值查找
- `cpp/src/spectral_analysis/_spectral.cu` - 频谱分析
- `cpp/src/io/_reader.cu` - 文件读取
- `cpp/src/io/_writer.cu` - 文件写入

### 其他文件
- `cpp/CMakeLists.txt` - CMake 构建配置
- `cpp/include/cusignal/convolution.h` - 卷积模块头文件
- `cpp/BUILD_GUIDE.md` - 构建指南 (本文件)

---

## 九、验证测试

编译完成后可运行以下 Python 测试:

```python
import cusignal
import cupy as cp

# 测试卷积
sig = cp.random.randn(1000)
kernel = cp.random.randn(50)
result = cusignal.convolve(sig, kernel, mode='valid')
print("Convolution test passed!")

# 测试峰值查找
data = cp.array([1, 3, 2, 5, 4])
peaks = cusignal.find_peaks(data)
print("Peak finding test passed!")
```

---

**文档版本**: 1.1
**创建日期**: 2026-04-08
**说明**: CuSignal C++ 源码迁移 - 代码开发阶段 (初赛)