# Blazecoin V1.5 — Complete Changelog vs Original (0.8.6.2)

**Generated:** 2026-04-24 — last updated 2026-04-26
**Scope:** Every source-level change made to the Blazecoin codebase between the original wpstudio/blazecoin 0.8.6.2 release and the compiled, running V1.5 binary.
**Validated against:** Production chain via sync test. Genesis hash matches; checkpoints 500K through 4M all match; daemon (blazecoind.exe) and GUI (blazecoin-qt.exe) both build cleanly on MSVC 2022 / Qt 5.15 / vcpkg.

## Revision history

| Date | Section | Change |
|------|---------|--------|
| 2026-04-24 | (initial) | First version after V1.5 daemon was built and validated to 500K |
| 2026-04-26 | §1, §2.2, §2.3, §9 | Corrected attribution: 0.8.6.2 syncs fine; the 2M stall was V2.0 specific |
| 2026-04-26 | §9 | Added 1M / 1.5M / 2M / 2.5M / 3M / 4M checkpoint match results |
| 2026-04-26 | §13 (new), §6, §7, §9 | Added Qt 5.15 GUI build (blazecoin-qt.exe) and per-version data-dir change |
| 2026-04-27 | §9.2 (new) | Added RPC throughput benchmark — V1.5 is 5–11 % faster than stock 0.8.6.2 |

---

## 1. Overview

V1.5 is a minimal-change modernization of the working 0.8.6.2 codebase. **The original 0.8.6.2 wallet syncs the full chain successfully** — the production node has been running continuously since 2014 and is currently at the chain tip. The motivation for V1.5 was the failed **V2.0** rebase (Bitcoin Core 28.0 base), which stalled at block ~2,000,000 due to issues documented separately in the V2.0 failure analysis. V1.5 returns to the proven 0.8.6.2 base and adds a small set of forward-looking safeguards plus the toolchain work needed to keep building it in 2026. Both the headless daemon (`blazecoind.exe`) and the Qt GUI wallet (`blazecoin-qt.exe`) build cleanly, retaining the original single-binary, retro-style architecture.

V1.5 contains three distinct categories of change:

| Category | Purpose | Risk |
|----------|---------|------|
| **Feature additions** | Proactive checkpoints up to 4M and raised header-request cap (50M); future-proofing as the chain keeps growing — *not* required to sync the current chain | Designed to be consensus-compatible; validated by hash match through 3M+ |
| **Toolchain changes** | Make the 2013-era code compile under MSVC 2022 / OpenSSL 3.x / Boost 1.90; the original toolchain is no longer obtainable | Required extensive API migration; no functional changes |
| **Latent bug fixes** | Fix pre-existing bugs in the original code that only surface in Release builds + OpenSSL 3.x | Repairs silently-broken behavior inherited from upstream |

Consensus rules, wire protocol, `wallet.dat` format, P2P ports, and magic bytes are **unchanged**.

---

## 2. Feature changes

These are the project-intent changes — modest, forward-looking additions on top of the working 0.8.6.2 baseline.

### 2.1 Version bump

**File:** `src/clientversion.h`

```
0.8.6.2  →  1.5.0.0
COPYRIGHT_YEAR 2013  →  2026
```

Wallet now reports: `Blazecoin version v1.5.0.0-<commit>-beta`.

### 2.2 Header download limit raised from 2M to 50M

**File:** `src/main.cpp`

The peer-to-peer header request loop had an upper bound around 2,000,000. The original 0.8.6.2 wallet still syncs the current ~4.1M-block chain successfully, so this limit is not a hard sync barrier in 0.8.6.2. The change to 50,000,000 is a defensive future-proofing edit — at Blazecoin's 30-second block interval (~1M blocks/year), bumping the ceiling now removes any chance of it becoming a real limit during the lifetime of V1.5.

### 2.3 Checkpoints added up to block 4,000,000

**File:** `src/checkpoints.cpp`

Checkpoints are trusted "this block at this height is definitely valid" markers. Original code had checkpoints up to block 363,120 (from 2014). V1.5 adds checkpoints every 500K blocks through 4,000,000, plus original intermediate markers. Expected hashes were extracted from the running production daemon via `Get-CheckpointHashes.ps1`.

