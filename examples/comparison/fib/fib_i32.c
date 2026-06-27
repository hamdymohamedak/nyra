#include <stdio.h>
#include <stdint.h>

int main(void) {
    const int32_t steps = 375000000;
    const int32_t mod = 1000000007;
    int32_t a = 0;
    int32_t b = 1;
    for (int32_t i = 0; i < steps; i++) {
        int32_t t = (a + b) % mod;
        a = b;
        b = t;
    }
    printf("%d\n", b);
    return 0;
}
