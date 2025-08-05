#!/usr/bin/env python3
"""
RTX 5070 + PyTorch Installation Verification Script
Tests CUDA functionality and reports system status
"""

import sys
import subprocess
import platform

def print_header(title):
    """Print a formatted header"""
    print(f"\n{'='*50}")
    print(f"  {title}")
    print(f"{'='*50}")

def print_result(test_name, status, details=""):
    """Print test result with status"""
    status_symbol = "✅" if status else "❌"
    print(f"{status_symbol} {test_name}: {details}")

def check_python_version():
    """Check Python version compatibility"""
    print_header("Python Environment")
    version = sys.version_info
    print(f"Python Version: {version.major}.{version.minor}.{version.micro}")
    print(f"Platform: {platform.platform()}")
    
    compatible = version.major == 3 and version.minor >= 10
    print_result("Python Version", compatible, 
                f"{'Compatible' if compatible else 'Requires Python 3.10+'}")
    return compatible

def check_pytorch_installation():
    """Check if PyTorch is installed and functional"""
    print_header("PyTorch Installation")
    
    try:
        import torch
        version = torch.__version__
        print_result("PyTorch Import", True, f"Version {version}")
        
        # Check if it's a nightly build
        is_nightly = "dev" in version
        print_result("Nightly Build", is_nightly, 
                    f"{'Detected' if is_nightly else 'Using stable release'}")
        
        return True, version
    except ImportError:
        print_result("PyTorch Import", False, "PyTorch not found")
        return False, None

def check_cuda_availability():
    """Check CUDA availability and version"""
    print_header("CUDA Configuration")
    
    try:
        import torch
        
        # CUDA availability
        cuda_available = torch.cuda.is_available()
        print_result("CUDA Available", cuda_available)
        
        if cuda_available:
            cuda_version = torch.version.cuda
            print_result("CUDA Version", True, f"Version {cuda_version}")
            
            # Device count
            device_count = torch.cuda.device_count()
            print_result("GPU Devices", device_count > 0, f"{device_count} device(s)")
            
            # Current device info
            if device_count > 0:
                device_name = torch.cuda.get_device_name(0)
                print_result("Primary GPU", True, device_name)
                
                # RTX 5070 specific check
                is_rtx_5070 = "5070" in device_name
                print_result("RTX 5070 Detected", is_rtx_5070)
                
                # Compute capability
                capability = torch.cuda.get_device_capability(0)
                expected_capability = (12, 0)  # Blackwell sm_120
                correct_arch = capability == expected_capability
                print_result("Compute Capability", correct_arch, 
                           f"{capability} {'(Blackwell sm_120)' if correct_arch else '(Check architecture)'}")
                
                return cuda_available, is_rtx_5070, correct_arch
        
        return cuda_available, False, False
        
    except Exception as e:
        print_result("CUDA Check", False, f"Error: {str(e)}")
        return False, False, False

def test_gpu_operations():
    """Test basic GPU tensor operations"""
    print_header("GPU Functionality Test")
    
    try:
        import torch
        
        if not torch.cuda.is_available():
            print_result("GPU Test", False, "CUDA not available")
            return False
        
        # Create tensors on GPU
        device = torch.device('cuda:0')
        a = torch.randn(1000, 1000, device=device)
        b = torch.randn(1000, 1000, device=device)
        
        # Matrix multiplication
        c = torch.matmul(a, b)
        
        # Memory check
        memory_allocated = torch.cuda.memory_allocated(0) / 1024**3  # GB
        memory_reserved = torch.cuda.memory_reserved(0) / 1024**3   # GB
        
        print_result("Tensor Creation", True, "GPU tensors created successfully")
        print_result("Matrix Operations", True, "GPU computation successful")
        print_result("Memory Usage", True, 
                    f"Allocated: {memory_allocated:.2f}GB, Reserved: {memory_reserved:.2f}GB")
        
        return True
        
    except Exception as e:
        print_result("GPU Test", False, f"Error: {str(e)}")
        return False

def check_nvidia_smi():
    """Check nvidia-smi output"""
    print_header("NVIDIA System Management")
    
    try:
        result = subprocess.run(['nvidia-smi'], capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print_result("nvidia-smi", True, "Available")
            
            # Look for RTX 5070 in output
            has_rtx_5070 = "RTX 5070" in result.stdout
            print_result("RTX 5070 in nvidia-smi", has_rtx_5070)
            
            return True
        else:
            print_result("nvidia-smi", False, "Command failed")
            return False
            
    except FileNotFoundError:
        print_result("nvidia-smi", False, "Command not found")
        return False
    except subprocess.TimeoutExpired:
        print_result("nvidia-smi", False, "Command timeout")
        return False

def main():
    """Main verification routine"""
    print("🚀 RTX 5070 + PyTorch Installation Verification")
    print("=" * 50)
    
    # Run all checks
    python_ok = check_python_version()
    pytorch_ok, pytorch_version = check_pytorch_installation()
    
    if pytorch_ok:
        cuda_ok, rtx_5070_ok, arch_ok = check_cuda_availability()
        gpu_test_ok = test_gpu_operations()
    else:
        cuda_ok = rtx_5070_ok = arch_ok = gpu_test_ok = False
    
    nvidia_smi_ok = check_nvidia_smi()
    
    # Final summary
    print_header("Installation Summary")
    
    all_checks = [python_ok, pytorch_ok, cuda_ok, rtx_5070_ok, arch_ok, gpu_test_ok]
    success_count = sum(all_checks)
    total_checks = len(all_checks)
    
    if success_count == total_checks:
        print("🎉 SUCCESS: RTX 5070 + PyTorch installation is fully functional!")
        print("✅ Ready for AI development and GPU-accelerated computing")
    elif success_count >= 4:
        print("⚠️  PARTIAL SUCCESS: Most components working, minor issues detected")
        print("🔧 Check failed items above for optimization opportunities")
    else:
        print("❌ FAILURE: Significant issues detected")
        print("📚 Refer to docs/CUDA_12.8_Installation.md for setup instructions")
    
    print(f"\nScore: {success_count}/{total_checks} checks passed")
    
    if pytorch_ok and pytorch_version:
        print(f"PyTorch Version: {pytorch_version}")
    
    return success_count == total_checks

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)