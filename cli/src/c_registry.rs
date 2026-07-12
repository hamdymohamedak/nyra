//! Built-in + user C library registry (`registry/c/*.toml`).

use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

use serde::Deserialize;

/// One registry library (system package → headers + link names).
#[derive(Debug, Clone, Deserialize)]
pub struct RegistryEntry {
    pub name: String,
    #[serde(default)]
    pub description: String,
    pub headers: Vec<String>,
    #[serde(default)]
    pub libs: Vec<String>,
    #[serde(default)]
    pub pkg_config: Option<String>,
    #[serde(default)]
    pub brew: Option<String>,
    #[serde(default)]
    pub apt: Option<String>,
    #[serde(default)]
    pub pacman: Option<String>,
    #[serde(default)]
    pub dnf: Option<String>,
    #[serde(default)]
    pub aliases: Vec<String>,
    /// Optional git URL — clone into `vendor/c-src/<name>/` (e.g. header-only libs).
    #[serde(default)]
    pub git: Option<String>,
    /// Registry names that must be installed first (headers + link paths).
    #[serde(default)]
    pub depends: Vec<String>,
    /// If set, emit a one-file C shim (`#define NAME` + `#include` header) and `link-source` it.
    /// Example: `RAYGUI_IMPLEMENTATION` for header-only raygui.
    #[serde(default)]
    pub impl_define: Option<String>,
    /// Preprocessor defines passed to libclang as `-DNAME` or `-DNAME=value`.
    #[serde(default)]
    pub defines: Vec<String>,
    /// Forced includes (`clang -include`), e.g. `stdio.h` before jpeglib.h / readline.h.
    #[serde(default)]
    pub force_include: Vec<String>,
    /// Parse headers as C++ (`-x c++ -std=c++17`) instead of C11.
    #[serde(default)]
    pub cxx: bool,
    /// Restrict to these OS names (`macos`, `linux`, `windows`). Empty = all.
    #[serde(default)]
    pub platforms: Vec<String>,
}

impl RegistryEntry {
    pub fn primary_header(&self) -> Result<&str, String> {
        self.headers
            .first()
            .map(String::as_str)
            .ok_or_else(|| format!("registry entry '{}': headers must be non-empty", self.name))
    }

    pub fn primary_link(&self) -> Result<&str, String> {
        self.libs
            .first()
            .map(String::as_str)
            .ok_or_else(|| format!("registry entry '{}': libs must be non-empty", self.name))
    }

    pub fn brew_formula(&self) -> &str {
        self.brew.as_deref().unwrap_or(self.name.as_str())
    }

    /// Empty platforms = supported everywhere.
    pub fn supports_host(&self) -> bool {
        if self.platforms.is_empty() {
            return true;
        }
        let host = if cfg!(target_os = "macos") {
            "macos"
        } else if cfg!(target_os = "linux") {
            "linux"
        } else if cfg!(windows) {
            "windows"
        } else {
            return false;
        };
        self.platforms.iter().any(|p| p.eq_ignore_ascii_case(host))
    }
}

/// Optional `nyra.toml` inside a third-party C repo.
#[derive(Debug, Clone, Deserialize, Default)]
pub struct NyraToml {
    #[serde(default)]
    pub c: Option<NyraTomlC>,
}

#[derive(Debug, Clone, Deserialize, Default)]
pub struct NyraTomlC {
    #[serde(default)]
    pub headers: Vec<String>,
    #[serde(default)]
    pub libraries: Vec<String>,
    #[serde(default)]
    pub include_dirs: Vec<String>,
    #[serde(default)]
    pub link_dirs: Vec<String>,
}

