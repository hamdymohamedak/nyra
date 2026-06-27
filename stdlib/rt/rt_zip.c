#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

extern char *read_file(const char *path);
extern int write_file(const char *path, const char *content);

#define ZIP_LOCAL_SIG 0x04034b50u
#define ZIP_CENTRAL_SIG 0x02014b50u
#define ZIP_END_SIG 0x06054b50u

typedef struct {
    char *name;
    const char *data;
    size_t size;
    uint32_t crc;
} ZipEntry;

static uint32_t zip_crc32(const unsigned char *buf, size_t len) {
    static uint32_t table[256];
    static int init = 0;
    if (!init) {
        for (uint32_t i = 0; i < 256; i++) {
            uint32_t c = i;
            for (int j = 0; j < 8; j++) {
                c = (c & 1) ? (0xedb88320u ^ (c >> 1)) : (c >> 1);
            }
            table[i] = c;
        }
        init = 1;
    }
    uint32_t crc = 0xffffffffu;
    for (size_t i = 0; i < len; i++) {
        crc = table[(crc ^ buf[i]) & 0xffu] ^ (crc >> 8);
    }
    return crc ^ 0xffffffffu;
}

static void le16(unsigned char *p, uint16_t v) {
    p[0] = (unsigned char)(v & 0xffu);
    p[1] = (unsigned char)((v >> 8) & 0xffu);
}

static void le32(unsigned char *p, uint32_t v) {
    p[0] = (unsigned char)(v & 0xffu);
    p[1] = (unsigned char)((v >> 8) & 0xffu);
    p[2] = (unsigned char)((v >> 16) & 0xffu);
    p[3] = (unsigned char)((v >> 24) & 0xffu);
}

static int zip_append(unsigned char **out, size_t *len, size_t *cap, const void *data, size_t n) {
    if (*len + n > *cap) {
        size_t nc = *cap ? *cap * 2 : 4096;
        while (nc < *len + n) {
            nc *= 2;
        }
        unsigned char *nd = (unsigned char *)realloc(*out, nc);
        if (!nd) {
            return -1;
        }
        *out = nd;
        *cap = nc;
    }
    memcpy(*out + *len, data, n);
    *len += n;
    return 0;
}

int zip_create_file(const char *archive_path, const char *source_path, const char *entry_name) {
    if (!archive_path || !source_path || !entry_name) {
        return -1;
    }
    char *payload = read_file(source_path);
    if (!payload) {
        return -1;
    }
    size_t size = strlen(payload);
    uint32_t crc = zip_crc32((const unsigned char *)payload, size);
    size_t name_len = strlen(entry_name);

    unsigned char *buf = NULL;
    size_t len = 0;
    size_t cap = 0;
    unsigned char local[30];
    memset(local, 0, sizeof(local));
    le32(local + 0, ZIP_LOCAL_SIG);
    le16(local + 8, 0);
    le32(local + 14, crc);
    le32(local + 18, (uint32_t)size);
    le32(local + 22, (uint32_t)size);
    le16(local + 26, (uint16_t)name_len);
    le16(local + 28, 0);
    if (zip_append(&buf, &len, &cap, local, 30) != 0) {
        free(payload);
        return -1;
    }
    if (zip_append(&buf, &len, &cap, entry_name, name_len) != 0) {
        free(buf);
        free(payload);
        return -1;
    }
    if (zip_append(&buf, &len, &cap, payload, size) != 0) {
        free(buf);
        free(payload);
        return -1;
    }

    unsigned char central[46];
    memset(central, 0, sizeof(central));
    le32(central + 0, ZIP_CENTRAL_SIG);
    le16(central + 10, 0);
    le32(central + 16, crc);
    le32(central + 20, (uint32_t)size);
    le32(central + 24, (uint32_t)size);
    le16(central + 28, (uint16_t)name_len);
    le32(central + 42, 0);
    if (zip_append(&buf, &len, &cap, central, 46) != 0) {
        free(buf);
        free(payload);
        return -1;
    }
    if (zip_append(&buf, &len, &cap, entry_name, name_len) != 0) {
        free(buf);
        free(payload);
        return -1;
    }

    unsigned char endrec[22];
    memset(endrec, 0, sizeof(endrec));
    le32(endrec + 0, ZIP_END_SIG);
    le16(endrec + 8, 1);
    le16(endrec + 10, 1);
    le32(endrec + 12, 46 + (uint32_t)name_len);
    le32(endrec + 16, 0);
    if (zip_append(&buf, &len, &cap, endrec, 22) != 0) {
        free(buf);
        free(payload);
        return -1;
    }

    buf[len] = '\0';
    int rc = write_file(archive_path, (const char *)buf);
    free(buf);
    free(payload);
    return rc;
}

static uint32_t rd32(const unsigned char *p) {
    return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}

static uint16_t rd16(const unsigned char *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

int zip_extract_file(const char *archive_path, const char *dest_path) {
    char *data = read_file(archive_path);
    if (!data) {
        return -1;
    }
    size_t n = strlen(data);
    if (n < 30) {
        free(data);
        return -1;
    }
    const unsigned char *p = (const unsigned char *)data;
    if (rd32(p) != ZIP_LOCAL_SIG) {
        free(data);
        return -1;
    }
    uint16_t name_len = rd16(p + 26);
    uint32_t comp_size = rd32(p + 18);
    uint16_t method = rd16(p + 8);
    if (method != 0) {
        free(data);
        return -1;
    }
    size_t off = 30 + name_len;
    if (off + comp_size > n) {
        free(data);
        return -1;
    }
    char *out = (char *)malloc(comp_size + 1);
    if (!out) {
        free(data);
        return -1;
    }
    memcpy(out, p + off, comp_size);
    out[comp_size] = '\0';
    int rc = write_file(dest_path, out);
    free(out);
    free(data);
    return rc;
}