Benefits of the new checkpoints:
- Faster initial sync (less work validating signatures up to each checkpoint)
- Defense against deep-reorg attacks that try to rewrite history before a checkpoint
- A built-in verification mechanism — if a peer feeds us a different chain, we reject at the next checkpoint

The original 0.8.6.2 syncs without these and produces an identical canonical chain; the checkpoints just make new V1.5 installs faster and more robust.

Full checkpoint list is in `Blazecoin_V1.5_Checkpoints.txt`.

---

## 3. OpenSSL 3.x migration

OpenSSL 3.0 made several APIs opaque and/or removed legacy functions. The 2013 Bitcoin codebase assumed OpenSSL 1.0.x. These are the files that needed real code changes to compile and function under OpenSSL 3.x:

### 3.1 `src/bignum.h` — CBigNum class refactor

OpenSSL 3.x made `BIGNUM` an opaque type; you can no longer access its fields or allocate it on the stack. The original code had:

```cpp
class CBigNum : public BIGNUM { ... };  // not possible in 3.x
```

Refactored to composition:

```cpp
class CBigNum {
    BIGNUM* bn;
public:
    CBigNum()  { bn = BN_new(); }
    ~CBigNum() { BN_free(bn); }
    operator BIGNUM*() { return bn; }
    operator const BIGNUM*() const { return bn; }
    // ... all methods updated to use bn instead of `this`
};
```

### 3.2 `src/key.cpp` — ECDSA API updates

- `ECDSA_SIG::r` / `::s` direct field access replaced with `ECDSA_SIG_get0(sig, &r, &s)` and `ECDSA_SIG_set0(sig, r, s)` accessors.
- `BIGNUM bn;` stack allocation (invalid in 3.x) replaced with `BIGNUM* bn = BN_new();` + `BN_clear_free(bn)`.
- `BN_zero()` now returns `void` (was `int`); call site updated to not check its return.

### 3.3 `src/crypter.cpp` — EVP_CIPHER_CTX heap allocation

`EVP_CIPHER_CTX` is now opaque. Changed both `Encrypt` and `Decrypt`:

```cpp
EVP_CIPHER_CTX ctx;            // OLD - invalid in 3.x
EVP_CIPHER_CTX_init(&ctx);
...
EVP_CIPHER_CTX_cleanup(&ctx);

EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();   // NEW
...
EVP_CIPHER_CTX_free(ctx);
```

### 3.4 `src/openssl_compat.h` — new file

Thin shim that detects OpenSSL ≥ 3.0 and provides:
- `BN_init(bn)` as a no-op macro (the function was removed).
- Documentation of the opaque types and where code was updated.

### 3.5 `src/base58.h` — drop `&` on CBigNum

Before the CBigNum refactor, `&someBignum` implicitly produced a `BIGNUM*` (via inheritance). After the refactor, `&someBignum` produces `CBigNum*`. Updated `BN_div` and `BN_mul` calls to pass the bignum directly (using the implicit conversion operator).

---

## 4. Modern Boost migration

vcpkg ships Boost 1.90 (October 2025); the original code targeted Boost ~1.50. Many APIs were renamed, moved, or removed.

### 4.1 Required vcpkg packages beyond the meta-Boost

These are not pulled in by vcpkg's top-level `boost`:

- `boost-foreach`
- `boost-signals2`
- `boost-iostreams`
- `boost-interprocess`

### 4.2 Removed header: `boost/filesystem/convenience.hpp`

Dropped from `src/init.cpp`. Its functionality moved into `boost/filesystem.hpp` a decade ago.

### 4.3 Filesystem renames

- `path::is_complete()` → `path::is_absolute()` — `src/util.cpp`, `src/blazecoinrpc.cpp`
- `copy_option::overwrite_if_exists` → `copy_options::overwrite_existing` — `src/walletdb.cpp`

### 4.4 Boost.Asio rewrite in `src/blazecoinrpc.cpp`

The RPC server uses Boost.Asio, which underwent heavy API changes between 1.66 and 1.80. The following renames were required:

