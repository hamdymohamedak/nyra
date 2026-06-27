#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static const char nyra_hex_digits[] = "0123456789abcdef";

static char *digest_to_hex(const uint8_t *digest, size_t n) {
    char *out = (char *)malloc(n * 2 + 1);
    if (!out) {
        return NULL;
    }
    for (size_t i = 0; i < n; i++) {
        out[i * 2] = nyra_hex_digits[digest[i] >> 4];
        out[i * 2 + 1] = nyra_hex_digits[digest[i] & 0x0f];
    }
    out[n * 2] = '\0';
    return out;
}

static const uint32_t k[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
};

#define ROTR(x, n) (((x) >> (n)) | ((x) << (32 - (n))))
#define CH(x, y, z) (((x) & (y)) ^ (~(x) & (z)))
#define MAJ(x, y, z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define EP0(x) (ROTR(x, 2) ^ ROTR(x, 13) ^ ROTR(x, 22))
#define EP1(x) (ROTR(x, 6) ^ ROTR(x, 11) ^ ROTR(x, 25))
#define SIG0(x) (ROTR(x, 7) ^ ROTR(x, 18) ^ ((x) >> 3))
#define SIG1(x) (ROTR(x, 17) ^ ROTR(x, 19) ^ ((x) >> 10))

static void sha256_digest(const uint8_t *data, size_t len, uint8_t out[32]) {
    uint32_t h0 = 0x6a09e667;
    uint32_t h1 = 0xbb67ae85;
    uint32_t h2 = 0x3c6ef372;
    uint32_t h3 = 0xa54ff53a;
    uint32_t h4 = 0x510e527f;
    uint32_t h5 = 0x9b05688c;
    uint32_t h6 = 0x1f83d9ab;
    uint32_t h7 = 0x5be0cd19;

    size_t padded_len = len + 1;
    size_t mod = padded_len % 64;
    if (mod > 56) {
        padded_len += 64 - mod + 64;
    } else {
        padded_len += 64 - mod;
    }
    uint8_t *msg = (uint8_t *)calloc(padded_len, 1);
    if (!msg) {
        return;
    }
    memcpy(msg, data, len);
    msg[len] = 0x80;
    uint64_t bit_len = (uint64_t)len * 8;
    for (int i = 0; i < 8; i++) {
        msg[padded_len - 8 + i] = (uint8_t)(bit_len >> (56 - 8 * i));
    }

    for (size_t off = 0; off < padded_len; off += 64) {
        uint32_t w[64];
        for (int i = 0; i < 16; i++) {
            w[i] = ((uint32_t)msg[off + i * 4] << 24) | ((uint32_t)msg[off + i * 4 + 1] << 16) |
                   ((uint32_t)msg[off + i * 4 + 2] << 8) | (uint32_t)msg[off + i * 4 + 3];
        }
        for (int i = 16; i < 64; i++) {
            w[i] = SIG1(w[i - 2]) + w[i - 7] + SIG0(w[i - 15]) + w[i - 16];
        }
        uint32_t a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, hh = h7;
        for (int i = 0; i < 64; i++) {
            uint32_t t1 = hh + EP1(e) + CH(e, f, g) + k[i] + w[i];
            uint32_t t2 = EP0(a) + MAJ(a, b, c);
            hh = g;
            g = f;
            f = e;
            e = d + t1;
            d = c;
            c = b;
            b = a;
            a = t1 + t2;
        }
        h0 += a;
        h1 += b;
        h2 += c;
        h3 += d;
        h4 += e;
        h5 += f;
        h6 += g;
        h7 += hh;
    }
    free(msg);

    uint32_t hs[8] = {h0, h1, h2, h3, h4, h5, h6, h7};
    for (int i = 0; i < 8; i++) {
        out[i * 4] = (uint8_t)(hs[i] >> 24);
        out[i * 4 + 1] = (uint8_t)(hs[i] >> 16);
        out[i * 4 + 2] = (uint8_t)(hs[i] >> 8);
        out[i * 4 + 3] = (uint8_t)hs[i];
    }
}

void nyra_sha256_raw(const uint8_t *data, size_t len, uint8_t out[32]) {
    sha256_digest(data, len, out);
}

char *sha256_hex(const char *data) {
    if (!data) {
        return NULL;
    }
    uint8_t digest[32];
    sha256_digest((const uint8_t *)data, strlen(data), digest);
    return digest_to_hex(digest, 32);
}

char *hmac_sha256_hex(const char *key, const char *data) {
    if (!key || !data) {
        return NULL;
    }
    uint8_t k0[64];
    memset(k0, 0, sizeof(k0));
    size_t klen = strlen(key);
    if (klen > 64) {
        uint8_t kh[32];
        sha256_digest((const uint8_t *)key, klen, kh);
        memcpy(k0, kh, 32);
    } else {
        memcpy(k0, key, klen);
    }
    uint8_t ipad[64];
    uint8_t opad[64];
    for (int i = 0; i < 64; i++) {
        ipad[i] = (uint8_t)(k0[i] ^ 0x36);
        opad[i] = (uint8_t)(k0[i] ^ 0x5c);
    }
    size_t dlen = strlen(data);
    uint8_t inner_input[64 + 65536];
    if (dlen > 65536) {
        return NULL;
    }
    memcpy(inner_input, ipad, 64);
    memcpy(inner_input + 64, data, dlen);
    uint8_t inner[32];
    sha256_digest(inner_input, 64 + dlen, inner);
    uint8_t outer_input[96];
    memcpy(outer_input, opad, 64);
    memcpy(outer_input + 64, inner, 32);
    uint8_t out[32];
    sha256_digest(outer_input, 96, out);
    return digest_to_hex(out, 32);
}
