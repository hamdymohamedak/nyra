#ifndef RT_MAP_HANDLE_H
#define RT_MAP_HANDLE_H

typedef struct {
    int refcount;
    void *inner;
} NyraMapHandle;

static inline void *map_handle_wrap(void *inner) {
    if (!inner) {
        return NULL;
    }
    NyraMapHandle *h = (NyraMapHandle *)calloc(1, sizeof(NyraMapHandle));
    if (!h) {
        return NULL;
    }
    h->refcount = 1;
    h->inner = inner;
    return h;
}

static inline void *map_handle_inner(void *handle) {
    if (!handle) {
        return NULL;
    }
    return ((NyraMapHandle *)handle)->inner;
}

static inline void map_handle_release(void *handle, void (*free_inner)(void *)) {
    NyraMapHandle *h = (NyraMapHandle *)handle;
    if (!h) {
        return;
    }
    h->refcount -= 1;
    if (h->refcount <= 0) {
        if (h->inner && free_inner) {
            free_inner(h->inner);
        }
        free(h);
    }
}

static inline void map_handle_retain(void *handle) {
    NyraMapHandle *h = (NyraMapHandle *)handle;
    if (h) {
        h->refcount += 1;
    }
}

#endif
