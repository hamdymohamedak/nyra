# ny-toml (NyraPkg)

Clean Nyra TOML API backed by `rust::toml` (`nyra bind rust toml`).

## Layout

```
ny-toml/
  nyra.mod         # require rust::toml, link-crate toml
  toml.ny          # parse_toml / stringify_toml / from_toml / to_toml
  stubs/toml/bindings.ny   # compile-only stub for CI
  toml_test.ny     # package tests
```

## Install

```bash
nyra pkg init
nyra pkg install ny-toml@^0.1.0
```

## Use

```ny
import "pkg/ny-toml/toml.ny"

fn main() {
    let doc = parse_toml("[db]\nhost = \"localhost\"\n")
    print(stringify_toml(doc))
}
```

## Bind (first time per project)

```bash
nyra bind rust toml --template
# or: nyra add rust::toml@^0.8.0
```

## Test

```bash
nyra bind rust toml --template --project examples/packages/ny-toml
nyra test examples/packages/ny-toml/toml_test.ny
```
