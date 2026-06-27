#ifndef NYRA_AES_CORE_H
#define NYRA_AES_CORE_H

#include <stddef.h>
#include <stdint.h>

#define CBC 1
#define ECB 1
#define CTR 0
#define AES128 0
#define AES192 0
#define AES256 1

#define AES_BLOCKLEN 16

#define AES_KEYLEN 32
#define AES_keyExpSize 240

struct AES_ctx {
    uint8_t RoundKey[AES_keyExpSize];
    uint8_t Iv[AES_BLOCKLEN];
};

void AES_init_ctx_iv(struct AES_ctx *ctx, const uint8_t *key, const uint8_t *iv);
void AES_CBC_encrypt_buffer(struct AES_ctx *ctx, uint8_t *buf, size_t length);
void AES_CBC_decrypt_buffer(struct AES_ctx *ctx, uint8_t *buf, size_t length);

#endif