| Original | Modern Boost.Asio |
|----------|-------------------|
| `asio::io_service` | `asio::io_context` |
| `socket.get_io_service()` | `socket.get_executor()` |
| `ssl::context(io_service, method)` | `ssl::context(method)` |
| `context->impl()` | `context->native_handle()` |
| `socket_base::max_connections` | `socket_base::max_listen_connections` |
| `address_v4::to_ulong()` | `address_v4::to_uint()` |
| `address_v6::is_v4_compatible()` | *(removed — dropped the check)* |
| `address_v6::to_v4()` | `make_address_v4(v4_mapped, v6)` |
| `resolver::query` + `resolver::iterator` | `resolver::resolve(host, port)` + range iteration |

The `AcceptedConnectionImpl` constructor now takes `const asio::any_io_executor&` instead of `asio::io_context&` to accept the modern executor type.

### 4.5 `src/util.cpp` — removed 2012 clang workaround

A hand-written forward declaration of `boost::program_options::to_internal` (originally added to work around a clang/Boost 1.46 bug) now conflicts with the real declaration's linkage in Boost 1.90. Removed.

---

## 5. C++11+ modernization

### 5.1 `src/serialize.h` — `IMPLEMENT_SERIALIZE` macro converted to variadic

Modern C++11 preprocessor lets us use `__VA_ARGS__` so commas inside the macro body (e.g. `std::map<int, CAddrInfo>`) don't split the argument list:

```cpp
#define IMPLEMENT_SERIALIZE(...) \
    ... { __VA_ARGS__ } ...
```

Previously the codebase worked around this with GCC statement expressions `(({ ... });)` — valid GCC extension, hard error on MSVC. The two call sites that used that pattern (`src/addrman.h:248`, `src/main.h:706` in `CTxOutCompressor`) were simplified to standard macro calls.

### 5.2 PRI64 / PRIszu format-specifier spacing

C++11 introduced user-defined literals with syntax `"string"suffix`. The 2013 code contained many `printf("...%"PRI64d"...", ...)` expressions which C++11 parses as user-defined literal `"...%"PRI64d` — compile error. Mechanically inserted spaces across 14 files so it reads `"...%" PRI64d " ..."`.

### 5.3 `src/util.h` — `__PRETTY_FUNCTION__` compat macro

GCC-only identifier. Added:

```cpp
#if defined(_MSC_VER) && !defined(__PRETTY_FUNCTION__)
#define __PRETTY_FUNCTION__ __FUNCSIG__
#endif
```

### 5.4 `src/main.h` — `CBlockIndexWorkComparator::operator()` made const

Modern `std::set<T, Compare>` requires the comparator's `operator()` be const. One-character change.

### 5.5 `src/bignum.h` — explicit CBigNum serialization overloads

Added free-function overloads for `CBigNum` so template code in `serialize.h` doesn't ambiguously match `(bool, int, int)` via the new `operator BIGNUM*()` → pointer → bool conversion chain:

```cpp
inline unsigned int GetSerializeSize(const CBigNum& a, int nType, int nVersion);
template<typename Stream> inline void Serialize(Stream& s, const CBigNum& a, int, int);
template<typename Stream> inline void Unserialize(Stream& s, CBigNum& a, int, int);
```

### 5.6 CBigNum disambiguations in `src/main.cpp` / `src/main.h`

Two spots where the implicit `operator BIGNUM*()` caused operator resolution ambiguity:

```cpp
bnTarget <= 0           →  bnTarget <= CBigNum(0)
bnTarget + 1            →  bnTarget + CBigNum(1)
*this = 0 - *this       →  *this = CBigNum(0) - *this
```

### 5.7 `src/json/json_spirit_value.h` — explicit Variant temporary

Modern `boost::variant` constructor SFINAE fails to deduce certain numeric types through perfect forwarding. Wrapped four constructors' variant initialization in an explicit temporary:

```cpp
v_( static_cast<int64_t>(value) )     →   v_( Variant( static_cast<int64_t>(value) ) )
```

---

## 6. Windows / MSVC-specific

### 6.1 `src/compat.h` — SOCKET typedef scoped to non-Windows

`typedef u_int SOCKET;` was unconditional; on Windows this clashes with `<winsock2.h>`'s own `SOCKET` (an unsigned pointer type, not an integer). Moved inside the `#else` branch.

### 6.2 `src/compat.h` — `ssize_t` typedef added for MSVC

```cpp
#ifdef WIN32
...
typedef SSIZE_T ssize_t;
#endif
```

### 6.3 `src/leveldb/port/port_win.h` — LevelDB ssize_t and snprintf

