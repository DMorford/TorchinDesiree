@echo off
setlocal EnableDelayedExpansion

:: =================================================================
:: PyTorch Build Automation - RTX 5070 + CUDA 12.9 FINAL VERSION
:: Machine: Desiree (i9-14900F, 32GB RAM, RTX 5070)
:: Target: PyTorch with CUDA 12.9 and Blackwell sm_120 architecture
:: Key Fix: Removed invalid TORCH_CUDA_ARCH_LIST line
:: =================================================================

echo ==========================================
echo    DESIREE'S RTX 5070 PYTORCH BUILD
echo    CUDA 12.9 + BLACKWELL ARCHITECTURE
echo    FINAL DEFINITIVE VERSION
echo ==========================================
echo.

:: Generate timestamped log file
for /f "tokens=2-4 delims=/ " %%a in ("%date%") do (
    for /f "tokens=1-3 delims=:." %%d in ("%time%") do (
        set TIMESTAMP=%%c%%a%%b_%%d%%e%%f
    )
)
set SCRIPT_DIR=%~dp0
set BUILD_LOG=%SCRIPT_DIR%pytorch_build_RTX5070_!TIMESTAMP!.log

echo [INFO] Starting RTX 5070 PyTorch build automation...
echo [INFO] Build log will be saved to: %BUILD_LOG%
echo [INFO] Using CUDA 12.9 with Blackwell sm_120 architecture
echo [INFO] Response files enabled to prevent linking failures
echo.

:: --- EXECUTION FLOW ---
call :ValidateEnvironment || goto :Error
call :ConfirmPaths || goto :Error
call :NuclearClean || goto :Error
call :ActivateVirtualEnv || goto :Error
call :PrepareBuildDirectory || goto :Error
call :ConfigureCMake || goto :Error
call :ExecuteBuild || goto :Error

echo.
echo ==========================================
echo    RTX 5070 PYTORCH BUILD COMPLETED!
echo ==========================================
echo [SUCCESS] Build artifacts are in: %BUILD_DIR%
echo [SUCCESS] Full build log is at: %BUILD_LOG%
echo [SUCCESS] Time to test CUDA 12.9 + RTX 5070 combo!
echo.
pause
exit /b 0

:: --- SCRIPT FUNCTIONS ---

:ValidateEnvironment
echo [STEP 1] Validating RTX 5070 build environment...

:: Check for x64 Native Tools prompt
where cl.exe >nul 2>&1
if !ERRORLEVEL! neq 0 (
    echo [ERROR] This script must be run from the 'x64 Native Tools Command Prompt for VS 2022'.
    exit /b 1
)
cl 2>&1 | findstr /i "x64" >nul
if !ERRORLEVEL! neq 0 (
    echo [ERROR] Compiler is not x64. Please use the x64 Native Tools prompt.
    exit /b 1
)

:: Verify CUDA 12.9 installation
if not exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9\bin\nvcc.exe" (
    echo [ERROR] CUDA 12.9 not found. Please ensure it is installed in the default location.
    exit /b 1
)

echo [SUCCESS] Environment validation passed - RTX 5070 ready!
exit /b 0

:ConfirmPaths
echo [STEP 2] Confirming build paths...

set "PYTORCH_DIR=%SCRIPT_DIR%pytorch"
set "VENV_DIR=%SCRIPT_DIR%pytorch-build"

if not exist "%PYTORCH_DIR%\setup.py" (
    echo [INPUT] PyTorch source not found at '%PYTORCH_DIR%'.
    set /p "PYTORCH_DIR=Please enter the full path to your PyTorch source directory: "
)
if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo [INPUT] Virtual env not found at '%VENV_DIR%'.
    set /p "VENV_DIR=Please enter the full path to your virtual environment: "
)

set "BUILD_DIR=%PYTORCH_DIR%\build"

