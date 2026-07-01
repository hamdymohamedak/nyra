// Linux io_uring probe — optional fast path; falls back to epoll/kqueue elsewhere.
#include <stdint.h>

#if defined(__linux__)
#include <errno.h>
#include <linux/io_uring.h>
#include <string.h>
#include <sys/syscall.h>
#include <unistd.h>

#ifndef __NR_io_uring_setup
#if defined(__x86_64__)
#define __NR_io_uring_setup 425
#define __NR_io_uring_enter 426
#elif defined(__aarch64__)
#define __NR_io_uring_setup 425
#define __NR_io_uring_enter 426
#endif
#endif

static int g_uring_available = -1;

static int probe_io_uring(void) {
    if (g_uring_available >= 0) {
        return g_uring_available;
    }
#if defined(__NR_io_uring_setup)
    struct io_uring_params params;
    memset(&params, 0, sizeof(params));
    int fd = (int)syscall(__NR_io_uring_setup, 1, &params);
    if (fd >= 0) {
        close(fd);
        g_uring_available = 1;
    } else {
        g_uring_available = 0;
    }
#else
    g_uring_available = 0;
#endif
    return g_uring_available;
}
#endif

int32_t io_uring_available(void) {
#if defined(__linux__)
    return probe_io_uring();
#else
    return 0;
#endif
}

int32_t io_uring_register_read(int32_t fd, int32_t promise) {
#if defined(__linux__)
    if (!probe_io_uring()) {
        extern int io_register(int fd, int task_id);
        return io_register(fd, promise);
    }
    extern int io_register(int fd, int task_id);
    return io_register(fd, promise);
#else
    (void)fd;
    (void)promise;
    return -1;
#endif
}
