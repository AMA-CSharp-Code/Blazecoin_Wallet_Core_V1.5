# Blazecoin Core V1.5 - Header Limit Fix & Upgrade Guide

## Overview
This document outlines the changes needed to fix the blockchain sync stopping issue in Blazecoin Core wallet when syncing beyond ~2,000,000 blocks. The blockchain currently has **4,000,000+ blocks** and is growing, requiring updates to hardcoded limits.

## Problem Summary
The original Blazecoin Core wallet (forked from Litecoin/Bitcoin) has several hardcoded limits that prevent it from syncing beyond approximately 2,000,000 blocks:

1. **Header download batch limits** - Network protocol limits on header requests
2. **Missing checkpoints** - Last checkpoint is at block 363,120 (current chain is 4M+)
3. **Potential array size limits** - Fixed-size data structures for block indexes
4. **Database initialization** - Possible LevelDB constraints

## Repository Location
**C++ Wallet Source Code:** `C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\`

## Required Changes

### 1. Update Checkpoints (CRITICAL)

**File:** `src/checkpoints.cpp`

**Current State:** Last checkpoint is at block 363,120
```cpp
static MapCheckpoints mapCheckpoints =
    boost::assign::map_list_of
    (  0,    uint256("0x5d871c1b6ea542c2bb8a3b3ac70028a591bbf81369e90c2446c1a2bbfb89459b"))
    (  1,    uint256("0x50f5ef3a2b2637c92907e9d444e6a58f925cb61eaac7b23f46263f2e7d9245c0"))
    ( 18500, uint256("0x6cfc4decf7c26c037c621190681f9b3f12912f8330b06c652e0c193340a23347"))
    ( 33000, uint256("0xcfd0eb628a7fee82accc4e2f183cdd1abd08afeedf2b1b030230836a4e74629e"))
    ( 60413, uint256("0x99ea9310aac366b03161254d77ada05c9eb1392ca8ca370885b013f80d41f56e"))
    ( 124650, uint256("0x0d8aa2452b7f2702a9a07a4cb36ad1edd12503014ba46da46992c9dba898dec2"))
    ( 215000, uint256("0x7e960cd973982501d2339906c3c7bf81c2e0c0a0a02192198263ae51f024e991"))
    ( 363120, uint256("0x40c6d6d81494d53781af0fc9d7aff91a2f3a13e38100b20c3ac819f944ecf9f4"))
    ;
```

**Action Required:**
1. Use your **production indexer API** (which is fully synced) to get block hashes at key heights
2. Add checkpoints at strategic intervals:
   - Every 500,000 blocks is recommended
   - Example heights: 500000, 1000000, 1500000, 2000000, 2500000, 3000000, 3500000, 4000000

**How to Get Block Hashes:**
```bash
# Using blazecoin-cli on your production daemon
blazecoin-cli getblockhash 500000
blazecoin-cli getblockhash 1000000
blazecoin-cli getblockhash 1500000
# ... continue for each checkpoint height
```

**Updated Code Example:**
```cpp
static MapCheckpoints mapCheckpoints =
    boost::assign::map_list_of
    (  0,      uint256("0x5d871c1b6ea542c2bb8a3b3ac70028a591bbf81369e90c2446c1a2bbfb89459b"))
    (  1,      uint256("0x50f5ef3a2b2637c92907e9d444e6a58f925cb61eaac7b23f46263f2e7d9245c0"))
    ( 18500,   uint256("0x6cfc4decf7c26c037c621190681f9b3f12912f8330b06c652e0c193340a23347"))
    ( 33000,   uint256("0xcfd0eb628a7fee82accc4e2f183cdd1abd08afeedf2b1b030230836a4e74629e"))
    ( 60413,   uint256("0x99ea9310aac366b03161254d77ada05c9eb1392ca8ca370885b013f80d41f56e"))
    ( 124650,  uint256("0x0d8aa2452b7f2702a9a07a4cb36ad1edd12503014ba46da46992c9dba898dec2"))
    ( 215000,  uint256("0x7e960cd973982501d2339906c3c7bf81c2e0c0a0a02192198263ae51f024e991"))
    ( 363120,  uint256("0x40c6d6d81494d53781af0fc9d7aff91a2f3a13e38100b20c3ac819f944ecf9f4"))
    ( 500000,  uint256("0x<HASH_FROM_PRODUCTION>"))  // ADD THIS
    ( 1000000, uint256("0x<HASH_FROM_PRODUCTION>"))  // ADD THIS
    ( 1500000, uint256("0x<HASH_FROM_PRODUCTION>"))  // ADD THIS
    ( 2000000, uint256("0x<HASH_FROM_PRODUCTION>"))  // ADD THIS
    ( 2500000, uint256("0x<HASH_FROM_PRODUCTION>"))  // ADD THIS
    ( 3000000, uint256("0x<HASH_FROM_PRODUCTION>"))  // ADD THIS
    ( 3500000, uint256("0x<HASH_FROM_PRODUCTION>"))  // ADD THIS
    ( 4000000, uint256("0x<HASH_FROM_PRODUCTION>"))  // ADD THIS
    ;
