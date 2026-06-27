# Call libc via `extern fn`

Demonstrates inbound FFI with the `ptr` type:

```bash
nyra run examples/ffi/call_libc/main.ny
```

Expected output: `5` (length of `"hello"`).

Link extra native libraries with:

```bash
nyra build . --link-lib sqlite3 --link-search-path /opt/homebrew/lib
```

Or in `nyra.mod`:

```
link sqlite3
link -L /opt/homebrew/lib
```
