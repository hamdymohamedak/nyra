#include <cstdio>
#include <cstdint>

int main() {
    int64_t sum = 0;
    const int64_t n = 200;
    for (int64_t i = 0; i < n; i++) {
        for (int64_t j = 0; j < n; j++) {
            sum += i * j;
        }
    }
    std::printf("%lld\n", static_cast<long long>(sum));
    return 0;
}