```

Also update the checkpoint metadata:
```cpp
static const CCheckpointData data = {
    &mapCheckpoints,
    1400891673, // * UNIX timestamp of last checkpoint block - UPDATE THIS
    0,          // * total number of transactions - UPDATE THIS
    100         // * estimated number of transactions per day
};
```

### 2. Search for Header/Block Limits

**Files to Check:**
- `src/main.h`
- `src/main.cpp`
- `src/net.h`
- `src/net.cpp`
- `src/protocol.h`

**What to Look For:**
```cpp
// Common patterns that might exist:
static const unsigned int MAX_HEADERS_RESULTS = 2000;
static const int MAX_BLOCK_HEIGHT = 2000000;
static const int MAX_BLOCKINDEX_SIZE = 2000000;
```

**Action:** Search for these patterns and increase to **50,000,000**

**PowerShell Search Command:**
```powershell
cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\src
Select-String -Path *.h,*.cpp -Pattern "MAX.*HEADER|2000000|MAX.*BLOCK.*HEIGHT" | Select-Object Filename, LineNumber, Line
```

### 3. Check for Fixed-Size Arrays

**Files to Check:**
- `src/main.cpp`
- `src/main.h`

**What to Look For:**
```cpp
// Fixed-size arrays that might overflow:
CBlockIndex* vBlockIndexByHeight[2000000];  // PROBLEM!
```

**Action:** Change to dynamic allocation or increase size to at least **50,000,000**

### 4. Increase Block File Size Limits (Optional but Recommended)

**File:** `src/main.h`

**Current:**
```cpp
static const unsigned int MAX_BLOCKFILE_SIZE = 0x8000000; // 128 MiB
```

**Recommended:** Keep as-is unless disk space is abundant, then increase to 256 MiB:
```cpp
static const unsigned int MAX_BLOCKFILE_SIZE = 0x10000000; // 256 MiB
```

### 5. Update Version Number

**File:** `src/clientversion.h`

Update version constants from 0.8.6.2 to 1.5.0.0:
```cpp
#define CLIENT_VERSION_MAJOR       0  // Current: 0, Change to: 1
#define CLIENT_VERSION_MINOR       5  // Change from 8 to 5
#define CLIENT_VERSION_REVISION    0  // Current: 6, Change to: 0
#define CLIENT_VERSION_BUILD       0  // Current: 2, Change to: 0
```

## Compilation Instructions

### Prerequisites
1. **Visual Studio 2019/2022** with C++ Desktop Development workload
2. **Qt 4.8.x or Qt 5.x** (for GUI wallet)
3. **Boost Libraries** (usually 1.55.0 or later)
4. **OpenSSL** (1.0.x or 1.1.x depending on Litecoin fork version)
5. **Berkeley DB 4.8** (for wallet.dat compatibility)
6. **MinGW-w64** (alternative to Visual Studio)

### Option A: Using Qt Creator (Easiest for GUI Wallet)
```bash
cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5
qmake blazecoin-qt.pro
make
```

### Option B: Using Visual Studio (Command-Line Daemon)
1. Open Visual Studio Developer Command Prompt
2. Navigate to source directory
3. Build using nmake or MSBuild

### Option C: Using MinGW (Recommended for Windows)
```bash
cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5
mingw32-make -f Makefile.mingw
```

**Note:** You may need to edit `Makefile.mingw` to point to correct library paths for Boost, OpenSSL, Berkeley DB, etc.

### Output Binaries
After successful compilation:
- **blazecoind.exe** - Command-line daemon (headless)
- **blazecoin-cli.exe** - RPC client
- **blazecoin-qt.exe** - GUI wallet (if built with Qt)

## Deployment Strategy

### Phase 1: Testing Environment Setup

1. **Create V1.5 Data Directory:**
```powershell
mkdir C:\blazecoin-data\BlazecoinV1.5
```

2. **Create V1.5 Configuration File:**
**Location:** `C:\blazecoin-data\BlazecoinV1.5\blazecoin.conf`
```ini
# Blazecoin V1.5 Testing Configuration
rpcuser=blazecoin_v15_user
rpcpassword=<STRONG_PASSWORD_HERE>
rpcport=55415
port=55416
datadir=C:\blazecoin-data\BlazecoinV1.5

# Enable transaction indexing
txindex=1

# Seed nodes (use production seed nodes)
addnode=85.15.179.171:55414
addnode=91.206.16.214:55414

