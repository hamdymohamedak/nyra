#include <cstdint>
#include <iostream>

struct Point {
    int x;
    int y;
};

int main() {
    std::int64_t sum = 0;
    const int n = 80000000;
    Point p{1, 2};
    for (int i = 0; i < n; ++i) {
        sum += p.x + p.y;
    }
    std::cout << sum << '\n';
    return 0;
}
