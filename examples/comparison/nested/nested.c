#include <stdio.h>
#include <stdint.h>

int main(void) {
    int64_t sum = 0;
    const int n = 4000;
    const int64_t mod = 1000000007LL;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            sum = (sum + (int64_t)i * j) % mod;
        }
    }
    printf("%lld\n", (long long)sum);
    return 0;
}
