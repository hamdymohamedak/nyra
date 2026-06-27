#include <stdlib.h>
#include <string.h>

extern char *i32_to_string(int n);
extern char *f64_to_string(double n);
extern char *str_cat(const char *a, const char *b);

static char *debug_append(char *acc, const char *piece) {
    char *joined = str_cat(acc, piece);
    free(acc);
    return joined;
}

static char *debug_empty_array(void) {
    char *out = (char *)malloc(3);
    if (out) {
        memcpy(out, "[]", 3);
    }
    return out;
}

static char *debug_finish(char *acc) {
    return debug_append(acc, "]");
}

static char *debug_start(void) {
    char *out = (char *)malloc(2);
    if (out) {
        out[0] = '[';
        out[1] = '\0';
    }
    return out;
}

char *array_i32_debug_string(const int *arr, int n) {
    if (!arr || n <= 0) {
        return debug_empty_array();
    }
    char *out = debug_start();
    if (!out) {
        return NULL;
    }
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            out = debug_append(out, ", ");
            if (!out) {
                return NULL;
            }
        }
        char *num = i32_to_string(arr[i]);
        if (!num) {
            free(out);
            return NULL;
        }
        char *next = str_cat(out, num);
        free(out);
        free(num);
        out = next;
        if (!out) {
            return NULL;
        }
    }
    return debug_finish(out);
}

char *array_f64_debug_string(const double *arr, int n) {
    if (!arr || n <= 0) {
        return debug_empty_array();
    }
    char *out = debug_start();
    if (!out) {
        return NULL;
    }
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            out = debug_append(out, ", ");
            if (!out) {
                return NULL;
            }
        }
        char *num = f64_to_string(arr[i]);
        if (!num) {
            free(out);
            return NULL;
        }
        char *next = str_cat(out, num);
        free(out);
        free(num);
        out = next;
        if (!out) {
            return NULL;
        }
    }
    return debug_finish(out);
}

char *array_f32_debug_string(const float *arr, int n) {
    if (!arr || n <= 0) {
        return debug_empty_array();
    }
    char *out = debug_start();
    if (!out) {
        return NULL;
    }
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            out = debug_append(out, ", ");
            if (!out) {
                return NULL;
            }
        }
        char *num = f64_to_string((double)arr[i]);
        if (!num) {
            free(out);
            return NULL;
        }
        char *next = str_cat(out, num);
        free(out);
        free(num);
        out = next;
        if (!out) {
            return NULL;
        }
    }
    return debug_finish(out);
}

char *array_bool_debug_string(const unsigned char *arr, int n) {
    if (!arr || n <= 0) {
        return debug_empty_array();
    }
    char *out = debug_start();
    if (!out) {
        return NULL;
    }
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            out = debug_append(out, ", ");
            if (!out) {
                return NULL;
            }
        }
        const char *word = (arr[i] & 1) ? "true" : "false";
        char *next = str_cat(out, word);
        free(out);
        out = next;
        if (!out) {
            return NULL;
        }
    }
    return debug_finish(out);
}

static char *debug_quote_string(const char *s) {
    if (!s) {
        s = "";
    }
    size_t len = strlen(s);
    char *out = (char *)malloc(len * 2 + 3);
    if (!out) {
        return NULL;
    }
    size_t j = 0;
    out[j++] = '"';
    for (size_t i = 0; i < len; i++) {
        unsigned char c = (unsigned char)s[i];
        if (c == '"' || c == '\\') {
            out[j++] = '\\';
        }
        out[j++] = (char)c;
    }
    out[j++] = '"';
    out[j] = '\0';
    return out;
}

char *array_str_debug_string(const char *const *arr, int n) {
    if (!arr || n <= 0) {
        return debug_empty_array();
    }
    char *out = debug_start();
    if (!out) {
        return NULL;
    }
    for (int i = 0; i < n; i++) {
        if (i > 0) {
            out = debug_append(out, ", ");
            if (!out) {
                return NULL;
            }
        }
        char *quoted = debug_quote_string(arr[i]);
        if (!quoted) {
            free(out);
            return NULL;
        }
        char *next = str_cat(out, quoted);
        free(out);
        free(quoted);
        out = next;
        if (!out) {
            return NULL;
        }
    }
    return debug_finish(out);
}
