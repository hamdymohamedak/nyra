#include <stdint.h>

void stdout_write_str(const char *s);
void stdout_write_i32(int32_t n);
void stdout_flush(void);

static void write_repeat(char c, int32_t n) {
    char buf[2] = {c, '\0'};
    for (int32_t i = 0; i < n; i++) {
        stdout_write_str(buf);
    }
}

void progress_update(int32_t current, int32_t total, const char *label) {
    if (!label) {
        label = "Running";
    }
    if (total <= 0) {
        total = 1;
    }
    if (current < 0) {
        current = 0;
    }
    if (current > total) {
        current = total;
    }

    int32_t pct = (current * 100) / total;
    const int32_t bar_width = 13;
    int32_t filled = (pct * bar_width + 99) / 100;
    if (filled > bar_width) {
        filled = bar_width;
    }

    stdout_write_str("\r[");
    write_repeat('#', filled);
    write_repeat('-', bar_width - filled);
    stdout_write_str("] ");
    stdout_write_i32(pct);
    stdout_write_str("%\n");
    stdout_write_str(label);
    stdout_write_str("\n");
    stdout_flush();
}

void progress_finish(void) {
    stdout_write_str("\n");
    stdout_flush();
}
