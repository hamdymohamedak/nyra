#include <cstdio>
#include <cstdint>

int main() {
    int64_t sum = 0;
    const int64_t n = 125000;
    for (int64_t i = 0; i < n; i++) {
        sum += i;
    }
    std::printf("%lld\n", static_cast<long long>(sum));
    return 0;
}
