#include <cstdint>
#include <iostream>

int main() {
    const std::int64_t steps = 375000000LL;
    const std::int64_t mod = 1000000007LL;
    std::int64_t a = 0;
    std::int64_t b = 1;
    for (std::int64_t i = 0; i < steps; ++i) {
        std::int64_t t = (a + b) % mod;
        a = b;
        b = t;
    }
    std::cout << b << '\n';
    return 0;
}
