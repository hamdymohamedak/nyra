const N = 375_000_000;
const MOD = 1_000_000_007;
let sum = 0;
for (let i = 0; i < N; i++) {
  sum = (sum + i) % MOD;
}
console.log(sum);
