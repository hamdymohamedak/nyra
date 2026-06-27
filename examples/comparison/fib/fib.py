steps = 375_000_000
mod = 1_000_000_007
a, b = 0, 1
for _ in range(steps):
    a, b = b, (a + b) % mod
print(b)
