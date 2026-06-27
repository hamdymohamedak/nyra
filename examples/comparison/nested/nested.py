mod = 1_000_000_007
n = 4000
total = 0
for i in range(n):
    for j in range(n):
        total = (total + i * j) % mod
print(total)
