const N = 180_000_000;
let acc = 0;
for (let i = 0; i < N; i++) {
  const term = (i % 997) * 31;
  acc = (acc + term) % 997;
}
console.log(acc);
