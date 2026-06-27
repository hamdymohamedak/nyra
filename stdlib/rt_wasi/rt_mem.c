#include <stdio.h>

void mem_start(const char *label) {
    (void)label;
}

void mem_end(const char *label) {
    if (label) {
        printf("%s: RSS +0.000 B (memory stats unavailable on WASI)\n", label);
    }
}
