#include "aes_core.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void nyra_sha256_raw(const uint8_t *data, size_t len, uint8_t out[32]);

static const char hex_digits[] = "0123456789abcdef";

static char *bytes_to_hex(const uint8_t *buf, size_t len) {
    char *out = (char *)malloc(len * 2 + 1);
    if (!out) {
        return NULL;
    }
    for (size_t i = 0; i < len; i++) {
        out[i * 2] = hex_digits[buf[i] >> 4];
        out[i * 2 + 1] = hex_digits[buf[i] & 0x0f];
    }
    out[len * 2] = '\0';
    return out;
}

static int hex_nibble(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10;
    }
    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    }
    return -1;
}

static uint8_t *hex_to_bytes(const char *hex, size_t *out_len) {
    if (!hex) {
        return NULL;
    }
    size_t n = strlen(hex);
    if (n % 2 != 0) {
        return NULL;
    }
    uint8_t *buf = (uint8_t *)malloc(n / 2);
    if (!buf) {
        return NULL;
    }
    for (size_t i = 0; i < n / 2; i++) {
        int hi = hex_nibble(hex[i * 2]);
        int lo = hex_nibble(hex[i * 2 + 1]);
        if (hi < 0 || lo < 0) {
            free(buf);
            return NULL;
        }
        buf[i] = (uint8_t)((hi << 4) | lo);
    }
    *out_len = n / 2;
    return buf;
}

static void derive_key_iv(const char *passphrase, uint8_t key[32], uint8_t iv[16]) {
    nyra_sha256_raw((const uint8_t *)passphrase, strlen(passphrase), key);
    char tag[256];
    snprintf(tag, sizeof(tag), "%s:nyra-aes-iv", passphrase);
    uint8_t ivhash[32];
    nyra_sha256_raw((const uint8_t *)tag, strlen(tag), ivhash);
    memcpy(iv, ivhash, 16);
}

static int pkcs7_pad(const uint8_t *in, size_t in_len, uint8_t **out, size_t *out_len) {
    size_t pad = AES_BLOCKLEN - (in_len % AES_BLOCKLEN);
    if (pad == 0) {
        pad = AES_BLOCKLEN;
    }
    size_t total = in_len + pad;
    uint8_t *buf = (uint8_t *)malloc(total);
    if (!buf) {
        return -1;
    }
    memcpy(buf, in, in_len);
    memset(buf + in_len, (int)pad, pad);
    *out = buf;
    *out_len = total;
    return 0;
}

static int pkcs7_unpad(uint8_t *buf, size_t *len) {
    if (!buf || *len == 0 || *len % AES_BLOCKLEN != 0) {
        return -1;
    }
    uint8_t pad = buf[*len - 1];
    if (pad == 0 || pad > AES_BLOCKLEN || pad > *len) {
        return -1;
    }
    for (size_t i = 0; i < pad; i++) {
        if (buf[*len - 1 - i] != pad) {
            return -1;
        }
    }
    *len -= pad;
    return 0;
}

char *aes_cbc_encrypt_hex(const char *key, const char *plaintext) {
    if (!key || !plaintext) {
        return NULL;
    }
    uint8_t aes_key[32];
    uint8_t iv[16];
    derive_key_iv(key, aes_key, iv);

    uint8_t *padded = NULL;
    size_t padded_len = 0;
    if (pkcs7_pad((const uint8_t *)plaintext, strlen(plaintext), &padded, &padded_len) != 0) {
        return NULL;
    }

    struct AES_ctx ctx;
    AES_init_ctx_iv(&ctx, aes_key, iv);
    AES_CBC_encrypt_buffer(&ctx, padded, padded_len);

    size_t packet_len = AES_BLOCKLEN + padded_len;
    uint8_t *packet = (uint8_t *)malloc(packet_len);
    if (!packet) {
        free(padded);
        return NULL;
    }
    memcpy(packet, iv, AES_BLOCKLEN);
    memcpy(packet + AES_BLOCKLEN, padded, padded_len);
    free(padded);

    char *hex = bytes_to_hex(packet, packet_len);
    free(packet);
    return hex;
}

char *aes_cbc_decrypt_hex(const char *key, const char *ciphertext_hex) {
    if (!key || !ciphertext_hex) {
        return NULL;
    }
    size_t packet_len = 0;
    uint8_t *packet = hex_to_bytes(ciphertext_hex, &packet_len);
    if (!packet || packet_len <= AES_BLOCKLEN) {
        free(packet);
        return NULL;
    }

    uint8_t aes_key[32];
    uint8_t iv[16];
    derive_key_iv(key, aes_key, iv);
    (void)iv;
    memcpy(iv, packet, AES_BLOCKLEN);

    size_t ct_len = packet_len - AES_BLOCKLEN;
    uint8_t *buf = (uint8_t *)malloc(ct_len);
    if (!buf) {
        free(packet);
        return NULL;
    }
    memcpy(buf, packet + AES_BLOCKLEN, ct_len);
    free(packet);

    struct AES_ctx ctx;
    AES_init_ctx_iv(&ctx, aes_key, iv);
    AES_CBC_decrypt_buffer(&ctx, buf, ct_len);

    size_t pt_len = ct_len;
    if (pkcs7_unpad(buf, &pt_len) != 0) {
        free(buf);
        return NULL;
    }

    char *out = (char *)malloc(pt_len + 1);
    if (!out) {
        free(buf);
        return NULL;
    }
    memcpy(out, buf, pt_len);
    out[pt_len] = '\0';
    free(buf);
    return out;
}
