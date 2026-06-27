# Nyra FFI hello (Rust host)

Build exported Nyra as a dynamic library:

```bash
nyra build examples/ffi/hello_from_rust/main.ny -o libnyra_hello --cdylib
```

Run the Rust host (builds cdylib via build.rs, then links):

```bash
cd examples/ffi/hello_from_rust && cargo run
```

Rust calls `add(a, b) -> i32` via `extern "C"`.

See also [`../export_greet/`](../export_greet/) for `string` returns + `free`.
