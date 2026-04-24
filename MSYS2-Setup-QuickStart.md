# Blazecoin V1.5 - MinGW Setup Quick Start Guide

## Overview

This guide helps you set up a complete MinGW build environment and compile Blazecoin V1.5 on Windows.

**Total Time:** 1-2 hours  
**Disk Space Required:** ~5 GB  
**Skill Level:** Intermediate (scripts do most of the work)

---

## What You'll Install

1. **7-Zip** - Archive extraction tool (~2 MB)
2. **MSYS2** - Unix-like environment for Windows (~500 MB)
3. **MinGW-w64** - GCC compiler toolchain (~200 MB)
4. **Dependencies** - Boost, OpenSSL, Berkeley DB, miniupnpc, Qt5 (~2 GB)

---

## Step-by-Step Instructions

### Step 1: Run Setup Script (15-30 minutes)

Open PowerShell as **Administrator** and run:

```powershell
cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5
.\Setup-MinGW-Environment.ps1
```

**This script will:**
- Download and install 7-Zip (if needed)
- Download and install MSYS2
- Download and extract MinGW-w64
- Add MinGW and MSYS2 to your PATH

**What to expect:**
- You may be prompted to install 7-Zip manually (just click through installer)
- MSYS2 installer will open (accept defaults, uncheck "Run MSYS2 now")
- Total download size: ~700 MB
- Time: 15-30 minutes depending on internet speed

---

### Step 2: Install Dependencies (15-30 minutes)

After Step 1 completes, **close and reopen PowerShell**, then run:

```powershell
cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5
.\Install-Blazecoin-Dependencies-MSYS2.ps1
```

**This script will:**
- Update MSYS2 package database
- Install GCC compiler toolchain
- Install Boost, OpenSSL, Berkeley DB, miniupnpc
- Install Qt5 (for GUI wallet)
- Configure environment variables

**What to expect:**
- Downloads ~2 GB of packages
- May see warnings about font cache (normal)
- Takes 15-30 minutes
- No user interaction needed (runs automatically)

---

### Step 3: Compile Blazecoin V1.5 (20-60 minutes)

After dependencies are installed, **close and reopen PowerShell**, then run:

```powershell
cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5
.\Compile-Blazecoin-V1.5.ps1
```

**This script will:**
- Verify your V1.5 code changes are correct
- Compile blazecoind.exe (command-line wallet)
- Optionally compile blazecoin-qt.exe (GUI wallet)
- Strip debug symbols to reduce file size
- Copy binaries to `compiled` folder

