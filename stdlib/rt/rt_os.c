// Portable OS API helpers: platform detection, environment, battery, file paths.
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(__APPLE__)
#include <TargetConditionals.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/ps/IOPowerSources.h>
#elif defined(__linux__) || defined(__APPLE__)
#include <unistd.h>
#elif defined(_WIN32)
#include <windows.h>
#endif

static char *dup_cstr(const char *s);

// 1 = linux, 2 = macos/darwin, 3 = windows, 0 = unknown
int32_t os_platform_id(void) {
#if defined(__linux__)
    return 1;
#elif defined(__APPLE__)
    return 2;
#elif defined(_WIN32)
    return 3;
#else
    return 0;
#endif
}

char *os_platform_name(void) {
    switch (os_platform_id()) {
    case 1:
        return dup_cstr("linux");
    case 2:
        return dup_cstr("darwin");
    case 3:
        return dup_cstr("windows");
    default:
        return dup_cstr("unknown");
    }
}

// Returns heap-owned string (Nyra auto-drop). NULL -> empty string.
static char *dup_cstr(const char *s) {
    if (!s) {
        char *e = (char *)malloc(1);
        if (e) {
            e[0] = '\0';
        }
        return e;
    }
    size_t n = strlen(s);
    char *out = (char *)malloc(n + 1);
    if (!out) {
        return NULL;
    }
    memcpy(out, s, n + 1);
    return out;
}

char *rt_os_getenv(const char *name) {
#if defined(_WIN32)
    char buf[32768];
    DWORD n = GetEnvironmentVariableA(name, buf, (DWORD)sizeof(buf));
    if (n == 0 || n >= sizeof(buf)) {
        return dup_cstr("");
    }
    return dup_cstr(buf);
#else
    const char *v = getenv(name);
    return dup_cstr(v ? v : "");
#endif
}

// 0 on success, -1 on failure.
int32_t rt_os_setenv(const char *name, const char *value) {
    if (!name || !*name || !value) {
        return -1;
    }
#if defined(_WIN32)
    return SetEnvironmentVariableA(name, value) != 0 ? 0 : -1;
#else
    return setenv(name, value, 1) == 0 ? 0 : -1;
#endif
}

// Battery percent 0-100, or -1 if unavailable.
int32_t os_battery_percent(void) {
#if defined(__APPLE__)
    CFDictionaryRef blob = IOPSCopyPowerSourcesInfo();
    if (!blob) {
        return -1;
    }
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    if (!sources) {
        CFRelease(blob);
        return -1;
    }
    int32_t best = -1;
    CFIndex count = CFArrayGetCount(sources);
    for (CFIndex i = 0; i < count; i++) {
        CFDictionaryRef ps =
            IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
        if (!ps) {
            continue;
        }
        CFNumberRef cap =
            (CFNumberRef)CFDictionaryGetValue(ps, CFSTR("Current Capacity"));
        if (!cap) {
            continue;
        }
        int val = 0;
        if (!CFNumberGetValue(cap, kCFNumberIntType, &val)) {
            continue;
        }
        if (val > best) {
            best = (int32_t)val;
        }
    }
    CFRelease(sources);
    CFRelease(blob);
    return best;
#elif defined(__linux__)
    static const char *paths[] = {
        "/sys/class/power_supply/BAT0/capacity",
        "/sys/class/power_supply/BAT1/capacity",
        "/sys/class/power_supply/battery/capacity",
    };
    for (size_t i = 0; i < sizeof(paths) / sizeof(paths[0]); i++) {
        FILE *f = fopen(paths[i], "r");
        if (!f) {
            continue;
        }
        int val = -1;
        if (fscanf(f, "%d", &val) == 1 && val >= 0 && val <= 100) {
            fclose(f);
            return (int32_t)val;
        }
        fclose(f);
    }
    return -1;
#elif defined(_WIN32)
    SYSTEM_POWER_STATUS st;
    if (!GetSystemPowerStatus(&st)) {
        return -1;
    }
    if (st.BatteryLifePercent == 255) {
        return -1;
    }
    return (int32_t)st.BatteryLifePercent;
#else
    return -1;
#endif
}

int32_t os_page_size(void) {
#if defined(_WIN32)
    SYSTEM_INFO si;
    GetSystemInfo(&si);
    return (int32_t)si.dwPageSize;
#else
    long p = sysconf(_SC_PAGESIZE);
    return p > 0 ? (int32_t)p : 4096;
#endif
}
