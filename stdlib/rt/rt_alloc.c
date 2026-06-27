#include <stdlib.h>
#include <string.h>

void heap_free(void *p) {
    if (p) {
        free(p);
    }
}

char *str_clone(const char *s) {
    if (!s) {
        return NULL;
    }
    size_t n = strlen(s);
    char *p = (char *)malloc(n + 1);
    if (p) {
        memcpy(p, s, n + 1);
    }
    return p;
}
