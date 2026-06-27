const N = 270_000_000;
const MOD = 1_000_000_007;
let acc = 0;
for (let i = 0; i < N; i++) {
  const t = (i % 997) * 31;
  acc = (acc + t + (acc % 4099)) % MOD;
}
console.log(acc);
