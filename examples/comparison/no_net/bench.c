#include <stdint.h>

int main(void) {
    int32_t h = 0;
    const int32_t n = 4000000;
    for (int32_t i = 0; i < n; i++) {
        h = (h + i * 31 + 17) % 999983;
    }
    static volatile int32_t sink;
    sink = h;
    return 0;
}
