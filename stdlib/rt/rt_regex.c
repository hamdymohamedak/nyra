#include <regex.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    regex_t re;
    int compiled;
    char pattern[512];
} NyraRegex;

void *regex_compile(const char *pattern) {
    if (!pattern) {
        return NULL;
    }
    NyraRegex *r = (NyraRegex *)calloc(1, sizeof(NyraRegex));
    if (!r) {
        return NULL;
    }
    strncpy(r->pattern, pattern, sizeof(r->pattern) - 1);
    if (regcomp(&r->re, pattern, REG_EXTENDED | REG_NOSUB) != 0) {
        free(r);
        return NULL;
    }
    r->compiled = 1;
    return r;
}

int regex_is_match(void *handle, const char *text) {
    NyraRegex *r = (NyraRegex *)handle;
    if (!r || !r->compiled || !text) {
        return 0;
    }
    return regexec(&r->re, text, 0, NULL, 0) == 0 ? 1 : 0;
}

void regex_free(void *handle) {
    NyraRegex *r = (NyraRegex *)handle;
    if (!r) {
        return;
    }
    if (r->compiled) {
        regfree(&r->re);
    }
    free(r);
}
