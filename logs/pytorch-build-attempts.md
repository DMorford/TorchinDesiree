# PyTorch Build Attempt Log

**Machine:** Desiree (Windows 11, RTX 5070)  
**Project:** XTTS/AI Co-Host Pipeline  
**Tracking:** Every CMake configuration attempted

---

## Build Attempt History

### Attempt 1 - Initial CUDA 12.9 Build

```bash
cmake .. -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_CUDA=ON \
  -DCMAKE_INSTALL_PREFIX=C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv \
  -DCUDA_TOOLKIT_ROOT_DIR="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9" \
  -DTORCH_CUDA_ARCH_LIST="8.9" \
  -DPython_EXECUTABLE="C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv\Scripts\python.exe" \
  -DUSE_DISTRIBUTED=ON \
  -DUSE_MPI=OFF \
  -DUSE_GLOO=ON \
  -DUSE_NCCL=OFF
```

**Key flags:** `USE_DISTRIBUTED=ON`, `USE_GLOO=ON`, CUDA 12.9  
**Outcome:** FAIL - link error `c10d::Work` unresolved in `torch_cpu.dll`

---

### Attempt 2 - Disable Distributed Components

```bash
cmake .. -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_CUDA=ON \
  -DCMAKE_INSTALL_PREFIX=C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv \
  -DCUDA_TOOLKIT_ROOT_DIR="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9" \
  -DTORCH_CUDA_ARCH_LIST="8.9" \
  -DPython_EXECUTABLE="C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv\Scripts\python.exe" \
  -DUSE_DISTRIBUTED=OFF \
  -DUSE_MPI=OFF \
  -DUSE_GLOO=OFF \
  -DUSE_NCCL=OFF
```

**Key flags:** Distributed stack OFF, CUDA 12.9  
**Outcome:** FAIL - linker still referencing `c10d::Work` (likely stale CMake cache)

---

### Attempt 3 - Default Distributed Settings

```bash
cmake .. -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_CUDA=ON \
  -DCMAKE_INSTALL_PREFIX=C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv \
  -DCUDA_TOOLKIT_ROOT_DIR="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9" \
  -DTORCH_CUDA_ARCH_LIST="8.9" \
  -DPython_EXECUTABLE="C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv\Scripts\python.exe"
```

**Key flags:** Distributed defaults (implicit ON), CUDA 12.9  
**Outcome:** FAIL - same unresolved `c10d::Work` link error

---

### Attempt 4 - Minimal Configuration

```bash
cmake .. -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_CUDA=ON \
  -DCMAKE_INSTALL_PREFIX=C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv \
  -DCUDA_TOOLKIT_ROOT_DIR="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9" \
  -DTORCH_CUDA_ARCH_LIST="8.9" \
  -DPython_EXECUTABLE="C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv\Scripts\python.exe" \
  -DUSE_DISTRIBUTED=OFF
```

**Key flags:** Distributed OFF, CUDA 12.9  
**Outcome:** FAIL - build stopped near end (details not captured)

---

## Next Planned Attempt - CUDA 12.3 Strategy

```bash
cmake .. -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DUSE_DISTRIBUTED=OFF \
  -DUSE_CUDA=ON \
  -DCUDA_TOOLKIT_ROOT_DIR="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.3" \
  -DTORCH_CUDA_ARCH_LIST="8.9" \
  -DCMAKE_CUDA_ARCHITECTURES=89 \
  -DPython_EXECUTABLE="C:\Users\morfo\Desktop\EASY_Voice\XTTS\venv\Scripts\python.exe"
```

**Strategy:** Switch from CUDA 12.9 to 12.3 for better PyTorch compatibility  
**Key Changes:**
- CUDA version downgrade to 12.3
- Added `BUILD_SHARED_LIBS=ON`
- Explicit `CMAKE_CUDA_ARCHITECTURES=89`
- Maintained distributed OFF

**Outcome:** Pending execution

---

## Analysis & Patterns

### Common Issues Identified

1. **c10d::Work linking errors** - Consistent across CUDA 12.9 attempts
2. **Stale CMake cache** - May be carrying forward distributed symbols
3. **CUDA 12.9 compatibility** - May be too new for stable PyTorch builds

### Strategy Evolution

1. **Attempt 1-4:** CUDA 12.9 with various distributed configurations
2. **Next approach:** CUDA 12.3 with shared libraries and explicit architectures

### Key Learnings

- Nuclear cleaning of build directories is essential
- Distributed components are problematic for Windows builds
- CUDA version compatibility is critical for RTX 5070
- Architecture targeting (sm_89 vs sm_120) needs investigation

---

**Status:** Multiple failed attempts documented  
**Next Steps:** Execute CUDA 12.3 strategy with improved configuration  
**Goal:** Successful PyTorch build for RTX 5070 + XTTS pipeline