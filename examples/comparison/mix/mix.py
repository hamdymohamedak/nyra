n = 270_000_000
mod = 1_000_000_007
acc = 0
for i in range(n):
    t = (i % 997) * 31
    acc = (acc + t + (acc % 4099)) % mod
print(acc)
