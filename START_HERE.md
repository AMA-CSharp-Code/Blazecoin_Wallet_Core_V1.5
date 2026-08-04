# 🚀 START HERE - Blazecoin V1.5 MinGW Setup

> **Note (corrected 2026-04-26):** This document was written during initial V1.5 planning, on the assumption that 0.8.6.2 (the production wallet) had a sync stall around block 2,000,000. Subsequent verification showed that 0.8.6.2 syncs the full ~4.1M-block chain without issue — the production node has been running continuously since 2014. The 2M-block stall was specific to the failed **V2.0** attempt (Bitcoin Core 28.0 base), which motivated V1.5's creation. Any "2M sync wall" framing behind this setup guide should be read in that corrected context. See `Blazecoin_V1.5_Technical_Changelog.md` for the accurate post-build account.
>
> **Note (2026-08-04): this entire MinGW/MSYS2 toolchain path is OBSOLETE.** V1.5 actually shipped via **MSVC 2022 + vcpkg** on Windows and **`makefile.unix`** on Linux — see `Blazecoin_V1.5_Technical_Changelog.md` §11 ("Build environment") for the authoritative build recipe. In addition, the Step-1 script `Setup-MinGW-Environment.ps1` referenced below is an empty 0-byte file, so the steps in this guide cannot be followed as written.

## Quick Start (3 Simple Steps)

### Step 1: Setup MinGW Environment
```powershell
cd C:\path\to\source\repos\Blazecoin_Core_V1.5
.\Setup-MinGW-Environment.ps1
```
**Then close and reopen PowerShell**

### Step 2: Install Dependencies
```powershell
cd C:\path\to\source\repos\Blazecoin_Core_V1.5
.\Install-Blazecoin-Dependencies-MSYS2.ps1
```
**Then close and reopen PowerShell**

### Step 3: Compile Wallet
```powershell
cd C:\path\to\source\repos\Blazecoin_Core_V1.5
.\Compile-Blazecoin-V1.5.ps1
```

**That's it!** Your compiled binaries will be in: `compiled\blazecoind.exe` and `compiled\blazecoin-qt.exe`

---

## What Each Script Does

| Script | Purpose | Time |
|--------|---------|------|
| `Setup-MinGW-Environment.ps1` | Installs MSYS2, MinGW, 7-Zip | 15-30 min |
| `Install-Blazecoin-Dependencies-MSYS2.ps1` | Installs Boost, OpenSSL, Berkeley DB, Qt5 | 15-30 min |
| `Compile-Blazecoin-V1.5.ps1` | Compiles blazecoind.exe and blazecoin-qt.exe | 30-60 min |
| `Verify-V1.5-Changes.ps1` | Verifies code changes before compilation | 1 min |

---

## Before You Start

### ✅ Prerequisites

- [x] Windows 10 or later
- [x] 10 GB free disk space
- [x] Administrator access
- [x] Internet connection
- [x] 1-2 hours of time

### ✅ Your Code is Ready

All V1.5 code modifications are complete and verified:
- ✅ Version updated to 1.5.0.0
- ✅ Header limits increased to 50M
- ✅ 16 checkpoints added (including critical 2M checkpoint)
- ✅ All changes verified

---

## If You Get Stuck

### Problem: "Execution policy error"
**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problem: "g++ not recognized" after setup
**Solution:** Close and reopen PowerShell (PATH changes need new session)

### Problem: Compilation fails
**Solution:** Check you ran all 3 steps in order and reopened PowerShell between steps

### Problem: Want to do it manually
**Solution:** See `MSYS2-Setup-QuickStart.md` for manual MSYS2 commands

---

## Alternative: Send to Someone with Build Environment

If you don't want to set up MinGW, you can:

1. **Zip your modified source:**
   ```powershell
   Compress-Archive -Path "C:\path\to\source\repos\Blazecoin_Core_V1.5\src" -DestinationPath "Blazecoin_V1.5_Source.zip"
   ```

2. **Include this file:**
   ```powershell
   Copy-Item "CHANGES_V1.5.md" -Destination "." 
   ```

3. **Send to someone who already has MinGW/MSYS2 setup**

4. **They just need to run:**
   ```bash
   cd src
   make -f makefile.mingw
   strip blazecoind.exe
   ```

---

## Full Documentation

| Document | Purpose |
|----------|---------|
| **MSYS2-Setup-QuickStart.md** | Detailed setup guide with troubleshooting |
| **CHANGES_V1.5.md** | Complete change summary with testing plan |
| **Blazecoin_V1.5_README.md** | Project overview |
| **Blazecoin_V1.5_Upgrade_Guide.md** | Comprehensive technical reference |

---

## Your Next Steps

1. **Run setup script** (`Setup-MinGW-Environment.ps1`)
2. **Reopen PowerShell**
3. **Run dependency script** (`Install-Blazecoin-Dependencies-MSYS2.ps1`)
4. **Reopen PowerShell**
5. **Run compile script** (`Compile-Blazecoin-V1.5.ps1`)
6. **Test compiled wallet** (see CHANGES_V1.5.md)
7. **Deploy to production** (after 72-hour test)

---

## Expected Results

### After Step 1 (Setup):
- `C:\msys64\` directory exists
- `g++ --version` works
- Total size: ~1 GB

### After Step 2 (Dependencies):
- `C:\msys64\mingw64\bin\` contains ~2,000 files
- All required DLLs present
- Total size: ~3 GB

### After Step 3 (Compilation):
- `compiled\blazecoind.exe` exists (~2-5 MB)
- `compiled\blazecoin-qt.exe` exists (~5-10 MB) [optional]
- Ready for testing

---

## Time Breakdown

```
Setup MinGW:           15-30 minutes
Install dependencies:  15-30 minutes  
Compile daemon:        10-30 minutes
Compile GUI:           15-40 minutes (optional)
─────────────────────────────────────
TOTAL:                 1-2 hours
```

---

## Support Resources

- **This directory:** All setup and compilation scripts
- **CHANGES_V1.5.md:** Complete technical documentation
- **MSYS2 documentation:** https://www.msys2.org/
- **MinGW-w64:** https://www.mingw-w64.org/

---

## Ready?

**Start with:**
```powershell
cd C:\path\to\source\repos\Blazecoin_Core_V1.5
.\Setup-MinGW-Environment.ps1
```

**Good luck! 🚀**
