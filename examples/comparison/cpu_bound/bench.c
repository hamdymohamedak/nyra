#include <stdint.h>
#include <stdio.h>

int main(void) {
    int64_t acc = 0;
    const int64_t n = 180000000LL;
    for (int64_t i = 0; i < n; i++) {
        int64_t term = (i % 997) * 31;
        acc = (acc + term) % 997;
    }
    static volatile int64_t sink;
    sink = acc;
    printf("%lld\n", (long long)acc);
    return 0;
}
