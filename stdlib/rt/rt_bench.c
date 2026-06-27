#include "rt_common.h"
#include <stdint.h>

int32_t blackbox_i32(int32_t x) {
    volatile int32_t keep = x;
    return keep;
}

#if defined(_WIN32)
#include <windows.h>
#include <psapi.h>
#else
#include <sys/resource.h>
#include <sys/time.h>
#endif

typedef struct {
    NyraTimeStamp wall_start;
    size_t rss_start;
#if defined(_WIN32)
    uint64_t cpu_start_ticks;
#else
    struct rusage ru_start;
#endif
    int active;
} NyraBenchState;

static NyraBenchState g_bench;

#if defined(_WIN32)
static uint64_t nyra_filetime_ticks(FILETIME ft) {
    ULARGE_INTEGER u;
    u.LowPart = ft.dwLowDateTime;
    u.HighPart = ft.dwHighDateTime;
    return u.QuadPart;
}

static uint64_t nyra_process_cpu_ticks(void) {
    FILETIME create, exit, kernel, user;
    if (!GetProcessTimes(GetCurrentProcess(), &create, &exit, &kernel, &user)) {
        return 0;
    }
    return nyra_filetime_ticks(kernel) + nyra_filetime_ticks(user);
}
#endif

void benchmark_begin(void) {
    g_bench.wall_start = nyra_now();
    g_bench.rss_start = nyra_current_rss_bytes();
#if defined(_WIN32)
    g_bench.cpu_start_ticks = nyra_process_cpu_ticks();
#else
    getrusage(RUSAGE_SELF, &g_bench.ru_start);
#endif
    g_bench.active = 1;
}

static void print_time_line(double elapsed_s) {
    double value;
    const char *unit;
    if (elapsed_s >= 1.0) {
        value = elapsed_s;
        unit = "s";
    } else {
        value = elapsed_s * 1e3;
        unit = "ms";
    }
    printf("Time: %.1f %s\n", value, unit);
}

static void print_memory_line(long long delta_bytes) {
    long long abs_bytes = delta_bytes < 0 ? -delta_bytes : delta_bytes;
    double value;
    const char *unit;
    if (abs_bytes < 1024LL) {
        value = (double)abs_bytes;
        unit = "B";
    } else if (abs_bytes < 1024LL * 1024LL) {
        value = (double)abs_bytes / 1024.0;
        unit = "KB";
    } else if (abs_bytes < 1024LL * 1024LL * 1024LL) {
        value = (double)abs_bytes / (1024.0 * 1024.0);
        unit = "MB";
    } else {
        value = (double)abs_bytes / (1024.0 * 1024.0 * 1024.0);
        unit = "GB";
    }
    printf("Memory: %.1f %s\n", value, unit);
}

static void print_cpu_line(double cpu_pct) {
    if (cpu_pct < 0.0) {
        cpu_pct = 0.0;
    }
    if (cpu_pct > 100.0) {
        cpu_pct = 100.0;
    }
    printf("CPU: %.0f%%\n", cpu_pct);
}

void benchmark_end(void) {
    if (!g_bench.active) {
        return;
    }
    g_bench.active = 0;

    double elapsed_s = nyra_elapsed_seconds(g_bench.wall_start, nyra_now());
    if (elapsed_s <= 0.0) {
        elapsed_s = 1e-9;
    }

    size_t rss_end = nyra_current_rss_bytes();
    long long mem_delta = (long long)rss_end - (long long)g_bench.rss_start;

    double cpu_pct = 0.0;
#if defined(_WIN32)
    uint64_t cpu_end = nyra_process_cpu_ticks();
    double cpu_s = (double)(cpu_end - g_bench.cpu_start_ticks) / 1e7;
    cpu_pct = (cpu_s / elapsed_s) * 100.0;
#else
    struct rusage ru_end;
    getrusage(RUSAGE_SELF, &ru_end);
    double user_s =
        (double)(ru_end.ru_utime.tv_sec - g_bench.ru_start.ru_utime.tv_sec) +
        (double)(ru_end.ru_utime.tv_usec - g_bench.ru_start.ru_utime.tv_usec) / 1e6;
    double sys_s =
        (double)(ru_end.ru_stime.tv_sec - g_bench.ru_start.ru_stime.tv_sec) +
        (double)(ru_end.ru_stime.tv_usec - g_bench.ru_start.ru_stime.tv_usec) / 1e6;
    cpu_pct = ((user_s + sys_s) / elapsed_s) * 100.0;
#endif

    print_time_line(elapsed_s);
    print_memory_line(mem_delta);
    print_cpu_line(cpu_pct);
    fflush(stdout);
}
