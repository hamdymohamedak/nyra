n = 375_000_000
mod = 1_000_000_007
total = 0
for i in range(n):
    total = (total + i) % mod
print(total)
