#include <stdio.h>
#include <stdint.h>

int main(void) {
    const int64_t steps = 375000000LL;
    const int64_t mod = 1000000007LL;
    int64_t a = 0;
    int64_t b = 1;
    for (int64_t i = 0; i < steps; i++) {
        int64_t t = (a + b) % mod;
        a = b;
        b = t;
    }
    printf("%lld\n", (long long)b);
    return 0;
}