const BUILTIN: &[(&str, &str)] = &[
    ("abseil", include_str!("../../registry/c/abseil.toml")),
    ("acl", include_str!("../../registry/c/acl.toml")),
    ("allegro", include_str!("../../registry/c/allegro.toml")),
    ("alsa-lib", include_str!("../../registry/c/alsa-lib.toml")),
    ("annoy", include_str!("../../registry/c/annoy.toml")),
    ("aom", include_str!("../../registry/c/aom.toml")),
    ("apr", include_str!("../../registry/c/apr.toml")),
    ("apr-util", include_str!("../../registry/c/apr-util.toml")),
    ("argon2", include_str!("../../registry/c/argon2.toml")),
    ("assimp", include_str!("../../registry/c/assimp.toml")),
    ("blake3", include_str!("../../registry/c/blake3.toml")),
    ("box2d", include_str!("../../registry/c/box2d.toml")),
    ("brotli", include_str!("../../registry/c/brotli.toml")),
    ("bzip2", include_str!("../../registry/c/bzip2.toml")),
    ("c-ares", include_str!("../../registry/c/c-ares.toml")),
    ("cairo", include_str!("../../registry/c/cairo.toml")),
    ("capstone", include_str!("../../registry/c/capstone.toml")),
    ("catboost", include_str!("../../registry/c/catboost.toml")),
    ("cfitsio", include_str!("../../registry/c/cfitsio.toml")),
    ("cglm", include_str!("../../registry/c/cglm.toml")),
    ("check", include_str!("../../registry/c/check.toml")),
    ("chipmunk", include_str!("../../registry/c/chipmunk.toml")),
    ("chromaprint", include_str!("../../registry/c/chromaprint.toml")),
    ("cjson", include_str!("../../registry/c/cjson.toml")),
    ("clamav", include_str!("../../registry/c/clamav.toml")),
    ("cmocka", include_str!("../../registry/c/cmocka.toml")),
    ("cublas", include_str!("../../registry/c/cublas.toml")),
    ("cuda", include_str!("../../registry/c/cuda.toml")),
    ("cudnn", include_str!("../../registry/c/cudnn.toml")),
    ("cunit", include_str!("../../registry/c/cunit.toml")),
    ("curl", include_str!("../../registry/c/curl.toml")),
    ("czmq", include_str!("../../registry/c/czmq.toml")),
    ("dav1d", include_str!("../../registry/c/dav1d.toml")),
    ("dbus", include_str!("../../registry/c/dbus.toml")),
    ("djvulibre", include_str!("../../registry/c/djvulibre.toml")),
    ("duktape", include_str!("../../registry/c/duktape.toml")),
    ("eigen", include_str!("../../registry/c/eigen.toml")),
    ("elfutils", include_str!("../../registry/c/elfutils.toml")),
    ("enet", include_str!("../../registry/c/enet.toml")),
    ("expat", include_str!("../../registry/c/expat.toml")),
    ("faiss", include_str!("../../registry/c/faiss.toml")),
    ("ffmpeg", include_str!("../../registry/c/ffmpeg.toml")),
    ("fftw", include_str!("../../registry/c/fftw.toml")),
    ("flac", include_str!("../../registry/c/flac.toml")),
    ("flatbuffers", include_str!("../../registry/c/flatbuffers.toml")),
    ("flint", include_str!("../../registry/c/flint.toml")),
    ("fluidsynth", include_str!("../../registry/c/fluidsynth.toml")),
    ("fontconfig", include_str!("../../registry/c/fontconfig.toml")),
    ("freealut", include_str!("../../registry/c/freealut.toml")),
    ("freeglut", include_str!("../../registry/c/freeglut.toml")),
    ("freeimage", include_str!("../../registry/c/freeimage.toml")),
    ("freetype", include_str!("../../registry/c/freetype.toml")),
    ("gdal", include_str!("../../registry/c/gdal.toml")),
    ("gdk-pixbuf", include_str!("../../registry/c/gdk-pixbuf.toml")),
    ("geos", include_str!("../../registry/c/geos.toml")),
    ("ggml", include_str!("../../registry/c/ggml.toml")),
    ("giflib", include_str!("../../registry/c/giflib.toml")),
    ("glew", include_str!("../../registry/c/glew.toml")),
    ("glfw", include_str!("../../registry/c/glfw.toml")),
    ("glib", include_str!("../../registry/c/glib.toml")),
    ("glpk", include_str!("../../registry/c/glpk.toml")),
    ("gmp", include_str!("../../registry/c/gmp.toml")),
    ("gnutls", include_str!("../../registry/c/gnutls.toml")),
    ("gsl", include_str!("../../registry/c/gsl.toml")),
    ("gtk3", include_str!("../../registry/c/gtk3.toml")),
    ("gtk4", include_str!("../../registry/c/gtk4.toml")),
    ("guile", include_str!("../../registry/c/guile.toml")),
    ("gumbo", include_str!("../../registry/c/gumbo.toml")),
    ("harfbuzz", include_str!("../../registry/c/harfbuzz.toml")),
    ("hdf5", include_str!("../../registry/c/hdf5.toml")),
    ("hidapi", include_str!("../../registry/c/hidapi.toml")),
    ("hiredis", include_str!("../../registry/c/hiredis.toml")),
    ("hnswlib", include_str!("../../registry/c/hnswlib.toml")),
    ("http-parser", include_str!("../../registry/c/http-parser.toml")),
    ("icu", include_str!("../../registry/c/icu.toml")),
    ("igraph", include_str!("../../registry/c/igraph.toml")),
    ("imagemagick", include_str!("../../registry/c/imagemagick.toml")),
    ("imath", include_str!("../../registry/c/imath.toml")),
    ("jack", include_str!("../../registry/c/jack.toml")),
    ("janet", include_str!("../../registry/c/janet.toml")),
    ("jansson", include_str!("../../registry/c/jansson.toml")),
    ("jemalloc", include_str!("../../registry/c/jemalloc.toml")),
    ("jpeg-xl", include_str!("../../registry/c/jpeg-xl.toml")),
    ("json-c", include_str!("../../registry/c/json-c.toml")),
    ("keystone", include_str!("../../registry/c/keystone.toml")),
    ("keyutils", include_str!("../../registry/c/keyutils.toml")),
    ("lame", include_str!("../../registry/c/lame.toml")),
    ("lapack", include_str!("../../registry/c/lapack.toml")),
    ("lcms2", include_str!("../../registry/c/lcms2.toml")),
    ("leptonica", include_str!("../../registry/c/leptonica.toml")),
    ("leveldb", include_str!("../../registry/c/leveldb.toml")),
    ("libarchive", include_str!("../../registry/c/libarchive.toml")),
    ("libavro", include_str!("../../registry/c/libavro.toml")),
    ("libbson", include_str!("../../registry/c/libbson.toml")),
    ("libcap", include_str!("../../registry/c/libcap.toml")),
    ("libcoap", include_str!("../../registry/c/libcoap.toml")),
    ("libcsv", include_str!("../../registry/c/libcsv.toml")),
    ("libdeflate", include_str!("../../registry/c/libdeflate.toml")),
    ("libedit", include_str!("../../registry/c/libedit.toml")),
    ("libevent", include_str!("../../registry/c/libevent.toml")),
    ("libffi", include_str!("../../registry/c/libffi.toml")),
    ("libfuse", include_str!("../../registry/c/libfuse.toml")),
    ("libgc", include_str!("../../registry/c/libgc.toml")),
    ("libgcrypt", include_str!("../../registry/c/libgcrypt.toml")),
    ("libgit2", include_str!("../../registry/c/libgit2.toml")),
    ("libheif", include_str!("../../registry/c/libheif.toml")),
    ("libidn2", include_str!("../../registry/c/libidn2.toml")),
    ("libjpeg-turbo", include_str!("../../registry/c/libjpeg-turbo.toml")),
    ("liblo", include_str!("../../registry/c/liblo.toml")),
    ("libmagic", include_str!("../../registry/c/libmagic.toml")),
    ("libmaxminddb", include_str!("../../registry/c/libmaxminddb.toml")),
    ("libmemcached", include_str!("../../registry/c/libmemcached.toml")),
    ("libmicrohttpd", include_str!("../../registry/c/libmicrohttpd.toml")),
    ("libmodbus", include_str!("../../registry/c/libmodbus.toml")),
    ("libnet", include_str!("../../registry/c/libnet.toml")),
    ("libnice", include_str!("../../registry/c/libnice.toml")),
    ("libogg", include_str!("../../registry/c/libogg.toml")),
    ("libpcap", include_str!("../../registry/c/libpcap.toml")),
    ("libpng", include_str!("../../registry/c/libpng.toml")),
    ("libpq", include_str!("../../registry/c/libpq.toml")),
    ("libpsl", include_str!("../../registry/c/libpsl.toml")),
    ("libraw", include_str!("../../registry/c/libraw.toml")),
    ("librdkafka", include_str!("../../registry/c/librdkafka.toml")),
    ("librsync", include_str!("../../registry/c/librsync.toml")),
    ("libsamplerate", include_str!("../../registry/c/libsamplerate.toml")),
    ("libseccomp", include_str!("../../registry/c/libseccomp.toml")),
    ("libsndfile", include_str!("../../registry/c/libsndfile.toml")),
    ("libsodium", include_str!("../../registry/c/libsodium.toml")),
    ("libsoup", include_str!("../../registry/c/libsoup.toml")),
    ("libsoxr", include_str!("../../registry/c/libsoxr.toml")),
    ("libsrtp", include_str!("../../registry/c/libsrtp.toml")),
    ("libssh", include_str!("../../registry/c/libssh.toml")),
    ("libssh2", include_str!("../../registry/c/libssh2.toml")),
    ("libtiff", include_str!("../../registry/c/libtiff.toml")),
    ("libtorch", include_str!("../../registry/c/libtorch.toml")),
    ("libunwind", include_str!("../../registry/c/libunwind.toml")),
    ("libusb", include_str!("../../registry/c/libusb.toml")),
    ("libuv", include_str!("../../registry/c/libuv.toml")),
    ("libvorbis", include_str!("../../registry/c/libvorbis.toml")),
    ("libvpx", include_str!("../../registry/c/libvpx.toml")),
    ("libwebp", include_str!("../../registry/c/libwebp.toml")),
    ("libwebsockets", include_str!("../../registry/c/libwebsockets.toml")),
    ("libx11", include_str!("../../registry/c/libx11.toml")),
    ("libxcb", include_str!("../../registry/c/libxcb.toml")),
    ("libxml2", include_str!("../../registry/c/libxml2.toml")),
    ("libxslt", include_str!("../../registry/c/libxslt.toml")),
    ("libyaml", include_str!("../../registry/c/libyaml.toml")),
    ("libzip", include_str!("../../registry/c/libzip.toml")),
    ("lightgbm", include_str!("../../registry/c/lightgbm.toml")),
    ("lilv", include_str!("../../registry/c/lilv.toml")),
    ("llama-cpp", include_str!("../../registry/c/llama-cpp.toml")),
    ("llhttp", include_str!("../../registry/c/llhttp.toml")),
    ("lmdb", include_str!("../../registry/c/lmdb.toml")),
    ("lua", include_str!("../../registry/c/lua.toml")),
    ("luajit", include_str!("../../registry/c/luajit.toml")),
    ("lz4", include_str!("../../registry/c/lz4.toml")),
    ("lzo", include_str!("../../registry/c/lzo.toml")),
    ("mariadb", include_str!("../../registry/c/mariadb.toml")),
    ("mbedtls", include_str!("../../registry/c/mbedtls.toml")),
    ("milvus", include_str!("../../registry/c/milvus.toml")),
    ("mimalloc", include_str!("../../registry/c/mimalloc.toml")),
    ("minizip", include_str!("../../registry/c/minizip.toml")),
    ("minizip-ng", include_str!("../../registry/c/minizip-ng.toml")),
    ("miopen", include_str!("../../registry/c/miopen.toml")),
    ("mongoc", include_str!("../../registry/c/mongoc.toml")),
    ("mpc", include_str!("../../registry/c/mpc.toml")),
    ("mpfr", include_str!("../../registry/c/mpfr.toml")),
    ("mpg123", include_str!("../../registry/c/mpg123.toml")),
    ("msgpack", include_str!("../../registry/c/msgpack.toml")),
    ("mupdf", include_str!("../../registry/c/mupdf.toml")),
    ("nccl", include_str!("../../registry/c/nccl.toml")),
    ("ncurses", include_str!("../../registry/c/ncurses.toml")),
    ("netcdf", include_str!("../../registry/c/netcdf.toml")),
    ("nettle", include_str!("../../registry/c/nettle.toml")),
    ("nghttp2", include_str!("../../registry/c/nghttp2.toml")),
    ("nghttp3", include_str!("../../registry/c/nghttp3.toml")),
    ("ngtcp2", include_str!("../../registry/c/ngtcp2.toml")),
    ("nlopt", include_str!("../../registry/c/nlopt.toml")),
    ("nng", include_str!("../../registry/c/nng.toml")),
    ("nuklear", include_str!("../../registry/c/nuklear.toml")),
    ("ode", include_str!("../../registry/c/ode.toml")),
    ("onednn", include_str!("../../registry/c/onednn.toml")),
    ("oniguruma", include_str!("../../registry/c/oniguruma.toml")),
    ("onnxruntime", include_str!("../../registry/c/onnxruntime.toml")),
    ("openal-soft", include_str!("../../registry/c/openal-soft.toml")),
    ("openblas", include_str!("../../registry/c/openblas.toml")),
    ("opencl", include_str!("../../registry/c/opencl.toml")),
    ("opencl-headers", include_str!("../../registry/c/opencl-headers.toml")),
    ("opencv", include_str!("../../registry/c/opencv.toml")),
    ("openexr", include_str!("../../registry/c/openexr.toml")),
    ("openjpeg", include_str!("../../registry/c/openjpeg.toml")),
    ("openssl", include_str!("../../registry/c/openssl.toml")),
    ("opus", include_str!("../../registry/c/opus.toml")),
    ("opusfile", include_str!("../../registry/c/opusfile.toml")),
    ("paho-mqtt", include_str!("../../registry/c/paho-mqtt.toml")),
    ("pango", include_str!("../../registry/c/pango.toml")),
    ("pcre2", include_str!("../../registry/c/pcre2.toml")),
    ("physfs", include_str!("../../registry/c/physfs.toml")),
    ("poppler", include_str!("../../registry/c/poppler.toml")),
    ("portaudio", include_str!("../../registry/c/portaudio.toml")),
    ("portmidi", include_str!("../../registry/c/portmidi.toml")),
    ("proj", include_str!("../../registry/c/proj.toml")),
    ("protobuf", include_str!("../../registry/c/protobuf.toml")),
    ("protobuf-c", include_str!("../../registry/c/protobuf-c.toml")),
    ("pulseaudio", include_str!("../../registry/c/pulseaudio.toml")),
    ("qhull", include_str!("../../registry/c/qhull.toml")),
    ("quickjs", include_str!("../../registry/c/quickjs.toml")),
    ("raygui", include_str!("../../registry/c/raygui.toml")),
    ("raylib", include_str!("../../registry/c/raylib.toml")),
    ("readline", include_str!("../../registry/c/readline.toml")),
    ("rnnoise", include_str!("../../registry/c/rnnoise.toml")),
    ("rocksdb", include_str!("../../registry/c/rocksdb.toml")),
    ("rocm", include_str!("../../registry/c/rocm.toml")),
    ("rtaudio", include_str!("../../registry/c/rtaudio.toml")),
    ("rtmidi", include_str!("../../registry/c/rtmidi.toml")),
    ("rubberband", include_str!("../../registry/c/rubberband.toml")),
    ("sdl2", include_str!("../../registry/c/sdl2.toml")),
    ("sdl2_image", include_str!("../../registry/c/sdl2_image.toml")),
    ("sdl2_mixer", include_str!("../../registry/c/sdl2_mixer.toml")),
    ("sdl2_net", include_str!("../../registry/c/sdl2_net.toml")),
    ("sdl2_ttf", include_str!("../../registry/c/sdl2_ttf.toml")),
    ("sdl3", include_str!("../../registry/c/sdl3.toml")),
    ("sdl3_image", include_str!("../../registry/c/sdl3_image.toml")),
    ("sdl3_ttf", include_str!("../../registry/c/sdl3_ttf.toml")),
    ("secp256k1", include_str!("../../registry/c/secp256k1.toml")),
    ("sentencepiece", include_str!("../../registry/c/sentencepiece.toml")),
    ("serd", include_str!("../../registry/c/serd.toml")),
    ("snappy", include_str!("../../registry/c/snappy.toml")),
    ("sokol", include_str!("../../registry/c/sokol.toml")),
    ("sord", include_str!("../../registry/c/sord.toml")),
    ("speex", include_str!("../../registry/c/speex.toml")),
    ("speexdsp", include_str!("../../registry/c/speexdsp.toml")),
    ("sqlite-vec", include_str!("../../registry/c/sqlite-vec.toml")),
    ("sqlite3", include_str!("../../registry/c/sqlite3.toml")),
    ("sratom", include_str!("../../registry/c/sratom.toml")),
    ("suitesparse", include_str!("../../registry/c/suitesparse.toml")),
    ("sundials", include_str!("../../registry/c/sundials.toml")),
    ("systemd", include_str!("../../registry/c/systemd.toml")),
    ("tcl", include_str!("../../registry/c/tcl.toml")),
    ("tcmalloc", include_str!("../../registry/c/tcmalloc.toml")),
    ("tensorflow", include_str!("../../registry/c/tensorflow.toml")),
    ("tensorrt", include_str!("../../registry/c/tensorrt.toml")),
    ("tesseract", include_str!("../../registry/c/tesseract.toml")),
    ("theora", include_str!("../../registry/c/theora.toml")),
    ("tidy-html5", include_str!("../../registry/c/tidy-html5.toml")),
    ("tokenizers", include_str!("../../registry/c/tokenizers.toml")),
    ("tokyocabinet", include_str!("../../registry/c/tokyocabinet.toml")),
    ("torchvision", include_str!("../../registry/c/torchvision.toml")),
    ("tree-sitter", include_str!("../../registry/c/tree-sitter.toml")),
    ("unicorn", include_str!("../../registry/c/unicorn.toml")),
    ("unixodbc", include_str!("../../registry/c/unixodbc.toml")),
    ("uriparser", include_str!("../../registry/c/uriparser.toml")),
    ("uuid", include_str!("../../registry/c/uuid.toml")),
    ("vips", include_str!("../../registry/c/vips.toml")),
    ("vulkan-headers", include_str!("../../registry/c/vulkan-headers.toml")),
    ("vulkan-loader", include_str!("../../registry/c/vulkan-loader.toml")),
    ("wayland", include_str!("../../registry/c/wayland.toml")),
    ("wolfssl", include_str!("../../registry/c/wolfssl.toml")),
    ("wren", include_str!("../../registry/c/wren.toml")),
    ("x264", include_str!("../../registry/c/x264.toml")),
    ("x265", include_str!("../../registry/c/x265.toml")),
    ("xgboost", include_str!("../../registry/c/xgboost.toml")),
    ("xxhash", include_str!("../../registry/c/xxhash.toml")),
    ("xz", include_str!("../../registry/c/xz.toml")),
    ("yara", include_str!("../../registry/c/yara.toml")),
    ("yyjson", include_str!("../../registry/c/yyjson.toml")),
    ("zeromq", include_str!("../../registry/c/zeromq.toml")),
    ("zlib", include_str!("../../registry/c/zlib.toml")),
    ("zookeeper", include_str!("../../registry/c/zookeeper.toml")),
    ("zstd", include_str!("../../registry/c/zstd.toml")),
    ("zydis", include_str!("../../registry/c/zydis.toml")),
];

