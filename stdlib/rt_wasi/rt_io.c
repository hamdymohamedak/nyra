#include "rt_common.h"

#include <stdio.h>
#include <string.h>

void stdout_write_str(const char *s) {
    if (!s) {
        return;
    }
    nyra_wasi_append(s, strlen(s));
}

void stdout_writeln_str(const char *s) {
    stdout_write_str(s);
    nyra_wasi_append("\n", 1);
}

void stdout_write_i32(int n) {
    char buf[32];
    snprintf(buf, sizeof(buf), "%d", n);
    stdout_write_str(buf);
}

void stdout_writeln_i32(int n) {
    stdout_write_i32(n);
    nyra_wasi_append("\n", 1);
}

void stdout_flush(void) {
    nyra_wasi_flush_and_reset();
}

int println(const char *msg) {
    stdout_writeln_str(msg);
    return 0;
}

char *stdin_read_line(const char *prompt) {
    if (prompt && prompt[0] != '\0') {
        stdout_write_str(prompt);
        stdout_flush();
    }
    char line[4096];
    if (!fgets(line, (int)sizeof(line), stdin)) {
        char *empty = (char *)malloc(1);
        if (empty) {
            empty[0] = '\0';
        }
        return empty;
    }
    size_t len = strlen(line);
    while (len > 0 && (line[len - 1] == '\n' || line[len - 1] == '\r')) {
        len--;
    }
    char *out = (char *)malloc(len + 1);
    if (!out) {
        return NULL;
    }
    memcpy(out, line, len);
    out[len] = '\0';
    return out;
}
