#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void race_runtime_init(void);

#if defined(NYRA_RACE_NATIVE_BUILD)
__attribute__((constructor)) static void nyra_race_auto_init(void) {
    race_runtime_init();
}
#endif

#if defined(_WIN32)
#include <windows.h>
typedef DWORD nyra_tid_t;
static nyra_tid_t nyra_current_tid(void) {
    return GetCurrentThreadId();
}
static CRITICAL_SECTION g_race_mu;
static int g_race_mu_init = 0;
static void race_lock(void) {
    if (!g_race_mu_init) {
        InitializeCriticalSection(&g_race_mu);
        g_race_mu_init = 1;
    }
    EnterCriticalSection(&g_race_mu);
}
static void race_unlock(void) {
    LeaveCriticalSection(&g_race_mu);
}
#else
#include <pthread.h>
typedef pthread_t nyra_tid_t;
static nyra_tid_t nyra_current_tid(void) {
    return pthread_self();
}
static pthread_mutex_t g_race_mu = PTHREAD_MUTEX_INITIALIZER;
static void race_lock(void) {
    pthread_mutex_lock(&g_race_mu);
}
static void race_unlock(void) {
    pthread_mutex_unlock(&g_race_mu);
}
#endif

#define NYRA_RACE_SLOTS 4096

typedef struct {
    void *addr;
    nyra_tid_t reader;
    nyra_tid_t writer;
    int reader_active;
    int writer_active;
} NyraRaceSlot;

static NyraRaceSlot g_slots[NYRA_RACE_SLOTS];
static int g_enabled = 0;

static int race_enabled(void) {
    if (g_enabled) {
        return 1;
    }
    const char *env = getenv("NYRA_RACE_NATIVE");
    if (env && env[0] != '\0' && strcmp(env, "0") != 0) {
        g_enabled = 1;
    }
    return g_enabled;
}

static NyraRaceSlot *slot_for(void *addr) {
    uintptr_t h = (uintptr_t)addr;
    h ^= h >> 16;
    h *= 0x7feb352dU;
    h ^= h >> 15;
    for (int probe = 0; probe < 64; probe++) {
        size_t idx = (size_t)((h + (uintptr_t)probe) % NYRA_RACE_SLOTS);
        NyraRaceSlot *s = &g_slots[idx];
        if (s->addr == NULL || s->addr == addr) {
            if (s->addr == NULL) {
                s->addr = addr;
            }
            return s;
        }
    }
    return NULL;
}

static void race_violation(const char *kind, void *addr) {
    fprintf(stderr, "nyra race: %s data race at %p\n", kind, addr);
    abort();
}

void race_runtime_init(void) {
    g_enabled = 1;
}

void race_track_read(void *addr, int64_t nbytes) {
    (void)nbytes;
    if (!race_enabled() || !addr) {
        return;
    }
    nyra_tid_t tid = nyra_current_tid();
    race_lock();
    NyraRaceSlot *s = slot_for(addr);
    if (!s) {
        race_unlock();
        return;
    }
    if (s->writer_active && s->writer != tid) {
        race_unlock();
        race_violation("write/read", addr);
    }
    if (s->reader_active && s->reader != tid && s->reader != (nyra_tid_t)0) {
        /* concurrent readers are allowed */
    }
    s->reader = tid;
    s->reader_active = 1;
    race_unlock();
}

void race_track_write(void *addr, int64_t nbytes) {
    (void)nbytes;
    if (!race_enabled() || !addr) {
        return;
    }
    nyra_tid_t tid = nyra_current_tid();
    race_lock();
    NyraRaceSlot *s = slot_for(addr);
    if (!s) {
        race_unlock();
        return;
    }
    if ((s->reader_active && s->reader != tid) ||
        (s->writer_active && s->writer != tid)) {
        race_unlock();
        race_violation("read/write", addr);
    }
    s->writer = tid;
    s->writer_active = 1;
    s->reader_active = 0;
    race_unlock();
}

void race_clear_access(void *addr) {
    if (!addr) {
        return;
    }
    race_lock();
    NyraRaceSlot *s = slot_for(addr);
    if (s && s->addr == addr) {
        s->reader_active = 0;
        s->writer_active = 0;
    }
    race_unlock();
}

int race_runtime_enabled(void) {
    return race_enabled();
}
