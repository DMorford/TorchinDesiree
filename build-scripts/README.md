# Build Scripts for RTX 5070 PyTorch Compilation

This directory contains the automation scripts we've developed for building PyTorch on RTX 5070 hardware.

## Scripts Overview

### `pytorch_build_RTX5070_FINAL.bat` - **THE WORKING VERSION** ✅

**Status:** Production-ready automation script  
**CUDA Version:** 12.9  
**Architecture:** sm_120 (Blackwell)  
**Features:**
- Complete environment validation
- Nuclear cleaning of old build artifacts  
- Response file implementation (prevents Windows linking failures)
- Optimized for i9-14900F (18 parallel jobs)
- Comprehensive error handling and logging
- Step-by-step progress tracking

**Usage:**
```batch
# Must be run from x64 Native Tools Command Prompt for VS 2022
pytorch_build_RTX5070_FINAL.bat
```

## Prerequisites

Before running any script:

1. **Visual Studio 2022** with "Desktop development with C++" workload
2. **CUDA 12.9** installed in default location
3. **Python 3.11.9** with virtual environment created
4. **PyTorch source** cloned with `git clone --recursive`
5. **32GB+ RAM** (recommended for parallel compilation)

## Script Evolution

We tried multiple approaches before landing on the final working version:

| Version | CUDA | Architecture | Status | Key Issue |
|---------|------|-------------|--------|-----------|
| Original | 12.4 | 8.9 (Ada) | ❌ Failed | Wrong arch for RTX 5070 |
| Fixed | 12.4 | 8.9 (Ada) | ❌ Failed | Still wrong architecture |
| **Final** | **12.9** | **12.0 (Blackwell)** | ✅ **Works** | **Correct targeting** |

## Key Learnings

### 1. Architecture Targeting is Critical
RTX 5070 uses Blackwell architecture (sm_120), not Ada (sm_89). Using the wrong architecture causes build failures.

### 2. CUDA Version Matters
RTX 5070 requires CUDA 12.8+ for full support. Earlier versions lack proper Blackwell drivers.

### 3. Response Files Save the Day
Windows command-line length limits cause linking failures. Response files solve this:
```batch
-DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=1
-DCMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS=1
```

### 4. Distributed Components Must Be Disabled
Distributed training components cause `c10d::Work` linking errors:
```batch
-DUSE_DISTRIBUTED=OFF
-DUSE_MPI=OFF
-DUSE_GLOO=OFF
-DUSE_NCCL=OFF
```

## Troubleshooting

### Common Issues:

**"nvcc not found"**
- Ensure CUDA 12.9 is installed
- Run from x64 Native Tools Command Prompt

**"Architecture mismatch"**
- Verify `CMAKE_CUDA_ARCHITECTURES=120`
- Check that you're targeting Blackwell, not Ada

**"Linking failures"**
- Ensure response files are enabled
- Check available disk space (>100GB recommended)

**"c10d::Work unresolved symbol"**
- Disable all distributed components
- Perform nuclear clean before retry

## Build Time Expectations

| Hardware | Parallel Jobs | Estimated Time |
|----------|---------------|----------------|
| i9-14900F (24 cores) | 18 | 20-40 minutes |
| i7-12700K (12 cores) | 8 | 45-75 minutes |
| i5-11600K (6 cores) | 4 | 2-3 hours |

## Success Indicators

✅ CMake configuration completes without architecture warnings  
✅ Ninja build progresses through linking stage without hanging  
✅ Final PyTorch installation recognizes RTX 5070 with CUDA 12.9  
✅ `torch.cuda.is_available()` returns `True`  
✅ `torch.cuda.get_device_name(0)` shows "RTX 5070"

---

*These scripts represent months of trial and error. Use them as a starting point for your own RTX 5070 builds!*