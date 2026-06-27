# Nyra FFI export (cdylib)

Build a shared library with exported C symbols:

```bash
nyra build examples/ffi/export_greet/main.ny -o libnyra_greet --cdylib
```

## Rust host

```bash
cd examples/ffi/export_greet/rust_host && cargo run
```

Calls `add` and `greet`; the host must **`free`** strings returned from Nyra.

## Python host

```bash
python3 examples/ffi/export_greet/python_host/call.py
```

## Node host (koffi)

```bash
cd examples/ffi/export_greet/node_host && npm install
node call.mjs
```

## Java host

JNI / Panama FFI or process bridge — see [`java_host/README.md`](java_host/README.md).

See [`docs/bridge.md`](../../../docs/bridge.md) and [`docs/abi-policy.md`](../../../docs/abi-policy.md) for integration patterns and ownership at the boundary.