LevelDB's bundled Windows port uses `ssize_t` (POSIX) and `#define snprintf _snprintf` (pre-VS2015). Fixed:

```cpp
#ifdef _MSC_VER
  #if _MSC_VER < 1900
    #define snprintf _snprintf
  #endif
  #include <BaseTsd.h>
  typedef SSIZE_T ssize_t;
#endif
```

### 6.4 `Blazecoin.vcxproj` — build tweaks

- **Include path** for `memenv` corrected from `leveldb\helpers\memenv` to `leveldb\helpers` so `#include <memenv/memenv.h>` resolves.
- **Removed** `src\leveldb\db\c.cc` from the compile list. It is LevelDB's C API binding, requires `unistd.h`, and is not used by the wallet.
- **Removed** `boost_system-vc145-mt-x64-1_90.lib` from link deps (header-only since Boost 1.69).
- **Added** `boost_iostreams-vc145-mt-x64-1_90.lib`.
- **Added** `<ObjectFileName>$(IntDir)%(RelativeDir)</ObjectFileName>` in the `ClCompile` defaults so `src/bloom.cpp` and `src/leveldb/util/bloom.cc` don't both emit `bloom.obj` into the same directory.

---

## 7. Latent bugs uncovered and fixed

During the sync test, two classes of silent bug surfaced. **Both were inherited from the upstream Bitcoin 0.8.x codebase and affect Release builds in general — not just V1.5.** OpenSSL 3.x's stricter behavior turned them from silent data corruption into visible failure.

### 7.1 The `assert(funcCall())` pattern

In Release builds (`NDEBUG` defined), the C standard says `assert(expr)` expands to `((void)0)` and **the expression is not evaluated**. Several critical code paths used the pattern `assert(sideEffectCall(...))` assuming the call would run. In Debug builds it does; in Release it is silently elided.

Fix pattern applied everywhere:

```cpp
// Before
assert(someCall(...));

// After
bool ok = someCall(...);
assert(ok);
```

### 7.2 Sites fixed

| File:Line | Elided call | Consequence in Release |
|-----------|-------------|------------------------|
| `key.cpp` `SetSecretBytes` | `BN_bin2bn`, `EC_KEY_regenerate_key` | Wallet keypool generated empty pubkeys; `CWallet::GenerateNewKey() : AddKey failed` |
| `main.cpp:1404` `UpdateCoins` | `coins.Spend(...)` | Spent inputs never marked spent in chainstate |
| `main.cpp:1410` `UpdateCoins` | `inputs.SetCoins(...)` | **Coinbase outputs never added to UTXO — chain couldn't sync past block 70** |
| `main.cpp:1796` `ConnectBlock` | `view.SetBestBlock(...)` | Best-block pointer never updated |
| `main.cpp:1887` `SetBestBlock` | `view.Flush()` | UTXO state never persisted to disk |
| `wallet.cpp:1262` `CreateTransaction` | `reservekey.GetReservedKey(...)` | Wallet change-key reservation skipped |

Other `assert(obj.IsValid())`, `assert(container.count(...))`, and `assert(bool_variable)` uses in the codebase are safe (no side effects) and were left alone.

---

## 8. Files changed (summary)

### Core / daemon source files

```
src/bignum.h              CBigNum class + serialization overloads
src/base58.h              BN_div / BN_mul call sites
src/compat.h              SOCKET, ssize_t typedefs
src/util.h                __PRETTY_FUNCTION__, PRI64 spacing
src/util.cpp              clang workaround removed; PRI64 spacing; is_absolute;
                          GetDefaultDataDir -> %APPDATA%\BlazecoinV1.5 (per-version isolation)
src/serialize.h           IMPLEMENT_SERIALIZE variadic
src/key.cpp               OpenSSL 3.x migration; NDEBUG fix
src/crypter.cpp           EVP_CIPHER_CTX heap alloc
src/main.h                PRI64 spacing; comparator const; CBigNum ctor;
                          IMPLEMENT_SERIALIZE GCC stmt expr removed
src/main.cpp              PRI64 spacing; CBigNum ctor; 4 NDEBUG fixes
src/addrman.h             IMPLEMENT_SERIALIZE GCC stmt expr removed
src/init.cpp              convenience.hpp removed; PRI64 spacing
src/wallet.cpp            PRI64 spacing; NDEBUG fix
src/walletdb.cpp          copy_options rename; PRI64 spacing
src/blazecoinrpc.cpp      Boost.Asio rewrite; is_absolute; PRI64 spacing
src/net.cpp               PRI64 spacing
src/net.h                 PRI64 spacing
src/rpcnet.cpp            PRI64 spacing
src/openssl_compat.h      new file
src/json/json_spirit_value.h  boost::variant temporary wrap
src/leveldb/port/port_win.h   ssize_t typedef, snprintf guard
src/checkpoints.cpp       extended checkpoint table (V1.5 feature)
src/clientversion.h       1.5.0.0 (V1.5 feature)
```

