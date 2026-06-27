#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>

typedef struct {
    CRITICAL_SECTION cs;
    CONDITION_VARIABLE cv;
    int *data;
    size_t len;
    size_t cap;
} NyraChannel;

void *channel_new(void) {
    NyraChannel *c = (NyraChannel *)calloc(1, sizeof(NyraChannel));
    if (!c) {
        return NULL;
    }
    InitializeCriticalSection(&c->cs);
    InitializeConditionVariable(&c->cv);
    c->cap = 64;
    c->data = (int *)malloc(c->cap * sizeof(int));
    if (!c->data) {
        DeleteCriticalSection(&c->cs);
        free(c);
        return NULL;
    }
    return c;
}

void channel_send(void *ch, int value) {
    NyraChannel *c = (NyraChannel *)ch;
    if (!c) {
        return;
    }
    EnterCriticalSection(&c->cs);
    if (c->len >= c->cap) {
        size_t nc = c->cap * 2;
        int *nd = (int *)realloc(c->data, nc * sizeof(int));
        if (nd) {
            c->data = nd;
            c->cap = nc;
        }
    }
    if (c->len < c->cap) {
        c->data[c->len++] = value;
        WakeConditionVariable(&c->cv);
    }
    LeaveCriticalSection(&c->cs);
}

int channel_recv(void *ch) {
    NyraChannel *c = (NyraChannel *)ch;
    if (!c) {
        return 0;
    }
    EnterCriticalSection(&c->cs);
    while (c->len == 0) {
        SleepConditionVariableCS(&c->cv, &c->cs, INFINITE);
    }
    int v = c->data[0];
    if (c->len > 1) {
        memmove(c->data, c->data + 1, (c->len - 1) * sizeof(int));
    }
    c->len--;
    LeaveCriticalSection(&c->cs);
    return v;
}

void channel_free(void *ch) {
    NyraChannel *c = (NyraChannel *)ch;
    if (!c) {
        return;
    }
    DeleteCriticalSection(&c->cs);
    free(c->data);
    free(c);
}

#else
#include <pthread.h>

typedef struct {
    pthread_mutex_t mu;
    pthread_cond_t not_empty;
    int *data;
    size_t len;
    size_t cap;
} NyraChannel;

void *channel_new(void) {
    NyraChannel *c = (NyraChannel *)calloc(1, sizeof(NyraChannel));
    if (!c) {
        return NULL;
    }
    pthread_mutex_init(&c->mu, NULL);
    pthread_cond_init(&c->not_empty, NULL);
    c->cap = 64;
    c->data = (int *)malloc(c->cap * sizeof(int));
    if (!c->data) {
        pthread_mutex_destroy(&c->mu);
        pthread_cond_destroy(&c->not_empty);
        free(c);
        return NULL;
    }
    return c;
}

void channel_send(void *ch, int value) {
    NyraChannel *c = (NyraChannel *)ch;
    if (!c) {
        return;
    }
    pthread_mutex_lock(&c->mu);
    if (c->len >= c->cap) {
        size_t nc = c->cap * 2;
        int *nd = (int *)realloc(c->data, nc * sizeof(int));
        if (nd) {
            c->data = nd;
            c->cap = nc;
        }
    }
    if (c->len < c->cap) {
        c->data[c->len++] = value;
        pthread_cond_signal(&c->not_empty);
    }
    pthread_mutex_unlock(&c->mu);
}

int channel_recv(void *ch) {
    NyraChannel *c = (NyraChannel *)ch;
    if (!c) {
        return 0;
    }
    pthread_mutex_lock(&c->mu);
    while (c->len == 0) {
        pthread_cond_wait(&c->not_empty, &c->mu);
    }
    int v = c->data[0];
    if (c->len > 1) {
        memmove(c->data, c->data + 1, (c->len - 1) * sizeof(int));
    }
    c->len--;
    pthread_mutex_unlock(&c->mu);
    return v;
}

void channel_free(void *ch) {
    NyraChannel *c = (NyraChannel *)ch;
    if (!c) {
        return;
    }
    pthread_mutex_destroy(&c->mu);
    pthread_cond_destroy(&c->not_empty);
    free(c->data);
    free(c);
}

#endif

/* --- String channels (Nyra 1.12.0) --- */

#if defined(_WIN32)
#include <windows.h>

typedef struct {
    CRITICAL_SECTION cs;
    CONDITION_VARIABLE cv;
    char **data;
    size_t len;
    size_t cap;
} NyraStrChannel;

