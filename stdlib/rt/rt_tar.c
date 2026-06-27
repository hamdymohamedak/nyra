#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define TAR_BLOCK 512

typedef struct {
    char name[100];
    char mode[8];
    char uid[8];
    char gid[8];
    char size[12];
    char mtime[12];
    char chksum[8];
    char typeflag;
    char linkname[100];
    char magic[6];
    char version[2];
    char padding[355];
} TarHeader;

static void tar_octal(char *dst, int field, unsigned long value) {
    snprintf(dst, (size_t)field, "%0*lo", field - 1, value);
}

static unsigned tar_checksum(const TarHeader *h) {
    const unsigned char *p = (const unsigned char *)h;
    unsigned sum = 0;
    for (int i = 0; i < TAR_BLOCK; i++) {
        if (i >= 148 && i < 156) {
            sum += (unsigned)' ';
        } else {
            sum += p[i];
        }
    }
    return sum;
}

static void tar_fill_header(TarHeader *h, const char *name, size_t size) {
    memset(h, 0, sizeof(*h));
    strncpy(h->name, name, sizeof(h->name) - 1);
    tar_octal(h->mode, sizeof(h->mode), 0644);
    tar_octal(h->uid, sizeof(h->uid), 0);
    tar_octal(h->gid, sizeof(h->gid), 0);
    tar_octal(h->size, sizeof(h->size), (unsigned long)size);
    tar_octal(h->mtime, sizeof(h->mtime), 0);
    h->typeflag = '0';
    memcpy(h->magic, "ustar", 5);
    memcpy(h->version, "00", 2);
    memset(h->chksum, ' ', sizeof(h->chksum));
    tar_octal(h->chksum, sizeof(h->chksum), tar_checksum(h));
}

static int tar_write_zeros(FILE *f, size_t n) {
    char zero[TAR_BLOCK];
    memset(zero, 0, sizeof(zero));
    while (n > 0) {
        size_t chunk = n > sizeof(zero) ? sizeof(zero) : n;
        if (fwrite(zero, 1, chunk, f) != chunk) {
            return -1;
        }
        n -= chunk;
    }
    return 0;
}

static const char *basename_only(const char *path) {
    const char *slash = strrchr(path, '/');
    return slash ? slash + 1 : path;
}

extern void *vec_str_new(void);
extern int vec_str_len(void *v);
extern char *vec_str_get(void *v, int index);

int tar_create(const char *archive, void *paths_vec) {
    if (!archive || !paths_vec) {
        return -1;
    }
    FILE *out = fopen(archive, "wb");
    if (!out) {
        return -1;
    }
    int n = vec_str_len(paths_vec);
    for (int i = 0; i < n; i++) {
        char *path = vec_str_get(paths_vec, i);
        if (!path) {
            continue;
        }
        FILE *in = fopen(path, "rb");
        if (!in) {
            fclose(out);
            return -1;
        }
        fseek(in, 0, SEEK_END);
        long sz = ftell(in);
        if (sz < 0) {
            fclose(in);
            fclose(out);
            return -1;
        }
        rewind(in);
        TarHeader hdr;
        tar_fill_header(&hdr, basename_only(path), (size_t)sz);
        if (fwrite(&hdr, 1, sizeof(hdr), out) != sizeof(hdr)) {
            fclose(in);
            fclose(out);
            return -1;
        }
        char buf[8192];
        long left = sz;
        while (left > 0) {
            size_t chunk = left > (long)sizeof(buf) ? sizeof(buf) : (size_t)left;
            size_t got = fread(buf, 1, chunk, in);
            if (got == 0) {
                break;
            }
            if (fwrite(buf, 1, got, out) != got) {
                fclose(in);
                fclose(out);
                return -1;
            }
            left -= (long)got;
        }
        fclose(in);
        size_t pad = ((size_t)sz + TAR_BLOCK - 1) / TAR_BLOCK * TAR_BLOCK - (size_t)sz;
        if (tar_write_zeros(out, pad) != 0) {
            fclose(out);
            return -1;
        }
    }
    if (tar_write_zeros(out, TAR_BLOCK * 2) != 0) {
        fclose(out);
        return -1;
    }
    fclose(out);
    return 0;
}

static int tar_read_header(FILE *f, TarHeader *hdr, size_t *payload) {
    if (fread(hdr, 1, sizeof(*hdr), f) != sizeof(*hdr)) {
        return 0;
    }
    int all_zero = 1;
    unsigned char *p = (unsigned char *)hdr;
    for (size_t i = 0; i < sizeof(*hdr); i++) {
        if (p[i] != 0) {
            all_zero = 0;
            break;
        }
    }
    if (all_zero) {
        return 0;
    }
    *payload = (size_t)strtoul(hdr->size, NULL, 8);
    return 1;
}

int tar_extract(const char *archive, const char *out_dir) {
    if (!archive || !out_dir) {
        return -1;
    }
    FILE *in = fopen(archive, "rb");
    if (!in) {
        return -1;
    }
    TarHeader hdr;
    size_t payload;
    while (tar_read_header(in, &hdr, &payload)) {
        char outpath[512];
        snprintf(outpath, sizeof(outpath), "%s/%s", out_dir, hdr.name);
        FILE *out = fopen(outpath, "wb");
        if (!out) {
            fclose(in);
            return -1;
        }
        char buf[8192];
        size_t left = payload;
        while (left > 0) {
            size_t chunk = left > sizeof(buf) ? sizeof(buf) : left;
            size_t got = fread(buf, 1, chunk, in);
            if (got == 0) {
                break;
            }
            if (fwrite(buf, 1, got, out) != got) {
                fclose(out);
                fclose(in);
                return -1;
            }
            left -= got;
        }
        fclose(out);
        size_t pad = (payload + TAR_BLOCK - 1) / TAR_BLOCK * TAR_BLOCK - payload;
        fseek(in, (long)pad, SEEK_CUR);
    }
    fclose(in);
    return 0;
}
