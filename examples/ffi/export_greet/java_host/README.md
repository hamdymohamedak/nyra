# Java host → Nyra cdylib

Java has no built-in stable dlopen like Python `ctypes`. Supported patterns:

## 1. Process bridge (recommended MVP)

Run a Nyra binary or worker from Java (`ProcessBuilder`) and exchange JSON on stdin/stdout — same protocol as [`examples/bridge/`](../../bridge/).

## 2. JNI / Panama FFI (production)

1. `nyra build ../main.ny -o libnyra_greet --cdylib`
2. Generate JNI header from `export fn` symbols
3. `System.loadLibrary("greet")` + `native` declarations

See [`docs/bridge.md`](../../../docs/bridge.md).

## 3. Sidecar

Ship `nyra build` executable next to your JAR (Tauri/Electron-style) — [`docs/integration-ideas/tauri-sidecar/`](../../../docs/integration-ideas/tauri-sidecar/).
