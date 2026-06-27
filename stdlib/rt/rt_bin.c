#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    uint8_t *data;
    size_t len;
    size_t cap;
} BinBuf;

static void bin_buf_reserve(BinBuf *b, size_t need) {
    if (b->len + need <= b->cap) {
        return;
    }
    size_t ncap = b->cap ? b->cap : 64;
    while (ncap < b->len + need) {
        ncap *= 2;
    }
    uint8_t *next = (uint8_t *)realloc(b->data, ncap);
    if (!next) {
        return;
    }
    b->data = next;
    b->cap = ncap;
}

static void bin_write_u32(BinBuf *b, uint32_t v) {
    bin_buf_reserve(b, 4);
    if (!b->data) {
        return;
    }
    b->data[b->len++] = (uint8_t)(v & 0xff);
    b->data[b->len++] = (uint8_t)((v >> 8) & 0xff);
    b->data[b->len++] = (uint8_t)((v >> 16) & 0xff);
    b->data[b->len++] = (uint8_t)((v >> 24) & 0xff);
}

void *bin_buf_new(void) {
    BinBuf *b = (BinBuf *)calloc(1, sizeof(BinBuf));
    return b;
}

void bin_buf_write_i32(void *handle, int32_t v) {
    BinBuf *b = (BinBuf *)handle;
    if (!b) {
        return;
    }
    bin_write_u32(b, (uint32_t)v);
}

void bin_buf_write_bool(void *handle, int flag) {
    BinBuf *b = (BinBuf *)handle;
    if (!b) {
        return;
    }
    bin_buf_reserve(b, 1);
    if (!b->data) {
        return;
    }
    b->data[b->len++] = flag ? 1 : 0;
}

void bin_buf_write_string(void *handle, const char *s) {
    BinBuf *b = (BinBuf *)handle;
    if (!b) {
        return;
    }
    if (!s) {
        s = "";
    }
    uint32_t len = (uint32_t)strlen(s);
    bin_write_u32(b, len);
    if (len > 0) {
        bin_buf_reserve(b, len);
        if (!b->data) {
            return;
        }
        memcpy(b->data + b->len, s, len);
        b->len += len;
    }
}

void bin_buf_write_bytes(void *handle, const void *bytes, int32_t len) {
    BinBuf *b = (BinBuf *)handle;
    if (!b || !bytes || len < 0) {
        return;
    }
    bin_write_u32(b, (uint32_t)len);
    if (len > 0) {
        bin_buf_reserve(b, (size_t)len);
        if (!b->data) {
            return;
        }
        memcpy(b->data + b->len, bytes, (size_t)len);
        b->len += (size_t)len;
    }
}

void *bin_buf_finish(void *handle) {
    BinBuf *b = (BinBuf *)handle;
    if (!b) {
        return NULL;
    }
    uint8_t *out = (uint8_t *)malloc(b->len + 4);
    if (!out) {
        free(b->data);
        free(b);
        return NULL;
    }
    out[0] = (uint8_t)(b->len & 0xff);
    out[1] = (uint8_t)((b->len >> 8) & 0xff);
    out[2] = (uint8_t)((b->len >> 16) & 0xff);
    out[3] = (uint8_t)((b->len >> 24) & 0xff);
    if (b->len > 0) {
        memcpy(out + 4, b->data, b->len);
    }
    free(b->data);
    free(b);
    return out;
}

static uint32_t bin_read_u32(const uint8_t *data, int32_t off, int32_t total) {
    if (!data || off < 0 || off + 4 > total) {
        return 0;
    }
    return (uint32_t)data[off]
        | ((uint32_t)data[off + 1] << 8)
        | ((uint32_t)data[off + 2] << 16)
        | ((uint32_t)data[off + 3] << 24);
}

int32_t bin_blob_payload_len(void *blob) {
    if (!blob) {
        return 0;
    }
    const uint8_t *p = (const uint8_t *)blob;
    return (int32_t)((uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16)
                     | ((uint32_t)p[3] << 24));
}

int32_t bin_decode_i32_at(void *blob, int32_t off) {
    if (!blob) {
        return 0;
    }
    int32_t total = bin_blob_payload_len(blob) + 4;
    const uint8_t *data = (const uint8_t *)blob;
    return (int32_t)bin_read_u32(data, off, total);
}

int32_t bin_decode_bool_at(void *blob, int32_t off) {
    if (!blob) {
        return 0;
    }
    int32_t total = bin_blob_payload_len(blob) + 4;
    const uint8_t *data = (const uint8_t *)blob;
    if (off < 0 || off + 1 > total) {
        return 0;
    }
    return data[off] ? 1 : 0;
}

char *bin_decode_string_at(void *blob, int32_t off) {
    if (!blob) {
        return NULL;
    }
    int32_t total = bin_blob_payload_len(blob) + 4;
    const uint8_t *data = (const uint8_t *)blob;
    uint32_t len = bin_read_u32(data, off, total);
    int32_t start = off + 4;
    if (start < 0 || (int32_t)len < 0 || start + (int32_t)len > total) {
        return NULL;
    }
    char *out = (char *)malloc((size_t)len + 1);
    if (!out) {
        return NULL;
    }
    if (len > 0) {
        memcpy(out, data + start, len);
    }
    out[len] = '\0';
    return out;
}

int32_t bin_field_width_string_at(void *blob, int32_t off) {
    if (!blob) {
        return 4;
    }
    int32_t total = bin_blob_payload_len(blob) + 4;
    const uint8_t *data = (const uint8_t *)blob;
    uint32_t len = bin_read_u32(data, off, total);
    return 4 + (int32_t)len;
}

int32_t bin_field_width_i32(void) {
    return 4;
}

int32_t bin_field_width_bool(void) {
    return 1;
}

int32_t bin_field_width_bytes_at(void *blob, int32_t off) {
    if (!blob) {
        return 4;
    }
    int32_t total = bin_blob_payload_len(blob) + 4;
    const uint8_t *data = (const uint8_t *)blob;
    uint32_t len = bin_read_u32(data, off, total);
    return 4 + (int32_t)len;
}

void bin_buf_append_blob(void *handle, void *blob) {
    if (!blob) {
        return;
    }
    int32_t len = bin_blob_payload_len(blob);
    bin_buf_write_bytes(handle, blob, len + 4);
}

void *bin_decode_blob_at(void *blob, int32_t off) {
    if (!blob) {
        return NULL;
    }
    int32_t total = bin_blob_payload_len(blob) + 4;
    const uint8_t *data = (const uint8_t *)blob;
    uint32_t len = bin_read_u32(data, off, total);
    int32_t start = off + 4;
    if (start < 0 || (int32_t)len < 0 || start + (int32_t)len > total) {
        return NULL;
    }
    uint8_t *out = (uint8_t *)malloc((size_t)len + 5);
    if (!out) {
        return NULL;
    }
    out[0] = (uint8_t)(len & 0xff);
    out[1] = (uint8_t)((len >> 8) & 0xff);
    out[2] = (uint8_t)((len >> 16) & 0xff);
    out[3] = (uint8_t)((len >> 24) & 0xff);
    if (len > 0) {
        memcpy(out + 4, data + start, len);
    }
    out[len + 4] = '\0';
    return out;
}

int32_t bin_field_width_blob_at(void *blob, int32_t off) {
    if (!blob) {
        return 4;
    }
    int32_t total = bin_blob_payload_len(blob) + 4;
    const uint8_t *data = (const uint8_t *)blob;
    uint32_t len = bin_read_u32(data, off, total);
    return 4 + (int32_t)len;
}

void bin_blob_free(void *blob) {
    free(blob);
}
