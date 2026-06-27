#include <stdio.h>
#include <stdint.h>

int main(void) {
    int64_t sum = 0;
    const int64_t n = 375000000LL;
    const int64_t mod = 1000000007LL;
    for (int64_t i = 0; i < n; i++) {
        sum = (sum + i) % mod;
    }
    printf("%lld\n", (long long)sum);
    return 0;
}