# Logging
debug=1
printtoconsole=0
```

3. **Start V1.5 Daemon:**
```powershell
cd C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5
.\blazecoind.exe -conf=C:\blazecoin-data\BlazecoinV1.5\blazecoin.conf -daemon
```

4. **Monitor Sync Progress:**
```powershell
.\blazecoin-cli.exe -rpcport=55415 getinfo
.\blazecoin-cli.exe -rpcport=55415 getblockcount
```

### Phase 2: .NET API Configuration

Update your Indexer API `appsettings.json` to support dual wallet configuration:

**File:** `Blazecoin_Indexer_API/appsettings.json`

```json
{
  "BlazecoinRpc": {
    "Production": {
      "Url": "http://localhost:55413",
      "Username": "username",
      "Password": "password",
      "Enabled": true
    },
    "V1_5_Testing": {
      "Url": "http://localhost:55415",
      "Username": "blazecoin_v15_user",
      "Password": "<STRONG_PASSWORD_HERE>",
      "Enabled": false
    }
  },
  "ActiveWalletProfile": "Production"
}
```

### Phase 3: Validation & Migration

1. **Wait for V1.5 to sync past 2,000,000 blocks** - This confirms the fix works
2. **Compare block hashes** between production and V1.5 at key heights to ensure chain consistency:
```powershell
# Production
blazecoin-cli.exe -rpcport=55413 getblockhash 2000000

# V1.5
blazecoin-cli.exe -rpcport=55415 getblockhash 2000000

# Hashes MUST match!
```
3. **Once V1.5 fully syncs to 4,000,000+**, test all RPC calls your Indexer API uses
4. **Gradually migrate** services by changing `ActiveWalletProfile` to `V1_5_Testing`
5. **Monitor for 48-72 hours** to ensure stability
6. **Decommission old wallet** once V1.5 is confirmed stable

### Phase 4: Production Rollout

1. **Create production V1.5 config** on default ports (55413/55414)
2. **Stop old production daemon**
3. **Backup old blockchain data** (optional, for rollback)
4. **Start V1.5 daemon on production ports**
5. **Update all services** to use V1.5
6. **Monitor and verify**

## Verification Checklist

After making code changes but before compiling:

- [ ] Added checkpoints up to block 4,000,000+
- [ ] Updated checkpoint timestamp and transaction count
- [ ] Searched for and increased any MAX_HEADERS limits
- [ ] Searched for and increased any MAX_BLOCK_HEIGHT limits
- [ ] Checked for fixed-size block index arrays
- [ ] Updated CLIENT_VERSION from 0.8.6.2 to 1.5.0.0
- [ ] Reviewed all changes in Git diff

After compiling:

- [ ] Binaries created successfully (blazecoind.exe, blazecoin-cli.exe)
- [ ] Version check shows 1.5.0.0: `blazecoin-cli.exe --version`
- [ ] Can start daemon with test config
- [ ] Can connect via RPC: `blazecoin-cli.exe -rpcport=55415 getinfo`

After initial sync testing:

- [ ] Syncs past block 500,000
- [ ] Syncs past block 1,000,000
- [ ] Syncs past block 2,000,000 (KEY MILESTONE!)
- [ ] Syncs past block 3,000,000
- [ ] Syncs past block 4,000,000
- [ ] Block hashes match production at all checkpoint heights
- [ ] RPC calls work correctly (getblockcount, getblockhash, getrawtransaction, etc.)

## Rollback Plan

If V1.5 encounters issues:

1. **Stop V1.5 daemon**
2. **Revert .NET services** to use production wallet (change `ActiveWalletProfile`)
3. **Keep V1.5 data** for debugging (don't delete)
4. **Review logs:** `C:\blazecoin-data\BlazecoinV1.5\debug.log`
5. **Investigate and fix** code issues
6. **Recompile and retry**

## Troubleshooting

### Sync Stops at Same Block Height
- **Cause:** Checkpoint validation failure or network issue
- **Solution:** Check debug.log for errors, verify checkpoint hashes are correct

### Compilation Errors
- **Cause:** Missing dependencies or incorrect library paths
- **Solution:** Install all prerequisites, check Makefile library paths

### RPC Connection Refused
- **Cause:** Daemon not running or wrong port
- **Solution:** Verify daemon is running with `tasklist | findstr blazecoin`, check config file

### "Blockchain data corrupted" Error
- **Cause:** Incomplete sync or database corruption
- **Solution:** Delete chainstate and blocks folders, resync from genesis

## Additional Resources

- **Original Blazecoin Repository:** https://github.com/wpstudio/blazecoin
- **Bitcoin Core Compilation Guide:** https://github.com/bitcoin/bitcoin/blob/master/doc/build-windows.md
- **Litecoin Build Instructions:** Similar to Bitcoin Core, good reference

## Support

For issues with:
- **C++ Wallet Code:** Review Bitcoin/Litecoin forums and documentation
- **.NET Integration:** Check your Indexer API logs and RPC client code
- **Blockchain Issues:** Use debug.log and blockchain explorers

## Change Log

### V1.5 (Planned)
- Increased header processing limits to 50,000,000 blocks
- Added checkpoints up to block 4,000,000
- Updated version identification
- Improved sync reliability for long-running chains

### 0.8.6.2 (Current)
- Based on Litecoin fork
- Basic scrypt mining
- 30-second block time
- Hardcoded limits suitable for <1,000,000 blocks

---

**Last Updated:** April 23, 2026
**Author:** AI Programming Assistant
**Status:** Ready for Implementation
