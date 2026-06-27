#include <stdint.h>
#include <stdio.h>

int main(void) {
    int64_t sum = 0;
    const int64_t n = 375000000LL;
    const int64_t mod = 1000000007LL;
    for (int64_t i = 0; i < n; i++) {
        sum = (sum + i) % mod;
    }
    static volatile int64_t sink;
    sink = sum;
    printf("%lld\n", (long long)sum);
    return 0;
}
