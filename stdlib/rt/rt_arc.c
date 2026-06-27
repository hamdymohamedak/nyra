#include "rt_common.h"
#include "../nyra_rt.h"
#include <stdlib.h>
#include <string.h>

typedef struct NyArcCellI32 {
    int refcount;
    int value;
} NyArcCellI32;

typedef struct NyArcCellString {
    int refcount;
    char *value;
} NyArcCellString;

void arc_inc(void *handle) {
    if (!handle) {
        return;
    }
    ((NyArcCellI32 *)handle)->refcount += 1;
}

void *arc_alloc_i32(int value) {
    NyArcCellI32 *cell = (NyArcCellI32 *)calloc(1, sizeof(NyArcCellI32));
    if (!cell) {
        return NULL;
    }
    cell->refcount = 1;
    cell->value = value;
    return (void *)cell;
}

void arc_dec_i32(void *handle) {
    if (!handle) {
        return;
    }
    NyArcCellI32 *cell = (NyArcCellI32 *)handle;
    cell->refcount -= 1;
    if (cell->refcount <= 0) {
        free(cell);
    }
}

int arc_get_i32(void *handle) {
    if (!handle) {
        return 0;
    }
    return ((NyArcCellI32 *)handle)->value;
}

void arc_dec(void *handle) {
    arc_dec_i32(handle);
}

static char *ny_arc_strdup(const char *s) {
    if (!s) {
        s = "";
    }
    size_t n = strlen(s) + 1;
    char *out = (char *)malloc(n);
    if (out) {
        memcpy(out, s, n);
    }
    return out;
}

void *arc_alloc_string(const char *value) {
    NyArcCellString *cell = (NyArcCellString *)calloc(1, sizeof(NyArcCellString));
    if (!cell) {
        return NULL;
    }
    cell->refcount = 1;
    cell->value = ny_arc_strdup(value);
    if (!cell->value) {
        free(cell);
        return NULL;
    }
    return (void *)cell;
}

void arc_dec_string(void *handle) {
    if (!handle) {
        return;
    }
    NyArcCellString *cell = (NyArcCellString *)handle;
    cell->refcount -= 1;
    if (cell->refcount <= 0) {
        if (cell->value) {
            free(cell->value);
        }
        free(cell);
    }
}

char *arc_get_string(void *handle) {
    if (!handle) {
        return NULL;
    }
    NyArcCellString *cell = (NyArcCellString *)handle;
    return cell->value ? cell->value : "";
}
