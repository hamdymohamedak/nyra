#include <stdio.h>
#include <stdint.h>

int main(void) {
    int64_t acc = 0;
    const int64_t n = 270000000LL;
    const int64_t mod = 1000000007LL;
    for (int64_t i = 0; i < n; i++) {
        int64_t t = (i % 997) * 31;
        acc = (acc + t + (acc % 4099)) % mod;
    }
    printf("%lld\n", (long long)acc);
    return 0;
}
