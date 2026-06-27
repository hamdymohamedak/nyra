#include "rt_common.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static char *nyra_wasi_buf = NULL;
static size_t nyra_wasi_len = 0;
static size_t nyra_wasi_cap = 0;

void nyra_wasi_append(const char *bytes, size_t len) {
    if (!bytes || len == 0) {
        return;
    }
    if (nyra_wasi_len + len > nyra_wasi_cap) {
        size_t nc = nyra_wasi_cap ? nyra_wasi_cap * 2 : 4096;
        while (nc < nyra_wasi_len + len) {
            nc *= 2;
        }
        char *nd = (char *)realloc(nyra_wasi_buf, nc);
        if (!nd) {
            return;
        }
        nyra_wasi_buf = nd;
        nyra_wasi_cap = nc;
    }
    memcpy(nyra_wasi_buf + nyra_wasi_len, bytes, len);
    nyra_wasi_len += len;
}

void nyra_wasi_flush_and_reset(void) {
    if (nyra_wasi_len == 0 || !nyra_wasi_buf) {
        return;
    }
    fwrite(nyra_wasi_buf, 1, nyra_wasi_len, stdout);
    fflush(stdout);
    nyra_wasi_len = 0;
}
