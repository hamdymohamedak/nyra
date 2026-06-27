// Raw OS syscalls and inline-asm syscall path for freestanding / advanced use.
#include <stdint.h>
#include <string.h>

#if defined(__linux__) || defined(__APPLE__)
#ifndef NYRA_FREESTANDING
#include <unistd.h>
#include <stdlib.h>
#include <sys/syscall.h>
#endif
#endif

#if defined(_WIN32)
#include <windows.h>
#endif

// --- Inline asm helpers (also callable from Nyra via extern fn) ---

void asm_nop(void) {
#if defined(__x86_64__) || defined(__i386__)
    __asm__ volatile("nop" ::: "memory");
#elif defined(__aarch64__)
    __asm__ volatile("nop" ::: "memory");
#else
    /* no-op on unsupported arch */
#endif
}

void asm_pause(void) {
#if defined(__x86_64__) || defined(__i386__)
    __asm__ volatile("pause" ::: "memory");
#elif defined(__aarch64__)
    __asm__ volatile("yield" ::: "memory");
#else
#endif
}

// --- Generic 6-argument syscall (Linux / macOS native) ---

int64_t os_syscall6(int64_t num, int64_t a0, int64_t a1, int64_t a2, int64_t a3,
                          int64_t a4, int64_t a5) {
#if defined(NYRA_FREESTANDING) && defined(__x86_64__) && defined(__linux__)
    int64_t ret;
    register int64_t r10 __asm__("r10") = a3;
    __asm__ volatile("syscall"
                     : "=a"(ret)
                     : "a"(num), "D"(a0), "S"(a1), "d"(a2), "r"(r10), "r"(a4), "r"(a5)
                     : "rcx", "r11", "memory");
    return ret;
#elif defined(NYRA_FREESTANDING) && defined(__aarch64__) && defined(__linux__)
    int64_t ret;
    register int64_t x8 __asm__("x8") = num;
    register int64_t x0 __asm__("x0") = a0;
    register int64_t x1 __asm__("x1") = a1;
    register int64_t x2 __asm__("x2") = a2;
    register int64_t x3 __asm__("x3") = a3;
    register int64_t x4 __asm__("x4") = a4;
    register int64_t x5 __asm__("x5") = a5;
    __asm__ volatile("svc #0"
                     : "+r"(x0)
                     : "r"(x8), "r"(x1), "r"(x2), "r"(x3), "r"(x4), "r"(x5)
                     : "memory");
    ret = x0;
    return ret;
#elif defined(__linux__) && !defined(NYRA_FREESTANDING)
    return (int64_t)syscall((long)num, (long)a0, (long)a1, (long)a2, (long)a3, (long)a4, (long)a5);
#elif defined(__APPLE__) && !defined(NYRA_FREESTANDING)
    (void)a4;
    (void)a5;
    return (int64_t)syscall((long)num, (long)a0, (long)a1, (long)a2, (long)a3);
#else
    (void)num;
    (void)a0;
    (void)a1;
    (void)a2;
    (void)a3;
    (void)a4;
    (void)a5;
    return -1;
#endif
}

// --- POSIX wrappers (libc or syscall fallback) ---

int32_t os_getpid(void) {
#if defined(_WIN32)
    return (int32_t)GetCurrentProcessId();
#elif defined(__linux__) && defined(__x86_64__)
    return (int32_t)os_syscall6(39, 0, 0, 0, 0, 0, 0);
#elif defined(__APPLE__)
    return (int32_t)getpid();
#else
    return -1;
#endif
}

void os_exit(int32_t code) {
#if defined(_WIN32)
    ExitProcess((UINT)code);
#elif defined(NYRA_FREESTANDING) && defined(__linux__) && defined(__x86_64__)
    os_syscall6(60, (int64_t)code, 0, 0, 0, 0, 0);
    __builtin_unreachable();
#elif !defined(NYRA_FREESTANDING)
    /* Use libc exit() so atexit handlers run (stdio flush, LLVM PGO profile write). */
    exit((int)code);
#else
    _exit((int)code);
#endif
}

int64_t os_read(int32_t fd, void *buf, int64_t count) {
#if defined(_WIN32)
    DWORD read_bytes = 0;
    if (!ReadFile((HANDLE)(intptr_t)fd, buf, (DWORD)count, &read_bytes, NULL)) {
        return -1;
    }
    return (int64_t)read_bytes;
#elif defined(__linux__) && defined(__x86_64__)
    return os_syscall6(0, (int64_t)fd, (int64_t)(uintptr_t)buf, count, 0, 0, 0);
#elif !defined(NYRA_FREESTANDING)
    return (int64_t)read(fd, buf, (size_t)count);
#else
    (void)fd;
    (void)buf;
    (void)count;
    return -1;
#endif
}

int64_t os_write(int32_t fd, const void *buf, int64_t count) {
#if defined(_WIN32)
    DWORD written = 0;
    if (!WriteFile((HANDLE)(intptr_t)fd, buf, (DWORD)count, &written, NULL)) {
        return -1;
    }
    return (int64_t)written;
#elif defined(__linux__) && defined(__x86_64__)
    return os_syscall6(1, (int64_t)fd, (int64_t)(uintptr_t)buf, count, 0, 0, 0);
#elif !defined(NYRA_FREESTANDING)
    return (int64_t)write(fd, buf, (size_t)count);
#else
    (void)fd;
    (void)buf;
    (void)count;
    return -1;
#endif
}

int32_t os_close_fd(int32_t fd) {
#if defined(_WIN32)
    return CloseHandle((HANDLE)(intptr_t)fd) ? 0 : -1;
#elif defined(__linux__) && defined(__x86_64__)
    return (int32_t)os_syscall6(3, (int64_t)fd, 0, 0, 0, 0, 0);
#elif !defined(NYRA_FREESTANDING)
    return close(fd);
#else
    (void)fd;
    return -1;
#endif
}