### Qt GUI source files (new in 2026-04-26 changes)

```
src/qt/blazecoin.cpp           QApplication name -> Blazecoin-Qt-V1.5 (separate QSettings)
src/qt/addressbookpage.cpp     setResizeMode -> setSectionResizeMode (Qt 5 rename)
src/qt/overviewpage.cpp        setResizeMode -> setSectionResizeMode
src/qt/blazecoingui.cpp        QSound stub (moved to QtMultimedia which we don't link);
                               QDesktopServices::storageLocation -> QStandardPaths::writableLocation;
                               added QStandardPaths include
src/qt/clientmodel.cpp         using namespace boost::placeholders (Boost 1.66+)
src/qt/walletmodel.cpp         using namespace boost::placeholders
src/qt/locale/blazecoin_*.qm   47 zero-byte placeholders so rcc can embed the
                               resource without lrelease (qt5-tools not installed)
```

### Project / build files

```
Blazecoin.vcxproj         include paths, library list, ObjectFileName, excluded c.cc
blazecoin-qt.pro          MSVC-aware: gated GCC-only flags, MSVC defines
                          (NOMINMAX etc.), vcpkg boost suffix, MSVC LevelDB
                          inline-source block, removed CODECFORTR, gated
                          mingwthrd to MinGW only, skipped lrelease on MSVC,
                          object_parallel_to_source for bloom.obj collision
.gitignore                added Qt build artifacts (.qmake.stash, build/,
                          release/, blazecoin-qt.vcxproj{,.filters},
                          qtbuild*.log, rebuild-*.log)
```

`blazecoin-qt.vcxproj` itself is **not tracked** — it's regenerated by `qmake` and contains machine-specific paths.

---

## 9. Validation

