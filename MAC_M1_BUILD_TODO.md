# Blazecoin V1.5 — macOS (Apple Silicon / M1) Build Notes

Status:
- ☑ **Daemon (`blazecoind`) builds and runs natively on arm64 + x86_64** (built separately in each tree, not yet lipo-merged into a universal binary). End-to-end tested: peer connections, block download, scrypt PoW verification, wallet creation, JSON-RPC, clean shutdown.
- ☑ **Qt GUI (`Blazecoin-Qt.app`) builds and runs natively on arm64 + x86_64.**
- ☑ **Deployed (self-contained):** `macdeployqt` + transitive Boost deps + ad-hoc codesign. Bundle no longer needs Homebrew on the target Mac.
- ☑ **Universal (arm64 + x86_64) GUI complete.** All 58 Mach-O files in the bundle are fat binaries. Both slices verified to launch on the build host (arm64 native, x86_64 via Rosetta). Bundle is 112 MB.
- ☑ **Build polish landed:** HiDPI Retina rendering, Retina-aware `.icns`, and the `~BlazecoinGUI` shutdown crash fix.
- ☑ **UX / theming polish landed** (during real-world testing on this branch):
  - In-app icon swapped from the gold coin to the red phoenix-in-circle from the header logo, centered on the canvas.
  - App display name is "Blazecoin V1.5" everywhere (CFBundleName/CFBundleDisplayName + bundle rename).
  - QMessageBox dialogs themed black/red/white to match the GUI; question dialogs use a custom white "?" via a `QProxyStyle` override.
  - Data-entry widgets (`QLineEdit`, `QComboBox`, `QAbstractSpinBox`, `QTextEdit`) globally given a white background + dark `#1c1c1c` text; combobox popups themed; spinbox up/down buttons get explicit arrow PNGs.
  - Bottom-right status indicator (`label_blaze`) blinks every 1s while syncing, holds solid red when caught up; `blaze_icon_on.png` re-coloured to BlazeCoin red while preserving the original meridian alpha.
- ☑ Installed to `/Applications/Blazecoin V1.5.app` (qmake builds `Blazecoin-Qt.app`; renamed post-deploy so Finder/Dock show "Blazecoin V1.5").
- ◐ **Real-world testing in progress** — chain sync + Send/Receive flows are being exercised on the build host. No data-integrity issues found; remaining feedback has been cosmetic and is captured in the commits above.
- ☐ Lipo-merge `blazecoind` arm64 + x86_64 into a universal CLI binary if you plan to ship the daemon alongside the GUI.
- ☐ End-to-end test on a clean Mac (no Homebrew) — both Apple Silicon and Intel.
- ☑ **GitHub release published:** `v1.5.0-macos.1` — https://github.com/AMA-CSharp-Code/Blazecoin_Wallet_Core_V1.5/releases/tag/v1.5.0-macos.1 (universal zip + SHA-256 `588f60d0…`, ad-hoc signed, first-run instructions in the notes).

The repo's existing build instructions (`START_HERE.md`, `MSYS2-Setup-QuickStart.md`, `VISUAL_STUDIO_BUILD_READY.md`) are Windows-only. This document captures the macOS port.

---

## Session checkpoint (2026-08-26) — Phoenix-413 on the macOS branch

**What happened:** the Phoenix-413 retarget (V1.5.2, INERT — `dev` commit `2ad8af7`)
was cherry-picked onto `macos-v1.5.0` as `fb94a58`, built, and installed.

- **Cherry-pick:** `src/main.cpp` merged clean (its hunks don't touch the branch's
  `boost::filesystem` fix). Hand-resolved: `.gitignore` (kept both sides +
  `src/test-phoenix413` for the Mac harness binary), `src/clientversion.h`
  (0 → **2**, `IS_RELEASE false`), Technical Changelog (took the §2.4 body +
  Phoenix table row only — dev's Aug doc-hygiene rows reference sections this
  branch's copy doesn't have).
- **Vector harness — PASS 45/45 on BOTH arches** (consensus code proven bit-exact):
  arm64: `clang++ -O2 -I/opt/homebrew/opt/openssl@3/include src/test-phoenix413.cpp -L/opt/homebrew/opt/openssl@3/lib -lcrypto`
  x86_64: same under `arch -x86_64` against `/usr/local/opt/openssl@3`.
