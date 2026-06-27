#!/usr/bin/env node
/** JSON line worker for Nyra bridge (Node.js). */
import { createInterface } from 'node:readline';

function handle(req) {
  const op = req.op;
  if (op === 'eval') {
    const expr = String(req.expr ?? '0');
    if (!/^[0-9+\-*/().\s]+$/.test(expr)) {
      return '0';
    }
    // eslint-disable-next-line no-eval
    return String(eval(expr));
  }
  if (op === 'add') {
    return String(Number(req.a ?? 0) + Number(req.b ?? 0));
  }
  if (op === 'npm_hint') {
    return 'use npm packages inside this worker — see docs/bridge.md';
  }
  return 'error';
}

const rl = createInterface({ input: process.stdin, crlfDelay: Infinity });
rl.once('line', (line) => {
  try {
    const req = JSON.parse(line.trim());
    const result = handle(req);
    console.log(JSON.stringify({ ok: true, result }));
  } catch (err) {
    console.log(JSON.stringify({ ok: false, error: String(err) }));
  }
  rl.close();
});
