
#include <stdio.h>
#include <stdint.h>
int main(void) {
    const int64_t n = 500000;
    const int64_t mod = 1000000007;
    int64_t acc = 0;
    for (int64_t i = 0; i < n; i++) {
        int64_t x = i % 997;
        int64_t y = (i * 3) % 991;
        acc = (acc + i) % mod;
    }
    printf("%lld\n", (long long)acc);
    return 0;
}
