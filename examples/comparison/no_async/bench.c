#include <stdio.h>
#include <stdint.h>

int main(void) {
    const int32_t n = 40;
    int32_t a = 0, b = 1;
    for (int32_t i = 0; i < n; i++) {
        int32_t t = a + b;
        a = b;
        b = t;
    }
    printf("%d\n", b);
    return 0;
}
