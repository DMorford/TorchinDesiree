@echo off
echo ================================
echo CUDA 12.9 Nuclear Cleanup Script
echo ================================
echo.
echo WARNING: This will remove ALL CUDA 12.9 installations
echo Press any key to continue or Ctrl+C to cancel...
pause >nul
echo.

echo [1/4] Stopping CUDA services...
net stop "NVIDIA Display Container LS" 2>nul
net stop "NVIDIA LocalSystem Container" 2>nul

echo [2/4] Uninstalling CUDA 12.9 via Control Panel...
wmic product where "name like '%%CUDA 12.9%%'" call uninstall /nointeractive 2>nul

echo [3/4] Removing CUDA 12.9 directories...
if exist "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9" (
    echo Removing CUDA 12.9 toolkit...
    rmdir /s /q "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9"
)

echo [4/4] Cleaning environment variables...
setx CUDA_PATH "" >nul 2>&1
setx CUDA_PATH_V12_9 "" >nul 2>&1

echo.
echo ================================
echo CUDA 12.9 cleanup complete!
echo ================================
echo.
echo Next steps:
echo 1. Restart your computer
echo 2. Install CUDA 12.8
echo 3. Install PyTorch nightly
echo.
echo Press any key to exit...
pause >nul