void *channel_str_new(void) {
    NyraStrChannel *c = (NyraStrChannel *)calloc(1, sizeof(NyraStrChannel));
    if (!c) {
        return NULL;
    }
    InitializeCriticalSection(&c->cs);
    InitializeConditionVariable(&c->cv);
    c->cap = 16;
    c->data = (char **)calloc(c->cap, sizeof(char *));
    if (!c->data) {
        DeleteCriticalSection(&c->cs);
        free(c);
        return NULL;
    }
    return c;
}

void channel_str_send(void *ch, const char *value) {
    NyraStrChannel *c = (NyraStrChannel *)ch;
    if (!c || !value) {
        return;
    }
    EnterCriticalSection(&c->cs);
    if (c->len >= c->cap) {
        size_t nc = c->cap * 2;
        char **nd = (char **)realloc(c->data, nc * sizeof(char *));
        if (nd) {
            c->data = nd;
            c->cap = nc;
        }
    }
    if (c->len < c->cap) {
        c->data[c->len++] = _strdup(value);
        WakeConditionVariable(&c->cv);
    }
    LeaveCriticalSection(&c->cs);
}

char *channel_str_recv(void *ch) {
    NyraStrChannel *c = (NyraStrChannel *)ch;
    if (!c) {
        return NULL;
    }
    EnterCriticalSection(&c->cs);
    while (c->len == 0) {
        SleepConditionVariableCS(&c->cv, &c->cs, INFINITE);
    }
    char *v = c->data[0];
    if (c->len > 1) {
        memmove(c->data, c->data + 1, (c->len - 1) * sizeof(char *));
    }
    c->len--;
    LeaveCriticalSection(&c->cs);
    return v;
}

void channel_str_free(void *ch) {
    NyraStrChannel *c = (NyraStrChannel *)ch;
    if (!c) {
        return;
    }
    for (size_t i = 0; i < c->len; i++) {
        free(c->data[i]);
    }
    free(c->data);
    DeleteCriticalSection(&c->cs);
    free(c);
}

#else
#include <pthread.h>

typedef struct {
    pthread_mutex_t mu;
    pthread_cond_t not_empty;
    char **data;
    size_t len;
    size_t cap;
} NyraStrChannel;

void *channel_str_new(void) {
    NyraStrChannel *c = (NyraStrChannel *)calloc(1, sizeof(NyraStrChannel));
    if (!c) {
        return NULL;
    }
    pthread_mutex_init(&c->mu, NULL);
    pthread_cond_init(&c->not_empty, NULL);
    c->cap = 16;
    c->data = (char **)calloc(c->cap, sizeof(char *));
    if (!c->data) {
        pthread_mutex_destroy(&c->mu);
        pthread_cond_destroy(&c->not_empty);
        free(c);
        return NULL;
    }
    return c;
}

void channel_str_send(void *ch, const char *value) {
    NyraStrChannel *c = (NyraStrChannel *)ch;
    if (!c || !value) {
        return;
    }
    pthread_mutex_lock(&c->mu);
    if (c->len >= c->cap) {
        size_t nc = c->cap * 2;
        char **nd = (char **)realloc(c->data, nc * sizeof(char *));
        if (nd) {
            c->data = nd;
            c->cap = nc;
        }
    }
    if (c->len < c->cap) {
        c->data[c->len] = strdup(value);
        c->len++;
        pthread_cond_signal(&c->not_empty);
    }
    pthread_mutex_unlock(&c->mu);
}

char *channel_str_recv(void *ch) {
    NyraStrChannel *c = (NyraStrChannel *)ch;
    if (!c) {
        return NULL;
    }
    pthread_mutex_lock(&c->mu);
    while (c->len == 0) {
        pthread_cond_wait(&c->not_empty, &c->mu);
    }
    char *v = c->data[0];
    if (c->len > 1) {
        memmove(c->data, c->data + 1, (c->len - 1) * sizeof(char *));
    }
    c->len--;
    pthread_mutex_unlock(&c->mu);
    return v;
}

void channel_str_free(void *ch) {
    NyraStrChannel *c = (NyraStrChannel *)ch;
    if (!c) {
        return;
    }
    for (size_t i = 0; i < c->len; i++) {
        free(c->data[i]);
    }
    free(c->data);
    pthread_mutex_destroy(&c->mu);
    pthread_cond_destroy(&c->not_empty);
    free(c);
}

#endif
