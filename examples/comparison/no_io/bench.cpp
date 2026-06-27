#include <cstdint>

int main() {
    int32_t acc = 0;
    const int32_t n = 5000000;
    for (int32_t i = 0; i < n; i++) {
        acc = (acc + i) % 999983;
    }
    asm volatile("" : : "r"(acc) : "memory");
    return 0;
}
