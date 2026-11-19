# cuSignal Build Documentation

## 环境说明

| 组件 | 版本 |
|------|------|
| 操作系统 | Windows 10 (10.0.26200) |
| CUDA Toolkit | 13.2 |
| NVCC | 13.2.51 |
| NVIDIA Driver | 572.70 |
| GPU | RTX 4060 (sm_86) |
| Python | 3.10.11 |
| MSVC | 14.43.34808 |
| Windows SDK | 10.0.22621.0 |

## 项目结构

```
cusignal-branch-23.10/
├── cpp/
│   └── src/
│       ├── convolution/_convolution.cu
│       ├── filtering/
│       │   ├── _channelizer.cu
│       │   ├── _sosfilt.cu
│       │   └── _upfirdn.cu
│       ├── io/
│       │   ├── _reader.cu
│       │   └── _writer.cu
│       ├── peak_finding/_peak_finding.cu
│       └── spectral_analysis/_spectral.cu
├── python/
│   ├── setup.py
│   └── cusignal/
│       ├── convolution/
│       ├── filtering/
│       ├── io/
│       ├── peak_finding/
│       └── spectral_analysis/
└── README.md
```

## 编译步骤

### 1. CUDA 编译 (fatbin 生成)

CUDA 13.2 配合 MSVC 需要额外的编译参数:

```bash
# 编译参数说明:
# -std=c++17           : C++17 标准
# --expt-extended-lambda : 支持扩展 lambda
# --expt-relaxed-constexpr : 支持实验性 constexpr
# -gencode arch=compute_XX,code=sm_XX : 目标 GPU 架构
# -Xcompiler /Zc:preprocessor : 解决 CUDA 13.2 预处理问题
# -I <path> : Windows SDK include 路径

nvcc --fatbin ^ 
  -std=c++17 --expt-extended-lambda --expt-relaxed-constexpr ^
  -gencode arch=compute_80,code=sm_80 ^
  -gencode arch=compute_86,code=sm_86 ^
  -gencode arch=compute_89,code=sm_89 ^
  -gencode arch=compute_90,code=sm_90 ^
  -Xcompiler /Zc:preprocessor ^
  -I "D:\develop_tool\VS\Windows Kits\10\include\10.0.22621.0\ucrt" ^
  -I "D:\develop_tool\VS\Windows Kits\10\include\10.0.22621.0\um" ^
  -I "D:\develop_tool\VS\Windows Kits\10\include\10.0.22621.0\shared" ^
  <source>.cu -o <output>.fatbin
```

### 2. 已编译的 fatbin 文件

| 模块 | 文件 | 架构支持 |
|------|------|----------|
| convolution | convolution.fatbin | sm_80, sm_86, sm_89, sm_90 |
| filtering | _upfirdn.fatbin | sm_80, sm_86, sm_89, sm_90 |
| filtering | _sosfilt.fatbin | sm_80, sm_86, sm_89, sm_90 |
| filtering | _channelizer.fatbin | sm_80, sm_86, sm_89, sm_90 |
| io | _reader.fatbin | sm_80, sm_86, sm_89, sm_90 |
| io | _writer.fatbin | sm_80, sm_86, sm_89, sm_90 |
| peak_finding | _peak_finding.fatbin | sm_80, sm_86, sm_89, sm_90 |
| spectral_analysis | _spectral.fatbin | sm_80, sm_86, sm_89, sm_90 |

### 3. Python 环境配置

#### 依赖安装

```bash
# 安装 cusignal (开发模式)
cd python
python setup.py develop

# 安装额外依赖 (CUDA 13)
pip install cupy-cuda13x
pip install cuda-python
pip install cuda-bindings
pip install cuda-pathfinder
pip install numpy>=2.0
```

#### 依赖版本

| 包 | 版本 |
|----|------|
| numpy | >= 2.0 |
| cupy-cuda13x | 14.0.1 |
| cuda-python | 13.2.0 |
| cuda-bindings | 13.2.0 |
| cuda-pathfinder | 1.5.2 |
| numba | 0.65.0 |
| llvmlite | 0.47.0 |

### 4. 安装验证

```bash
python -c "import cusignal; print('cusignal imported successfully')"
```

输出:
```
cusignal imported successfully
```

## 注意事项

### CUDA 13.2 编译问题

1. **C1083: 无法打开核心头文件**
   - 原因: MSVC 找不到 Windows SDK 头文件
   - 解决: 使用 `-I` 参数显式指定 Windows SDK 路径

2. **C1189: 传统预处理器错误**
   - 原因: CUDA 13.2 需要符合标准的预处理器
   - 解决: 添加 `-Xcompiler /Zc:preprocessor`

3. **C4819: Unicode 警告**
   - 原因: CUDA 头文件包含非 ASCII 字符
   - 影响: 仅警告，不影响编译

### GPU 驱动兼容性

- 当前驱动 (572.70) 支持 CUDA 12.8
- cupy-cuda13x 需要 CUDA 13 运行时
- 实际运行需要更新驱动或使用 cupy-cuda12x

## 运行测试

### 环境验证

```python
import cusignal
import numpy as np
import cupy as cp

# 模块导入测试
print(cusignal.__version__)
```

### GPU 测试 (需要匹配的驱动)

```python
import cusignal
import numpy as np
import cupy as cp

# 将数据移到 GPU
sig = cp.array([1, 2, 3])
kernel = cp.array([1, 1])
result = cusignal.convolve(sig, kernel)
print(result)
```

## 项目模块

| 模块 | 功能 |
|------|------|
| convolution | 卷积操作 (convolve, correlate) |
| filtering | 滤波 (lfilter, sosfilt, upfirdn, firwin) |
| io | 文件读写 (read, write) |
| peak_finding | 峰值检测 (find_peaks) |
| spectral_analysis | 频谱分析 (spectrum, spectrogram) |

## 编译命令汇总

```bash
# 批量编译所有 CUDA 源文件
for file in _convolution _sosfilt _channelizer _upfirdn _reader _writer _peak_finding _spectral; do
  nvcc --fatbin -std=c++17 --expt-extended-lambda --expt-relaxed-constexpr \
    -gencode arch=compute_80,code=sm_80 \
    -gencode arch=compute_86,code=sm_86 \
    -gencode arch=compute_89,code=sm_89 \
    -gencode arch=compute_90,code=sm_90 \
    -Xcompiler /Zc:preprocessor \
    -I "D:\develop_tool\VS\Windows Kits\10\include\10.0.22621.0\ucrt" \
    -I "D:\develop_tool\VS\Windows Kits\10\include\10.0.22621.0\um" \
    -I "D:\develop_tool\VS\Windows Kits\10\include\10.0.22621.0\shared" \
    "cpp\src\${file}.cu" -o "python\cusignal\${file}.fatbin"
done
```

## 故障排除

| 问题 | 解决方案 |
|------|----------|
| `ModuleNotFoundError: No module named 'cupy'` | `pip install cupy-cuda13x` |
| `ModuleNotFoundError: No module named 'cuda'` | `pip install cuda-python` |
| `ImportError: DLL load failed while importing cublas` | 切换到匹配的 cupy-cuda 版本 |
| `cudaErrorInsufficientDriver` | 更新 NVIDIA 驱动或使用兼容的 cupy 版本 |

## 许可证

Copyright (c) 2019-2023 NVIDIA CORPORATION & AFFILIATES. All rights reserved.

MIT License - 详见项目 LICENSE 文件