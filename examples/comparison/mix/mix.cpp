#include <cstdint>
#include <iostream>

int main() {
    std::int64_t acc = 0;
    const std::int64_t n = 270000000LL;
    const std::int64_t mod = 1000000007LL;
    for (std::int64_t i = 0; i < n; ++i) {
        std::int64_t t = (i % 997) * 31;
        acc = (acc + t + (acc % 4099)) % mod;
    }
    std::cout << acc << '\n';
    return 0;
}