pub fn load_registry() -> Result<BTreeMap<String, RegistryEntry>, String> {
    let mut map = BTreeMap::new();
    for (name, text) in BUILTIN {
        let entry: RegistryEntry = toml::from_str(text)
            .map_err(|e| format!("builtin registry/{name}.toml: {e}"))?;
        if entry.name != *name && entry.name.to_ascii_lowercase() != *name {
            // allow; key by file stem
        }
        map.insert(entry.name.clone(), entry);
    }

    // User / local overrides win.
    for dir in registry_search_dirs() {
        if !dir.is_dir() {
            continue;
        }
        let entries = std::fs::read_dir(&dir).map_err(|e| format!("{}: {e}", dir.display()))?;
        for ent in entries.filter_map(|e| e.ok()) {
            let path = ent.path();
            if path.extension().and_then(|e| e.to_str()) != Some("toml") {
                continue;
            }
            if path.file_name().and_then(|n| n.to_str()) == Some("README.md") {
                continue;
            }
            let text = std::fs::read_to_string(&path).map_err(|e| format!("{}: {e}", path.display()))?;
            let entry: RegistryEntry = toml::from_str(&text)
                .map_err(|e| format!("{}: {e}", path.display()))?;
            map.insert(entry.name.clone(), entry);
        }
    }
    Ok(map)
}

