#include <stdio.h>
#include <stdint.h>

int main(void) {
    int64_t sum = 0;
    const int64_t n = 125000;
    for (int64_t i = 0; i < n; i++) {
        sum += i;
    }
    printf("%lld\n", (long long)sum);
    return 0;
}