- **x64 tree cleaned up:** it had sat on `dev` with the May macOS patches as
  *uncommitted* edits. Those were stashed (`git stash list` — "pre-phoenix413 x64
  tree state"), the tree checked out to `macos-v1.5.0`/`fb94a58`, and the one
  deliberate local edit re-applied: the `sed` in `src/makefile.osx`
  (`/opt/homebrew`→`/usr/local`, `-arch arm64`→`-arch x86_64`). Six stale
  untracked files (now tracked on the branch) were moved to the session scratchpad.
- **Rebuilt + repackaged** via the "code-only patch" workflow below: make in both
  trees, `macdeployqt` on each per-arch bundle, lipo-merge of just the executable
  into `Blazecoin-Qt-universal/`, ad-hoc re-sign, binary swapped into
  `/Applications/Blazecoin V1.5.app`.
- **Validated:** reports `v1.5.2.0-g55c5572-beta (2026-08-26 …)` in debug.log
  (the `g55c5572` is the upstream's hard-coded fallback in `src/version.cpp:40` —
  `git describe` finds no annotated tags; all platforms report it), resumed sync
  from the May chainstate (~99.8% → tip), clean quit (`Shutdown : done`, no new
  crash log). Send/receive not re-tested: the change is consensus-inert
  (`PHOENIX_ACTIVATION_HEIGHT = 0x7fffffff`) and those paths were validated in May.
- **`build/build.h` gotcha:** genbuild only rewrites it when the BUILD_DESC line
  changes, so `BUILD_DATE` had been stuck at 2026-05-08. `rm build/build.h` +
  `make` re-stamps it.

**When the activation height H_A is ratified** (per `PHOENIX_413.md` in
`Blazecoin_Wallet_V2_Core`; sequenced after Halving IV and the 2026-09-07
migration), the macOS V1.5.2 release is:
1. Set `PHOENIX_ACTIVATION_HEIGHT` in `src/main.cpp` to H_A (same height as the
   V2 daemon + lite wallets).
2. Add the checkpoint at/near H_A that spec §4 requires (`src/checkpoints.cpp`).
3. Flip `CLIENT_VERSION_IS_RELEASE` to `true`.
4. `rm build/build.h`, rebuild both trees, macdeployqt each, lipo, re-sign
   (workflow below), re-run the pre-release validation checklist, zip + SHA-256,
   publish `v1.5.2-macos` in lockstep with the other platforms.

---

## Session checkpoint (2026-05-13)

When picking this back up:

**State on disk and on the branch:**
- Branch: `macos-v1.5.0`, pushed and in sync with `origin/macos-v1.5.0`. Tip commit: `adaaf1d`.
- Installed app: `/Applications/Blazecoin V1.5.app` — universal binary, ad-hoc signed, all the polish above applied.
- Build trees: `~/blazecoin-investigation/Blazecoin_Wallet_Core_V1.5` (arm64) and `Blazecoin_Wallet_Core_V1.5_x64` (x86_64). Both clean against HEAD.
- Wallet data: `~/Library/Application Support/BlazecoinV1.5/` — leave it as-is between sessions; it's just persistent chain + wallet state.

**The remaining work, in order:**

1. **Real-world testing — PASSED on BOTH platforms.** M1 (Apple Silicon) and Intel both fully synced with send + receive confirmed working (transaction signing + broadcast + receipt through the OpenSSL 3 / BDB 18.1 paths, native on each arch — Intel ran the x86_64 slice with no Rosetta and no Homebrew). This clears the release gate.

   **Intel Mac clean-room test (2026-05-13):** the universal zip (`Blazecoin-V1.5-macOS-universal.zip`, SHA-256 `588f60d0…`) was transferred to a second Mac running Intel hardware with no Homebrew / Qt / Boost installed. It launched and ran natively as the x86_64 slice (Intel Macs have no Rosetta, so this proves the self-contained bundle works for end users). Window, theme and sync all looked correct on first run. Still to finish there: drive it to full sync + do a send/receive.
2. **(Optional) Lipo-merge `blazecoind` into a universal CLI** if you intend to ship the daemon alongside the GUI. Recipe under "Daemon build § Optional: lipo-merge the daemon into a universal CLI binary". Not needed if shipping GUI only.
3. **Test on a clean Mac without Homebrew** (one Apple Silicon, one Intel if you have one). Use the Pre-release validation checklist under "GitHub release § 4. Pre-release validation".
4. **Cut the GitHub release.** Zip + SHA-256 + release notes. Full recipe under "GitHub release". `gh` CLI is installed and authenticated; the only manual step is writing the release notes.
5. **Notarization** if/when the project picks up an Apple Developer Program seat. Optional — ad-hoc signing + the right-click → Open story is fine for an initial release.

**Things to *not* do on resume:**
- Don't merge `macos-v1.5.0` into `dev` without re-confirming the two source areas the doc flags as "needs `_WIN32` guard" (`_exit(0)` shutdown fix) and "subtle but compatible" (CBigNum default-arg reshuffle). The branch is safe to ship from on its own; merging is a separate decision.
- Don't force-push `macos-v1.5.0` — every commit has been pushed cleanly.
- Don't `git rebase -i` the existing commits; if you want to amend the history, do it on a new branch.

---

## Why this works

The V1.5 maintainers already did the hard cross-platform work (see [Blazecoin_V1.5_Technical_Changelog.md](Blazecoin_V1.5_Technical_Changelog.md) §3–§5):

- OpenSSL 3.x migration is **complete** (`src/openssl_compat.h` shim, `CBigNum` refactored to composition, `ECDSA_SIG`/`EVP_CIPHER_CTX` updated). The standalone [OPENSSL_COMPATIBILITY_ISSUE.md](OPENSSL_COMPATIBILITY_ISSUE.md) is stale.
- Boost 1.90 migration is **complete** (filesystem v4, full Asio rewrite `io_service`→`io_context`).
- C++11+ modernization is **complete** (variadic `IMPLEMENT_SERIALIZE`, PRI64 spacing, etc.).
- All MSVC-specific code is `#ifdef _MSC_VER`-guarded — clang on Mac skips it cleanly.
- `src/compat.h` already has POSIX branches for sockets/types.
- scrypt has a `_generic` fallback ([src/scrypt.cpp:246](src/scrypt.cpp#L246)) used when `USE_SSE2` is not defined — ARM64 uses it automatically.

---

## Prerequisites

Homebrew on Apple Silicon installs to `/opt/homebrew` (not `/usr/local`).

```bash
xcode-select --install
brew install openssl@3 boost miniupnpc qrencode pkg-config qt@5 berkeley-db
```

Versions in use as of last build (2026-05-08):

| Package | Version |
|---|---|
| openssl@3 | 3.6.2 |
| boost | 1.90.0 |
| berkeley-db | 18.1.40 |
| qt@5 | 5.15.18 |

Notes:
- `openssl@3`, `qt@5`, and `berkeley-db` are keg-only — do not symlink into `/opt/homebrew`. The makefile/.pro file references them by `/opt/homebrew/opt/<name>/...`.
- BDB 18.1 is fine for fresh wallets. The Windows V1.5 build also uses modern BDB (6.2 via MSYS2, latest via vcpkg) — wallet.dat format is compatible.
- A freshly-built `.app` will dynamically link against `/opt/homebrew/opt/...`, so it only runs on a Mac that has Homebrew at the same prefix. The "Deployment" section below shows how to bundle the dylibs inside the .app for portability.

---

## Daemon build

Run from [src/](src/):

```bash
cd src
mkdir -p obj obj-test
make -f makefile.osx
```

Result: native arm64 `blazecoind`, ~14 MB.

### Required changes for the daemon

**Build system:**

1. **[src/makefile.osx](src/makefile.osx) — top section rewritten** for M1:
   - `CXX=clang++` (not `llvm-g++`)
   - Paths point to `/opt/homebrew/opt/{openssl@3,boost,berkeley-db}` (not `/usr/local/...`)
   - Added explicit `BOOSTDIR` because Boost on M1 is at `/opt/homebrew/opt/boost`
   - `BDB_LIB_SUFFIX=-18.1` (matches `libdb_cxx-18.1.dylib`); old default was `-4.8`
   - Dropped `-mt` Boost library suffix
   - Dropped `boost_system` link (header-only since Boost 1.69)
   - Dropped `-stdlib=libstdc++` (libc++ is required)
   - `-arch arm64` (not `-arch i386`)
   - Removed `-mmacosx-version-min=10.5`
   - Added `-std=c++14` to match the GCC/MinGW pin in `blazecoin-qt.pro`
   - Added `-Wno-deprecated-declarations` to silence OpenSSL 3 deprecation noise

2. **`USE_UPNP:=-`** in `makefile.osx`. Modern Homebrew miniupnpc added arguments to `upnpDiscover` and `UPNP_GetValidIGD`; Blazecoin's `net.cpp` uses the older signatures. Disabling UPnP just turns off NAT traversal. Re-enabling later requires patching the two call sites in [src/net.cpp](src/net.cpp).

**Source code patches (also used by the GUI build):**

3. **`boost::` qualifier added to bare `filesystem::` references** in 5 files. Even with `-std=c++14`, libc++'s `<chrono>` (via `<__chrono/file_clock.h>`) leaks `std::filesystem` into namespace scope on modern macOS SDKs. Affected lines:
   - [src/db.cpp:67–69](src/db.cpp#L67-L69)
   - [src/blazecoinrpc.cpp:777–784](src/blazecoinrpc.cpp#L777-L784)
   - [src/init.cpp:440–445](src/init.cpp#L440-L445), [795](src/init.cpp#L795), [918–931](src/init.cpp#L918-L931)
   - [src/walletdb.cpp:547–560](src/walletdb.cpp#L547-L560)
   - [src/main.cpp:2556](src/main.cpp#L2556)

4. **CBigNum serialization overloads — forward-declared in `serialize.h`.** V1.5 §5.5 added free-function overloads for `CBigNum` in [src/bignum.h](src/bignum.h) to disambiguate from the bool overload. Those overloads work under MSVC's looser two-phase template lookup, but clang's stricter lookup at template-instantiation time inside `CDataStream::Serialize<T>` doesn't find them — so `Write('I', bnBestInvalidWork)` in `txdb.cpp:83` is ambiguous.
   - Added forward declarations of all three CBigNum overloads near the top of [src/serialize.h](src/serialize.h).
   - Removed default arguments from the corresponding `Serialize`/`Unserialize` definitions in `bignum.h`.

5. **`#include "bignum.h"` added to [src/leveldb.h](src/leveldb.h)** so the templated `CLevelDBBatch::Write` sees the CBigNum overloads at parse time.

### Daemon end-to-end test results (2026-05-08)

- Started fresh from genesis (height 0); synced 27,474 blocks in ~3 minutes.
- Connected to both bootstrap peers (`85.15.179.171:55414`, `91.206.16.214:55414`) running `BlazecoinFoundation:0.8.6.2`. Network tip at the time: 4,109,390.
- JSON-RPC: `getinfo`, `getpeerinfo`, `stop` all worked. `getinfo` reported `version=1050000`, `protocolversion=75000`, `walletversion=60000`.
- Clean shutdown via `./blazecoind stop` (exit 0). debug.log ends with `Shutdown : done` after BDB checkpoint and chainstate flush.
- Persistent state: `blocks/` (59 MB), `chainstate/` (8.3 MB LevelDB UTXO set), `wallet.dat` (52 KB BDB 18.1).

### Optional: lipo-merge the daemon into a universal CLI binary

The daemon build above produces an arm64 binary in the arm64 source tree and an x86_64 binary in the x86_64 source tree (per the "Universal binary" section below). To ship a single `blazecoind` that runs on both arches:

```bash
lipo -create \
  Blazecoin_Wallet_Core_V1.5/src/blazecoind \
  Blazecoin_Wallet_Core_V1.5_x64/src/blazecoind \
  -output blazecoind
file blazecoind   # Mach-O universal binary with 2 architectures
```

The daemon has no bundled-frameworks story (it's a plain CLI binary that links against system libs + Homebrew dylibs at runtime), so to ship it standalone you'd also want to either statically link (rebuild with `STATIC=1` flag in `makefile.osx`) or document the Homebrew dependency for end users. For a typical GitHub release of a wallet, the GUI is the primary artifact and the daemon is optional.

---

## Qt GUI build

Run from the repo root:

```bash
/opt/homebrew/opt/qt@5/bin/qmake \
  USE_UPNP=- \
  BOOST_LIB_PATH=/opt/homebrew/opt/boost/lib \
  BOOST_INCLUDE_PATH=/opt/homebrew/opt/boost/include \
  BDB_LIB_PATH=/opt/homebrew/opt/berkeley-db/lib \
  BDB_INCLUDE_PATH=/opt/homebrew/opt/berkeley-db/include \
  BDB_LIB_SUFFIX=-18.1 \
  OPENSSL_LIB_PATH=/opt/homebrew/opt/openssl@3/lib \
  OPENSSL_INCLUDE_PATH=/opt/homebrew/opt/openssl@3/include \
  blazecoin-qt.pro

make -j$(sysctl -n hw.ncpu)
```

Result: `Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt` — 10 MB arm64 binary in a complete .app bundle (Info.plist, PkgInfo, blazecoin.icns).

### Required changes for the GUI

The daemon's source patches (filesystem qualifiers, CBigNum forward declarations, `bignum.h` include in `leveldb.h`) are reused. Additional changes needed:

1. **[blazecoin-qt.pro:447](blazecoin-qt.pro#L447) — removed `macx:BOOST_LIB_SUFFIX = -mt`** default. Modern Homebrew Boost has no `-mt` suffix. qmake silently ignores empty-string overrides on the command line, so the default has to be patched directly.

2. **[src/qt/sendcoinsentry.cpp:21–23](src/qt/sendcoinsentry.cpp#L21) — removed obsolete `#ifdef Q_OS_MAC` block** that referenced `ui->payToLayout->setSpacing(4)`. The `payToLayout` widget was removed from `src/qt/forms/sendcoinsentry.ui` at some point, but the Mac-only code never updated. The V1.5 maintainers never compiled this branch (Windows-only).

3. **`USE_UPNP=-` passed to qmake** — same modern miniupnpc API drift as the daemon.

### Install to /Applications/

qmake produces `Blazecoin-Qt.app`. Rename to `Blazecoin V1.5.app` before
installing so Finder, the Dock and the Cmd-Tab switcher show the proper
product name. The binary inside stays `Contents/MacOS/Blazecoin-Qt`
(unchanged `CFBundleExecutable`), and `Info.plist`'s `CFBundleName` /
`CFBundleDisplayName` already say "Blazecoin V1.5", so every label is
consistent.

```bash
cp -R Blazecoin-Qt.app "/Applications/Blazecoin V1.5.app"
codesign --force --deep --sign - --timestamp=none "/Applications/Blazecoin V1.5.app"
open "/Applications/Blazecoin V1.5.app"
```

Or just drag the `.app` from a Finder window into `/Applications/` and
rename it there.

The app uses the same data dir as the daemon: `~/Library/Application Support/BlazecoinV1.5/`. If the daemon already populated it, the GUI starts with that block height instead of from genesis.

---

## Deployment — making the bundle portable across Macs

After the build above, the .app dynamically links against `/opt/homebrew/...`, so it only runs on this machine. To make it self-contained (runs on any Mac without Homebrew installed), bundle Qt + Boost + BDB + OpenSSL inside the `.app` and ad-hoc codesign.

### 1. Bundle Qt + direct deps

```bash
/opt/homebrew/opt/qt@5/bin/macdeployqt Blazecoin-Qt.app -verbose=1
```

This copies:
- All Qt frameworks the binary uses (`QtCore`, `QtGui`, `QtWidgets`, `QtNetwork`, `QtPrintSupport`, `QtSvg`, etc.)
- All Qt plugins needed at runtime (`platforms/libqcocoa.dylib`, image format plugins, style plugins, etc.)
- Direct dynamic deps: Boost (chrono, filesystem, program_options, thread), BerkeleyDB 18.1, OpenSSL 3 (libssl, libcrypto), and Qt's transitive deps (freetype, glib, libintl, libjpeg, lzma, md4c, pcre2)

It rewrites the binary's `LC_LOAD_DYLIB` entries from `/opt/homebrew/opt/...` to `@executable_path/../Frameworks/...` — but only for direct deps it sees.

### 2. Manually copy Boost transitive deps

`macdeployqt` only follows direct dependencies. `libboost_thread.dylib` (which the binary loads) itself loads `libboost_atomic`, `libboost_container`, `libboost_date_time`, `libboost_chrono`. `macdeployqt` only copied `libboost_chrono` (because Blazecoin-Qt links it directly). The others must be copied manually:

```bash
cp -L /opt/homebrew/opt/boost/lib/libboost_atomic.dylib \
       /opt/homebrew/opt/boost/lib/libboost_container.dylib \
       /opt/homebrew/opt/boost/lib/libboost_date_time.dylib \
       Blazecoin-Qt.app/Contents/Frameworks/

chmod u+w Blazecoin-Qt.app/Contents/Frameworks/libboost_{atomic,container,date_time}.dylib

for lib in libboost_atomic libboost_container libboost_date_time; do
  install_name_tool -id "@rpath/${lib}.dylib" \
    "Blazecoin-Qt.app/Contents/Frameworks/${lib}.dylib"
done
```

The `install_name_tool -id` rewrite is required: without it, the libs still claim to live at `/opt/homebrew/...`, which is the install_name (cosmetic) but can confuse some tools.

### 3. Ad-hoc codesign

Modifying any Mach-O file with `install_name_tool` invalidates the existing signature. Re-sign:

```bash
codesign --force --deep --sign - --timestamp=none Blazecoin-Qt.app
codesign --verify --deep --strict --verbose=2 Blazecoin-Qt.app
```

`--sign -` is ad-hoc (no Apple Developer cert needed). The verify should print `valid on disk` and `satisfies its Designated Requirement`.

`spctl -a -t exec -vv Blazecoin-Qt.app` will say `rejected` — that's expected for ad-hoc, which is why first-run users must right-click → Open (see "GitHub release" below).

### 4. Verify self-containment

```bash
# No /opt/homebrew or /usr/local/Cellar refs in any LC_LOAD_DYLIB
otool -L Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt | grep -E "homebrew|usr/local"

# Same for every dylib in Frameworks/
for f in Blazecoin-Qt.app/Contents/Frameworks/*.dylib; do
  otool -L "$f" | tail -n +3 | grep "/opt/homebrew" && echo "BAD: $f"
done
```

Expect both checks to print nothing.

### 5. Final install

```bash
rm -rf /Applications/Blazecoin-Qt.app
cp -R Blazecoin-Qt.app /Applications/
```

After deployment, the bundle is ~56 MB (vs ~10 MB before — Qt frameworks are bulky).

---

## Universal binary (arm64 + x86_64) for Intel Mac support — completed

Universal binaries contain code for both architectures in a single Mach-O file. macOS's loader picks the right slice at launch. Apple's `lipo` glues two single-arch builds together.

**Actual elapsed time on the build host: ~10 minutes** (much shorter than the original 3–6 hour estimate, because Homebrew bottles for x86_64 turned out to be available — none of the deps had to compile from source under Rosetta).

### Architecture

Homebrew installs separately for each architecture and refuses to mix them:
- arm64 Homebrew: `/opt/homebrew/` (used by the arm64 build)
- Intel (x86_64) Homebrew: `/usr/local/` (installed under Rosetta 2)

Each set of deps has to be installed twice. The build has to run twice. Then `lipo` merges every Mach-O file in the bundle.

### One-time setup

```bash
# Install Rosetta 2 (required to run x86_64 binaries on Apple Silicon)
softwareupdate --install-rosetta --agree-to-license

# Install x86_64 Homebrew at /usr/local
# Note: needs sudo for the chown of /usr/local — must be run interactively in a Terminal
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install x86_64 deps (mirrors the arm64 install list)
arch -x86_64 /usr/local/bin/brew install openssl@3 boost qrencode pkg-config qt@5 berkeley-db
```

### Build x86_64

In a separate output directory so it doesn't clobber the arm64 build:

```bash
# Clean a copy of the source tree
cp -R Blazecoin_Wallet_Core_V1.5 Blazecoin_Wallet_Core_V1.5_x64
cd Blazecoin_Wallet_Core_V1.5_x64

# Wipe stale arm64 build artifacts before re-using the tree
find src/obj src/obj-test src/leveldb build -type f \
  \( -name "*.o" -o -name "*.a" -o -name "*.d" -o -name "*.P" \) -delete 2>/dev/null
rm -rf Blazecoin-Qt.app Makefile build

# Edit src/makefile.osx — swap /opt/homebrew → /usr/local and -arch arm64 → -arch x86_64
sed -i '' 's|/opt/homebrew|/usr/local|g; s|-arch arm64|-arch x86_64|g' src/makefile.osx

# Build daemon
arch -x86_64 make -C src -f makefile.osx

# Configure + build Qt GUI under Rosetta (uses /usr/local Qt5)
arch -x86_64 /usr/local/opt/qt@5/bin/qmake \
  USE_UPNP=- \
  BOOST_LIB_PATH=/usr/local/opt/boost/lib \
  BOOST_INCLUDE_PATH=/usr/local/opt/boost/include \
  BDB_LIB_PATH=/usr/local/opt/berkeley-db/lib \
  BDB_INCLUDE_PATH=/usr/local/opt/berkeley-db/include \
  BDB_LIB_SUFFIX=-18.1 \
  OPENSSL_LIB_PATH=/usr/local/opt/openssl@3/lib \
  OPENSSL_INCLUDE_PATH=/usr/local/opt/openssl@3/include \
  blazecoin-qt.pro

arch -x86_64 make -j$(sysctl -n hw.ncpu)

# Deploy x86_64 bundle (same steps as the arm64 deploy)
arch -x86_64 /usr/local/opt/qt@5/bin/macdeployqt Blazecoin-Qt.app
cp -L /usr/local/opt/boost/lib/libboost_atomic.dylib \
       /usr/local/opt/boost/lib/libboost_container.dylib \
       /usr/local/opt/boost/lib/libboost_date_time.dylib \
       Blazecoin-Qt.app/Contents/Frameworks/
chmod u+w Blazecoin-Qt.app/Contents/Frameworks/libboost_{atomic,container,date_time}.dylib
for lib in libboost_atomic libboost_container libboost_date_time; do
  install_name_tool -id "@rpath/${lib}.dylib" "Blazecoin-Qt.app/Contents/Frameworks/${lib}.dylib"
done
```

### Merge with lipo

Don't merge each binary by name — the bundle has 58+ Mach-O files (main exe + dylibs + Qt framework binaries + plugins). Walk the bundle, lipo every Mach-O against its x86_64 counterpart:

```bash
ARM_BUNDLE="$(pwd)/../Blazecoin_Wallet_Core_V1.5/Blazecoin-Qt.app"
X64_BUNDLE="$(pwd)/Blazecoin-Qt.app"
mkdir -p ../Blazecoin-Qt-universal
cp -R "$ARM_BUNDLE" ../Blazecoin-Qt-universal/

UNIVERSAL="$(pwd)/../Blazecoin-Qt-universal/Blazecoin-Qt.app"

while IFS= read -r f; do
  rel="${f#$UNIVERSAL/}"
  x64="$X64_BUNDLE/$rel"
  [ -f "$x64" ] || { echo "MISSING in x64: $rel"; continue; }
  tmp=$(mktemp)
  if lipo -create "$f" "$x64" -output "$tmp" 2>/dev/null; then
    chmod --reference="$f" "$tmp" 2>/dev/null || chmod 0755 "$tmp"
    mv "$tmp" "$f"
  else
    rm -f "$tmp"
  fi
done < <(find "$UNIVERSAL" -type f -exec sh -c 'file "$1" 2>/dev/null | grep -q "Mach-O" && echo "$1"' _ {} \;)

# Re-codesign — every install_name_tool/lipo edit invalidates the prior signature
codesign --force --deep --sign - --timestamp=none "$UNIVERSAL"
codesign --verify --deep --strict --verbose=2 "$UNIVERSAL"
```

### Verify

```bash
file Blazecoin-Qt-universal/Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt
# Expect: Mach-O universal binary with 2 architectures: [x86_64:...] [arm64]

lipo -info Blazecoin-Qt-universal/Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt
# Expect: Architectures in the fat file: ... are: x86_64 arm64

# Sanity: launch each slice on Apple Silicon (arm64 native, x86_64 via Rosetta)
arch -arm64  Blazecoin-Qt-universal/Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt &
arch -x86_64 Blazecoin-Qt-universal/Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt &
```

### What worked, what to watch for

- Same source patches the arm64 build needed (filesystem qualifiers, CBigNum forward decls, sendcoinsentry.cpp Q_OS_MAC removal) carry over with no new code changes.
- All four Homebrew formulae had x86_64 bottles available — Qt5 did not need to compile from source. If bottles ever stop being published for x86_64, this step gets significantly slower.
- Both slices launched cleanly on the M1 build host (arm64 native: ~270 MB RSS at startup; x86_64 via Rosetta: slower startup but functional).
- The post-merge bundle is ~112 MB (vs ~56 MB single-arch — each binary now carries both architectures).

---

## GitHub release

Once the universal bundle is verified, packaging for download:

### 1. Rename the .app for the user-visible label

qmake builds the bundle as `Blazecoin-Qt.app` (TARGET in the .pro). macOS
shows the .app's filename (minus `.app`) under the icon in Finder and the
Dock. To display "Blazecoin V1.5" everywhere, rename the bundle before
zipping or installing:

```bash
mv Blazecoin-Qt.app "Blazecoin V1.5.app"
# Re-sign because the rename can invalidate the existing signature
codesign --force --deep --sign - --timestamp=none "Blazecoin V1.5.app"
```

The binary inside stays `Contents/MacOS/Blazecoin-Qt` and
`CFBundleExecutable` keeps pointing at it. Only the bundle filename
changes. The Info.plist `CFBundleName` / `CFBundleDisplayName` (already
"Blazecoin V1.5") cover the Dock, menu bar, Spotlight and Cmd-Tab.

### 2. Compress the .app

```bash
# Zip preserves bundle structure and is what Gatekeeper expects
cd /Applications
zip -ry Blazecoin-V1.5-macOS-universal.zip "Blazecoin V1.5.app"
```

A DMG is also fine (`hdiutil create`) but adds no real value over a zip for download distribution.

### 3. First-run instructions for users (include in release notes)

Because the build is ad-hoc signed, Gatekeeper will block first launch. Users need:

> 1. Download `Blazecoin-Qt-v1.5.0-macOS-universal.zip` and unzip it.
> 2. Move `Blazecoin-Qt.app` to your `/Applications/` folder.
> 3. **Right-click** (or Control-click) `Blazecoin-Qt.app` and choose **Open**.
> 4. macOS will warn that the app is from an unidentified developer. Click **Open** again.
> 5. After the first launch, you can open it normally (double-click, Spotlight, Launchpad).
>
> If macOS still refuses the right-click → Open path (newer Sequoia/Tahoe versions sometimes do), open Terminal and run:
>
> ```bash
> xattr -cr /Applications/Blazecoin-Qt.app
> ```
>
> This removes the quarantine flag set during download. Then double-click to launch.

### 4. Pre-release validation (run on the build host)

Quick checks the universal bundle is sound before zipping:

```bash
APP=/Applications/Blazecoin-Qt.app

# (a) Universal binary
file "$APP/Contents/MacOS/Blazecoin-Qt"
# expect: Mach-O universal binary with 2 architectures: [x86_64] [arm64]

# (b) Self-contained — no /opt/homebrew or /usr/local/Cellar in any LC_LOAD_DYLIB
otool -L "$APP/Contents/MacOS/Blazecoin-Qt" | grep -E "homebrew|usr/local/Cellar" && echo "BAD" || echo "OK"
for f in "$APP/Contents/Frameworks/"*.dylib; do
  otool -L "$f" | tail -n +3 | grep -q "/opt/homebrew\|/usr/local/Cellar" && echo "BAD: $f"
done

# (c) Signature valid
codesign --verify --deep --strict --verbose=2 "$APP" 2>&1 | tail -3
# expect: valid on disk + satisfies its Designated Requirement

# (d) Both slices launch
arch -arm64  "$APP/Contents/MacOS/Blazecoin-Qt" &
sleep 8 && kill $! 2>/dev/null
arch -x86_64 "$APP/Contents/MacOS/Blazecoin-Qt" &
sleep 8 && kill $! 2>/dev/null

# (e) No new crash log on quit
before=$(ls ~/Library/Logs/DiagnosticReports/Blazecoin* 2>/dev/null | wc -l)
open "$APP" && sleep 8
osascript -e 'tell application "Blazecoin-Qt" to quit'; sleep 6
after=$(ls ~/Library/Logs/DiagnosticReports/Blazecoin* 2>/dev/null | wc -l)
[ "$before" = "$after" ] && echo "quit OK" || echo "still crashing on quit"

# (f) debug.log shows a clean shutdown sequence
tail -3 "$HOME/Library/Application Support/BlazecoinV1.5/debug.log"
# expect: ... wallet.dat closed / DBFlush(true) ended / Shutdown : done
```

### 5. Release checklist

- ☐ Bump version in [src/clientversion.h](src/clientversion.h) and [blazecoin-qt.pro](blazecoin-qt.pro) (currently `0.8.6.2` in the .pro, `1050000` reported by `getinfo`).
- ☐ Tag the commit (`git tag -a v1.5.0-macos.1 -m "..."`).
- ☐ Generate SHA-256: `shasum -a 256 Blazecoin-Qt-v1.5.0-macOS-universal.zip > SHA256SUMS.txt`. Include in the release.
- ☐ Run the validation checks above on the build host.
- ☐ Test the unzipped `.app` on at least one **other** Mac without Homebrew installed, ideally one Apple Silicon and one Intel.
- ☐ Write release notes covering: (a) what V1.5 does, (b) the macOS first-run instructions above, (c) known limitations (UPnP off; no NEON scrypt; data dir at `~/Library/Application Support/BlazecoinV1.5/`; toolbar icons soft on Retina because source PNGs are 1x).

### Optional later: full notarization

Apple Developer Program ($99/yr) → Developer ID Application certificate → `codesign --sign "Developer ID Application: ..."` → `xcrun notarytool submit ... --wait` → `xcrun stapler staple Blazecoin-Qt.app`. Removes the right-click → Open dance entirely. Worth it if the project gets traction; not needed for an initial test release.

---

## HiDPI / Retina rendering

By default, Qt5 doesn't enable high-DPI scaling — even with `NSHighResolutionCapable=true` in Info.plist, widgets render at 1x and macOS upscales the bitmap, producing a quantized/pixelated look on Retina displays.

**Fix in [src/qt/blazecoin.cpp](src/qt/blazecoin.cpp), before `QApplication app(argc, argv)`:**

```cpp
#if QT_VERSION >= 0x050600 && QT_VERSION < 0x060000
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
#if QT_VERSION >= 0x050100 && QT_VERSION < 0x060000
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);
#endif
```

This makes layout, text, and widgets render at native Retina resolution. Bitmap icons in the toolbar are still soft because the source PNGs in `src/qt/res/icons/` are 1x only — Qt smooth-scales them, which looks better than nearest-neighbor upscale but isn't pixel-perfect. Truly crisp toolbar icons would require redrawing each at 2x (art-asset job).

### Dock icon (.icns)

The original `src/qt/res/icons/blazecoin.icns` had only 1x slices (16/32/48/128/256/512). Apple's iconutil expects matched 1x + `@2x` pairs for Retina. Rebuild the iconset with @2x slices derived from the existing pixels:

```bash
iconutil -c iconset src/qt/res/icons/blazecoin.icns -o /tmp/blz.iconset
# Use existing higher-res slices as @2x for smaller sizes (lossless)
cp /tmp/blz.iconset/icon_32x32.png   /tmp/blz.iconset/icon_16x16@2x.png
cp /tmp/blz.iconset/icon_256x256.png /tmp/blz.iconset/icon_128x128@2x.png
cp /tmp/blz.iconset/icon_512x512.png /tmp/blz.iconset/icon_256x256@2x.png
# Downscale 128→64 for icon_32x32@2x (lossless-ish)
sips -z 64 64 /tmp/blz.iconset/icon_128x128.png --out /tmp/blz.iconset/icon_32x32@2x.png
# Upscale 512→1024 for icon_512x512@2x (lossy but only used at huge sizes)
sips -z 1024 1024 /tmp/blz.iconset/icon_512x512.png --out /tmp/blz.iconset/icon_512x512@2x.png
# Drop non-standard 48x48 (macOS uses 16/32/128/256/512)
rm -f /tmp/blz.iconset/icon_48x48.png
iconutil -c icns /tmp/blz.iconset -o src/qt/res/icons/blazecoin.icns
```

After replacing the .icns inside an installed `.app`, refresh Finder/Dock cache so the new icon shows:

```bash
touch /Applications/Blazecoin-Qt.app
killall Dock Finder
```

---

## Shutdown crash on quit — fixed via `_exit(0)`

Vintage 2013-era Bitcoin/Litecoin codebases have a known shutdown ordering bug: child widgets owned by `BlazecoinGUI` (overview page, transaction view, etc.) hold cached pointers into `ClientModel` and `WalletModel`. Those models are stack-allocated in `main()` inside an inner block scope and destroyed before `Shutdown()` runs. `Shutdown()` then destroys the global `pwalletMain` etc. By the time `~BlazecoinGUI` runs (when the stack unwinds), the child widgets try to disconnect signals/slots from the dead model objects → `EXC_BAD_ACCESS` at vtable lookup → crash dialog after every clean quit.

The chain has already been flushed at that point (`debug.log` ends with `Shutdown : done` *before* the crash), so it's purely cosmetic — no data loss — but users see a "Blazecoin-Qt quit unexpectedly" dialog every time.

**Fix in [src/qt/blazecoin.cpp](src/qt/blazecoin.cpp):** call `_exit(0)` immediately after `Shutdown()` so the C++ stack/static destructor chain never runs. Note: `window` is declared **inside** the try block scope, so `_exit` must be **inside** the try block too — not after the catch — otherwise the stack-unwind to the catch destroys `window` first and the crash still fires.

```cpp
#include <unistd.h>  // _exit
...
        if(AppInit2(threadGroup))
        {
            { /* inner block, models created and destroyed */ }
            threadGroup.interrupt_all();
            threadGroup.join_all();
            Shutdown();
            _exit(0);   // <-- skip ~BlazecoinGUI() and other dtors
        }
        else
        {
            threadGroup.interrupt_all();
            threadGroup.join_all();
            Shutdown();
            _exit(1);
        }
```

This is safe because `Shutdown()` has already flushed everything that needs flushing — wallet.dat (BDB), the LevelDB chainstate, peers.dat. The OS reclaims memory and file handles on process exit.

To verify the fix worked, run the binary, send a real quit (`osascript -e 'tell application "Blazecoin-Qt" to quit'` or just ⌘Q) and check the crash-log directory:

```bash
before=$(ls ~/Library/Logs/DiagnosticReports/Blazecoin* 2>/dev/null | wc -l)
open /Applications/Blazecoin-Qt.app && sleep 8
osascript -e 'tell application "Blazecoin-Qt" to quit'
sleep 6
after=$(ls ~/Library/Logs/DiagnosticReports/Blazecoin* 2>/dev/null | wc -l)
[ "$before" = "$after" ] && echo "OK" || echo "still crashing"
```

---

## Gotcha: rebuilding the binary after macdeployqt

If you rebuild `Blazecoin-Qt` (e.g. for a source patch like the HiDPI fix above) **after** macdeployqt has already deployed the bundle, the freshly-linked binary will **revert to absolute Homebrew paths** in its `LC_LOAD_DYLIB` entries — macdeployqt's install_name rewrites only affected the *previous* binary in the bundle.

If you swap that fresh binary into a deployed bundle, the dynamic loader will follow `/opt/homebrew/...` paths instead of `@executable_path/../Frameworks/...`. On the build machine this often "works" because Homebrew is still present, but signatures and library matching get inconsistent and the app can crash silently or at random.

**Fix:** re-run `macdeployqt path/to/Blazecoin-Qt.app` on each per-arch bundle after the rebuild. macdeployqt detects the new binary and rewrites its install_names to point at the already-bundled frameworks. Then lipo-merge again and re-codesign. Workflow for a code-only patch:

```bash
# In arm64 source tree
make -j$(sysctl -n hw.ncpu)
/opt/homebrew/opt/qt@5/bin/macdeployqt Blazecoin-Qt.app

# In x86_64 source tree
arch -x86_64 make -j$(sysctl -n hw.ncpu)
arch -x86_64 /usr/local/opt/qt@5/bin/macdeployqt Blazecoin-Qt.app

# Lipo-merge JUST the executable (Frameworks/ haven't changed)
lipo -create \
  arm64_tree/Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt \
  x64_tree/Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt \
  -output /Applications/Blazecoin-Qt.app/Contents/MacOS/Blazecoin-Qt
codesign --force --deep --sign - --timestamp=none /Applications/Blazecoin-Qt.app
```

This is much cheaper than redoing the full bundle — the bundled frameworks (~50 MB of Qt + Boost + BDB + OpenSSL) don't need to be touched if only the main binary changed.

---

## Outstanding / future work

Build / packaging:
- ☐ End-to-end test the universal bundle on a clean Mac without Homebrew before publishing — ideally one Apple Silicon Mac and one Intel Mac. Use the validation checks under "GitHub release § Pre-release validation".
- ☐ (Optional) Lipo-merge the two `blazecoind` binaries into a universal CLI if shipping the daemon alongside the GUI.
- ☐ Cut the GitHub release once tested (zip + SHA-256 + release notes).
- ☐ (Later, if the project gains traction) Apple Developer Program signing + notarization to remove the right-click → Open dance.

Functionality:
- ☐ Re-enable UPnP cleanly by patching `src/net.cpp` for the new miniupnpc 7-arg `upnpDiscover` / 7-arg `UPNP_GetValidIGD`.
- ☐ Add NEON-accelerated scrypt path (currently using the scalar `_generic` fallback on arm64; functionally correct but slower than SSE2 on x86 — the x86_64 slice of the universal build also currently uses the scalar fallback because `USE_SSE2` is not enabled).
- ☐ Move the "Bootstrap peers" `addnode=` lines out of `~/Library/Application Support/BlazecoinV1.5/blazecoin.conf` once `peers.dat` is established.

Visual polish (art-asset work, not code):
- ☐ Redraw toolbar icons in `src/qt/res/icons/` at 2x. Current PNGs are 1x only; Qt smooth-scales them on Retina but they aren't pixel-perfect.
- ☐ Provide a 1024×1024 source for the dock icon. Current `.icns` upscales the 512×512 slice for the `512x512@2x` size, which is the only lossy slice in the iconset.

---

## File-by-file change summary

Build system:
- [src/makefile.osx](src/makefile.osx) — top half rewritten for M1/clang/Homebrew; UPnP disabled.
- [blazecoin-qt.pro](blazecoin-qt.pro) — removed `macx:BOOST_LIB_SUFFIX = -mt` default.

Source patches (small, targeted; shared between daemon and GUI):
- [src/serialize.h](src/serialize.h) — added forward declarations of CBigNum serialization overloads.
- [src/bignum.h](src/bignum.h) — removed default args from `Serialize`/`Unserialize` definitions to match forward declarations.
- [src/leveldb.h](src/leveldb.h) — added `#include "bignum.h"`.
- [src/db.cpp](src/db.cpp), [src/blazecoinrpc.cpp](src/blazecoinrpc.cpp), [src/init.cpp](src/init.cpp), [src/walletdb.cpp](src/walletdb.cpp), [src/main.cpp](src/main.cpp) — qualified bare `filesystem::` with `boost::`.

GUI-only source patches:
- [src/qt/sendcoinsentry.cpp](src/qt/sendcoinsentry.cpp) — removed obsolete `Q_OS_MAC` block referencing the long-removed `payToLayout`.
- [src/qt/blazecoin.cpp](src/qt/blazecoin.cpp):
  - added `Qt::AA_EnableHighDpiScaling` and `Qt::AA_UseHighDpiPixmaps` attributes before `QApplication` construction so widgets render at native Retina resolution
  - added `_exit(0)` immediately after `Shutdown()` (inside the try block — `window` is declared there) to skip the buggy `~BlazecoinGUI` destructor chain
  - added `#include <unistd.h>` for `_exit`
  - added `BlazecoinProxyStyle : QProxyStyle` with `standardIcon()` override returning a custom white "?" for `SP_MessageBoxQuestion`; installed via `app.setStyle(...)` so it applies to every QMessageBox without per-call-site changes
  - added a global stylesheet on `QApplication` that:
    - themes `QMessageBox` black/red/white (`background-color`, label text colour, button border `#d80317`, hover bg, default button bg);
    - gives `QLineEdit / QAbstractSpinBox / QComboBox / QPlainTextEdit / QTextEdit` a white background, `#1c1c1c` text, `1px #ededed` border, `min-height: 20px`;
    - themes the `QComboBox QAbstractItemView` popup (white bg, dark text, BlazeCoin-red `selection-background-color`);
    - renders explicit `QAbstractSpinBox::up-button` / `::down-button` with PNG arrows (because Qt stops drawing native arrow sub-controls once the spinbox class is stylesheet-styled);
    - sets `padding-right: 18px` on `QAbstractSpinBox` so the value doesn't overlap the buttons
- [src/qt/blazecoingui.cpp](src/qt/blazecoingui.cpp) / [.h](src/qt/blazecoingui.h):
  - added `blazeIconBlinkTimer` (QTimer, 1000 ms interval) that toggles `ui->label_blaze->setVisible(...)` so the bottom-right status icon blinks while syncing
  - `setNumBlocks()` stops the timer + forces the icon visible (with the `:/res/blaze_icon_on.png` pixmap) once `count >= nTotalBlocks` and the tip is recent

Asset updates:
- [src/qt/res/icons/blazecoin.icns](src/qt/res/icons/blazecoin.icns) — regenerated with `@2x` slices for Retina dock-icon rendering.
- [src/qt/res/icons/blazecoin.png](src/qt/res/icons/blazecoin.png) — in-app icon replaced with the red phoenix-in-circle from the header logo (centered on a 1024 master, downscaled to 256×256 with Lanczos). Backup of the original gold coin lives alongside as `blazecoin.png.gold.bak` and `blazecoin.icns.gold.bak` (uncommitted, in case of revert).
- [src/qt/res/blaze_icon_on.png](src/qt/res/blaze_icon_on.png) — recoloured from white to BlazeCoin red `#d80317` using `imagemagick -fill #d80317 -colorize 100` so the alpha mask (the meridian/globe shape) is preserved. The original white pixmap is preserved alongside as `blaze_icon_on.png.white.bak` (uncommitted).
- [src/qt/res/spinbox_up.png](src/qt/res/spinbox_up.png) / [spinbox_down.png](src/qt/res/spinbox_down.png) / `_hover` variants — small 16×16 dark-grey triangles drawn with ImageMagick, used by the spinbox button stylesheet rules. Hover variants are white triangles on the BlazeCoin-red hover bg.
- [src/qt/res/msgbox_question_white.png](src/qt/res/msgbox_question_white.png) — 64×64 white "?" on transparent canvas, returned by `BlazecoinProxyStyle` for `SP_MessageBoxQuestion`.
- [src/qt/res.qrc](src/qt/res.qrc) — registers the new spinbox arrow PNGs and the white-? icon.
- [share/qt/Info.plist](share/qt/Info.plist) — added `CFBundleName` / `CFBundleDisplayName` = "Blazecoin V1.5". `CFBundleExecutable` stays "Blazecoin-Qt" so the binary path on disk is unchanged.
