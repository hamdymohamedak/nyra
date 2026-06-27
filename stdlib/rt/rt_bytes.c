#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char *data;
    long long len;
} ByteBuf;

static ByteBuf *bytebuf_new(const char *data, long long len) {
    ByteBuf *b = (ByteBuf *)calloc(1, sizeof(ByteBuf));
    if (!b) {
        return NULL;
    }
    if (len > 0 && data) {
        b->data = (char *)malloc((size_t)len);
        if (!b->data) {
            free(b);
            return NULL;
        }
        memcpy(b->data, data, (size_t)len);
    } else {
        b->data = (char *)malloc(1);
        if (!b->data) {
            free(b);
            return NULL;
        }
        b->data[0] = '\0';
    }
    b->len = len;
    return b;
}

void *bytes_read_file(const char *path) {
    if (!path) {
        return NULL;
    }
    FILE *f = fopen(path, "rb");
    if (!f) {
        return NULL;
    }
    if (fseek(f, 0, SEEK_END) != 0) {
        fclose(f);
        return NULL;
    }
    long sz = ftell(f);
    if (sz < 0) {
        fclose(f);
        return NULL;
    }
    rewind(f);
    char *buf = (char *)malloc((size_t)sz + 1);
    if (!buf) {
        fclose(f);
        return NULL;
    }
    size_t n = fread(buf, 1, (size_t)sz, f);
    fclose(f);
    ByteBuf *out = bytebuf_new(buf, (long long)n);
    free(buf);
    return out;
}

long long bytes_len(void *handle) {
    ByteBuf *b = (ByteBuf *)handle;
    return b ? b->len : 0;
}

int byte_at(void *handle, long long index) {
    ByteBuf *b = (ByteBuf *)handle;
    if (!b || index < 0 || index >= b->len) {
        return 0;
    }
    return (unsigned char)b->data[index];
}

int bytes_write_file(const char *path, void *handle) {
    ByteBuf *b = (ByteBuf *)handle;
    if (!path || !b) {
        return -1;
    }
    FILE *f = fopen(path, "wb");
    if (!f) {
        return -1;
    }
    size_t n = b->len > 0 ? (size_t)b->len : 0;
    size_t w = fwrite(b->data, 1, n, f);
    fclose(f);
    return (w == n) ? 0 : -1;
}

void bytes_free(void *handle) {
    ByteBuf *b = (ByteBuf *)handle;
    if (!b) {
        return;
    }
    free(b->data);
    free(b);
}

void *bytes_from_string(const char *s) {
    if (!s) {
        return bytebuf_new("", 0);
    }
    return bytebuf_new(s, (long long)strlen(s));
}

char *bytes_to_string(void *handle) {
    ByteBuf *b = (ByteBuf *)handle;
    if (!b) {
        return strdup("");
    }
    char *out = (char *)malloc((size_t)b->len + 1);
    if (!out) {
        return NULL;
    }
    if (b->len > 0) {
        memcpy(out, b->data, (size_t)b->len);
    }
    out[b->len] = '\0';
    return out;
}

void *stdin_read_bytes(int max_bytes) {
    long long limit = max_bytes <= 0 ? (64LL * 1024 * 1024) : (long long)max_bytes;
    size_t cap = (size_t)limit + 1;
    char *buf = (char *)malloc(cap);
    if (!buf) {
        return NULL;
    }
    size_t total = 0;
    while (total < (size_t)limit) {
        size_t chunk = cap - total - 1;
        if (chunk > 65536) {
            chunk = 65536;
        }
        size_t n = fread(buf + total, 1, chunk, stdin);
        if (n == 0) {
            break;
        }
        total += n;
    }
    buf[total] = '\0';
    ByteBuf *out = bytebuf_new(buf, (long long)total);
    free(buf);
    return out;
}

void stdout_write_bytes(void *handle) {
    ByteBuf *b = (ByteBuf *)handle;
    if (!b || b->len <= 0) {
        return;
    }
    fwrite(b->data, 1, (size_t)b->len, stdout);
    fflush(stdout);
}
