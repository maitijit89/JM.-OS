# JM OS

JM OS is a premium, custom Android-based operating system built for high performance, sleek aesthetics, and advanced user control.

## Project Vision
To create a modern Android experience that combines the stability of AOSP with cutting-edge features and a "JM-themed" aesthetic (vibrant colors, audio-centric optimizations, and glassmorphism UI).

## Prerequisites
- **OS**: Windows 10/11 with WSL2 (Ubuntu 22.04+ recommended)
- **Disk Space**: At least 400GB free (Current D: drive has ~157GB - *Warning: Action required*)
- **RAM**: 32GB+ recommended
- **CPU**: High-performance multi-core processor

## Getting Started
1. **Setup Environment**: Install build dependencies in WSL.
2. **Initialize Repo**: `repo init -u <manifest-url> -b android-14`
3. **Sync Source**: `repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags`
4. **Build**: `source build/envsetup.sh && lunch <target> && mka bacon`
