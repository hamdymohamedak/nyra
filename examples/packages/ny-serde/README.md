# ny-serde (NyraPkg)

Clean Nyra JSON API backed by `rust::serde_json` (`nyra bind rust serde_json`).

## Layout

```
ny-serde/
  nyra.mod         # require rust::serde_json, link-crate serde_json
  serde.ny         # parse_json / stringify_json / from_json / to_json
  stubs/serde_json/bindings.ny   # compile-only stub for CI
  serde_test.ny    # package tests
```

## Install

```bash
nyra pkg init
nyra pkg install ny-serde@^0.1.0
```

## Use

```ny
import "pkg/ny-serde/serde.ny"

fn main() {
    let obj = parse_json("{\"ok\":true}")
    print(stringify_json(obj))
}
```

## Bind (first time per project)

```bash
nyra bind rust serde_json --template
# or: nyra add rust::serde_json@^1.0.0
```

## Test

```bash
nyra bind rust serde_json --template --project examples/packages/ny-serde
nyra test examples/packages/ny-serde/serde_test.ny
```
