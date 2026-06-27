#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *str_cat(const char *a, const char *b) {
    if (!a) {
        a = "";
    }
    if (!b) {
        b = "";
    }
    size_t la = strlen(a);
    size_t lb = strlen(b);
    char *out = (char *)malloc(la + lb + 1);
    if (!out) {
        return NULL;
    }
    memcpy(out, a, la);
    memcpy(out + la, b, lb + 1);
    return out;
}

char *i32_to_string(int n) {
    char buf[32];
    int len = snprintf(buf, sizeof(buf), "%d", n);
    if (len < 0) {
        return NULL;
    }
    char *out = (char *)malloc((size_t)len + 1);
    if (!out) {
        return NULL;
    }
    memcpy(out, buf, (size_t)len + 1);
    return out;
}
