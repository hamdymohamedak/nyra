const n = 4000;
const MOD = 1_000_000_007;
let sum = 0;
for (let i = 0; i < n; i++) {
  for (let j = 0; j < n; j++) {
    sum = (sum + i * j) % MOD;
  }
}
console.log(sum);
