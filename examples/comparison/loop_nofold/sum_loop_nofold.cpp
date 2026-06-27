#include <cstdint>
#include <iostream>

int main() {
    std::int64_t sum = 0;
    const std::int64_t n = 375000000LL;
    const std::int64_t mod = 1000000007LL;
    for (std::int64_t i = 0; i < n; ++i) {
        sum = (sum + i) % mod;
    }
    std::cout << sum << '\n';
    asm volatile("" : : "r"(sum) : "memory");
    return 0;
}
