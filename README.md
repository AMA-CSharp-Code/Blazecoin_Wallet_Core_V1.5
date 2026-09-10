> ⚠️ **Network notice (2026-08-26): run v1.5.2 or later.** Since block **4,194,000** the Blazecoin chain uses the
> **Phoenix-413** per-block difficulty retarget (spec: `PHOENIX_413.md` in the V2 repo; V1.5 implementation in
> `src/phoenix413.h`, §2.4 of `Blazecoin_V1.5_Technical_Changelog.md`). Older builds — including the original 2014
> 0.8.6.2 client and V1.5.0/1.5.1 — stop at that height. Releases: tags `v1.5.2-windows`, `v1.5.2-linux`, `v1.5.2-macos.1`.
> The text below is the original 2014 README, kept verbatim (its "retargets every 120 blocks" and "2,065,000,000"
> lines describe the launch design; total emission is ≈ 888.9 M BLZ and the retarget is per-block since the fork).

Blazecoin - a fork of Litecoin version with fast block time and faster confirmations (2 confirmations needed instead of 6). Like Litecoin it uses scrypt as a proof of work scheme.

	- 30 second block target
	- Difficulty retargets every 1 hour  (which means every 120 blocks it retargets)
	- Total coins will be around 2,065,000,000.
	- Block rewards will be 413 coins per block
	- Block subsidy halves once per year.
	- The default ports are 55414 (connect) and 55413 (json rpc).
	- First 100 blocks only receive 13 coins
	- Premined 1% in order to do matching fire grants. (Read more in the foundation area)

Note - Make sure you are always using the `master branch` for production use.  The `dev branch` is for testing and coding.
