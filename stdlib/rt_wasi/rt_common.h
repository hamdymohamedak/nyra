#ifndef NYRA_RT_WASI_COMMON_H
#define NYRA_RT_WASI_COMMON_H

#include <stddef.h>

void nyra_wasi_append(const char *bytes, size_t len);
void nyra_wasi_flush_and_reset(void);

#endif
