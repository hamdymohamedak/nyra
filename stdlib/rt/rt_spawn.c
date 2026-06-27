#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
#include <windows.h>
#else
#include <pthread.h>
#endif

typedef void (*NyraSpawnBody)(void *);

typedef struct {
    NyraSpawnBody body;
    void *data;
} NyraSpawnJob;

#if defined(_WIN32)
static DWORD WINAPI nyra_spawn_thread(LPVOID arg) {
    NyraSpawnJob *job = (NyraSpawnJob *)arg;
    if (job && job->body) {
        job->body(job->data);
    }
    if (job) {
        free(job->data);
        free(job);
    }
    return 0;
}
#else
static void *nyra_spawn_thread(void *arg) {
    NyraSpawnJob *job = (NyraSpawnJob *)arg;
    if (job && job->body) {
        job->body(job->data);
    }
    if (job) {
        free(job->data);
        free(job);
    }
    return NULL;
}
#endif

int spawn_capture(void (*body)(void *), void *data, int64_t nbytes) {
    if (!body) {
        return -1;
    }
    NyraSpawnJob *job = (NyraSpawnJob *)calloc(1, sizeof(NyraSpawnJob));
    if (!job) {
        return -1;
    }
    job->body = body;
    if (data && nbytes > 0) {
        job->data = malloc((size_t)nbytes);
        if (!job->data) {
            free(job);
            return -1;
        }
        memcpy(job->data, data, (size_t)nbytes);
    } else {
        job->data = NULL;
    }
#if defined(_WIN32)
    HANDLE th = CreateThread(NULL, 0, nyra_spawn_thread, job, 0, NULL);
    if (!th) {
        free(job->data);
        free(job);
        return -1;
    }
    CloseHandle(th);
#else
    pthread_t thread;
    if (pthread_create(&thread, NULL, nyra_spawn_thread, job) != 0) {
        free(job->data);
        free(job);
        return -1;
    }
    pthread_detach(thread);
#endif
    return 1;
}
