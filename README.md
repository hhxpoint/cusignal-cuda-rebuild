# cuSignal CUDA rebuild (C++ port)

> 基于 **NVIDIA cuSignal**（Apache-2.0）的 CUDA / C++ 重构实验。  
> 上游：<https://github.com/rapidsai/cusignal>（branch 23.10）  
> 本仓库由 **hhxpoint** 整理/修改：C++ 侧构建、CUDA 编译脚本、构建验证文档与本地重建步骤。

![CUDA](https://img.shields.io/badge/CUDA-12.x-76B900?logo=nvidia&logoColor=white)
![C++](https://img.shields.io/badge/C++-17-00599C?logo=cplusplus)
![License](https://img.shields.io/badge/License-Apache--2.0-blue)

---

## 说明

cuSignal 是 RAPIDS 生态的 GPU 信号处理库。本仓库是其在 **23.10** 分支上的本地重建版本，重点：

- CUDA / C++ 构建脚本（`build_cuda.bat`、`build_all.bat`、`build.sh`）
- C++ 源码（`cpp/`）与 Python 绑定（`python/`）
- 构建验证文档（`BUILD_VERIFICATION.md`、`BUILD.md`）
- 保留上游 `LICENSE`、`CHANGELOG`、文档与测试

> 不是从零实现的独立库；原始版权归 NVIDIA / RAPIDS 作者，本仓库仅保留上游许可与署名，并记录本地重建修改。

---

## 环境

- Windows 10/11 或 Linux
- CUDA Toolkit 12.x
- CMake 3.20+
- Visual Studio 2022 / g++（C++17）
- Python 3.10+（可选绑定）
- 上游 cuSignal 依赖（CuPy、NumPy 等）

## 构建

### Windows

```bat
build_cuda.bat
build_all.bat
```

### Linux

```bash
bash build.sh
```

详细步骤见 [`BUILD.md`](BUILD.md) 与 [`BUILD_VERIFICATION.md`](BUILD_VERIFICATION.md)。

## 测试

```bash
# Python 侧（需 CUDA 环境）
python -m pytest python -q

# C++ 构建产物按 build 目录说明运行
```

> 本机未安装 CUDA Toolkit，未执行完整 GPU 构建；构建日志与验证步骤已保留在上游文档中。

---

## 上游与许可

- Upstream: [rapidsai/cusignal](https://github.com/rapidsai/cusignal)
- License: Apache-2.0，见 [LICENSE](LICENSE)
- 原始 README: [README_UPSTREAM.md](README_UPSTREAM.md)
- hhxpoint 的修改/整理亦按 Apache-2.0 发布；请保留版权与 NOTICE。
