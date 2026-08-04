# Blazecoin V1.5 - Visual Studio Build Ready

> **Note (corrected 2026-04-26):** This document was written during initial V1.5 planning, on the assumption that 0.8.6.2 (the production wallet) had a sync stall around block 2,000,000. Subsequent verification showed that 0.8.6.2 syncs the full ~4.1M-block chain without issue — the production node has been running continuously since 2014. The 2M-block stall was specific to the failed **V2.0** attempt (Bitcoin Core 28.0 base), which motivated V1.5's creation. Any "2M sync wall" framing behind this build setup should be read in that corrected context. See `Blazecoin_V1.5_Technical_Changelog.md` for the accurate post-build account.
>
> **Note (2026-08-04):** `boost_system-vc145-mt-x64-1_90.lib` (listed among the link deps below) was later **removed** from the link dependencies — Boost.System has been header-only since Boost 1.69. See `Blazecoin_V1.5_Technical_Changelog.md` §6.4.

**Date:** April 23, 2026  
**Status:** ✅ Ready to Compile in Visual Studio  
**Configuration:** Release x64

---

## ✅ What's Been Configured

### 1. Project Files Created
- ✅ `Blazecoin.sln` - Visual Studio solution file
- ✅ `Blazecoin.vcxproj` - Visual Studio project file

### 2. Source Files Added (69 total files)
- ✅ 33 Blazecoin core source files (`.cpp`)
- ✅ 3 JSON library files (`.cpp`)
- ✅ 33 LevelDB source files (`.cc`) - **Now included directly!**

### 3. Dependencies Configured (via vcpkg)
- ✅ Boost 1.90.0 (system, filesystem, program-options, thread, chrono)
- ✅ OpenSSL 3.6.2 (libssl, libcrypto)
- ✅ Berkeley DB 4.8.30 (libdb48)
- ✅ miniupnpc 2.3.2

### 4. Library Names Fixed
**Old (incorrect):**
```
libboost_system-vc143-mt.lib
libboost_filesystem-vc143-mt.lib
...
```

**New (correct):**
```
boost_system-vc145-mt-x64-1_90.lib
boost_filesystem-vc145-mt-x64-1_90.lib
boost_program_options-vc145-mt-x64-1_90.lib
boost_thread-vc145-mt-x64-1_90.lib
boost_chrono-vc145-mt-x64-1_90.lib
```

### 5. LevelDB Integration
**Added 33 LevelDB source files directly to project:**
- Database core: `db_impl.cc`, `version_set.cc`, `write_batch.cc`, etc.
- Table handling: `table.cc`, `table_builder.cc`, `block.cc`, etc.
- Utilities: `arena.cc`, `bloom.cc`, `cache.cc`, `crc32c.cc`, etc.
- Windows port: `port_win.cc`, `env_win.cc` (platform-specific)
- Memory environment: `memenv.cc` (for in-memory databases)

**Excluded:** Test files, benchmarks, POSIX-specific files

### 6. Preprocessor Definitions
```cpp
WIN32                        // Windows platform
_WINDOWS                     // Windows subsystem
NDEBUG                       // Release build (optimized)
_CRT_SECURE_NO_WARNINGS     // Disable MSVC security warnings
BOOST_THREAD_USE_LIB        // Use Boost thread library
BOOST_SPIRIT_THREADSAFE     // Thread-safe Boost Spirit
LEVELDB_PLATFORM_WINDOWS    // LevelDB Windows platform
OS_WIN                       // Operating system: Windows
```

### 7. Include Directories
```
C:\path\to\source\repos\Blazecoin_Core_V1.5\src
C:\path\to\source\repos\Blazecoin_Core_V1.5\src\json
C:\path\to\source\repos\Blazecoin_Core_V1.5\src\leveldb
C:\path\to\source\repos\Blazecoin_Core_V1.5\src\leveldb\include
C:\path\to\source\repos\Blazecoin_Core_V1.5\src\leveldb\helpers\memenv
C:\vcpkg\installed\x64-windows\include
```

### 8. Library Directories
```
C:\vcpkg\installed\x64-windows\lib
```

### 9. Linked Libraries
**Windows system libraries:**
- `ws2_32.lib` - Windows Sockets API
- `shlwapi.lib` - Shell utility functions
- `mswsock.lib` - Microsoft Winsock extensions
- `iphlpapi.lib` - IP Helper API (network info)

**vcpkg-installed libraries:**
- `boost_system-vc145-mt-x64-1_90.lib`
- `boost_filesystem-vc145-mt-x64-1_90.lib`
- `boost_program_options-vc145-mt-x64-1_90.lib`
- `boost_thread-vc145-mt-x64-1_90.lib`
- `boost_chrono-vc145-mt-x64-1_90.lib`
- `libssl.lib` (OpenSSL)
- `libcrypto.lib` (OpenSSL)
- `libdb48.lib` (Berkeley DB)
- `miniupnpc.lib` (UPnP)

---

## 🚀 How to Build in Visual Studio

### Method 1: Build in Visual Studio IDE (Recommended)

1. **Open the solution:**
   ```powershell
   Start-Process "C:\path\to\source\repos\Blazecoin_Core_V1.5\Blazecoin.sln"
   ```

2. **Select configuration:**
   - Configuration: **Release**
   - Platform: **x64**

3. **Build the project:**
   - Press **Ctrl+Shift+B** or
   - Menu: **Build → Build Solution**

4. **Output location:**
   ```
   C:\path\to\source\repos\Blazecoin_Core_V1.5\bin\x64\Release\blazecoind.exe
   ```

### Method 2: Build from Command Line (MSBuild)

