const STEPS = 375_000_000;
const MOD = 1_000_000_007;
let a = 0;
let b = 1;
for (let i = 0; i < STEPS; i++) {
  const t = (a + b) % MOD;
  a = b;
  b = t;
}
console.log(b);
