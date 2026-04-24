# Blazecoin Core V1.5 - Implementation Checklist

Use this checklist to track your progress through the upgrade process.

## Phase 1: Preparation ☐

- [ ] Production Blazecoin daemon is running and fully synced
- [ ] Confirmed current block height is 4,000,000+ blocks
- [ ] C++ wallet source code cloned to: `C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\`
- [ ] All documentation files created and reviewed:
  - [ ] `Blazecoin_V1.5_README.md`
  - [ ] `Blazecoin_V1.5_Upgrade_Guide.md`
  - [ ] `Get-CheckpointHashes.ps1`

## Phase 2: Checkpoint Extraction ☐

- [ ] Edited `Get-CheckpointHashes.ps1` with correct RPC credentials
- [ ] Ran the PowerShell script successfully
- [ ] `Blazecoin_V1.5_Checkpoints.txt` file created
- [ ] Verified checkpoint hashes look correct (64-character hex strings)
- [ ] Copied checkpoint data for next step

**Checkpoints Extracted:**
- [ ] Block 500,000: `______________________________________`
- [ ] Block 1,000,000: `______________________________________`
- [ ] Block 1,500,000: `______________________________________`
- [ ] Block 2,000,000: `______________________________________`
- [ ] Block 2,500,000: `______________________________________`
- [ ] Block 3,000,000: `______________________________________`
- [ ] Block 3,500,000: `______________________________________`
- [ ] Block 4,000,000: `______________________________________`

## Phase 3: Code Modification ☐

### File: `src/checkpoints.cpp`
- [ ] Opened file in editor
- [ ] Replaced `mapCheckpoints` with new checkpoint data
- [ ] Updated `CCheckpointData` timestamp
- [ ] Saved changes

### Search for Hardcoded Limits
- [ ] Ran search command: `Select-String -Pattern "2000000|MAX.*HEADER|MAX.*BLOCK.*HEIGHT" -Path *.h,*.cpp`
- [ ] **Found limits?** (Circle one): YES / NO
  - If YES, list files and line numbers:
    - [ ] File: `_______________` Line: `___` Changed to: **50,000,000**
    - [ ] File: `_______________` Line: `___` Changed to: **50,000,000**
    - [ ] File: `_______________` Line: `___` Changed to: **50,000,000**

### File: `src/clientversion.h`
- [ ] Opened file in editor
- [ ] Changed version from 0.8.6.2 to 1.5.0.0
- [ ] Saved changes

### Git Status Check
- [ ] Ran `git diff` to review all changes
- [ ] Verified changes look correct
- [ ] **Optional:** Created a branch: `git checkout -b v1.5-header-fix`
- [ ] **Optional:** Committed changes: `git commit -am "V1.5: Fix header limits for 4M+ blocks"`

## Phase 4: Compilation ☐

### Prerequisites
- [ ] Visual Studio C++ tools installed (OR MinGW-w64)
- [ ] Qt 4.8/5.x installed (for GUI wallet)
- [ ] Boost libraries installed
- [ ] OpenSSL installed
- [ ] Berkeley DB 4.8 installed

### Build Process
- [ ] Navigated to: `C:\Users\Andrew\source\repos\Blazecoin_Core_V1.5\`
- [ ] **Method used:** (Circle one): MinGW / Visual Studio / Qt Creator
- [ ] Ran build command: `________________________________`
- [ ] Build completed successfully

### Output Verification
- [ ] `blazecoind.exe` created
- [ ] `blazecoin-cli.exe` created
- [ ] `blazecoin-qt.exe` created (if building GUI)
- [ ] Verified version: `blazecoin-cli.exe --version` shows `1.5.0.0`

### Build Issues (if any)
- [ ] No issues encountered
- Issues encountered (describe):
  ```
  _____________________________________________________________
  _____________________________________________________________
  _____________________________________________________________
  ```
- Resolution:
  ```
  _____________________________________________________________
  _____________________________________________________________
  ```

## Phase 5: Testing Environment Setup ☐

### Directory Creation
- [ ] Created: `C:\blazecoin-data\BlazecoinV1.5\`

### Configuration File
- [ ] Created: `C:\blazecoin-data\BlazecoinV1.5\blazecoin.conf`
- [ ] Set `rpcuser=blazecoin_v15_user`
- [ ] Set strong `rpcpassword=________________`
- [ ] Set `rpcport=55415`
- [ ] Set `port=55416`
- [ ] Set `txindex=1`
- [ ] Added seed nodes

### First Start
- [ ] Started V1.5 daemon with test config
- [ ] Daemon started successfully
- [ ] Can connect via RPC: `blazecoin-cli.exe -rpcport=55415 getinfo`
- [ ] Initial peer connections established

## Phase 6: Sync Testing ☐

### Milestone: Block 500,000
- [ ] Reached block 500,000
- [ ] Date/Time reached: `_______________`
- [ ] Block hash matches checkpoint: YES / NO
  - Production hash: `______________________________________`
  - V1.5 hash:       `______________________________________`

### Milestone: Block 1,000,000
- [ ] Reached block 1,000,000
- [ ] Date/Time reached: `_______________`
- [ ] Block hash matches checkpoint: YES / NO

### Milestone: Block 2,000,000 ⭐ CRITICAL
- [ ] Reached block 2,000,000
- [ ] Date/Time reached: `_______________`
- [ ] Block hash matches production: YES / NO
- [ ] **SYNC DID NOT STOP** - Fix confirmed working!

### Milestone: Block 3,000,000
- [ ] Reached block 3,000,000
- [ ] Date/Time reached: `_______________`
- [ ] Block hash matches checkpoint: YES / NO

### Milestone: Block 4,000,000+
- [ ] Reached current tip (4,000,000+)
- [ ] Date/Time reached: `_______________`
- [ ] Final height: `_______________`
- [ ] Block hash matches production: YES / NO

### Sync Issues (if any)
- [ ] No issues encountered
- Issues encountered:
  ```
  _____________________________________________________________
  _____________________________________________________________
  _____________________________________________________________
  ```
- Check `C:\blazecoin-data\BlazecoinV1.5\debug.log` for errors

## Phase 7: RPC Testing ☐

Test all RPC commands your Indexer API uses:

- [ ] `getinfo` - Returns correct info
- [ ] `getblockcount` - Returns correct height
- [ ] `getblockhash <height>` - Works correctly
- [ ] `getblock <hash>` - Returns block data
- [ ] `getrawtransaction <txid>` - Works with txindex
- [ ] `getbestblockhash` - Returns current tip
- [ ] `getdifficulty` - Returns current difficulty
- [ ] Other commands used by your API:
  - [ ] `_______________`
  - [ ] `_______________`

## Phase 8: .NET Integration Testing ☐

### Configuration Update
- [ ] Updated `Blazecoin_Indexer_API/appsettings.json`
- [ ] Added `V1_5_Testing` profile with port 55415
- [ ] Set `ActiveWalletProfile` to `V1_5_Testing`

### API Testing
- [ ] Started Indexer API in test mode
- [ ] API connects to V1.5 daemon successfully
- [ ] Block indexing works correctly
- [ ] Transaction indexing works correctly
- [ ] Address analytics work correctly
- [ ] Supply calculations work correctly
- [ ] No errors in API logs

### Monitoring Period
- [ ] Monitored for 24 hours - Status: `_______________`
- [ ] Monitored for 48 hours - Status: `_______________`
- [ ] Monitored for 72 hours - Status: `_______________`

## Phase 9: Production Deployment ☐

**⚠️ Only proceed if ALL above tests passed!**

### Pre-Deployment Checklist
- [ ] V1.5 fully synced and stable for 72+ hours
- [ ] All block hashes verified against production
- [ ] All RPC commands tested and working
- [ ] .NET API tested and working
- [ ] Backup of production wallet.dat created
- [ ] Backup of production blockchain data created (optional)
- [ ] Deployment plan documented
- [ ] Rollback plan documented

### Deployment Window
- [ ] Scheduled maintenance window: `_______________`
- [ ] Notified users/stakeholders
- [ ] Stopped old production daemon
- [ ] Verified old daemon stopped
- [ ] Configured V1.5 for production ports (55413/55414)
- [ ] Started V1.5 daemon on production ports
- [ ] Verified V1.5 daemon running
- [ ] Updated .NET services to use V1.5
- [ ] Restarted all dependent services:
  - [ ] Indexer API
  - [ ] MVC Web App
  - [ ] Mining Pool API
  - [ ] Other: `_______________`

### Post-Deployment Verification
- [ ] All services connected to V1.5 successfully
- [ ] Block height correct
- [ ] Transaction processing working
- [ ] Website functioning correctly
- [ ] Mining pool functioning correctly
- [ ] No errors in any logs

### Monitoring Schedule
- [ ] Hour 1: Status `_______________`
- [ ] Hour 4: Status `_______________`
- [ ] Hour 12: Status `_______________`
- [ ] Day 1: Status `_______________`
- [ ] Day 2: Status `_______________`
- [ ] Day 3: Status `_______________`
- [ ] Week 1: Status `_______________`

## Phase 10: Cleanup ☐

- [ ] Decommissioned old wallet daemon
- [ ] Archived old blockchain data (if space needed)
- [ ] Removed test V1.5 configuration (port 55415/55416)
- [ ] Updated documentation
- [ ] **Optional:** Pushed V1.5 code changes to GitHub
- [ ] **Optional:** Created release tag: `v1.5.0`

## Issues & Notes

Use this space to track any issues encountered or important notes:

```
Date: __________ Issue/Note: _____________________________________________
_________________________________________________________________________
_________________________________________________________________________

Date: __________ Issue/Note: _____________________________________________
_________________________________________________________________________
_________________________________________________________________________

Date: __________ Issue/Note: _____________________________________________
_________________________________________________________________________
_________________________________________________________________________
```

## Final Sign-Off

- [ ] V1.5 upgrade completed successfully
- [ ] Production system stable
- [ ] All stakeholders notified
- [ ] Documentation updated

**Completed by:** `_______________`  
**Date:** `_______________`  
**Final Block Height:** `_______________`  
**Status:** ☐ Success ☐ Partial Success ☐ Issues Remain

---

**Notes:**
- Print this checklist or keep it open while working
- Check off items as you complete them
- Document any issues immediately
- Don't skip testing phases!
- When in doubt, refer to the full guide

**Last Updated:** April 23, 2026