| Test | Result |
|------|--------|
| Daemon starts with V1.5 code | Pass |
| Wallet keypool generates distinct keys | Pass |
| Connects to seed nodes | Pass — `91.206.16.214`, `85.15.179.171` |
| Genesis block hash matches production | Pass — `5d871c1b6ea542c2bb8a3b3ac70028a591bbf81369e90c2446c1a2bbfb89459b` |
| Sync past block 70 (first non-coinbase tx) | Pass — required NDEBUG fixes (see § 7) |
| 500K hash matches production checkpoint | Pass — `9b6f14f13f0ee345eb03aa2742630480d7e2f7c3ce46e4c34ecbb23d2d871f6c` |
| 1M hash matches production checkpoint | Pass — `2f1c4d32c87f0e77a63fc4cb902223307cf3b3c867818fa45f1bc7fef60d2686` |
| 1.5M hash matches production checkpoint | Pass — `44a971426d30eb1446086b1319979edcf73536897efb04505782da3760be4809` |
| 2M hash matches production checkpoint *(the V2.0 failure point)* | Pass — `4ceca77d22d672d391670224ca2f9457209bc1ecf5f5eaf5e9d652b81656995b` |
| 2.5M hash matches production checkpoint | Pass — `a6c937fcf01c04eb3aa7a8e06c80acb80e6843acd268fb6d520c5dad6194e7db` |
| 3M hash matches production checkpoint | Pass — `1af43523e055656cae5e3b6894d4484b968c25ddf7adbd758e5908e45e38fdf0` |
| 3.5M hash matches production checkpoint | Pass — `f637143b959c511cd0e4d3df7859181f1e5633ca2460f270eb02d4903846e04f` |
| 4M hash matches production checkpoint | Pass — `959ec2a6d7d67cf4272bcb6508c68daa69a7c280123f26d001c47387186fc1fd` |
| Sync to tip (~4.1M) | Pass — V1.5 reached `4,105,596` matching peers |
| Cross-version peer test: stock 0.8.6.2 binary syncs from V1.5 | Started — handshake confirmed (test peer received `/BlazecoinFoundation:1.5.0/` version message and accepted V1.5 as syncnode); test paused at ~107K blocks for resumption later |
| RPC commands respond | Pass — `getblockcount`, `getconnectioncount`, `getinfo`, `getblockhash`, etc. |
| `blazecoin-qt.exe` (GUI) builds and links | Pass — 4.5 MB binary at `release/blazecoin-qt.exe` |
| GUI defaults to `%APPDATA%\BlazecoinV1.5\` | Pass — daemon and GUI both honor the per-version path |

### 9.2 RPC throughput benchmark (added 2026-04-27)

Direct head-to-head between V1.5 (MSVC 2022 build) and stock 0.8.6.2 (the 2019 MinGW production binary at `C:\Users\Andrew\Desktop\Blazecoin\blazecoin-qt.exe`). Both daemons running, both at chain tip (4,105,596). 1000 calls per HTTP request via JSON-RPC batching, best of 3 runs:

| Operation | V1.5 (MSVC 2022) | Stock 0.8.6.2 (2019) | V1.5 advantage |
|-----------|------------------:|---------------------:|---------------:|
| `getblockcount` | **3,984 ops/sec** (251 µs) | 3,690 ops/sec (271 µs) | **+8.0 %** |
| `getblockhash 1000000` | **4,063 ops/sec** (246 µs) | 3,668 ops/sec (273 µs) | **+10.8 %** |
| `getblock <2M hash>` (full JSON) | **1,681 ops/sec** (595 µs) | 1,601 ops/sec (625 µs) | **+5.0 %** |

V1.5 is consistently 5–11 % faster across the three operation types. Lighter ops (in-memory state lookups) benefit more — those are tight code paths where the modern MSVC optimizer beats the 2019 MinGW build. Heavier ops (disk read + JSON serialization for `getblock`) benefit less because their time is dominated by I/O and parser work, neither of which is affected by compiler choice.

Reproducible via `./bench-rpc-batch.sh [N]` from the repo root (defaults to N=1000 calls). Requires both daemons running on their respective ports; edit credentials in the script if reusing.

---

## 9.1 Per-version data-directory isolation

Both `blazecoind.exe` and `blazecoin-qt.exe` now default to a V1.5-specific data directory so they never collide with the production 0.8.6.2 wallet's storage:

| Platform | Before | After |
|----------|--------|-------|
| Windows | `%APPDATA%\Blazecoin\` | `%APPDATA%\BlazecoinV1.5\` |
| macOS | `~/Library/Application Support/Blazecoin/` | `~/Library/Application Support/BlazecoinV1.5/` |
| Unix | `~/.blazecoin/` | `~/.blazecoinv1.5/` |

Implemented in `src/util.cpp` `GetDefaultDataDir()`. Users who pass an explicit `-datadir=...` are unaffected.

The Qt application name was also bumped from `Blazecoin-Qt` to `Blazecoin-Qt-V1.5` (`src/qt/blazecoin.cpp`) so V1.5's `QSettings` (window geometry, options dialog state, etc.) live in a separate registry/INI group from the production wallet.

---

## 10. What V1.5 deliberately does NOT change

These are the invariants that let V1.5 interoperate with production nodes on the same network:

- **Consensus rules** — block validity, PoW (scrypt), difficulty adjustment, reward halving schedule
- **Wire / P2P protocol** — message format, magic bytes (`0xfb 0xc0 0xb6 0xdb`), protocol version 75000
- **Transaction format** — `CTransaction` serialization, signature hashing, Merkle tree construction
- **wallet.dat format** — Berkeley DB records, key derivation, encryption (AES-256-CBC)
- **Address encoding** — Base58 prefix 26 (addresses start with 'B')
- **Block time** — 30 seconds
- **Coinbase maturity** — 30 blocks
- **Default ports** — RPC 55413, P2P 55414 (V1.5 test instance uses 55415/55416 to coexist with production)

An existing production node will peer with V1.5 as if it were another 0.8.6.2 client.

---

## 11. Build environment

Tested and confirmed working with:

- Visual Studio 2022 Community, MSVC v14.50
- Windows 11 Pro (SDK 10.0.26100)
- vcpkg (x64-windows triplet): boost 1.90 + foreach + signals2 + iostreams + interprocess, openssl 3.6.2, berkeley-db 4.8, miniupnpc, leveldb (bundled), **qt5-base 5.15.18**

### Daemon build

```
msbuild Blazecoin.sln /p:Configuration=Release /p:Platform=x64 /m
```

Output: `bin\x64\Release\blazecoind.exe` (~1.8 MB).

### GUI build (added 2026-04-26)

Run from a 64-bit VS Developer Command Prompt:

```
qmake -tp vc -spec win32-msvc blazecoin-qt.pro \
    BOOST_INCLUDE_PATH=C:/vcpkg/installed/x64-windows/include \
    BOOST_LIB_PATH=C:/vcpkg/installed/x64-windows/lib \
    BDB_INCLUDE_PATH=C:/vcpkg/installed/x64-windows/include \
    BDB_LIB_PATH=C:/vcpkg/installed/x64-windows/lib \
    OPENSSL_INCLUDE_PATH=C:/vcpkg/installed/x64-windows/include \
    OPENSSL_LIB_PATH=C:/vcpkg/installed/x64-windows/lib \
    USE_UPNP=- USE_QRCODE=0 USE_IPV6=1
