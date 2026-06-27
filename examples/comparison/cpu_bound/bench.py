n = 180_000_000
acc = 0
for i in range(n):
    term = (i % 997) * 31
    acc = (acc + term) % 997
print(acc)
