# Nyra C library registry

Slim manifests for `nyra bind <name>` / `nyra pkg add <name>`.

Nyra is **not** a C package manager. These files only map names so Nyra can:

1. Suggest the right `brew` / `apt` / `dnf` / `pacman` install command
2. Find headers via `pkg-config` (or system include paths)
3. Generate bindings + `nyra.mod` link lines

There are **310+** built-in entries covering:

| Area | Examples |
|------|----------|
| **AI / inference** | `onnxruntime`, `llama-cpp`, `ggml`, `tensorflow`, `libtorch`, `onednn`, `whisper-cpp`, `ctranslate2` |
| **AI / ML & vectors** | `xgboost`, `lightgbm`, `faiss`, `hnswlib`, `annoy`, `sqlite-vec`, `sentencepiece` |
| **AI / GPU** | `cuda`, `cudnn`, `tensorrt`, `rocm`, `miopen`, `opencl`, `vulkan-loader`, `moltenvk`, `mkl` |
| **RPC / data** | `grpc`, `thrift`, `capnp`, `arrow`, `parquet`, `duckdb`, `protobuf`, `flatbuffers` |
| **Observability** | `opentelemetry-cpp`, `prometheus-cpp`, `opentelemetry-c` |
| **WebAssembly** | `wasmtime`, `wasmer`, `wamr` |
| **Auth / security** | `openldap`, `krb5`, `cyrus-sasl`, `pam`, `pkcs11-helper`, `tpm2-tss`, `openssl`, `libsodium` |
| **Cloud** | `aws-c-common`, `aws-c-s3`, `aws-sdk-cpp`, `azure-iot-sdk-c` |
| **Messaging** | `zeromq`, `librdkafka`, `rabbitmq-c`, `qpid-proton`, `nats-c`, `pulsar` |
| **DB clients** | `sqlite3`, `libpq`, `mongoc`, `hiredis`, `cassandra`, `neo4j-client` |
| Networks / async | `curl`, `libuv`, `nghttp2`, `libwebsockets` |
| Games / graphics | `raylib`, `sdl2`, `sdl3`, `glfw`, `box2d`, `bullet`, `assimp` |
| GUI / desktop | `gtk3`, `gtk4`, `cairo`, `ncurses`, `raygui` |
| Media / live | `ffmpeg`, `gstreamer`, `opencv`, `portaudio`, `opus`, `openexr` |
| Robotics / vision | `pcl`, `realsense`, `opencv`, `zbar`, `zxing-cpp` |
| Documents | `mupdf`, `poppler`, `pdfium`, `tesseract` |
| Science | `gsl`, `openblas`, `lapack`, `eigen`, `hdf5`, `gdal` |

Validate locally:

```bash
python3 make/py/test_c_registry.py              # schema + brew formulae
python3 make/py/test_c_registry.py --bind       # bind every installed keg
python3 make/py/test_c_registry.py --install-bind  # brew install missing, then bind all
```

AI quick start:

```bash
brew install onnxruntime llama.cpp sentencepiece faiss
nyra bind onnxruntime
nyra bind llama-cpp
nyra bind sentencepiece
nyra bind faiss
```

```toml
name = "gsl"
description = "GNU Scientific Library"
headers = ["gsl/gsl_sf.h"]
libs = ["gsl", "gslcblas"]
pkg_config = "gsl"
brew = "gsl"
apt = "libgsl-dev"
pacman = "gsl"
dnf = "gsl-devel"
aliases = ["gnu-gsl"]
```

Header-only libs that live on GitHub (e.g. raygui):

```toml
name = "raygui"
headers = ["src/raygui.h"]
libs = ["raylib"]
brew = "raylib"
git = "https://github.com/raysan5/raygui.git"
depends = ["raylib"]
```

User overrides: `~/.nyra/registry/c/*.toml`

Maintainers: edit [`make/py/contrib_dev/c_registry_catalog.py`](../make/py/contrib_dev/c_registry_catalog.py) then run:

```bash
python3 make/py/contrib_dev/sync_c_registry.py
```

For GitHub C projects, prefer a root `nyra.toml`:

```toml
[c]
headers = ["include/cool.h"]
libraries = ["cool"]
include_dirs = ["include"]
```

If a library is **not** in any package manager and not in this registry:

```bash
nyra bind c /path/to/header.h --lib NAME --update-mod
```
