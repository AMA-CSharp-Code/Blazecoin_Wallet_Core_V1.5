// openssl_compat.h
// Compatibility layer for OpenSSL 3.x with old Bitcoin 0.8.x code
// This bridges the API gap between OpenSSL 1.0.x/1.1.x and OpenSSL 3.x

#ifndef OPENSSL_COMPAT_H
#define OPENSSL_COMPAT_H

#include <openssl/opensslv.h>

// Check if we're using OpenSSL 3.x
#if OPENSSL_VERSION_NUMBER >= 0x30000000L

#include <openssl/bn.h>
#include <openssl/ec.h>
#include <openssl/ecdsa.h>
#include <openssl/evp.h>
#include <openssl/ripemd.h>

// OpenSSL 3.x removed direct BIGNUM structure access
// We need to provide compatibility macros/functions

// BN_init() was removed in OpenSSL 3.x - BIGNUM must be created via BN_new()
// Old code: BIGNUM bn; BN_init(&bn);
// New code: BIGNUM *bn = BN_new();
// For compatibility, we make BN_init a no-op and rely on BN_new()
#define BN_init(bn) do {} while(0)

// In OpenSSL 3.x, BIGNUM is opaque - we can't inherit from it
// The old code had: struct CBigNum : public BIGNUM
// We need to wrap BIGNUM* instead
#define BIGNUM_OPAQUE

// ECDSA_SIG structure is now opaque in OpenSSL 3.x
// Old code accessed: sig->r and sig->s directly
// New code must use: ECDSA_SIG_get0_r() and ECDSA_SIG_get0_s()

// Helper function to get ECDSA_SIG components (if needed)
static inline void ECDSA_SIG_get0_compat(const ECDSA_SIG *sig, const BIGNUM **pr, const BIGNUM **ps) {
    ECDSA_SIG_get0(sig, pr, ps);
}

// Helper function to set ECDSA_SIG components (if needed)
static inline int ECDSA_SIG_set0_compat(ECDSA_SIG *sig, BIGNUM *r, BIGNUM *s) {
    return ECDSA_SIG_set0(sig, r, s);
}

// EC_KEY functions - mostly unchanged but some details differ

// EVP_MD_CTX is now opaque
// Old code: EVP_MD_CTX ctx;
// New code: EVP_MD_CTX *ctx = EVP_MD_CTX_new();

// RIPEMD160 context
// Old code: RIPEMD160_CTX ctx;
// New code: Still works but some functions may differ

#endif // OPENSSL_VERSION_NUMBER >= 0x30000000L

#endif // OPENSSL_COMPAT_H
