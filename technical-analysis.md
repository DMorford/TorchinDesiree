🛠️ PyTorch RTX 5070 Build Script Comparison & Documentation
Project: Custom PyTorch Build for RTX 5070 (Blackwell Architecture)
Machine: Desiree (i9-14900F, 32GB RAM, RTX 5070 12GB)
Date: July 24, 2025
Purpose: A comprehensive comparison and technical reference for RTX 50xx builders

🚀 Executive Summary
This doc compares three PyTorch build scripts developed for the RTX 5070, showing the evolution from failure to a successful production build.

TL;DR:
✔️ RTX 5070 requires CUDA 12.9+ and sm_120 (Blackwell) targeting
✔️ Response files fix Windows linker failures
❌ Do not use Ada architecture (sm_89) for RTX 5070 builds

🧬 Script Evolution Timeline
🔴 Script 1: pytorch_build.bat
CUDA: 12.4

Target Arch: 8.9 (Ada / RTX 40xx)

❌ Fail: Wrong architecture for Blackwell

🔴 Script 2: pytorch_build_FIXED.bat
CUDA: 12.4

Target Arch: 8.9 (Still Ada)

Change: Disabled pthreads

❌ Fail: Still wrong arch = same failure

✅ Script 3: pytorch_build_RTX5070_FINAL.bat
CUDA: 12.9

Target Arch: 12.0 (Blackwell / RTX 50xx)

✅ Success: Stable, tested, and production-ready

🔍 Critical Fixes & Comparisons
1. CUDA Version Compatibility
Script	CUDA Version	✅/❌	Notes
Original	12.4	❌	Skips 12.3; 12.4 poorly supported
Fixed	12.4	❌	Still broken
Final	12.9	✅	Full Blackwell support

Finding: RTX 5070 needs CUDA 12.8+ for proper driver and compute support.

2. Architecture Targeting (🧠 CRITICAL)
Script	TORCH_CUDA_ARCH_LIST	CMAKE_CUDA_ARCHITECTURES	Target	✅/❌
Original	"8.9"	89	Ada	❌
Fixed	"8.9"	89	Ada	❌
Final	"12.0"	120	Blackwell	✅

Discovery: Blackwell GPUs like the 5070 must use sm_120, not sm_89.

3. Response Files (Fix for Long Command Lines on Windows)
Script	Response Files Used	✅/❌	Purpose
Original	❌	❌	Default linking
Fixed	❌	❌	Still vulnerable
Final	✅	✅	Solves command length issues

CMake flags added:

batch
Copy
Edit
-DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=1
-DCMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS=1
-DCMAKE_C_USE_RESPONSE_FILE_FOR_INCLUDES=1
-DCMAKE_CXX_USE_RESPONSE_FILE_FOR_INCLUDES=1
4. Other Key Fixes
✅ Correct CUDA Path
batch
Copy
Edit
# Bad
-DCUDA_TOOLKIT_ROOT_DIR="C:\\Program Files\\NVIDIA GPU Computing Toolkit\\CUDA\\v12.4"

# Good
-DCUDA_TOOLKIT_ROOT_DIR="C:\\Program Files\\NVIDIA GPU Computing Toolkit\\CUDA\\v12.9"
✅ Disabled Components (All Scripts)
batch
Copy
Edit
-DUSE_DISTRIBUTED=OFF
-DUSE_MPI=OFF
-DUSE_GLOO=OFF
-DUSE_NCCL=OFF
-DUSE_PTHREADPOOL=OFF
-DCAFFE2_USE_PTHREADPOOL=OFF
✅ i9-14900F Optimization
Parallel Jobs: 18 (leaves cores for OS)

Flags: /MP /O2 for speed and stability

⚙️ Final CMake Config (Copy & Paste Ready)
batch
Copy
Edit
cmake .. -GNinja ^
-DCMAKE_BUILD_TYPE=Release ^
-DBUILD_SHARED_LIBS=ON ^
-DUSE_CUDA=ON ^
-DCUDA_TOOLKIT_ROOT_DIR="C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9" ^
-DCMAKE_CUDA_ARCHITECTURES=120 ^
-DPython_EXECUTABLE="%VENV_DIR%\Scripts\python.exe" ^
-DCMAKE_CUDA_FLAGS="-allow-unsupported-compiler" ^
-DCMAKE_CXX_FLAGS="/MP /O2" ^
-DCMAKE_C_FLAGS="/MP /O2" ^
-DUSE_DISTRIBUTED=OFF ^
-DUSE_MPI=OFF ^
-DUSE_GLOO=OFF ^
-DUSE_NCCL=OFF ^
-DUSE_OPENMP=OFF ^
-DBUILD_CAFFE2=OFF ^
-DUSE_CAFFE2=OFF ^
-DUSE_PTHREADPOOL=OFF ^
-DCAFFE2_USE_PTHREADPOOL=OFF ^
-DUSE_SYSTEM_PTHREADPOOL=OFF ^
-DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS=1 ^
-DCMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS=1 ^
-DCMAKE_C_USE_RESPONSE_FILE_FOR_INCLUDES=1 ^
-DCMAKE_CXX_USE_RESPONSE_FILE_FOR_INCLUDES=1
🧰 System Requirements
✅ Hardware (Tested)
CPU: i9-14900F (24 cores)

RAM: 32GB recommended (16GB min)

GPU: RTX 5070 (12GB Blackwell)

Storage: 1TB+ (build can be space-hungry)

✅ Software
OS: Windows 11

Visual Studio 2022 (with C++ desktop dev tools)

CUDA: 12.9

Python: 3.11.9 (3.10+ also works)

Git: Latest (recursive clone support)

✅ Environment Setup
bash
Copy
Edit
# Use x64 Native Tools Command Prompt for VS 2022
pip install ninja cmake setuptools wheel typing_extensions pyyaml
🛠️ Build Execution
1. Prepare Environment
bash
Copy
Edit
cd C:\dev
activate venv
verify CUDA 12.9
2. Run the Script
bash
Copy
Edit
pytorch_build_RTX5070_FINAL.bat
3. Monitor Build
Time: ~20–40 mins

Cores: 18 threads

Logs: Timestamped in build directory

🧨 Common Issues (and Fixes)
Problem	Fix
Architecture mismatch	Use sm_120, not sm_89
CUDA errors	Must use CUDA 12.8+
Windows linker failure	Use response files
Threading conflicts	Disable all pthreads

🌍 Community Impact
This is the first documented PyTorch build for RTX 5070 on Windows using Blackwell architecture.

Why it matters:

Helps devs on bleeding-edge hardware

Solves linker issues for large builds

Ready-to-run config script for anyone with RTX 50xx

*This documentation is actively maintained. Found an issue or have a suggestion? Open an issue or submit a PR!*