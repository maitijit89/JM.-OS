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

---

## ⚡ Easy Installation Process

JM OS is designed to be easily flashed onto compatible target devices. We provide two user-friendly installation workflows to choose from:

### 1. JM OS Web Installer (Recommended)
Flash your phone directly from your web browser without typing any commands!
* **Requirements**: Chrome, Edge, or Opera (supporting WebUSB).
* **Launch**: Open [vendor/jmos/installer/web/index.html](file:///e:/Dj-OS/vendor/jmos/installer/web/index.html) in your browser.
* **Steps**:
  1. Boot your phone into Bootloader mode (`Volume Down` + `Power`).
  2. Connect your device via USB.
  3. Click **Connect Phone** inside the web app.
  4. Perform **Bootloader Unlock** (if needed) and click **Begin Flash OS**.
  5. The interactive console will flash partitions automatically and format userdata.

### 2. Automated Desktop Flashing Scripts
Traditional flashing using offline high-performance fastboot scripts:
* **For Windows Users**: Double-click [flash-all.bat](file:///e:/Dj-OS/vendor/jmos/installer/flash-all.bat) inside Command Prompt.
* **For macOS & Linux Users**: Open a terminal and run `bash flash-all.sh` under [flash-all.sh](file:///e:/Dj-OS/vendor/jmos/installer/flash-all.sh).
* **Benefits**: Strictly checks local configurations, ensures `fastboot` is in environment PATH, guides user through driver installations, and conducts userspace FastbootD flashing.

