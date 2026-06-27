#include <cstdint>
#include <iostream>

int main() {
    std::int64_t sum = 0;
    const int n = 4000;
    const std::int64_t mod = 1000000007LL;
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            sum = (sum + static_cast<std::int64_t>(i) * j) % mod;
        }
    }
    std::cout << sum << '\n';
    return 0;
}
