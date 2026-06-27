#!/usr/bin/env node
/**
 * Load Nyra cdylib via koffi (npm install in this directory).
 * Build: nyra build ../main.ny -o libnyra_greet --cdylib
 */
import { spawnSync } from 'node:child_process';
import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import koffi from 'koffi';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..', '..', '..', '..');
const libNames = [
  join(root, 'target', 'debug', 'libnyra_greet.dylib'),
  join(root, 'target', 'debug', 'libnyra_greet.so'),
  join(root, 'target', 'debug', 'libnyra_greet.dll'),
];
let libPath = libNames.find((p) => existsSync(p));

if (!libPath) {
  spawnSync(
    'cargo',
    ['run', '-q', '-p', 'cli', '--', 'build', join(here, '..', 'main.ny'), '-o', 'libnyra_greet', '--cdylib'],
    { cwd: root, stdio: 'inherit' },
  );
  libPath = libNames.find((p) => existsSync(p));
}
if (!libPath) {
  console.error('libnyra_greet not found after build');
  process.exit(1);
}

const lib = koffi.load(libPath);
const add = lib.func('add', 'int', ['int', 'int']);
const greet = lib.func('greet', 'void *', ['str']);
const free = lib.func('free', 'void', ['void *']);

if (add(10, 32) !== 42) {
  throw new Error('add failed');
}
const raw = greet('World');
const msg = koffi.decode(raw, 'char', -1);
free(raw);
if (msg !== 'Hello, World') {
  throw new Error(`greet got ${msg}`);
}
console.log('export_greet node_host: ok');