pub fn find_entry(name: &str) -> Result<RegistryEntry, String> {
    let key = name.trim().to_ascii_lowercase();
    let map = load_registry()?;
    if let Some(e) = map.get(&key) {
        return Ok(e.clone());
    }
    for e in map.values() {
        if e.name.eq_ignore_ascii_case(&key) {
            return Ok(e.clone());
        }
        if e.aliases.iter().any(|a| a.eq_ignore_ascii_case(&key)) {
            return Ok(e.clone());
        }
        if e.libs.iter().any(|l| l.eq_ignore_ascii_case(&key)) {
            return Ok(e.clone());
        }
        // Do not match on `brew` — multiple entries can share a formula (e.g. raygui → raylib).
    }
    let known: Vec<_> = map.keys().cloned().collect();
    Err(format!(
        "unknown c-lib '{name}' — known: {}\n  tip: nyra pkg add https://github.com/org/repo  ·  or nyra bind c HEADER.h --lib NAME",
        known.join(", ")
    ))
}

pub fn is_registry_lib(name: &str) -> bool {
    find_entry(name).is_ok()
}

pub fn list_names() -> Result<Vec<String>, String> {
    Ok(load_registry()?.keys().cloned().collect())
}

pub fn parse_nyra_toml(text: &str) -> Result<NyraToml, String> {
    toml::from_str(text).map_err(|e| format!("nyra.toml: {e}"))
}

