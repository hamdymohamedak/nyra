const n = 80_000_000;
const p = { x: 1, y: 2 };
let sum = 0;
for (let i = 0; i < n; i++) {
  sum += p.x + p.y;
}
console.log(sum);
