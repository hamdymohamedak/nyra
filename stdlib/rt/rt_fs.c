#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

static char *fs_append_line(char *base, const char *line) {
    if (!line) {
        return base;
    }
    size_t blen = base ? strlen(base) : 0;
    size_t llen = strlen(line);
    char *out = (char *)realloc(base, blen + llen + 2);
    if (!out) {
        free(base);
        return strdup("");
    }
    if (blen > 0) {
        out[blen] = '\n';
        memcpy(out + blen + 1, line, llen + 1);
    } else {
        memcpy(out, line, llen + 1);
    }
    return out;
}

char *read_file(const char *path) {
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
    buf[n] = '\0';
    return buf;
}

char *read_file_limit(const char *path, int max_bytes) {
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
    long to_read = sz;
    if (max_bytes > 0 && to_read > max_bytes) {
        to_read = max_bytes;
    }
    char *buf = (char *)malloc((size_t)to_read + 1);
    if (!buf) {
        fclose(f);
        return NULL;
    }
    size_t n = fread(buf, 1, (size_t)to_read, f);
    fclose(f);
    buf[n] = '\0';
    return buf;
}

int write_file(const char *path, const char *content) {
    FILE *f = fopen(path, "wb");
    if (!f) {
        return -1;
    }
    size_t len = strlen(content);
    size_t n = fwrite(content, 1, len, f);
    fclose(f);
    return (int)((n == len) ? 0 : -1);
}

int file_exists(const char *path) {
    struct stat st;
    if (!path) {
        return 0;
    }
    return stat(path, &st) == 0 ? 1 : 0;
}

int append_file(const char *path, const char *content) {
    FILE *f = fopen(path, "ab");
    if (!f || !content) {
        return -1;
    }
    size_t len = strlen(content);
    size_t n = fwrite(content, 1, len, f);
    fclose(f);
    return (int)((n == len) ? 0 : -1);
}

int fsync_file(const char *path) {
    if (!path) {
        return -1;
    }
    FILE *f = fopen(path, "r+b");
    if (!f) {
        f = fopen(path, "wb");
    }
    if (!f) {
        return -1;
    }
    fflush(f);
#if defined(__APPLE__) || defined(__linux__)
    int fd = fileno(f);
    int rc = fsync(fd);
    fclose(f);
    return rc == 0 ? 0 : -1;
#else
    fclose(f);
    return 0;
#endif
}

int remove_file(const char *path) {
    if (!path) {
        return -1;
    }
    return unlink(path) == 0 ? 0 : -1;
}

int create_dir(const char *path) {
    if (!path) {
        return -1;
    }
    return mkdir(path, 0755) == 0 ? 0 : -1;
}

int remove_dir(const char *path) {
    if (!path) {
        return -1;
    }
    return rmdir(path) == 0 ? 0 : -1;
}

long long file_size(const char *path) {
    struct stat st;
    if (!path || stat(path, &st) != 0) {
        return -1;
    }
    return (long long)st.st_size;
}

int path_is_dir(const char *path) {
    struct stat st;
    if (!path || stat(path, &st) != 0) {
        return 0;
    }
    return S_ISDIR(st.st_mode) ? 1 : 0;
}

char *list_dir(const char *path) {
    DIR *d = opendir(path);
    if (!d) {
        return strdup("");
    }
    char *out = strdup("");
    struct dirent *ent;
    while ((ent = readdir(d)) != NULL) {
        const char *name = ent->d_name;
        if (!name) {
            continue;
        }
        if (name[0] == '.' && (name[1] == '\0' || (name[1] == '.' && name[2] == '\0'))) {
            continue;
        }
        out = fs_append_line(out, name);
    }
    closedir(d);
    return out ? out : strdup("");
}

long long copy_file(const char *src, const char *dst) {
    FILE *in = NULL;
    FILE *out = NULL;
    char buf[65536];
    long long total = 0;

    if (!src || !dst) {
        return -1;
    }
    in = fopen(src, "rb");
    if (!in) {
        return -1;
    }
    out = fopen(dst, "wb");
    if (!out) {
        fclose(in);
        return -1;
    }
    for (;;) {
        size_t n = fread(buf, 1, sizeof(buf), in);
        if (n == 0) {
            break;
        }
        if (fwrite(buf, 1, n, out) != n) {
            fclose(in);
            fclose(out);
            return -1;
        }
        total += (long long)n;
    }
    if (ferror(in)) {
        fclose(in);
        fclose(out);
        return -1;
    }
    fclose(in);
    fclose(out);
    return total;
}
