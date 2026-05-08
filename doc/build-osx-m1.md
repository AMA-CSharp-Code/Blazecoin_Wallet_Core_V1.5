Blazecoin V1.5 build instructions for macOS (Apple Silicon)
===========================================================

This document covers building the daemon (`blazecoind`) and the Qt wallet
(`Blazecoin-Qt.app`) on Apple Silicon Macs (M1/M2/M3) running modern macOS.

The legacy `doc/build-osx.md` targets OS X 10.5–10.8 on 32-bit Intel and is
preserved only for historical reference. None of its toolchain assumptions
apply to Apple Silicon — do not follow it.


Prerequisites
-------------

1. **Xcode Command Line Tools** — provides `clang`, `make`, `git`. From
   Terminal.app:

        xcode-select --install

   You do **not** need the full Xcode IDE.

2. **Homebrew** — package manager. Install per the one-liner at
   <https://brew.sh>. On Apple Silicon, Homebrew installs to
   `/opt/homebrew` (not `/usr/local`); every dependency path below
   reflects that prefix.


Dependencies
------------

Install the build dependencies via Homebrew:

    brew install qt@5 boost berkeley-db@4 openssl@1.1 miniupnpc pkg-config

Notes:

- **OpenSSL 1.1 vs 3.x.** Blazecoin V1.5 was written against the OpenSSL
  1.0/1.1 API and uses idioms (e.g. raw `EC_KEY` access, ECDSA_sign) that
  do not compile cleanly against OpenSSL 3.x without source patches. Use
  `openssl@1.1` until V2.0 is rebased.
- **Berkeley DB 4.8.** The wallet format requires BDB 4.x. The
  `berkeley-db@4` formula is keg-only on Homebrew; if it has been removed
  from the core tap by the time you read this, the `bitcoin-core/cask`
  tap historically provides it, otherwise build from source.
- **Qt 5, not Qt 6.** The `.pro` file and Qt 4/5-era widget code in
  `src/qt` will not build against Qt 6.


Source
------

Clone via git (do **not** copy a zip from another machine — the
executable bit on `contrib/macdeploy/macdeployqtplus` and
`share/genbuild.sh` matters and only git preserves it):

    git clone <remote-url> blazecoin
    cd blazecoin
    git checkout dev


Building blazecoind
-------------------

From the repo root:

    cd src
    make -f makefile.osx \
        OPENSSL_INCLUDE_PATH=/opt/homebrew/opt/openssl@1.1/include \
        OPENSSL_LIB_PATH=/opt/homebrew/opt/openssl@1.1/lib \
        BDB_INCLUDE_PATH=/opt/homebrew/opt/berkeley-db@4/include \
        BDB_LIB_PATH=/opt/homebrew/opt/berkeley-db@4/lib \
        BOOST_INCLUDE_PATH=/opt/homebrew/include \
        BOOST_LIB_PATH=/opt/homebrew/lib \
        BOOST_LIB_SUFFIX=-mt

The output binary is `src/blazecoind`.

If `makefile.osx` still hard-codes `/usr/local/...` paths, the
command-line overrides above take precedence — but the makefile may also
need a one-time edit to remove stale paths. Patch it on a `mac-m1`
branch and commit.


Building Blazecoin-Qt
---------------------

From the repo root:

    qmake blazecoin-qt.pro \
        OPENSSL_INCLUDE_PATH=/opt/homebrew/opt/openssl@1.1/include \
        OPENSSL_LIB_PATH=/opt/homebrew/opt/openssl@1.1/lib \
        BDB_INCLUDE_PATH=/opt/homebrew/opt/berkeley-db@4/include \
        BDB_LIB_PATH=/opt/homebrew/opt/berkeley-db@4/lib \
        BOOST_INCLUDE_PATH=/opt/homebrew/include \
        BOOST_LIB_PATH=/opt/homebrew/lib
    make

If `qmake` is not on the PATH (Homebrew's `qt@5` is keg-only), use the
fully qualified path:

    /opt/homebrew/opt/qt@5/bin/qmake ...

The output is `Blazecoin-Qt.app` in the repo root.

**Do not pass `RELEASE=1`.** The release block in `blazecoin-qt.pro`
forces `-arch i386 -isysroot /Developer/SDKs/MacOSX10.5.sdk`, which is
neither valid nor available on Apple Silicon. Strip or guard that block
before committing M1 changes.


Bundling for distribution
-------------------------

Once `Blazecoin-Qt.app` builds, package it with the bundled deploy
script (which calls `macdeployqt` and copies dylibs into the bundle):

    contrib/macdeploy/macdeployqtplus Blazecoin-Qt.app

Code signing and notarization are not covered here — V1.5 has not been
through Apple's developer-program signing pipeline.


Running
-------

Daemon configuration lives in:

    ~/Library/Application Support/Blazecoin/blazecoin.conf

The daemon will print the expected path on first run if the file is
missing.


Known issues / open work
------------------------

- `RELEASE=1` block in `blazecoin-qt.pro` is broken on Apple Silicon and
  should be either removed or rewritten to target a current SDK.
- Hard-coded `/usr/local/opt/...` paths in the `macx:` blocks of
  `blazecoin-qt.pro` predate Apple Silicon and should be overridable
  from the qmake command line — verify and patch as needed.
- OpenSSL 3 support requires source-level changes equivalent to the
  ones already applied to the MSVC build; tracked separately.
- BDB 4.8 sourcing on arm64 Homebrew is fragile; document the working
  source once confirmed.
