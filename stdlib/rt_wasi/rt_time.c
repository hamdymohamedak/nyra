#include <stdio.h>

void time_start(const char *label) {
    (void)label;
}

void time_end(const char *label) {
    if (label) {
        printf("%s: 0.000000ms (timing unavailable on WASI)\n", label);
    }
}
