#include <stdio.h>
#include <stdint.h>

typedef struct {
    int x;
    int y;
} Point;

int main(void) {
    int64_t sum = 0;
    const int n = 80000000;
    Point p = {1, 2};
    for (int i = 0; i < n; i++) {
        sum += p.x + p.y;
    }
    printf("%lld\n", (long long)sum);
    return 0;
}
