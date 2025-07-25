# CUDA 12.3 Installation Guide for RTX 5070

**Machine:** Desiree (i9-14900F, 32GB RAM, RTX 5070 12GB)  
**Date:** July 19-20, 2025  
**Purpose:** Step-by-step CUDA 12.3 setup for PyTorch building

---

## Environment Setup Process

### Step 1: Command Prompt Setup

**Important:** Use the x64 Native Tools Command Prompt for VS 2022, NOT a regular command window.

**To find it:**
1. Hit the Windows key and type "x64 Native Tools"
2. Look for "x64 Native Tools Command Prompt for VS 2022"
3. Run that

**Why this matters:** The x64 Native Tools prompt sets up all the proper environment variables for MSVC, CUDA, and the build tools to work together. A regular command prompt might not have all the paths configured correctly.

### Step 2: Verify CUDA Installation

Once in the x64 Native Tools prompt, test:

```bash
nvcc --version
```

Should show:
```
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2023 NVIDIA Corporation
Built on Wed_Nov_22_10:30:42_Pacific_Standard_Time_2023
Cuda compilation tools, release 12.3, V12.3.107
Build cuda_12.3.r12.3/compiler.33567101_0
```

Also test:
```bash
nvidia-smi
```

Expected output for RTX 5070:
```
Sat Jul 19 23:52:23 2025
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 576.80                 Driver Version: 576.80         CUDA Version: 12.9     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                  Driver-Model | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5070      WDDM  |   00000000:01:00.0  On |                  N/A |
|  0%   31C    P8             11W /  250W |     628MiB /  12227MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
```

**Key Success Indicators:**
- ✅ RTX 5070 detected and healthy - 12GB VRAM, running cool at 31°C
- ✅ Driver 576.80 is current and stable
- ✅ GPU is idle and ready - only 11W power usage, 0% utilization

**Important Note:** The driver reports "CUDA Version: 12.9" but nvcc shows 12.3. This is perfect:
- Your CUDA Toolkit is 12.3 (what we want for stability)
- Your driver supports up to 12.9 (gives you headroom)
- This combination should eliminate compatibility issues

### Step 3: Python Installation

**Recommended:** Python 3.11.9 (latest stable in 3.11 series)

**Download from:** https://python.org/downloads/

**Critical Installation Steps:**
1. Download "Windows installer (64-bit)" for Python 3.11.9
2. **During installation:** Check "Add Python to PATH"
3. Click "Customize installation" (don't use quick install)
4. **Optional Features:** Check all boxes (pip, tcl/tk, Python test suite, py launcher)
5. **Advanced Options:**
   - ✅ Associate files with Python - CHECKED
   - ✅ Create shortcuts - CHECKED  
   - ✅ Add Python to environment variables - CHECKED
   - ❌ Install Python 3.11 for all users - UNCHECKED (avoids admin issues)
   - Leave debugging options unchecked
6. **Final step:** Click "Disable path length limit" when prompted (requires admin for this one step)

**Verification:**
Close and reopen your x64 Native Tools Command Prompt, then test:
```bash
python --version
```
Should show: `Python 3.11.9`

---

## Build Environment Setup

### Virtual Environment Creation

```bash
cd C:\
mkdir dev
cd dev
python -m venv pytorch-build
pytorch-build\Scripts\activate
```

### Install Dependencies

```bash
pip install --upgrade pip setuptools wheel ninja cmake typing_extensions pyyaml
```

---

## Key Discoveries

### CUDA 12.3 Support Gap

**Critical Finding:** CUDA 12.3 is NOT officially supported by any stable PyTorch release

- **PyTorch 2.5:** Supports CUDA 11.8, 12.1, 12.4
- **PyTorch 2.6:** Supports CUDA 11.8, 12.4 (stable), 12.6 (experimental)
- **PyTorch 2.7:** Supports CUDA 11.8, 12.6 (stable), 12.8 (experimental)

### RTX 5070 Compatibility Challenge

- Blackwell architecture uses sm_120 compute capability
- Current stable PyTorch only supports up to sm_90
- Makes this a true "pioneer build" - uncharted territory

---

## Next Steps

This environment setup creates the foundation for attempting custom PyTorch builds. The combination of:
- CUDA 12.3 toolkit
- Driver 576.80 (with 12.9 support)
- Python 3.11.9 in isolated virtual environment
- x64 Native Tools environment

Provides the best chance of success for RTX 5070 PyTorch compilation.

---

**Status:** Environment successfully prepared  
**Ready for:** CMake configuration and build attempts  
**Hardware:** RTX 5070 12GB validated and ready