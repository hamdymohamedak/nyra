#include <cstdint>
#include <iostream>

int main() {
    std::int64_t acc = 0;
    const std::int64_t n = 180000000LL;
    for (std::int64_t i = 0; i < n; ++i) {
        std::int64_t term = (i % 997) * 31;
        acc = (acc + term) % 997;
    }
    std::cout << acc << '\n';
    asm volatile("" : : "r"(acc) : "memory");
    return 0;
}