fn registry_search_dirs() -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    if let Ok(extra) = std::env::var("NYRA_C_REGISTRY") {
        dirs.push(PathBuf::from(extra));
    }
    if let Some(home) = dirs::home_dir() {
        dirs.push(home.join(".nyra/registry/c"));
    }
    // Dev checkout: repo registry next to cwd or CARGO_MANIFEST_DIR equivalent at runtime.
    let cwd = std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
    dirs.push(cwd.join("registry/c"));
    if let Ok(root) = std::env::var("NYRA_HOME") {
        dirs.push(Path::new(&root).join("registry/c"));
    }
    dirs
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn loads_builtin_gsl() {
        let e = find_entry("gsl").unwrap();
        assert_eq!(e.name, "gsl");
        assert_eq!(e.primary_header().unwrap(), "gsl/gsl_sf.h");
        assert_eq!(e.libs[0], "gsl");
    }

    #[test]
    fn resolves_aliases() {
        assert_eq!(find_entry("sqlite").unwrap().name, "sqlite3");
        assert_eq!(find_entry("z").unwrap().name, "zlib");
        assert_eq!(find_entry("libcurl").unwrap().name, "curl");
    }

    #[test]
    fn parses_project_nyra_toml() {
        let t = parse_nyra_toml(
            r#"
[c]
headers = ["include/cool.h"]
libraries = ["cool"]
include_dirs = ["include"]
"#,
        )
        .unwrap();
        let c = t.c.unwrap();
        assert_eq!(c.headers, vec!["include/cool.h"]);
        assert_eq!(c.libraries, vec!["cool"]);
    }

    #[test]
    fn loads_raygui_git() {
        let e = find_entry("raygui").unwrap();
        assert_eq!(e.name, "raygui");
        assert!(e.git.as_deref().unwrap().contains("raygui"));
        assert_eq!(e.depends, vec!["raylib"]);
        assert_eq!(e.primary_header().unwrap(), "src/raygui.h");
    }
}
