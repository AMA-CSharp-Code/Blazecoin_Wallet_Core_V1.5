# Blazecoin V1.5 — macOS Release Notes (v1.5.0-macos.1)

> Mirrors the GitHub release
> [`v1.5.0-macos.1`](https://github.com/AMA-CSharp-Code/Blazecoin_Wallet_Core_V1.5/releases/tag/v1.5.0-macos.1)
> (published 2026-05-21, built from branch `macos-v1.5.0`). This file is deliberately
> **force-added past the `release/` gitignore** so at least one release note per platform is
> version-controlled — the Windows/Linux notes in this folder exist only on the build machine.

## Blazecoin V1.5 — macOS (Universal: Apple Silicon + Intel)

The first native macOS build of the Blazecoin V1.5 wallet. This is a **universal binary** —
it runs natively on both **Apple Silicon** (M1/M2/M3/M4) and **Intel** Macs. The app is
**self-contained**: no Homebrew, Qt, or other dependencies need to be installed.

Tested end-to-end (full blockchain sync + send + receive) on both Apple Silicon and Intel
hardware.

### Download & verify

- **`Blazecoin-V1.5-macOS-universal.zip`** (~52 MB) — the wallet application

Verify your download is intact:

```
shasum -a 256 Blazecoin-V1.5-macOS-universal.zip
```

Expected:

```
588f60d0dfa537321629a01affca4e25c246c16806c259bd3382a68c88d8cdb9
```

### Install & first launch

This build is ad-hoc signed (not yet notarized via the Apple Developer Program), so macOS
Gatekeeper will block the first launch. To open it:

1. Unzip the download and move **Blazecoin V1.5.app** into your **/Applications** folder.
2. **Right-click** (or Control-click) the app and choose **Open**.
3. In the warning dialog, click **Open** again.
4. After the first launch you can open it normally (double-click, Spotlight, Launchpad).

If macOS still refuses to open it (newer macOS versions can be stricter), open **Terminal**
and run:

```
xattr -cr "/Applications/Blazecoin V1.5.app"
```

then double-click to launch.

### Notes for users

- Wallet data is stored at `~/Library/Application Support/BlazecoinV1.5/`.
- On first launch the wallet downloads and verifies the full blockchain from the network —
  this takes a few hours. The indicator in the bottom-right of the window **blinks while
  syncing** and turns **solid red when fully caught up**.
- Always back up your wallet (File → Backup Wallet) after you receive coins.

### Known limitations

- UPnP automatic port-forwarding is disabled in this build. If you want to accept inbound
  connections, forward TCP port **55414** on your router manually.
- A few toolbar icons are not yet redrawn at Retina (@2x) resolution, so they may look
  slightly soft on Retina displays. Cosmetic only.