echo [CONFIRM] PyTorch source: %PYTORCH_DIR%
echo [CONFIRM] Virtual env:    %VENV_DIR%
echo [CONFIRM] Build folder:   %BUILD_DIR%
echo [CONFIRM] Target: RTX 5070 (sm_120) with CUDA 12.9
set /p "CONFIRM=Continue with RTX 5070 build? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo [ABORTED] Build cancelled by user.
    exit /b 1
)
exit /b 0

:NuclearClean
echo [STEP 3] Nuclear cleaning - removing ALL old build artifacts...

taskkill /f /im ninja.exe 2>nul
taskkill /f /im cmake.exe 2>nul
taskkill /f /im cl.exe 2>nul
timeout /t 2 /nobreak >nul

if exist "%BUILD_DIR%" (
    echo [INFO] Nuking old build directory: %BUILD_DIR%
    rmdir /s /q "%BUILD_DIR%" 2>nul
    if exist "%BUILD_DIR%" (
        takeown /f "%BUILD_DIR%" /r /d y 2>nul
        icacls "%BUILD_DIR%" /grant administrators:F /t 2>nul
        rmdir /s /q "%BUILD_DIR%" 2>nul
    )
)

if exist "%PYTORCH_DIR%\CMakeCache.txt" del /f "%PYTORCH_DIR%\CMakeCache.txt" 2>nul
if exist "%PYTORCH_DIR%\CMakeFiles" rmdir /s /q "%PYTORCH_DIR%\CMakeFiles" 2>nul

echo [SUCCESS] Nuclear cleaning complete - fresh slate for RTX 5070 build
exit /b 0

:ActivateVirtualEnv
echo [STEP 4] Activating virtual environment...

call "%VENV_DIR%\Scripts\activate.bat"
if !ERRORLEVEL! neq 0 (
    echo [ERROR] Failed to activate virtual environment: %VENV_DIR%
    exit /b 1
)

echo [SUCCESS] Virtual environment activated
exit /b 0

:PrepareBuildDirectory
echo [STEP 5] Preparing build directory...

cd /d "%PYTORCH_DIR%"
mkdir "%BUILD_DIR%" 2>nul

echo [SUCCESS] Build directory ready: %BUILD_DIR%
exit /b 0

:ConfigureCMake
echo [STEP 6] Configuring CMake for RTX 5070 + CUDA 12.9...

cd /d "%BUILD_DIR%"

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
-DCMAKE_CXX_USE_RESPONSE_FILE_FOR_INCLUDES=1 ^
>> "%BUILD_LOG%" 2>&1

if !ERRORLEVEL! neq 0 (
    echo [ERROR] CMake configuration failed! Check the log for details.
    echo [ERROR] Last 15 lines of build log:
    powershell "Get-Content '%BUILD_LOG%' | Select-Object -Last 15"
    goto :Error
)

echo [SUCCESS] CMake configured for RTX 5070 with response files enabled
exit /b 0

:ExecuteBuild
echo [STEP 7] Building PyTorch with RTX 5070 optimizations...

set MAX_JOBS=18

echo [INFO] Building with %MAX_JOBS% parallel jobs optimized for i9-14900F
echo [INFO] This will take 20-40 minutes - response files will prevent linking failures
echo [INFO] Progress logged to: %BUILD_LOG%

ninja -j %MAX_JOBS% >> "%BUILD_LOG%" 2>&1

if !ERRORLEVEL! neq 0 (
    echo [ERROR] Build failed! Check the log for details.
    echo [ERROR] Last 25 lines of build log:
    powershell "Get-Content '%BUILD_LOG%' | Select-Object -Last 25"
    goto :Error
)

echo [SUCCESS] RTX 5070 PyTorch build completed successfully!
exit /b 0

:Error
echo.
echo ==========================================
echo    RTX 5070 BUILD FAILED
echo ==========================================
echo [ERROR] The script stopped due to an error.
echo [ERROR] Please check the full build log for details:
echo [ERROR] %BUILD_LOG%
echo [ERROR] Common issues: CUDA 12.9 installation, architecture mismatch
echo.
pause
exit /b 1