**What to expect:**
- Daemon compilation: 10-30 minutes
- GUI compilation: 15-40 minutes (optional)
- Final files in: `C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\compiled\`

---

### Step 4: Test V1.5 Wallet

See `CHANGES_V1.5.md` for complete testing instructions.

**Quick test:**

1. Create test config:
   ```powershell
   New-Item -ItemType Directory -Path "C:\blazecoin-data\BlazecoinV1.5" -Force
   
   @"
   rpcport=55415
   port=55416
   rpcuser=username
   rpcpassword=password
   server=1
   txindex=1
   addnode=85.15.179.171:55414
   addnode=91.206.16.214:55414
   "@ | Out-File "C:\blazecoin-data\BlazecoinV1.5\blazecoin.conf" -Encoding ASCII
   ```

2. Start V1.5 wallet (TEST MODE):
   ```powershell
   cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\compiled
   .\blazecoind.exe -datadir=C:\blazecoin-data\BlazecoinV1.5
   ```

3. Monitor sync progress:
   ```powershell
   .\blazecoind.exe -rpcport=55415 getblockcount
   ```

4. **Critical test:** Watch for wallet to sync PAST block 2,000,000 without stopping!

---

## Troubleshooting

### "Script execution is disabled"

Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "g++ is not recognized"

Close and reopen PowerShell after running setup scripts. PATH changes don't take effect in current session.

### "pacman: command not found"

MSYS2 not installed correctly. Re-run `Setup-MinGW-Environment.ps1`.

### Compilation errors about missing libraries

Dependencies not installed. Re-run `Install-Blazecoin-Dependencies-MSYS2.ps1`.

### "makefile.mingw: No such file or directory"

You're in wrong directory. Navigate to:
```powershell
cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5
```

### Compilation takes forever

This is normal! C++ compilation is slow:
- Daemon: 10-30 minutes
- GUI: 15-40 minutes
- Total: up to 1 hour on slower systems

---

## Alternative: Manual MSYS2 Setup

If the scripts don't work, you can do everything manually in MSYS2:

1. **Start MSYS2 MinGW64 shell** (not MSYS2 MSYS!)
   - Run: `C:\msys64\mingw64.exe`

2. **Update packages:**
   ```bash
   pacman -Syu
   ```

3. **Install dependencies:**
   ```bash
   pacman -S --needed \
     mingw-w64-x86_64-toolchain \
     mingw-w64-x86_64-boost \
     mingw-w64-x86_64-openssl \
     mingw-w64-x86_64-db \
     mingw-w64-x86_64-miniupnpc \
     mingw-w64-x86_64-qt5 \
     base-devel
   ```

4. **Compile:**
   ```bash
   cd /c/Users/Andrew/source/repos/Blazecoin_Core_V1.5/src
   make -f makefile.mingw USE_UPNP=1
   strip blazecoind.exe
   ```

---

## Files Created by Scripts

| File | Purpose |
|------|---------|
| `Setup-MinGW-Environment.ps1` | Installs MSYS2 and MinGW |
| `Install-Blazecoin-Dependencies-MSYS2.ps1` | Installs libraries via pacman |
| `Compile-Blazecoin-V1.5.ps1` | Compiles wallet binaries |
| `Verify-V1.5-Changes.ps1` | Verifies code modifications |
| `MSYS2-Setup-QuickStart.md` | This file |

---

## Installation Directories

| Component | Location |
|-----------|----------|
| MSYS2 | `C:\msys64\` |
| MinGW-w64 (standalone) | `C:\blazecoin-deps\mingw64\` |
| MinGW-w64 (MSYS2) | `C:\msys64\mingw64\` |
| Dependencies | `C:\blazecoin-deps\` |
| Compiled binaries | `C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\compiled\` |

---

## System Requirements

**Minimum:**
- Windows 10 or later
- 8 GB RAM
- 10 GB free disk space
- Internet connection

**Recommended:**
- Windows 11
- 16 GB RAM
- 20 GB free disk space (for faster compilation)
- SSD for faster compilation
- Multi-core CPU (speeds up parallel compilation)

---

## Time Estimates

| Task | Time |
|------|------|
| Setup MinGW | 15-30 minutes |
| Install dependencies | 15-30 minutes |
| Compile daemon | 10-30 minutes |
| Compile GUI | 15-40 minutes |
| **Total** | **1-2 hours** |

*Times vary based on internet speed, CPU, and disk speed.*

---

## After Compilation

Once compilation succeeds:

1. ✅ Test V1.5 wallet in isolated environment (ports 55415/55416)
2. ✅ Verify sync past 2M blocks
3. ✅ Run 72-hour stability test
4. ✅ Test with .NET Indexer API
5. ✅ Deploy to production (replace binaries on ports 55413/55414)

See `CHANGES_V1.5.md` for complete deployment guide.

---

## Need Help?

**Common Questions:**

**Q: Can I use Visual Studio instead?**  
A: The code uses MinGW-specific features. Visual Studio would require extensive code changes.

**Q: Can I compile on Linux instead?**  
A: Yes! Cross-compilation on Linux is actually easier. See `CHANGES_V1.5.md` for Linux instructions.

**Q: Do I need to compile the GUI?**  
A: No, the daemon (blazecoind.exe) is sufficient for server operation. GUI is optional.

**Q: How do I update the compiler?**  
A: Run `pacman -Syu` in MSYS2 to update all packages including GCC.

**Q: Can I delete MSYS2 after compilation?**  
A: Keep it if you plan to make code changes. Delete if you only need to run the compiled wallet.

---

## Success Criteria

✅ **Setup successful when:**
- `g++ --version` works in PowerShell
- `make --version` works in PowerShell  
- All dependency DLLs found in `C:\msys64\mingw64\bin\`

✅ **Compilation successful when:**
- `blazecoind.exe` created with no errors
- Executable size is reasonable (~2-5 MB after stripping)
- Wallet starts without immediate crashes

✅ **Testing successful when:**
- V1.5 syncs past block 2,000,000 without stopping
- All block hashes match production wallet
- RPC commands work correctly
- 72-hour stability test passes

---

## Quick Reference Commands

```powershell
# Setup (run once)
.\Setup-MinGW-Environment.ps1
.\Install-Blazecoin-Dependencies-MSYS2.ps1

# Compile (run after code changes)
.\Compile-Blazecoin-V1.5.ps1

# Verify changes (run before compilation)
.\Verify-V1.5-Changes.ps1

# Test wallet
cd compiled
.\blazecoind.exe -datadir=C:\blazecoin-data\BlazecoinV1.5
.\blazecoind.exe -rpcport=55415 getinfo

# Stop test wallet
.\blazecoind.exe -rpcport=55415 stop
```

---

**Good luck with your compilation! 🚀**

*Last updated: April 23, 2026*
