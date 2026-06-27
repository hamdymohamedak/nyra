#include <cstdint>

int main() {
    int32_t x = 1, y = 2, acc = 0;
    const int32_t n = 5000000;
    for (int32_t i = 0; i < n; i++) {
        acc += x + y;
        x++;
        y++;
    }
    asm volatile("" : : "r"(acc) : "memory");
    return 0;
}
