# Blazecoin V1.5 — Complete Changelog vs Original (0.8.6.2)

**Generated:** 2026-04-24 — last updated 2026-08-24 (see the revision table; body sections lag the table for post-April work)
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
| 2026-04-27 | §13.1 (new), §8 | Mining page rework: layout converted to QHBoxLayout/QVBoxLayout, Speed moved into header, slider gains thread-count readout + 75 % danger-zone warning, slider max capped at cores − 1, Win 7+ `GetActiveProcessorCount` for >64-core boxes |
| 2026-04-27 | §13.2 (new), §8 | Qt GUI visual redesign: tiled phoenix-coin wallpaper (cached `QPixmap` painted in `BlazecoinGUI::paintEvent` below the 127 px main header), main-window logo coin recomposited, semi-transparent black panels (`rgba(0,0,0,180)`) replace light-blue containers across overview / mining / send / receive / address book / sign / verify / encrypt / about / transactions, red `#d80317` accent lines + button hovers, white text throughout, network connection icons recolored red, address-book table styled (transparent items, `rgba(255,255,255,30)` alternate rows, left-aligned via model `Qt::TextAlignmentRole`) |
| 2026-04-27 | §13.4 (new), §13.5 (new) | EditAddress dialog dark-mode finish: outer `QDialog` and `wCaption` switched from blue `rgb(0, 82, 174)` to black, `picEdit` and `picAdd` indicator icons recoloured red, "Receiving Address" capitalisation; close X recipe rewritten to `background-image:` + `background-color:` so the red hover overlay paints below the white X glyph (the QSS `image:` property paints in a different z-order and was being covered by `background-color:`). |
| 2026-04-27 | §13.6 (new) | Build-system note: MSBuild's custom-build step does not reliably re-invoke `rcc` when only a referenced PNG changes — it tracks the `.qrc` and the input PNG list snapshot, but timestamp updates inside an unchanged-list PNG are missed. Cure is to run `rcc.exe` by hand (one invocation per `.qrc` — `res.qrc` and `blazecoin.qrc` are separate compilation units that must not collide on `-o`). |
| 2026-04-27 | §13.7 (new) | Encrypt Wallet (askpassphrasedialog), Sign Message, Verify Message dark-mode finish: outer `QDialog` and `wCaption`/`wHeader` switched to black; `encrypt.png`, `change_pass.png`, `sign_message_icon.png`, `verify_sign.png` recoloured red `#d80317`; "Encrypt wallet" → "Encrypt Wallet"; default `QLabel { color: #000000 }` flipped to white in askpassphrasedialog so labels read on the dark frame. |
| 2026-04-28 | §13.8 (new) | Branding refresh: splash redesigned around the new neon-red shield artwork with a centred "BlazeCoin" caption baked into the PNG (split-colour: `Blaze` `#e64619` / `Coin` white). Header coin in `blazecoin-logo.png` replaced with the phoenix-medallion artwork, circle-cropped to match the original coin shape; word "Blazecoin" alongside it nudged down 4 px to sit lower against the new coin. Top-right `wallet-header.jpg` corner icon swapped from the small flame-shield to the same neon shield (28→36 px), brightness-keyed so the dark binary-haze background of the source PNG renders transparent over the header gradient; canvas widened from 828→845 px so the icon sits visibly inside the wallet's right margin instead of being clipped by the rounded corner mask. |
| 2026-04-28 | §13.9 (new) | Dropdown menus (`File`, `Operations`, `Settings`) restyled: `QMenu { background-color }` flipped from red `#9e000f` to solid black; `QMenu::item:selected` background fixed (was `#0099СС` — invalid colour because of two Cyrillic 'С' characters that survived as literal text into Qt's parser, falling back to default highlight blue) → red `#d80317` with white text. Per-action `QIcon` arguments removed from `Exit` (File menu) and `Sign Message` / `Verify Message` (Operations menu) so all entries align to the same left edge. |
| 2026-04-27 | §13.23 *(renumbered 2026-08-24 — this row and the next were a duplicate §13.8/§13.9 pair; the body sections §13.8/§13.9 belong to the 2026-04-28 rows)* | Close-X (bClose) `background-image` recipe rolled out across all five remaining dialogs (askpassphrasedialog, addressbookpage, aboutdialog, signverifymessagedialog, message_box_dialog) so hover paints red bg under the white X glyph instead of `image:` over `background-color`. |
| 2026-04-27 | §13.24 *(renumbered 2026-08-24, see previous row)* | Options page (Common settings + Network) recoloured: `wServiceMessagesHeader_4` strip black, `wContainer` `rgba(0,0,0,180)`, blue text → white, blue accent line → red, buttons restyled like other dialogs, `settings_icon.png` recoloured red. QCheckBox given small `padding: 1px 0; min-height: 14px` to ease the Common-section text clipping that existed in the original wallet. The "Optional transaction fee per kB…" `showNotification(...)` banner in `optionspage.cpp` removed. "Pay transaction fee" → "Pay Optional Transaction Fee". |
| 2026-04-27 | §13.10 (new) | "Check updates at startup" feature removed. The checkbox was permanently `enabled=false` in the .ui, the model forced `bCheckUpdatesAtStartup = false` regardless of saved setting, and `getCheckUpdatesAtStartup()` was never called from anywhere — pure UI placeholder for an unimplemented feature. Removed: the `QCheckBox` widget; `OptionsModel::CheckUpdatesAtStartup` enum entry, getter, member; `Init()` / `data()` / `setData()` cases; mapper line and `setCheckUpdatesAtStartup()` setter on `OptionsDialog`. |
| 2026-04-27 | §13.11 (new) | Capitalisation pass: "Common settings, Network" → "Common Settings, Network"; "Service messages" → "Service Messages" (File menu); "Sign &message…" → "Sign &Message…", "&Verify message…" → "&Verify Message…" (Operations menu, both action declarations and right-click context menu via replace_all); "Command-line options" → "Command-line Options". |
| 2026-04-27 | §13.12 (new) | Splash screen redesign: "Coin" word recoloured from black to white (only near-black pixels in the bottom 45 % flipped, so the shield's interior stays dark); `splash.png` red bg flipped to black with a 3 px red `#d80317` border drawn on the perimeter (~213 K bg pixels matched against `R>110 ∧ G<40 ∧ B<40 ∧ R−G>80`, so the orange flame and silver shield are spared); same applied to `splash_testnet.png`. The runtime status message colour in `blazecoin.cpp:90` (`splashref->showMessage(...)`) flipped from `QColor(55,55,55)` to white. |
| 2026-04-27 | §13.13 (new) | RPC Console / Debug window dark mode: top-level QSS sets `QDialog` black bg, `QTabWidget::pane` `rgba(0,0,0,180)` with red `#d80317` border, dark tabs (selected solid red), white labels, `QTextEdit` / `QLineEdit` dark with red border + red selection, dark-with-red-hover buttons, dark/translucent scrollbars. New `wCaption` strip (32 px black with red border) at top, holding the "Blazecoin - Debug Window" title and a `bClose` button (white X / red hover) wired to `close()`; `setWindowFlags(...FramelessWindowHint...)` drops the OS title bar; `DialogMoveHandler` on `wCaption` keeps the dialog draggable. Also `setNumBlocks(getNumBlocks(), getNumBlocksOfPeers())` added to `RPCConsole::setClientModel()` so Current/Estimated/Last block fields populate immediately rather than waiting for the next `numBlocksChanged` signal (which never fires once at chain tip). |
| 2026-04-27 | §13.14 (new) | `GUIUtil::HelpMessageBox` (the "Command-line Options" popup) converted from `QMessageBox` to a custom frameless `QDialog` with the same dark recipe: black `wCaption` strip with title + close X, `DialogMoveHandler`, header label + scrollable `QTextEdit` body (full `HelpMessage()` core options + UI options), centred OK button, red `#d80317` 1 px border on the dialog (`setObjectName + WA_StyledBackground + #HelpMessageBox` selector — required to make the QSS border paint on a frameless top-level QDialog). `printToConsole()` / `showOrPrint()` API unchanged so the two call sites (`rpcconsole.cpp:451`, `blazecoin.cpp:201`) need no edits. |
| 2026-04-27 | §13.15 (new) | Main wallet top-right close X (`mainwindow.ui` bClose) switched from `image:` (no-op hover) to the `background-image:` + `background-color:` recipe so hovering paints solid red `#d80317` behind the white X (matches dialog close buttons). |
| 2026-04-27 | §13.16 (new) | Header logo (`blazecoin-logo.png`) regenerated programmatically: phoenix-coin circular crop on the left, "Blazecoin" rendered in Segoe UI Bold 40pt white (the same default sans-serif the rest of the wallet inherits), flame icon removed. Banner widened from 331×83 to 361×83 to fit the larger text; `mainwindow.ui` `#label` widget grown to 390×83 and given `background-repeat: no-repeat; background-position: top left` so the bg-image doesn't tile a partial second coin in the gap. |
| 2026-04-27 | §13.17 (new) | Console (`rpcconsole.cpp`) message-widget CSS: dark red `#590607` for `td.cmd-request` and `b` flipped to lighter coral `#FF6B6B` so outgoing-command echo and bold text read on the dark console bg. |
| 2026-04-27 | §13.18 (new) | New **Import Wallet** GUI feature (File menu → "Import Wallet"). Berkeley DB has `wallet.dat` locked while the wallet is running, so the swap is staged: `BlazecoinGUI::importWallet()` shows a file picker, asks for confirmation, writes the chosen source path into `<datadir>/wallet-import-pending.txt`, and calls `qApp->quit()`. On the next startup, the new block in `init.cpp` (just before `bitdb.Open(GetDataDir())`) reads the marker, renames the existing `wallet.dat` to `wallet.dat.bak.YYYYMMDD-HHMMSS`, copies the source over, removes the BDB env files (`log.0000000001`, `__db.*`) so a fresh env is created on open, deletes the marker, and proceeds with normal startup. Errors abort via `InitError` and clear the marker. The dropdown is dispatched from `BlazecoinGUI::menuFileRequested()` (the wallet's custom popup `QMenu`, *not* the platform `QMenuBar`) — the action lives there, not in `createMenuBar()`. |
| 2026-05-08 | §13.19 (new) | Linux build added on a `linux` branch off `dev`. Daemon (`blazecoind`) and GUI (`blazecoin-qt`) both build cleanly on Ubuntu 22.04 (gcc 11, Qt 5.15, OpenSSL 3.0.2, Boost 1.74, libdb_cxx 5.3) under WSL2. Two minimal source fixes: `src/makefile.unix` adds `-l boost_chrono` to the `LIBS` list (between `boost_thread` and `db_cxx`); `blazecoin-qt.pro` collapses the `win32:LIBS += -lboost_chrono` / `macx:LIBS += -lboost_chrono` pair (lines 524–525) into one unconditional `LIBS += -lboost_chrono$$BOOST_LIB_SUFFIX` in the non-MSVC `else` branch. Both fixes address `undefined reference to boost::chrono::steady_clock::now()` from `boost::condition_variable::wait_for` — Boost 1.65+ requires explicit `-lboost_chrono` for time-aware Boost.Thread primitives. Build flags worth knowing: pass `CXXFLAGS=-std=gnu++14 -Wno-deprecated-declarations` to the daemon make (gcc 11 defaults to C++17, which both removes the dynamic exception specifications used in `src/leveldb.h` and adds `std::filesystem` that collides with `boost::filesystem` under `using namespace std; using namespace boost;` in `init.cpp`). The `.pro` file already pins `-std=gnu++14` for `*-g++`. |
| 2026-05-08 | §13.20 (new) | Status-bar progress label (`label_12` in `mainwindow.ui`) was sized for the 22-char placeholder "Synchronizing Network" and right-aligned at 143 px — runtime strings "Synchronizing with network…", "Importing blocks from disk…", "Reindexing blocks on disk…" (all ~28 chars / ~155 px in 8 pt) had their leading characters clipped on Linux Qt 5, so users saw "chronizing with network…". Fix: alignment switched from `Qt::AlignRight\|Qt::AlignTrailing` to `Qt::AlignLeading\|Qt::AlignLeft` (no leading gap on shorter strings either), label width 143→165 px, progress bar shifted x 161→185 with width tightened 655→640 so its right edge lands at x 825 — 5 px clear of the connection icon at x 830, matching the 5–9 px text-to-bar gap on the left. Strictly a Qt 5 / Linux fix; MSVC Qt 5 on Windows happened to render the same string within the 143 px box without truncation due to a slightly narrower default font metric. |
| 2026-05-09 | §13.21 (new) | All `QMessageBox::information / warning / critical / question` call sites (33 across 11 GUI files) converted to a themed `MessageBoxDialog` flow. Four new static helpers — `information() / warning() / critical() / question()` — added to `MessageBoxDialog` so call sites read like the QMessageBox API (`MessageBoxDialog::critical(this, title, text)`); `question()` returns `QDialog::Accepted` / `QDialog::Rejected`, replacing the handful of `retval == QMessageBox::Yes` checks. `message_box_dialog.ui` palette flipped to match the rest of the dark wallet: outer dialog and `wCaption` strip black `rgb(0, 0, 0)` (was Microsoft-blue `rgb(0, 82, 174)`), frame body `rgba(0, 0, 0, 180)` (was `#D8DFE9`), labels white `#FFFFFF` (was `#0052AE` / `#E9D9D8`), buttons `rgba(0, 0, 0, 200)` with red `#d80317` hover/pressed (was `#758EB3` / `#0099CC`). Capitalisation pass on the visible titles: "Confirm wallet encryption" → "Confirm Wallet Encryption"; post-encryption warning "Wallet encrypted" → "Wallet Encrypted". The raw `QMessageBox` instance in `BlazecoinGUI::message` (`blazecoingui.cpp:810`, the system-tray modal fallback driven by `CClientUIInterface`) was deliberately left intact — it consumes a `QMessageBox::StandardButton`-typed mask from the lib core and isn't a user-visible Blazecoin dialog. |
| 2026-05-09 | §13.22 (new) | Follow-up Title Case sweep across the remaining dialog headers + one MSVC-specific include fix on top of §13.21. Title-case adjustments: `askpassphrasedialog.cpp` "Wallet encryption failed" → "Wallet Encryption Failed" (4 sites), "Wallet unlock failed" → "Wallet Unlock Failed", "Wallet decryption failed" → "Wallet Decryption Failed", "Unlock wallet" → "Unlock Wallet" (window title + lbTitle), "Decrypt wallet" → "Decrypt Wallet" (idem), "Change passphrase" → "Change Passphrase" (idem); `addressbookpage.cpp` + `transactionview.cpp` "Error exporting" → "Error Exporting"; `blazecoingui.cpp` "Confirm transaction fee" → "Confirm Transaction Fee"; `blazecoin.cpp` "Runaway exception" → "Runaway Exception"; `optionsdialog.cpp` + `optionspage.cpp` "Confirm options reset" → "Confirm Options Reset"; `sendcoinsdialog.cpp` "Confirm send coins" → "Confirm Send Coins"; `editaddressdialog.cpp` "New sending address" / "Edit sending address" → "New Sending Address" / "Edit Sending Address" (the Receiving variants were already title-cased per §13.4). Build fix: `addressbookpage.cpp` had `#include "message_box_dialog.h"` placed inside the `#ifdef USE_QRCODE` block by §13.21's auto-rewrite — MSVC's `blazecoin-qt.vcxproj` does not define `USE_QRCODE`, so the include compiled out and link of `MessageBoxDialog::critical` fails; the include was moved out of the `#ifdef`. |
| 2026-05-09 | Release (Linux) | **`v1.5.0-linux` — Linux x86_64, tagged at `4e52cb4` on `linux`.** Asset `blazecoin-v1.5.0-linux-x86_64.tar.gz`; release notes `release/RELEASE_NOTES.md`. Note: that file's "Source-level changes vs v1.5.0" table lists the §13.21 MessageBoxDialog + Title Case work later shipped to Windows as **1.5.1** — the asset is correctly versioned 1.5.0 because the tag predates the `9889468` version bump. *(Row added retroactively 2026-08-24 — the release event had build notes in §13.19 but no table row.)* |
| 2026-05-13 | Release (Windows 1.5.1) | **`v1.5.1` — Windows x64, tagged on `dev`** (`ed3a0e8`; the `linux` branch carries the same bump as `9889468`). Delta vs `v1.5.0`: the §13.21 `MessageBoxDialog` helpers + §13.22 Title Case sweep, and the status-bar Blaze icon tinted red `#d80317`, blinking 1 s on/off while syncing and solid red when synced (replaces the near-blank `blaze_icon_on.png`). Asset `blazecoin-v1.5.1-windows-x64.zip` ≈ 17 MB, sha256 `92c16d0e…891d73`; bundle `blazecoin-qt.exe` `8ba7ac15…d870f9`, `blazecoind.exe` `c6058a01…27268c`. Release notes: `release/WINDOWS_RELEASE_NOTES.md`. *(Row added retroactively 2026-08-22.)* |
| 2026-05-21 | Release (macOS) | **`v1.5.0-macos.1` — the first native macOS release, a UNIVERSAL binary (Apple Silicon M1–M4 + Intel), published on GitHub from branch `macos-v1.5.0`** (not merged into `linux`/`dev`). Self-contained `Blazecoin V1.5.app` — no Homebrew/Qt/OpenSSL install needed, superseding this doc set's build-from-source-only picture of macOS (see the banner in `doc/build-osx-m1.md`). Tested end-to-end (full sync + send + receive) on both architectures. Ad-hoc signed, NOT notarized — first launch needs right-click→Open (or `xattr -cr`). Data dir `~/Library/Application Support/BlazecoinV1.5/` (matches §9.1). Asset `Blazecoin-V1.5-macOS-universal.zip` (~52 MB), sha256 `588f60d0…c88d8cdb9`. Known limitations: UPnP disabled (forward TCP 55414 manually); a few toolbar icons not yet @2x. Release notes: `release/MACOS_RELEASE_NOTES.md`. *(Row added retroactively 2026-08-13 — the release predated it by nearly three months with no changelog record.)* |
| 2026-05-16 | `linux` branch only | Post-release Linux/GUI work that lives ONLY on `linux` (never merged to `dev`): frameless-window drag under Wayland via `startSystemMove` (`0339618`), force the xcb platform so the window runs under XWayland (`bafe3d8`), Qt high-DPI scaling (`634bf8c`), `-lboost_system` dropped from the Linux link line — header-only since Boost 1.69, breaks the link on modern distros (`64bbecd`), status icon kept red always with the blink done via a transparent pixmap (`ad1f756`) and the red Blaze icon synthesized from the globe shape because the branch has no red asset (`d706910`). `dev` meanwhile holds the Title Case sweep `4c12133` (§13.22) and the §12 superseded note `80bc689` that `linux` received as ported text. *(Row added retroactively 2026-08-22.)* |
| 2026-08-22 | header, §2.2, §12, this table | Docs re-trued: the second `2000 → 50000000` edit at `src/main.cpp:2285` (inv-relay guard, not a header limit) is now recorded in §2.2; 1.5.1 + linux-branch rows added above; published `v1.5.0` asset hashes recorded in §12 (the repo's `release/blazecoin-v1.5.0-windows-x64.sha256sums.txt` describes a different local build); stale `// Blazecoin: 15 sec` comment on `nTargetSpacing` fixed to 30 sec; the 2026-08-04 / 08-13 doc commits (`48c649f`, `d91978e`) cherry-picked onto `dev` so the GitHub default branch no longer shows un-bannered planning docs. |
| 2026-08-24 | structure, §2.1, §2.2, §12, §13.7, this table | Doc-hygiene pass: §12 moved above §13 (numbering order); §9.1 re-levelled + moved before §9.2; missing §13.7 body added; duplicate 04-27 §13.8/§13.9 rows renumbered §13.23/§13.24; macOS/Windows release rows put in date order; Linux `v1.5.0-linux` release row added; §2.1 notes the current tree reports 1.5.1; §2.2 heading corrected (2,000 → 50,000,000 headers per reply, not "2M→50M"); §12 records the local `v1.5.0` zip as a third unrecorded artifact; `CHANGES_V1.5.md` line-number/checkpoint-arithmetic corrections banner added; `.gitignore` gains `msbuild*.log`. |
| 2026-08-26 (evening) | §2.4, Releases | **V1.5.2 RELEASED + Phoenix-413 ACTIVATED — all in the same day.** The operator stopped mining at tip 4,193,990 and chose H_A = 4,194,000 (`f017836` set the height; `IS_RELEASE true`); releases published: `v1.5.2-windows` (zip sha `49a2cd7c…`), `v1.5.2-macos.1` (universal, sha `b2d9686c…`, built/tested on-Mac by the operator), `v1.5.2-linux` (tar sha `0c625cb0…`, Ubuntu 22.04 WSL, `USE_UPNP= CXXFLAGS=-std=gnu++14`). Mining resumed; the fork crossed at 4,194,000 (anchor `add35fb6…`), first Era-3 block 4,194,001 `d8063c33…` verified bit-exact across implementations. H_A checkpoint added to `checkpoints.cpp` (rides the next build). Two build finds en route: the `linux` branch had `message_box_dialog.h` inside `#ifdef USE_QRCODE` (Windows GUI couldn't compile there — fixed `16c6920`); the Qt vcxproj's post-build DLL copy uses illegal wildcards (exe links fine; stage OpenSSL DLLs by hand). |
| 2026-08-26 | §2.4 (new), §2.1 | **V1.5.2 (toward): Phoenix-413 retarget implemented, INERT** — new `src/phoenix413.h` (self-contained ASERT core on raw OpenSSL BN, aserti3-2d fixed point, τ = 413 blocks), Era-3 dispatch in `GetNextWorkRequired` gated on `PHOENIX_ACTIVATION_HEIGHT = 0x7fffffff` (**placeholder = never active — the shipped binary is consensus-identical to 1.5.1**), anchor cached from block H_A + its parent's timestamp; standalone harness `src/test-phoenix413.cpp` **passes all 45 canonical vectors** from `contrib/phoenix413/generate_phoenix_vectors.py` (the Python reference that also pins the V2 daemon + lite-wallet C# implementations); version → **1.5.2.0-prerelease** (`CLIENT_VERSION_IS_RELEASE false` until H_A is set). Decision + spec: `PHOENIX_413.md` in `Blazecoin_Wallet_V2_Core` (RATIFIED 2026-08-26). |

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
*(Since the 1.5.1 release — `9889468` on `linux`, `ed3a0e8` on `dev` — `CLIENT_VERSION_REVISION` is
`1`, so the current tree reports `v1.5.1.0-<commit>-beta`. Noted 2026-08-24.)*

### 2.2 Header-response cap raised (2,000 → 50,000,000 headers per reply)

**File:** `src/main.cpp`

The peer-to-peer header request loop had an upper bound around 2,000,000. The original 0.8.6.2 wallet still syncs the current ~4.1M-block chain successfully, so this limit is not a hard sync barrier in 0.8.6.2. The change to 50,000,000 is a defensive future-proofing edit — at Blazecoin's 30-second block interval (~1M blocks/year), bumping the ceiling now removes any chance of it becoming a real limit during the lifetime of V1.5.

**What the diff actually is (clarified 2026-08-22, from `CHANGES_V1.5.md`):** two literal edits, both of a hard-coded `2000`. (1) `src/main.cpp:3607` in the `getheaders` handler — `int nLimit = 2000;` → `50000000`: this is the per-`headers`-message response cap (the 0.8-era equivalent of `MAX_HEADERS_RESULTS`), i.e. how many headers one reply may carry, **not** a chain-height ceiling; the wording "2M → 50M" elsewhere in this doc and in the release notes is shorthand for that. (2) `src/main.cpp:2285` in `SendMessages` — the inv-relay guard `pnode->nStartingHeight - 2000` → `- 50000000`. That guard only decides whether to relay new-block `inv`s to a peer that is still far behind its own starting height; raising it to 50M makes the condition always true, so every peer now receives every inv. It is harmless (peers simply ignore invs they cannot use yet) but it is not a header limit and was never needed — it is listed under §12 as a candidate for reverting to `2000`.

### 2.3 Checkpoints added up to block 4,000,000

**File:** `src/checkpoints.cpp`

Checkpoints are trusted "this block at this height is definitely valid" markers. Original code had checkpoints up to block 363,120 (from 2014). V1.5 adds checkpoints every 500K blocks through 4,000,000, plus original intermediate markers. Expected hashes were extracted from the running production daemon via `Get-CheckpointHashes.ps1`.

Benefits of the new checkpoints:
- Faster initial sync (less work validating signatures up to each checkpoint)
- Defense against deep-reorg attacks that try to rewrite history before a checkpoint
- A built-in verification mechanism — if a peer feeds us a different chain, we reject at the next checkpoint

The original 0.8.6.2 syncs without these and produces an identical canonical chain; the checkpoints just make new V1.5 installs faster and more robust.

Full checkpoint list is in `Blazecoin_V1.5_Checkpoints.txt`.

### 2.4 Phoenix-413 retarget (V1.5.2, added 2026-08-26 — INERT until the activation height is set)

**Files:** `src/phoenix413.h` (new), `src/main.cpp` (dispatch + anchor), `src/test-phoenix413.cpp` (new, harness only), `contrib/phoenix413/` (reference generator + canonical vectors), `src/phoenix413_vectors.h` (generated)

Blazecoin's first planned consensus change (**RATIFIED 2026-08-26**; spec of record: `PHOENIX_413.md` in the `Blazecoin_Wallet_V2_Core` repo): above a network-wide activation height `H_A`, the Era-2 ±10%/120-block retarget is replaced by a **per-block ASERT exponential with half-life 413 blocks (τ = 12,390 s)** — the aserti3-2d fixed-point form (BCH mainnet since Nov 2020) wearing Blazecoin's constants. Purpose: without it, V1.5 (and the 2014 client) would reject every post-fork block and freeze at `H_A`; **V1.5.2 keeps V1.5 a live client through the fork** (decision reversed from the spec's earlier no-V1.5.2 lean — Andrew chose to maintain the legacy client, 2026-08-26).

Mechanics in this codebase:
- `src/phoenix413.h` is **self-contained** (raw OpenSSL `BN_*` only — no `util.h`/`CBigNum`), so the standalone harness compiles it in isolation. Its compact encode/decode is algorithm-identical to `CBigNum::SetCompact/GetCompact` for positive targets; its powLimit constant (2^236 − 1) is provably `bnProofOfWorkLimit` (`~uint256(0) >> 20`).
- `GetNextWorkRequired` gains an Era-3 dispatch at the top (mainnet only): `nHeight > PHOENIX_ACTIVATION_HEIGHT` → `GetNextWorkRequiredPhoenix`, which walks once to block `H_A`, caches its `nBits` (the last Era-2 target) + its **parent's** timestamp as the anchor, and evaluates the absolute ASERT formula from there. All blocks ≤ `H_A` validate byte-identically to 1.5.1. The anchor cache is safe because the activation release also ships a checkpoint at/near `H_A` (no reorg across the fork height).
- **`PHOENIX_ACTIVATION_HEIGHT` is `0x7fffffff` (never active) in this tree.** The V1.5.2 *final* release is cut only when the network-wide `H_A` is chosen (same height as the V2 daemon + lite wallets, ≥ 2 weeks after every implementation ships); it is a one-line change plus the checkpoint row.
- **Pinned semantics** (all implementations must match): C-truncating division for the exponent, arithmetic-shift floor for the integer part, two's-complement low 16 bits for the fraction, the aserti3-2d cubic, right-shift floors, zero→1, clamp to powLimit. `contrib/phoenix413/generate_phoenix_vectors.py` is the Python reference authority; **the harness passes all 45 vectors** (steady state, half-life boundaries, 13×/23×/100× strands, 2 h future-time abuse, both clamps, a 120-block LCG walk). `ComputeMinWork` needs no change (its 4×/4 h decay allowance is strictly more permissive than Phoenix's 2×/3.4 h).

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
| `key.cpp:206` `CECKey::Sign` | `ECDSA_sign(...)` | Transactions silently signed with uninitialised buffer; sends rejected by `VerifyScript` and reported as `"Signing transaction failed"` |

Other `assert(obj.IsValid())`, `assert(container.count(...))`, and `assert(bool_variable)` uses in the codebase are safe (no side effects) and were left alone.

### 7.3 Fresh-install bootstrap (post-release fix in v1.5.0)

Latent issue inherited from the original Blazecoin code, hidden as long as the project ran on machines that already had populated `peers.dat` and explicit `addnode=` lines. Surfaced when v1.5.0 was downloaded onto a clean machine for the first time: the wallet launched, sat at 0 peers indefinitely, and never synced.

Root causes:

1. **Dead DNS seed.** `seed.blazeco.in` has been NXDOMAIN for years. The literal-IP fallback `172.245.137.35:55414` listed alongside it in `strMainNetDNSSeed` is also offline.
2. **Dead in-binary seed.** `pnSeed[]` in `src/net.cpp` had a single entry, `0xA2F337A6` → `166.55.243.162:55414`, which has been offline for years.
3. **No conf, no addnodes.** A fresh install starts with no `blazecoin.conf`. The wallet never auto-creates one, so there's no `addnode=` line to fall back on.

Fix (commit `a087b51`):

- **`util.cpp` `ReadConfigFile`** now writes a default `blazecoin.conf` if none exists. The default seeds two known-good production peers as `addnode=` lines, plus commented-out RPC settings as a starting template. Visible to the user, editable, survives wallet restarts.
- **`net.cpp` `pnSeed[]`** updated to the same two peers, little-endian uint32 encoded (`0xABB30F55` → `85.15.179.171`, `0xD610CE5B` → `91.206.16.214`). Kicks in if `addrman.size()==0` more than 60s after start, providing a belt-and-braces fallback if the conf is later deleted while `peers.dat` is also missing.
- **Dead DNS seed entries** pruned from `strMainNetDNSSeed` and `strTestNetDNSSeed` to avoid 60s of pointless DNS lookups on every startup.

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

### 9.1 Per-version data-directory isolation

Both `blazecoind.exe` and `blazecoin-qt.exe` now default to a V1.5-specific data directory so they never collide with the production 0.8.6.2 wallet's storage:

| Platform | Before | After |
|----------|--------|-------|
| Windows | `%APPDATA%\Blazecoin\` | `%APPDATA%\BlazecoinV1.5\` |
| macOS | `~/Library/Application Support/Blazecoin/` | `~/Library/Application Support/BlazecoinV1.5/` |
| Unix | `~/.blazecoin/` | `~/.blazecoinv1.5/` |

Implemented in `src/util.cpp` `GetDefaultDataDir()`. Users who pass an explicit `-datadir=...` are unaffected.

The Qt application name was also bumped from `Blazecoin-Qt` to `Blazecoin-Qt-V1.5` (`src/qt/blazecoin.cpp`) so V1.5's `QSettings` (window geometry, options dialog state, etc.) live in a separate registry/INI group from the production wallet.

### 9.2 RPC throughput benchmark (added 2026-04-27)

Direct head-to-head between V1.5 (MSVC 2022 build) and stock 0.8.6.2 (the 2019 MinGW production binary at `C:\path\to\Desktop\Blazecoin\blazecoin-qt.exe`). Both daemons running, both at chain tip (4,105,596). 1000 calls per HTTP request via JSON-RPC batching, best of 3 runs:

| Operation | V1.5 (MSVC 2022) | Stock 0.8.6.2 (2019) | V1.5 advantage |
|-----------|------------------:|---------------------:|---------------:|
| `getblockcount` | **3,984 ops/sec** (251 µs) | 3,690 ops/sec (271 µs) | **+8.0 %** |
| `getblockhash 1000000` | **4,063 ops/sec** (246 µs) | 3,668 ops/sec (273 µs) | **+10.8 %** |
| `getblock <2M hash>` (full JSON) | **1,681 ops/sec** (595 µs) | 1,601 ops/sec (625 µs) | **+5.0 %** |

V1.5 is consistently 5–11 % faster across the three operation types. Lighter ops (in-memory state lookups) benefit more — those are tight code paths where the modern MSVC optimizer beats the 2019 MinGW build. Heavier ops (disk read + JSON serialization for `getblock`) benefit less because their time is dominated by I/O and parser work, neither of which is affected by compiler choice.

Reproducible via `./bench-rpc-batch.sh [N]` from the repo root (defaults to N=1000 calls). Requires both daemons running on their respective ports; edit credentials in the script if reusing.

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

*(Section moved above §13 on 2026-08-24 — it had been appended after §13, breaking the numbering order.)*

- **Cross-version peer test** paused at ~107K blocks. Resume by relaunching the test peer (stock 0.8.6.2 from `C:\path\to\Desktop\Blazecoin\blazecoin-qt.exe`) with `-datadir=C:\blazecoin-data\TestPeer`. It will continue downloading from V1.5 toward 4.1M tip.
- **Sanitize local paths** in `MSYS2-Setup-QuickStart.md` and `OPENSSL_COMPATIBILITY_ISSUE.md` (a few `C:\path\to\...` strings) if the repo is ever made public.
- **Translation files** (`src/qt/locale/*.qm`) are committed as zero-byte placeholders. To regenerate real translations, install vcpkg's `qt5-tools` and re-run `qmake` without the `!win32-msvc*` guard around the `lrelease` block in `blazecoin-qt.pro`.
- **`USE_UPNP` in the GUI build** is currently disabled (the bundled `net.cpp` UPNP code uses an older miniupnpc API). The daemon build also doesn't define it. Re-enable by updating the `upnpDiscover()` and `UPNP_GetValidIGD()` call sites to the modern signatures.
- **`USE_QRCODE`** disabled — receive-address QR codes aren't built. Add `qrencode` to vcpkg and pass `USE_QRCODE=1` to qmake to re-enable.
- **`QSound`** sound notifications on incoming transactions disabled (`src/qt/blazecoingui.cpp:856`). To re-enable: add `qt5-multimedia` and switch to `QSoundEffect`.
- **Long-term:** V2.0 should be an incremental Bitcoin Core rebase (e.g. 0.8 → 0.12 → 0.16 → 0.21 → 28.x) using V1.5 as the proven baseline rather than the failed jump-to-28.0 attempt. *(Superseded 2026-05-05: the direct jump-to-28.0 was unblocked by filling four chainparams TODOs in V2's `kernel/chainparams.cpp` — incremental rebase is no longer needed. See V2's `BLAZECOIN_V2.md` "Recent work" for the actual unblock path.)*
- **Revert `src/main.cpp:2285` (`nStartingHeight - 50000000`) to the original `- 2000`** — the edit was a misread of the header-limit change (see §2.2); behaviourally a no-op today, but it is noise in the consensus-adjacent diff. *(Added 2026-08-22.)*
- **Published-asset hashes vs the repo's local sums files (recorded 2026-08-22):** the GitHub `v1.5.0` asset `Blazecoin-V1.5.0-windows-x64.zip` is sha256 `7518b9fb0d2113ff03326e61c9dc9481c77a1c22d792ffb9ff50a8ebb0f6f68f` and the `blazecoin-qt.exe` inside it is `a06acd080c0229fd5c3bf34a1b90c29aa15f4974800d881bb3de1ce4c21dee70` (verified by downloading the asset). The gitignored `release/blazecoin-v1.5.0-windows-x64.sha256sums.txt` on this box lists `431c260e…` for `blazecoin-qt.exe` — a different local build, so trust the GitHub release digest, not that file. The local `release/blazecoin-v1.5.0-windows-x64.zip` beside it is a **third** artifact (sha256 `05286f26dc00ef1ac5efcbe12038e35e2408885e10e966fcce1b4a45bf7adb5d`, verified 2026-08-24) — neither the published asset nor anything any doc records; do not treat it as the release either. `v1.5.1` hashes (zip `92c16d0e…`, exe `8ba7ac15…`, daemon `c6058a01…`) agree across the release body, the bundle's `sha256sums.txt` and the Desktop extract.
- **Branch hygiene:** `macos-v1.5.0` (tag `v1.5.0-macos.1`) exists only on the `mine` remote — not merged, not fetched locally; `linux` carries six Wayland/high-DPI/icon commits `dev` lacks and `dev` carries the §13.22 Title Case sweep `linux` lacks (see the 2026-05-16 revision row). A release of 1.5.2 from either branch should first reconcile the two. *(Added 2026-08-22.)*

---

## 13. Qt GUI redesign (2026-04-27)

Two waves of work landed on top of the working Qt 5.15 build: a rework of the mining
page and a wallet-wide visual theme. Both are pure Qt-side changes — no consensus
or core code is touched.

### 13.1 Mining page rework

- **Layout** converted from absolute geometry (`<rect>`-positioned children) to
  proper `QHBoxLayout` / `QVBoxLayout` so the page resizes cleanly. Three rows now:
  mining log, status row (Threads slider with numeric readout), buttons row.
- **Speed** indicator moved from the bottom row into the dark page header
  (top-right), restyled white-on-black to match the title strip.
- **Slider** is fixed-width (240 px) so it does not dominate the row; tick marks
  every 16 threads; new red-themed groove (`rgba(0,0,0,160)` with `rgba(216,3,23,100)`
  border) and red handle (`#d80317`).
- **Numeric thread readout** (`lThreadCount`) sits flush right of the slider; turns
  bold red `#FF6B6B` above 75 % of usable cores as a thermal/power danger cue.
- **Slider max** capped at `cores − 1` on multi-core boxes so the GUI/OS always
  retain one core; single-core boxes still get their one thread.
- **`>64-core` Windows fix** in `src/qt/miningpage.cpp` — `boost::thread::hardware_concurrency()`
  only sees the current processor group (64-CPU cap). Now dynamically loads
  `GetActiveProcessorCount` from `kernel32.dll` via `GetProcAddress` and passes
  `ALL_PROCESSOR_GROUPS` (compile-time `_WIN32_WINNT=0x0501` hides the symbol,
  hence the runtime lookup). Hard ceiling `kMiningThreadMax = 512`.
- Note: miner threads already run at `THREAD_PRIORITY_LOWEST` in `main.cpp ~4643`,
  so scheduler priority is not the bottleneck; the new caps and warning address
  thermal/power saturation, which priority demotion cannot fix.

### 13.2 Wallet-wide visual theme

The wallet is now styled around a tiled phoenix-coin wallpaper with semi-transparent
black panels and red accents.

#### Tiled background

- New resource `src/qt/res/blazecoin-bg.png` — a 450 × 450 super-tile composed from
  two source images (`ComfyUI_02555_.png` and `ComfyUI_02889_.png`) in a 2 × 2
  checker layout (`A B / B A`) so neighbours never repeat.
- Painting goes through `BlazecoinGUI::paintEvent` (overridden) using
  `QPainter::drawTiledPixmap`. A cached `QPixmap m_bgTile` member holds the
  resource; the tile area is offset down by 127 px so it starts cleanly below
  the main `wHeader` strip. `QSS background-repeat` and `QPalette::Window`
  texture brushes were both tried first and are unreliable on `QMainWindow`.
- Old solid-red `#MainWindow { background-color: rgb(158, 0, 15); }` rule
  removed from `mainwindow.ui`.

#### Logo

- `src/qt/res/blazecoin-logo.png` regenerated: original gold coin replaced with
  a circle-cropped (700 × 700 centred crop, 76 px diameter, antialiased
  `GraphicsPath::AddEllipse`) phoenix coin from the source image. Banner
  width / "BLAZECOIN" text / flame icon preserved.

#### Panels and tabs

- `wState` (Account status), `wLastTransactionsContainer`, `wContainer` (mining,
  send), `#SendCoinsDialog` outer, `wAddressBookContainer`, `wStatusBar` (footer),
  and the analogous containers in askpassphrase / signmessage / verifymessage /
  aboutdialog / transactionspage / editaddress / transactiondesc all switched
  from light `#D8DFE9` to `rgba(0, 0, 0, 180)` (footer at `210`). The `QScrollArea`
  in `sendcoinsdialog` also gets `QScrollArea > QWidget > QWidget {
  background-color: transparent }` so its viewport doesn't paint a default-grey
  layer over the wallpaper.
- Side-menu nav buttons (Send / Receive / Transactions / Address Book / Console)
  given default `background-color: rgba(0, 0, 0, 200)` for legibility against
  the wallpaper; hover/pressed state stays `#d80317` red.

#### Accents and text

- Thin accent lines above "Account Status" / "Last Transactions" / mining-page
  header changed from blue `#0052AE` to red `#d80317`.
- Blue `#0052AE` text recoloured to white throughout the panels (Balance,
  Unconfirmed, Immature labels and values; Pay To / Label / Amount in
  `sendcoinsentry.ui`; mining log message colours).
- "Account status" → "Account Status", "Last transactions" → "Last Transactions",
  "Mining coins" → "Mining Coins", "Address for receiving Blazecoins" → "Address
  for Receiving Blazecoins" (capitalisation).

#### Address-book / receive table

- Rebuilt for dark mode: `QTableView { background-color: rgba(0,0,0,180);
  alternate-background-color: rgba(255,255,255,30); color: #d80317; border:
  1px solid #d80317; gridline-color: rgba(255,255,255,30); }` plus a
  `QTableView::item { background: transparent; color: #d80317 }` rule.
- Headers (`QHeaderView::section`) flipped from light blue to `rgba(0,0,0,180)`
  with white text.
- Cell and header text alignment now driven from the model:
  `AddressTableModel::data()` and `headerData()` return
  `Qt::AlignLeft | Qt::AlignVCenter` for `Qt::TextAlignmentRole`.
- Receive-mode header layout fixed: `label_25_1` (download icon) moved from
  `x=46` to `x=11` so the visible icon is always at the left edge regardless
  of whether `SendingTab` or `ReceivingTab` is showing; `label_27` widened
  from 103 → 320 px (so "Address for Receiving Blazecoins" no longer truncates)
  and shifted from `x=81` to `x=48` to sit flush with the icon.

#### Icons

- `src/qt/res/connection_{1..5}.png` — WiFi-arc signal icons recoloured from
  pale blue/grey to bright red `#FA031A`. The original alpha mask is
  preserved (`Color.FromArgb(p.A, R, G, B)` per pixel); originals saved as
  `.bak` siblings.
- `src/qt/res/last_transactions.png` recoloured the same way (red briefcase),
  but the Transactions page header was then re-pointed to `:/res/transactions.png`
  (the side-menu's red-arrows icon) for consistency. A 10 px fixed spacer was
  inserted between icon and title in the header layout.

### 13.3 Files added / modified by §13

```
src/qt/blazecoingui.{h,cpp}       paintEvent override + cached QPixmap m_bgTile
src/qt/miningpage.{h,cpp}         GetActiveProcessorCount lookup, slider readout,
                                  thread cap, slot wiring; mining-log style tweaks
src/qt/addresstablemodel.cpp      Qt::TextAlignmentRole in data() / headerData()
src/qt/addressbookpage.cpp        "Address for Receiving Blazecoins" capitalisation
src/qt/forms/mainwindow.ui        removed solid-red bg; added side-menu button bg;
                                  footer rgba(0,0,0,210)
src/qt/forms/miningpage.ui        full layout rework; red theme; slider restyle
src/qt/forms/overviewpage.ui      black panels, white text, red accent lines, title case
src/qt/forms/sendcoinsdialog.ui   transparent SendCoinsDialog + scrollArea viewport
src/qt/forms/sendcoinsentry.ui    label color blue → white
src/qt/forms/addressbookpage.ui   header layout fix; dark-mode QTableView styles
src/qt/forms/{askpassphrase,signmessage,verifymessage,aboutdialog,
              transactionspage,editaddress,transactiondesc}.ui
                                  bulk colour mapping (sed) — light bg → rgba(0,0,0,180);
                                  blue accent → red; blue text → white;
                                  blue button → dark, hover/pressed → red
src/qt/res.qrc                    + res/blazecoin-bg.png
src/qt/res/blazecoin-bg.png       new — 450x450 2x2 checker tile (A B / B A)
src/qt/res/blazecoin-logo.png     phoenix-coin replaces gold coin
src/qt/res/connection_{1..5}.png  recoloured red (alpha preserved)
src/qt/res/last_transactions.png  recoloured red (kept for non-header uses)
```

### 13.4 EditAddress dialog dark finish

- Outer `QDialog` and inner `wCaption` (the title strip) bg both swapped from
  blue `rgb(0, 82, 174)` to black `rgb(0, 0, 0)`. The caption "Edit record" /
  "Add record" label flipped from pinkish `#E9D9D8` to white.
- `picEdit` (`edit_record_icon.png`) and `picAdd` (`add_record_icon.png`) — the
  small mode-indicator icons next to the title — recoloured red `#d80317`
  with the per-pixel Color.FromArgb(p.A, R, G, B) trick that keeps the
  alpha mask. Originals saved as `.bak` siblings.
- Title text capitalised: "New receiving address" → "New Receiving Address",
  "Edit receiving address" → "Edit Receiving Address" (in
  `editaddressdialog.cpp`, both `lbTitle->setText` and `setWindowTitle` calls).
  Sending-mode counterparts deliberately left lowercase per the request.

### 13.5 Close button (X) hover recipe

The close-X button (`bClose`) appears on every dialog in the wallet and was
the most stubborn part of the redesign. Final working recipe in
`editaddressdialog.ui`:

```css
QPushButton {
    background-color: transparent;
    background-image: url(:/res/close_normal.png);
    background-repeat: no-repeat;
    background-position: center;
    border: 0px solid gray;
}
QPushButton:hover {
    background-color: #d80317;
    background-image: url(:/res/close_normal.png);
    background-repeat: no-repeat;
    background-position: center;
}
QPushButton:pressed:flat {
    background-color: #FF1A2E;
    background-image: url(:/res/close_normal.png);
    background-repeat: no-repeat;
    background-position: center;
}
```

Why `background-image` and not `image`. With the `image:` QSS property,
QPushButton paints the icon **before** the `background-color`, so the
`background-color: #d80317` on hover ended up painted *over* the white X —
producing a solid red square with no glyph. Switching to `background-image`
moves the X into the background layer, where `background-color` is the
**bottom** colour and `background-image` the layer above it; the result is
white X on top of red. `close_normal.png` is now the only state image —
white X on transparent — and the hover red comes purely from
`background-color`.

### 13.6 Build-system note: rcc and the two `.qrc` files

`blazecoin-qt` uses **two** Qt resource files:

| `.qrc` | Generates | Contents |
|--------|-----------|----------|
| `src/qt/blazecoin.qrc` | `release/qrc_blazecoin.cpp` | Splash screens, app icons, locale `.qm` files |
| `src/qt/res.qrc` | `release/qrc_res.cpp` | All dialog images / styled-button icons / wallpaper |

MSBuild's CustomBuild step **only re-invokes `rcc` when the `.qrc` itself
changes** — modifying a PNG referenced by an unchanged `.qrc` does *not*
re-trigger generation, even if you `touch src/qt/res.qrc` afterwards (the
dependency snapshot is at the inputs-list level, not file timestamps). The
result is that the embedded resource silently stays at the version baked
into the existing generated `.cpp`.

Reliable workflow when only PNGs change:

```bash
"/c/vcpkg/installed/x64-windows/tools/qt5/bin/rcc.exe" -name res \
    src/qt/res.qrc -o release/qrc_res.cpp
rm -f build/release/qrc_res.obj
"/c/Program Files/Microsoft Visual Studio/.../MSBuild.exe" blazecoin-qt.vcxproj \
    /p:Configuration=Release /p:Platform=x64 /m /t:Build
```

**Critical pitfall:** the two `.qrc` files compile to *different* `.cpp`
filenames — running `rcc -name blazecoin src/qt/res.qrc -o
release/qrc_blazecoin.cpp` (the wrong `-o`) will silently overwrite the
splash/icon `.cpp` with `res.qrc` content and produce a broken splash. The
`-name` and `-o` arguments must match the `.qrc`'s natural pair:

| `.qrc` | `-name` | `-o` |
|--------|---------|------|
| `blazecoin.qrc` | `blazecoin` | `release/qrc_blazecoin.cpp` |
| `res.qrc` | `res` | `release/qrc_res.cpp` |

### 13.7 Encrypt Wallet / Sign Message / Verify Message dark-mode finish

*(Body section added retroactively 2026-08-24 — the 2026-04-27 revision row existed with no body,
leaving §13.6 → §13.8 a numbering gap.)*

The same dark recipe as §13.4/§13.5, applied to the three remaining dialogs:

- `askpassphrasedialog` (Encrypt Wallet / passphrase flows), Sign Message and Verify Message: the
  outer `QDialog` and the `wCaption`/`wHeader` strips switched from blue to black.
- Icons `encrypt.png`, `change_pass.png`, `sign_message_icon.png`, `verify_sign.png` recoloured
  red `#d80317`.
- Capitalisation: "Encrypt wallet" → "Encrypt Wallet".
- `askpassphrasedialog`'s default `QLabel { color: #000000 }` flipped to white so labels read on
  the dark frame.

### 13.8 Branding refresh — splash and header logos

The Bitcoin-era splash and the `:/res/blazecoin-logo.png` header banner
were both rebuilt around new neon-red artwork that ships alongside the
codebase under `Qt Images for GUI/`. The work spans three resource files:

| File | Role | Change |
|------|------|--------|
| `src/qt/res/images/splash.png` (+ `splash_testnet.png`) | First-run splash screen | New shield artwork composited at 512×512 onto a 512×560 canvas; `BlazeCoin` caption rendered underneath at y=420 in 64 pt Arial Bold, split-colour (`Blaze` `#e64619`, `Coin` white) |
| `src/qt/res/blazecoin-logo.png` | Header coin + wordmark (`mainwindow.ui` line 823, `:/res/blazecoin-logo.png`) | Coin replaced with the new phoenix medallion, circle-cropped (`GraphicsPath.AddEllipse` clip), 75×75, 8 px left margin, 2 px top margin (so it isn't clipped by the rounded-corner mask on `wHeader`); the original "Blazecoin" wordmark on the right was shifted down 4 px to balance under the new coin |
| `src/qt/res/wallet-header.jpg` | Header background bitmap (`mainwindow.ui` line 490) | Top-right flame-shield icon replaced with the new neon shield. The replacement is non-trivial because the source PNG has a *dark binary-haze background*, not transparency: brightness-keyed alpha (R·0.5 + G·0.3 + B·0.2 with a 30/80 cutoff) is computed at composite time so only the bright shield + glow paint over the gradient. Canvas was widened from 828→845 px (the `wHeader` widget defaults to 902 px wide; the JPG tiles, so a wider canvas shifts the icon further right within the visible tile). Final icon: 36 px, right margin 4 px, top margin 2 px. |

Both `blazecoin.qrc` and `res.qrc` had to be re-rcc'd (see §13.6). The
in-memory transparency keying for the header icon is the cleanest way to
avoid the original problem we hit on the first attempt — pasting the
source PNG directly drew an opaque dark rectangle over the gradient
because the binary-code halo is *almost* black but not zero alpha.

### 13.9 Dropdown menu restyle — File / Operations / Settings

The menu bar dropdowns were red on a dark wallet, which clashed. Two
edits in `src/qt/forms/mainwindow.ui`:

```css
QMenu {
    background-color: #000000;   /* was #9e000f (dark red) */
    border: 0px solid black;
}

QMenu::item:selected {
    background-color: #d80317;   /* was #0099СС — see note below */
    color: #FFFFFF;
}
```

**Cyrillic-letter colour bug.** The previous selected-item background
read as `#0099CC` to a human eye but the trailing two characters were
the *Cyrillic capital С* (U+0421), not Latin C (U+0043). Qt's QSS
colour parser only accepts ASCII hex, so the value silently fell back
to the platform default highlight (Windows blue). Replacing the
non-ASCII chars and switching the colour to the wallet's accent red
both resolves the bug and harmonises with the rest of the theme.

**Icon strip in `blazecoingui.cpp`.** The dynamically built menus
opened by `menuFileRequested()` and `menuOperationsRequested()` had
three actions with leading `QIcon` arguments — `Exit` in the File
menu (`://res/menu/menu_exit.png`), `Sign Message`
(`://res/menu/sign.png`) and `Verify Message`
(`://res/menu/check_signature.png`) in the Operations menu. The
remaining seven actions had no icon, so the menus rendered with an
inconsistent left margin. Removing the three `QIcon` arguments lets
all entries align to the same text gutter.

---
