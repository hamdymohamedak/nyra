#pragma once

namespace demo {

inline int add(int a, int b) { return a + b; }

class Counter {
public:
  explicit Counter(int start) : value_(start) {}
  int get() const { return value_; }
  void add(int n) { value_ += n; }

private:
  int value_;
};

} // namespace demo
