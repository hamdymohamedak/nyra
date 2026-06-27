#include <stdlib.h>

char *read_file(const char *path) {
    (void)path;
    return NULL;
}

char *read_file_limit(const char *path, int max_bytes) {
    (void)path;
    (void)max_bytes;
    return NULL;
}

int write_file(const char *path, const char *content) {
    (void)path;
    (void)content;
    return -1;
}

int file_exists(const char *path) {
    (void)path;
    return 0;
}

int append_file(const char *path, const char *content) {
    (void)path;
    (void)content;
    return -1;
}

int fsync_file(const char *path) {
    (void)path;
    return -1;
}

int remove_file(const char *path) {
    (void)path;
    return -1;
}

int create_dir(const char *path) {
    (void)path;
    return -1;
}

int remove_dir(const char *path) {
    (void)path;
    return -1;
}
