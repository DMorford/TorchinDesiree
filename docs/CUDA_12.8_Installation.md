# 🔧 CUDA 12.8 + PyTorch Nightly Installation Guide
## The Working Path for RTX 5070

---

## 📋 Prerequisites

- **Windows 11** (fresh install recommended)
- **RTX 5070** with latest drivers (576.57+)
- **Claude Code AI assistant** (optional but highly recommended)

---

## 🚀 Step 1: Environment Preparation

### Clean any existing CUDA 12.9 installations
```batch
# Run the cleanup script
cleanup_cuda129.bat
```

### Verify RTX 5070 detection
```cmd
nvidia-smi
# Should show RTX 5070 with current drivers
```

---

## 📦 Step 2: CUDA 12.8 Installation

### Download CUDA 12.8 network installer

1. **Visit:** https://developer.nvidia.com/cuda-12-8-0-download-archive
2. **Select:** Windows → x86_64 → 11 → exe (network)
3. **File size:** ~13.6 MB

### Install with Claude Code assistance
```
# Tell Claude Code:
"Install CUDA 12.8 from the downloaded network installer"
```

### Manual installation alternative
```cmd
# Run as Administrator
cuda_12.8.0_windows_network.exe
# Accept defaults, let it install alongside existing CUDA
```

---

## 🐍 Step 3: PyTorch Nightly Installation
```cmd
# This is the magic command that works
pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128
```

---

## ✅ Step 4: Verification
```python
import torch
print(f"PyTorch: {torch.__version__}")
print(f"CUDA Available: {torch.cuda.is_available()}")
print(f"GPU: {torch.cuda.get_device_name(0)}")
print(f"CUDA Version: {torch.version.cuda}")

# Expected output:
# PyTorch: 2.9.0.dev20250803+cu128
# CUDA Available: True  
# GPU: NVIDIA GeForce RTX 5070
# CUDA Version: 12.8
```

---

## 🛠️ Troubleshooting

- **Permission errors:** Run installer as Administrator
- **Version conflicts:** Use cleanup script first
- **Import errors:** Restart terminal after installation

---

**✨ Success! You now have working PyTorch + CUDA 12.8 on RTX 5070**