```powershell
# Open Visual Studio Developer PowerShell
# Then run:
cd "C:\path\to\source\repos\Blazecoin_Core_V1.5"
msbuild Blazecoin.sln /p:Configuration=Release /p:Platform=x64 /m
```

**Build flags:**
- `/p:Configuration=Release` - Release build (optimized)
- `/p:Platform=x64` - 64-bit target
- `/m` - Multi-processor compilation (faster)

---

## ⏱️ Expected Build Time

- **First compilation:** 5-15 minutes (69 source files, LevelDB included)
- **Incremental builds:** 1-3 minutes (only changed files)
- **Multi-processor compilation:** Enabled (uses all CPU cores)

---

## ⚠️ Potential Compilation Issues & Solutions

### Issue 1: C++11/14 Compatibility Errors
**Symptom:** Errors about `auto`, range-based for loops, or other modern C++ features

**Solution:** LevelDB uses C++11 features. The project is already set to C++17, which should work. If errors occur:
1. Right-click project → Properties
2. C/C++ → Language → C++ Language Standard
3. Set to: **ISO C++17 Standard (/std:c++17)** or higher

### Issue 2: Snappy Compression Library Missing
**Symptom:** Linker error about missing `snappy.lib`

**Solution:** LevelDB optionally uses Snappy compression. Either:
1. Install Snappy via vcpkg: `vcpkg install snappy:x64-windows`
2. Or disable Snappy by adding preprocessor definition: `LEVELDB_NO_SNAPPY`

### Issue 3: Windows API Version Conflicts
**Symptom:** Errors about undefined Windows functions

**Solution:** Add to preprocessor definitions:
```
_WIN32_WINNT=0x0601
```
(0x0601 = Windows 7, ensures compatible API level)

### Issue 4: Berkeley DB C++ Errors
**Symptom:** Cannot find `db_cxx.h` or linking errors for Berkeley DB

**Solution:** The vcpkg version uses `libdb48.lib`. If errors occur:
```powershell
cd C:\vcpkg
.\vcpkg list | Select-String "berkeley"
# Verify it shows: berkeleydb:x64-windows 4.8.30#9
```

### Issue 5: Boost Library Linking Errors
**Symptom:** `LNK1104: cannot open file 'boost_....lib'`

**Solution:** Verify library names match exactly:
```powershell
Get-ChildItem "C:\vcpkg\installed\x64-windows\lib" -Filter "boost*.lib"
```
The project file is already configured with correct names for Boost 1.90.0.

### Issue 6: OpenSSL Deprecated Functions
**Symptom:** Warnings or errors about deprecated OpenSSL functions

**Solution:** Add preprocessor definition to suppress:
```
_CRT_SECURE_NO_DEPRECATE
OPENSSL_SUPPRESS_DEPRECATED
```

---

## ✅ Post-Build Verification

After successful compilation, verify the executable:

```powershell
# Check file exists
Test-Path "C:\path\to\source\repos\Blazecoin_Core_V1.5\bin\x64\Release\blazecoind.exe"

# Check file size (should be 2-5 MB typically)
(Get-Item "C:\path\to\source\repos\Blazecoin_Core_V1.5\bin\x64\Release\blazecoind.exe").Length / 1MB

# Test basic execution (should show help text)
& "C:\path\to\source\repos\Blazecoin_Core_V1.5\bin\x64\Release\blazecoind.exe" --help
```

---

## 🧪 Next Steps After Successful Build

1. **Test in isolated environment:**
   - Create test directory: `C:\blazecoin-data\BlazecoinV1.5`
   - Create config file: `blazecoin.conf` with test ports (55415/55416)
   - Start daemon: `blazecoind.exe -datadir=C:\blazecoin-data\BlazecoinV1.5`

2. **Monitor sync progress:**
   - Watch for sync past 2,000,000 blocks (PRIMARY SUCCESS CRITERION)
   - Verify checkpoint hashes at milestones

3. **Run stability test:**
   - 72-hour minimum uptime
   - Monitor CPU, memory, debug logs

4. **Production deployment:**
   - After all tests pass
   - During scheduled maintenance window

---

## 📝 Files Modified for Visual Studio Build

1. **Blazecoin.vcxproj** - Visual Studio project file
   - Added 33 LevelDB source files
   - Fixed Boost library names (vc145-mt-x64-1_90)
   - Added LevelDB preprocessor definitions (LEVELDB_PLATFORM_WINDOWS, OS_WIN)
   - Added LevelDB include directory
   - Removed leveldb.lib and memenv.lib (now built from source)

2. **Blazecoin.sln** - Visual Studio solution file
   - Created new solution for Blazecoin project

---

## 🎯 Success Criteria

✅ **Compilation successful** - No errors, possible warnings OK  
✅ **blazecoind.exe created** - File size 2-5 MB  
✅ **Executable runs** - Shows help text or version  
✅ **Syncs blockchain** - Connects to network, downloads blocks  
✅ **Passes 2M blocks** - Critical milestone reached  
✅ **RPC functional** - getinfo, getblockcount, etc. work  

---

## 📚 Reference Documents

- `CHANGES_V1.5.md` - Complete changelog and testing plan
- `Blazecoin.sln` - Visual Studio solution file
- `Blazecoin.vcxproj` - Visual Studio project file
- `C:\vcpkg\` - Dependency manager with all libraries

---

**Ready to build!** Open Visual Studio and press **Ctrl+Shift+B** 🚀

---

**Document Version:** 1.0  
**Last Updated:** April 23, 2026  
**Status:** ✅ All configurations complete, ready for compilation
