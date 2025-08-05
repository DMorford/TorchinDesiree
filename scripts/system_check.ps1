# RTX 5070 System Validation Script
# Hardware and environment verification

Write-Host "🔍 RTX 5070 System Validation Script" -ForegroundColor Cyan
Write-Host "=" * 50

# Function to print colored results
function Write-Result {
    param(
        [string]$Test,
        [bool]$Status,
        [string]$Details = ""
    )
    
    $symbol = if ($Status) { "✅" } else { "❌" }
    $color = if ($Status) { "Green" } else { "Red" }
    
    Write-Host "$symbol $Test" -ForegroundColor $color -NoNewline
    if ($Details) {
        Write-Host ": $Details" -ForegroundColor White
    } else {
        Write-Host ""
    }
}

# Check Windows version
Write-Host "`n🖥️ Operating System" -ForegroundColor Yellow
$osInfo = Get-WmiObject -Class Win32_OperatingSystem
$isWindows11 = $osInfo.Version -ge "10.0.22000"
Write-Result "Windows 11" $isWindows11 "$($osInfo.Caption) (Build $($osInfo.BuildNumber))"

# Check CPU
Write-Host "`n⚡ Processor Information" -ForegroundColor Yellow
$cpu = Get-WmiObject -Class Win32_Processor
$isI9 = $cpu.Name -like "*i9*"
Write-Result "Intel i9 Processor" $isI9 "$($cpu.Name)"
Write-Result "Core Count" ($cpu.NumberOfCores -ge 20) "$($cpu.NumberOfCores) cores, $($cpu.NumberOfLogicalProcessors) threads"

# Check RAM
Write-Host "`n🧠 Memory Configuration" -ForegroundColor Yellow
$memory = Get-WmiObject -Class Win32_ComputerSystem
$memoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 1)
$sufficientRAM = $memoryGB -ge 30
Write-Result "Memory (32GB+)" $sufficientRAM "$memoryGB GB installed"

# Check GPU
Write-Host "`n🎮 Graphics Hardware" -ForegroundColor Yellow
try {
    $gpu = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -like "*RTX*" }
    if ($gpu) {
        $isRTX5070 = $gpu.Name -like "*5070*"
        Write-Result "RTX 5070 Detection" $isRTX5070 "$($gpu.Name)"
        
        # Check VRAM (approximate)
        if ($gpu.AdapterRAM) {
            $vramGB = [math]::Round($gpu.AdapterRAM / 1GB, 1)
            $sufficientVRAM = $vramGB -ge 10
            Write-Result "VRAM (10GB+)" $sufficientVRAM "$vramGB GB"
        }
    } else {
        Write-Result "RTX GPU" $false "No RTX GPU detected"
    }
} catch {
    Write-Result "GPU Detection" $false "Error checking GPU"
}

# Check NVIDIA drivers
Write-Host "`n🔧 NVIDIA Drivers" -ForegroundColor Yellow
try {
    $nvidiaDrivers = Get-WmiObject -Class Win32_PnPSignedDriver | Where-Object { $_.DeviceName -like "*NVIDIA*" -and $_.DeviceName -like "*RTX*" }
    if ($nvidiaDrivers) {
        $latestDriver = $nvidiaDrivers | Sort-Object DriverVersion -Descending | Select-Object -First 1
        $driverVersion = $latestDriver.DriverVersion
        $isRecentDriver = $driverVersion -ge "31.0.15.7657"  # Approximate 576.57
        Write-Result "NVIDIA Drivers" $isRecentDriver "Version $driverVersion"
    } else {
        Write-Result "NVIDIA Drivers" $false "Not found"
    }
} catch {
    Write-Result "Driver Check" $false "Error checking drivers"
}

# Check CUDA installations
Write-Host "`n🚀 CUDA Toolkit" -ForegroundColor Yellow
$cudaPath12_8 = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.8"
$cudaPath12_9 = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.9"

$hasCuda128 = Test-Path $cudaPath12_8
$hasCuda129 = Test-Path $cudaPath12_9

Write-Result "CUDA 12.8 Installed" $hasCuda128 $cudaPath12_8
Write-Result "CUDA 12.9 Absent" (-not $hasCuda129) "$(if ($hasCuda129) { 'Found (should be removed)' } else { 'Not found (good)' })"

# Check Visual Studio
Write-Host "`n🛠️ Development Tools" -ForegroundColor Yellow
$vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\*\Common7\IDE\devenv.exe"
$hasVS2022 = (Get-ChildItem -Path $vsPath -ErrorAction SilentlyContinue).Count -gt 0
Write-Result "Visual Studio 2022" $hasVS2022

# Check Python
Write-Host "`n🐍 Python Environment" -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    if ($pythonVersion -like "Python 3.*") {
        $versionMatch = $pythonVersion -match "Python (\d+)\.(\d+)"
        if ($versionMatch) {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            $isCompatible = $major -eq 3 -and $minor -ge 10
            Write-Result "Python 3.10+" $isCompatible $pythonVersion
        }
    } else {
        Write-Result "Python" $false "Not found or not in PATH"
    }
} catch {
    Write-Result "Python" $false "Error checking version"
}

# Check disk space
Write-Host "`n💾 Storage" -ForegroundColor Yellow
$drives = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3"
foreach ($drive in $drives) {
    $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 1)
    $sufficientSpace = $freeSpaceGB -ge 50
    Write-Result "Drive $($drive.DeviceID) Free Space" $sufficientSpace "$freeSpaceGB GB available"
}

# Check network connectivity
Write-Host "`n🌐 Network Connectivity" -ForegroundColor Yellow
try {
    $pingResult = Test-NetConnection -ComputerName "developer.nvidia.com" -Port 443 -InformationLevel Quiet
    Write-Result "NVIDIA Developer Access" $pingResult "Required for downloads"
} catch {
    Write-Result "Network Test" $false "Unable to test connectivity"
}

# Summary
Write-Host "`n📊 System Readiness Summary" -ForegroundColor Yellow
Write-Host "=" * 50

$readyForSetup = $isWindows11 -and $sufficientRAM -and $hasCuda128 -and (-not $hasCuda129)

if ($readyForSetup) {
    Write-Host "🎉 SYSTEM READY for RTX 5070 + PyTorch setup!" -ForegroundColor Green
    Write-Host "✅ All prerequisites met - proceed with installation" -ForegroundColor Green
} else {
    Write-Host "⚠️ SYSTEM NEEDS PREPARATION" -ForegroundColor Yellow
    Write-Host "🔧 Address the issues above before proceeding" -ForegroundColor Yellow
}

Write-Host "`n📚 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Fix any failed checks above"
Write-Host "2. Run docs/CUDA_12.8_Installation.md guide"
Write-Host "3. Use scripts/verify_installation.py to test results"

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")