#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <pthread.h>
#endif

extern int rt_tcp_write(int fd, const char *data);

typedef struct {
#if defined(_WIN32)
    CRITICAL_SECTION mu;
#else
    pthread_mutex_t mu;
#endif
    int *fds;
    int count;
    int cap;
} NyraTcpHub;

void *rt_tcp_hub_new(int32_t max_clients) {
    if (max_clients <= 0) {
        max_clients = 16;
    }
    if (max_clients > 64) {
        max_clients = 64;
    }
    NyraTcpHub *hub = (NyraTcpHub *)calloc(1, sizeof(NyraTcpHub));
    if (!hub) {
        return NULL;
    }
#if defined(_WIN32)
    InitializeCriticalSection(&hub->mu);
#else
    pthread_mutex_init(&hub->mu, NULL);
#endif
    hub->cap = max_clients;
    hub->fds = (int *)calloc((size_t)max_clients, sizeof(int));
    if (!hub->fds) {
#if defined(_WIN32)
        DeleteCriticalSection(&hub->mu);
#else
        pthread_mutex_destroy(&hub->mu);
#endif
        free(hub);
        return NULL;
    }
    return hub;
}

int32_t rt_tcp_hub_add(void *handle, int32_t fd) {
    NyraTcpHub *hub = (NyraTcpHub *)handle;
    if (!hub || fd < 0) {
        return -1;
    }
#if defined(_WIN32)
    EnterCriticalSection(&hub->mu);
#else
    pthread_mutex_lock(&hub->mu);
#endif
    if (hub->count >= hub->cap) {
#if defined(_WIN32)
        LeaveCriticalSection(&hub->mu);
#else
        pthread_mutex_unlock(&hub->mu);
#endif
        return -1;
    }
    hub->fds[hub->count++] = fd;
#if defined(_WIN32)
    LeaveCriticalSection(&hub->mu);
#else
    pthread_mutex_unlock(&hub->mu);
#endif
    return 0;
}

void rt_tcp_hub_remove(void *handle, int32_t fd) {
    NyraTcpHub *hub = (NyraTcpHub *)handle;
    if (!hub || fd < 0) {
        return;
    }
#if defined(_WIN32)
    EnterCriticalSection(&hub->mu);
#else
    pthread_mutex_lock(&hub->mu);
#endif
    for (int i = 0; i < hub->count; i++) {
        if (hub->fds[i] == fd) {
            hub->fds[i] = hub->fds[hub->count - 1];
            hub->count--;
            break;
        }
    }
#if defined(_WIN32)
    LeaveCriticalSection(&hub->mu);
#else
    pthread_mutex_unlock(&hub->mu);
#endif
}

void rt_tcp_hub_broadcast(void *handle, const char *msg) {
    NyraTcpHub *hub = (NyraTcpHub *)handle;
    if (!hub || !msg) {
        return;
    }
#if defined(_WIN32)
    EnterCriticalSection(&hub->mu);
#else
    pthread_mutex_lock(&hub->mu);
#endif
    for (int i = 0; i < hub->count; i++) {
        rt_tcp_write(hub->fds[i], msg);
    }
#if defined(_WIN32)
    LeaveCriticalSection(&hub->mu);
#else
    pthread_mutex_unlock(&hub->mu);
#endif
}

void rt_tcp_hub_free(void *handle) {
    NyraTcpHub *hub = (NyraTcpHub *)handle;
    if (!hub) {
        return;
    }
    free(hub->fds);
#if defined(_WIN32)
    DeleteCriticalSection(&hub->mu);
#else
    pthread_mutex_destroy(&hub->mu);
#endif
    free(hub);
}