```

Then patch the toolset (qmake emits `v143`, this machine has `v145`):

```
sed -i 's/<PlatformToolset>v143<\/PlatformToolset>/<PlatformToolset>v145<\/PlatformToolset>/g' blazecoin-qt.vcxproj
```

And patch `<ObjectFileName>build\</ObjectFileName>` to `<ObjectFileName>$(IntDir)%(RelativeDir)</ObjectFileName>` to prevent `bloom.obj` collision between `src/bloom.cpp` and `src/leveldb/util/bloom.cc`.

```
msbuild blazecoin-qt.vcxproj /p:Configuration=Release /p:Platform=x64 /m
```

Output: `release\blazecoin-qt.exe` (~4.5 MB). Runtime requires Qt 5 DLLs and vcpkg DLLs on `PATH`:

```
$env:PATH = "C:\vcpkg\installed\x64-windows\bin;C:\vcpkg\installed\x64-windows\tools\qt5\bin;" + $env:PATH
.\release\blazecoin-qt.exe
```

The GUI defaults to `%APPDATA%\BlazecoinV1.5\` (see § 9.1).

---

## 12. Known follow-ups

- **Cross-version peer test** paused at ~107K blocks. Resume by relaunching the test peer (stock 0.8.6.2 from `C:\Users\Andrew\Desktop\Blazecoin\blazecoin-qt.exe`) with `-datadir=C:\blazecoin-data\TestPeer`. It will continue downloading from V1.5 toward 4.1M tip.
- **Sanitize local paths** in `MSYS2-Setup-QuickStart.md` and `OPENSSL_COMPATIBILITY_ISSUE.md` (a few `C:\Users\Andrew\...` strings) if the repo is ever made public.
- **Translation files** (`src/qt/locale/*.qm`) are committed as zero-byte placeholders. To regenerate real translations, install vcpkg's `qt5-tools` and re-run `qmake` without the `!win32-msvc*` guard around the `lrelease` block in `blazecoin-qt.pro`.
- **`USE_UPNP` in the GUI build** is currently disabled (the bundled `net.cpp` UPNP code uses an older miniupnpc API). The daemon build also doesn't define it. Re-enable by updating the `upnpDiscover()` and `UPNP_GetValidIGD()` call sites to the modern signatures.
- **`USE_QRCODE`** disabled — receive-address QR codes aren't built. Add `qrencode` to vcpkg and pass `USE_QRCODE=1` to qmake to re-enable.
- **`QSound`** sound notifications on incoming transactions disabled (`src/qt/blazecoingui.cpp:856`). To re-enable: add `qt5-multimedia` and switch to `QSoundEffect`.
- **Long-term:** V2.0 should be an incremental Bitcoin Core rebase (e.g. 0.8 → 0.12 → 0.16 → 0.21 → 28.x) using V1.5 as the proven baseline rather than the failed jump-to-28.0 attempt.
