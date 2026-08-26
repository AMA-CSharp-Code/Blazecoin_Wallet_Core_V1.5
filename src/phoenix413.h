// Copyright (c) 2026 The Blazecoin Developers
// Distributed under the MIT/X11 software license.
//
// Phoenix-413 — per-block ASERT difficulty retarget for Blazecoin.
// Spec of record: PHOENIX_413.md in the Blazecoin_Wallet_V2_Core repo
// (RATIFIED 2026-08-26). Fixed-point form: aserti3-2d (BCH mainnet since
// Nov 2020, MIT) with Blazecoin constants:
//     T (target spacing)          = 30 s
//     tau (half-life)             = 12,390 s  == 413 blocks
//     powLimit                    = 2^236 - 1 == ~uint256(0) >> 20
//                                             == bnProofOfWorkLimit (main.cpp)
//
// This header is deliberately SELF-CONTAINED (OpenSSL BN only — no util.h,
// no CBigNum) so the standalone vector harness (src/test-phoenix413.cpp)
// compiles it without the rest of the tree. The compact encode/decode below
// is algorithm-identical to CBigNum::SetCompact/GetCompact for the positive
// targets this code handles (and to Core's arith_uint256 compact).
//
// Consensus-critical: every implementation (this one, the V2 daemon, the
// lite-wallet C# verifier) must match contrib/phoenix413/phoenix413_vectors
// bit-exactly. Do not "clean up" the arithmetic — truncating division and
// arithmetic shifts are part of the pinned semantics.

#ifndef BLAZECOIN_PHOENIX413_H
#define BLAZECOIN_PHOENIX413_H

#include <stdint.h>
#include <openssl/bn.h>

static const int64_t PHOENIX413_TARGET_SPACING = 30;      // seconds
static const int64_t PHOENIX413_HALF_LIFE      = 12390;   // seconds = 413 blocks

// powLimit = 2^236 - 1 (proven equal to bnProofOfWorkLimit = ~uint256(0)>>20).
inline void Phoenix413_SetPowLimit(BIGNUM* bn)
{
    BN_one(bn);
    BN_lshift(bn, bn, 236);
    BN_sub_word(bn, 1);
}

// Compact -> BIGNUM (positive targets only; mirrors CBigNum::SetCompact).
inline void Phoenix413_SetCompact(BIGNUM* bn, unsigned int nCompact)
{
    unsigned int nSize = nCompact >> 24;
    unsigned int nWord = nCompact & 0x007fffff;
    if (nSize <= 3)
    {
        nWord >>= 8 * (3 - nSize);
        BN_set_word(bn, nWord);
    }
    else
    {
        BN_set_word(bn, nWord);
        BN_lshift(bn, bn, 8 * (nSize - 3));
    }
}

// BIGNUM -> compact (positive targets only; mirrors CBigNum::GetCompact).
inline unsigned int Phoenix413_GetCompact(const BIGNUM* bn)
{
    unsigned int nSize = BN_num_bytes(bn);
    unsigned int nCompact = 0;
    if (nSize <= 3)
        nCompact = (unsigned int)(BN_get_word(bn) << (8 * (3 - nSize)));
    else
    {
        BIGNUM* bn2 = BN_new();
        BN_rshift(bn2, bn, 8 * (nSize - 3));
        nCompact = (unsigned int)BN_get_word(bn2);
        BN_free(bn2);
    }
    if (nCompact & 0x00800000)
    {
        nCompact >>= 8;
        nSize++;
    }
    return nCompact | (nSize << 24);
}

// The rule. Computes the compact target FOR the block at nEvalHeight
// (which must be > nAnchorHeight), given:
//   nAnchorBits       — nBits OF the anchor block H_A (last old-rule target)
//   nAnchorParentTime — timestamp of block H_A - 1
//   nParentTime       — timestamp of block nEvalHeight - 1
inline unsigned int Phoenix413_NextCompact(unsigned int nAnchorBits,
                                           int64_t nAnchorParentTime,
                                           int64_t nAnchorHeight,
                                           int64_t nEvalHeight,
                                           int64_t nParentTime)
{
    const int64_t nTimeDiff   = nParentTime - nAnchorParentTime;
    const int64_t nHeightDiff = (nEvalHeight - 1) - nAnchorHeight;

    // exponent in 1/65536 units of half-lives behind (+) / ahead (-) schedule.
    // C-style truncating division — pinned semantics, matches the vectors.
    const int64_t nNum = (nTimeDiff
                          - PHOENIX413_TARGET_SPACING * (nHeightDiff + 1))
                         * 65536;
    const int64_t nExponent = nNum / PHOENIX413_HALF_LIFE;

    // Arithmetic shift (floor) for the integer part; two's-complement low 16
    // bits for the fraction. MSVC/GCC/Clang all shift signed values
    // arithmetically; the harness asserts this against the vectors.
    const int64_t  nShifts = nExponent >> 16;
    const uint64_t nFrac   = (uint64_t)nExponent & 0xffff;

    // Cubic approximation of 2^(frac/65536) in 16-bit fixed point
    // (aserti3-2d constants; sum stays inside uint64 by construction).
    const uint64_t nFactor = 65536ULL
        + ((195766423245049ULL * nFrac
            + 971821376ULL * nFrac * nFrac
            + 5127ULL * nFrac * nFrac * nFrac
            + (1ULL << 47)) >> 48);

    BIGNUM* bnTarget = BN_new();
    Phoenix413_SetCompact(bnTarget, nAnchorBits);
    BN_mul_word(bnTarget, (BN_ULONG)nFactor);

    const int64_t nNet = nShifts - 16;
    if (nNet < 0)
        BN_rshift(bnTarget, bnTarget, (int)(-nNet));   // floors
    else if (nNet > 0)
        BN_lshift(bnTarget, bnTarget, (int)nNet);

    if (BN_is_zero(bnTarget))
        BN_one(bnTarget);

    BIGNUM* bnLimit = BN_new();
    Phoenix413_SetPowLimit(bnLimit);
    if (BN_cmp(bnTarget, bnLimit) > 0)
        BN_copy(bnTarget, bnLimit);

    const unsigned int nResult = Phoenix413_GetCompact(bnTarget);
    BN_free(bnLimit);
    BN_free(bnTarget);
    return nResult;
}

#endif // BLAZECOIN_PHOENIX413_H
