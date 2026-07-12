"""Built-in C library registry catalog (system PM → nyra bind).

Categories cover networks, games, GUI, backend, media, crypto, science, and more.
Source of truth for `sync_c_registry.py` → registry/c/*.toml + cli BUILTIN.
"""
from __future__ import annotations

from typing import Any


def _e(
    name: str,
    description: str,
    headers: list[str],
    libs: list[str],
    *,
    pkg_config: str | None = None,
    brew: str | None = None,
    apt: str | None = None,
    pacman: str | None = None,
    dnf: str | None = None,
    aliases: list[str] | None = None,
    git: str | None = None,
    depends: list[str] | None = None,
    impl_define: str | None = None,
    platforms: list[str] | None = None,
    defines: list[str] | None = None,
    force_include: list[str] | None = None,
    cxx: bool = False,
) -> dict[str, Any]:
    """brew='-' / pacman='-' means omit that package manager field."""
    if brew == "-":
        brew_val: str | None = None
    elif brew is not None:
        brew_val = brew
    elif git:
        brew_val = None
    else:
        brew_val = name

    if apt == "-":
        apt_val: str | None = None
    else:
        apt_val = apt

    if pacman == "-":
        pacman_val: str | None = None
    elif pacman is not None:
        pacman_val = pacman
    elif brew_val is None and git:
        pacman_val = None
    else:
        pacman_val = name

    if dnf == "-":
        dnf_val: str | None = None
    else:
        dnf_val = dnf

    return {
        "name": name,
        "description": description,
        "headers": headers,
        "libs": libs,
        "pkg_config": pkg_config,
        "brew": brew_val,
        "apt": apt_val,
        "pacman": pacman_val,
        "dnf": dnf_val,
        "aliases": aliases or [],
        "git": git,
        "depends": depends or [],
        "impl_define": impl_define,
        "platforms": list(platforms or []),
        "defines": list(defines or []),
        "force_include": list(force_include or []),
        "cxx": bool(cxx),
    }


# ---------------------------------------------------------------------------
# Catalog — keep names stable; brew/apt are best-effort common distro names.
# ---------------------------------------------------------------------------

ENTRIES: list[dict[str, Any]] = [
    # ── already shipping ──────────────────────────────────────────────────
    _e("zlib", "Lossless compression library", ["zlib.h"], ["z"], pkg_config="zlib", brew="zlib", apt="zlib1g-dev", pacman="zlib", dnf="zlib-devel", aliases=["z"]),
    _e("sqlite3", "Embedded SQL database engine", ["sqlite3.h"], ["sqlite3"], pkg_config="sqlite3", brew="sqlite", apt="libsqlite3-dev", pacman="sqlite", dnf="sqlite-devel", aliases=["sqlite"]),
    _e("raylib", "Simple and easy-to-use game programming library", ["raylib.h"], ["raylib"], pkg_config="raylib", brew="raylib", apt="libraylib-dev", pacman="raylib", dnf="raylib-devel"),
    _e("sdl2", "Simple DirectMedia Layer 2", ["SDL2/SDL.h"], ["SDL2"], pkg_config="sdl2", brew="sdl2-compat", apt="libsdl2-dev", pacman="sdl2", dnf="SDL2-devel", aliases=["SDL2"]),
    _e(
        "raygui",
        "Immediate-mode GUI for raylib (header-only; fetched from GitHub)",
        ["src/raygui.h"],
        ["raylib"],
        brew="raylib",
        apt="libraylib-dev",
        pacman="raylib",
        dnf="raylib-devel",
        git="https://github.com/raysan5/raygui.git",
        depends=["raylib"],
        impl_define="RAYGUI_IMPLEMENTATION",
    ),
    _e("gsl", "GNU Scientific Library", ["gsl/gsl_sf.h"], ["gsl", "gslcblas"], pkg_config="gsl", brew="gsl", apt="libgsl-dev", pacman="gsl", dnf="gsl-devel"),
    _e("openssl", "TLS / cryptography toolkit", ["openssl/ssl.h"], ["ssl", "crypto"], pkg_config="openssl", brew="openssl@3", apt="libssl-dev", pacman="openssl", dnf="openssl-devel", aliases=["ssl"]),
    _e("libpng", "PNG image codec", ["png.h"], ["png"], pkg_config="libpng", brew="libpng", apt="libpng-dev", pacman="libpng", dnf="libpng-devel", aliases=["png"]),
    _e("curl", "URL transfer library", ["curl/curl.h"], ["curl"], pkg_config="libcurl", brew="curl", apt="libcurl4-openssl-dev", pacman="curl", dnf="libcurl-devel", aliases=["libcurl"]),
    # ── compression / archives ────────────────────────────────────────────
    _e("brotli", "Brotli compression", ["brotli/decode.h"], ["brotlidec", "brotlienc", "brotlicommon"], pkg_config="libbrotlidec", brew="brotli", apt="libbrotli-dev", pacman="brotli", dnf="brotli-devel"),
    _e("zstd", "Zstandard compression", ["zstd.h"], ["zstd"], pkg_config="libzstd", brew="zstd", apt="libzstd-dev", pacman="zstd", dnf="libzstd-devel"),
    _e("lz4", "Extremely fast compression", ["lz4.h"], ["lz4"], pkg_config="liblz4", brew="lz4", apt="liblz4-dev", pacman="lz4", dnf="lz4-devel"),
    _e("snappy", "Fast compressor/decompressor", ["snappy-c.h"], ["snappy"], pkg_config="snappy", brew="snappy", apt="libsnappy-dev", pacman="snappy", dnf="snappy-devel"),
    _e("bzip2", "bzip2 compression", ["bzlib.h"], ["bz2"], pkg_config="bzip2", brew="bzip2", apt="libbz2-dev", pacman="bzip2", dnf="bzip2-devel", aliases=["bz2"]),
    _e("xz", "LZMA / xz compression", ["lzma.h"], ["lzma"], pkg_config="liblzma", brew="xz", apt="liblzma-dev", pacman="xz", dnf="xz-devel", aliases=["lzma", "liblzma"]),
    _e("libarchive", "Multi-format archive library", ["archive.h"], ["archive"], pkg_config="libarchive", brew="libarchive", apt="libarchive-dev", pacman="libarchive", dnf="libarchive-devel", aliases=["archive"]),
    _e("lzo", "LZO real-time compression", ["lzo/lzo1x.h"], ["lzo2"], pkg_config="lzo2", brew="lzo", apt="liblzo2-dev", pacman="lzo", dnf="lzo-devel"),
    # ── crypto / security ─────────────────────────────────────────────────
    _e("libsodium", "Modern easy-to-use crypto library", ["sodium.h"], ["sodium"], pkg_config="libsodium", brew="libsodium", apt="libsodium-dev", pacman="libsodium", dnf="libsodium-devel", aliases=["sodium"]),
    _e("mbedtls", "TLS and crypto (Apache / Arm)", ["mbedtls/ssl.h"], ["mbedtls", "mbedx509", "mbedcrypto"], pkg_config="mbedtls", brew="mbedtls", apt="libmbedtls-dev", pacman="mbedtls", dnf="mbedtls-devel"),
    _e("gnutls", "GNU TLS library", ["gnutls/gnutls.h"], ["gnutls"], pkg_config="gnutls", brew="gnutls", apt="libgnutls28-dev", pacman="gnutls", dnf="gnutls-devel"),
    _e("nettle", "Low-level crypto library", ["nettle/aes.h"], ["nettle", "hogweed"], pkg_config="nettle", brew="nettle", apt="nettle-dev", pacman="nettle", dnf="nettle-devel"),
    _e("libgcrypt", "GNU crypto library", ["gcrypt.h"], ["gcrypt"], pkg_config="libgcrypt", brew="libgcrypt", apt="libgcrypt20-dev", pacman="libgcrypt", dnf="libgcrypt-devel", aliases=["gcrypt"]),
    _e("libssh2", "SSH2 client library", ["libssh2.h"], ["ssh2"], pkg_config="libssh2", brew="libssh2", apt="libssh2-1-dev", pacman="libssh2", dnf="libssh2-devel", aliases=["ssh2"]),
    _e("libssh", "SSH client/server library", ["libssh/libssh.h"], ["ssh"], pkg_config="libssh", brew="libssh", apt="libssh-dev", pacman="libssh", dnf="libssh-devel"),
    _e("argon2", "Argon2 password hashing", ["argon2.h"], ["argon2"], pkg_config="libargon2", brew="argon2", apt="libargon2-dev", pacman="argon2", dnf="argon2-devel"),
    _e("secp256k1", "Optimized ECDSA / secp256k1", ["secp256k1.h"], ["secp256k1"], pkg_config="libsecp256k1", brew="secp256k1", apt="libsecp256k1-dev", pacman="libsecp256k1", dnf="libsecp256k1-devel"),
    _e("gmp", "GNU multiple precision arithmetic", ["gmp.h"], ["gmp"], pkg_config="gmp", brew="gmp", apt="libgmp-dev", pacman="gmp", dnf="gmp-devel"),
    _e("mpfr", "Multiple-precision floating-point", ["mpfr.h"], ["mpfr"], pkg_config="mpfr", brew="mpfr", apt="libmpfr-dev", pacman="mpfr", dnf="mpfr-devel", depends=["gmp"]),
    _e("mpc", "Complex floating-point (GNU MPC)", ["mpc.h"], ["mpc"], pkg_config="mpc", brew="libmpc", apt="libmpc-dev", pacman="mpc", dnf="libmpc-devel", depends=["mpfr", "gmp"]),
    # ── networking / async I/O ────────────────────────────────────────────
    _e("libuv", "Cross-platform async I/O", ["uv.h"], ["uv"], pkg_config="libuv", brew="libuv", apt="libuv1-dev", pacman="libuv", dnf="libuv-devel", aliases=["uv"]),
    _e("libevent", "Event notification library", ["event2/event.h"], ["event"], pkg_config="libevent", brew="libevent", apt="libevent-dev", pacman="libevent", dnf="libevent-devel"),
    _e("nghttp2", "HTTP/2 C library", ["nghttp2/nghttp2.h"], ["nghttp2"], pkg_config="libnghttp2", brew="libnghttp2", apt="libnghttp2-dev", pacman="nghttp2", dnf="libnghttp2-devel"),
    _e("nghttp3", "HTTP/3 C library", ["nghttp3/nghttp3.h"], ["nghttp3"], pkg_config="libnghttp3", brew="libnghttp3", apt="libnghttp3-dev", pacman="nghttp3", dnf="libnghttp3-devel"),
    _e("c-ares", "Async DNS resolver", ["ares.h"], ["cares"], pkg_config="libcares", brew="c-ares", apt="libc-ares-dev", pacman="c-ares", dnf="c-ares-devel", aliases=["cares"]),
    _e("libwebsockets", "Lightweight WebSocket library", ["libwebsockets.h"], ["websockets"], pkg_config="libwebsockets", brew="libwebsockets", apt="libwebsockets-dev", pacman="libwebsockets", dnf="libwebsockets-devel", aliases=["websockets"]),
    _e("zeromq", "High-performance messaging (ØMQ)", ["zmq.h"], ["zmq"], pkg_config="libzmq", brew="zeromq", apt="libzmq3-dev", pacman="zeromq", dnf="zeromq-devel", aliases=["zmq", "libzmq"]),
    _e("nng", "Nanomsg-next-generation messaging", ["nng/nng.h"], ["nng"], pkg_config="nng", brew="nng", apt="libnng-dev", pacman="nng", dnf="nng-devel"),
    _e("librdkafka", "Apache Kafka C client", ["librdkafka/rdkafka.h"], ["rdkafka"], pkg_config="rdkafka", brew="librdkafka", apt="librdkafka-dev", pacman="librdkafka", dnf="librdkafka-devel", aliases=["rdkafka"]),
    _e("hiredis", "Minimal Redis C client", ["hiredis/hiredis.h"], ["hiredis"], pkg_config="hiredis", brew="hiredis", apt="libhiredis-dev", pacman="hiredis", dnf="hiredis-devel"),
    _e("libmicrohttpd", "Small embeddable HTTP server", ["microhttpd.h"], ["microhttpd"], pkg_config="libmicrohttpd", brew="libmicrohttpd", apt="libmicrohttpd-dev", pacman="libmicrohttpd", dnf="libmicrohttpd-devel", aliases=["microhttpd"]),
    _e("libidn2", "Internationalized domain names", ["idn2.h"], ["idn2"], pkg_config="libidn2", brew="libidn2", apt="libidn2-dev", pacman="libidn2", dnf="libidn2-devel"),
    _e("libpsl", "Public Suffix List library", ["libpsl.h"], ["psl"], pkg_config="libpsl", brew="libpsl", apt="libpsl-dev", pacman="libpsl", dnf="libpsl-devel"),
    _e("libnice", "ICE / connectivity (WebRTC)", ["nice/agent.h"], ["nice"], pkg_config="nice", brew="libnice", apt="libnice-dev", pacman="libnice", dnf="libnice-devel"),
    _e("libsrtp", "Secure RTP (WebRTC)", ["srtp2/srtp.h"], ["srtp2"], pkg_config="libsrtp2", brew="srtp", apt="libsrtp2-dev", pacman="libsrtp", dnf="libsrtp-devel"),
    _e("protobuf-c", "Protocol Buffers C runtime", ["protobuf-c/protobuf-c.h"], ["protobuf-c"], pkg_config="libprotobuf-c", brew="protobuf-c", apt="libprotobuf-c-dev", pacman="protobuf-c", dnf="protobuf-c-devel"),
    _e("paho-mqtt", "Eclipse Paho MQTT C client", ["MQTTClient.h"], ["paho-mqtt3c"], pkg_config="libpaho-mqtt3c", brew="libpaho-mqtt", apt="libpaho-mqtt-dev", pacman="libpaho-mqtt-c", dnf="paho-c-devel", aliases=["mqtt", "paho"]),
    _e("libmodbus", "Modbus protocol library", ["modbus/modbus.h"], ["modbus"], pkg_config="libmodbus", brew="libmodbus", apt="libmodbus-dev", pacman="libmodbus", dnf="libmodbus-devel"),
    _e("llhttp", "HTTP parser from Node.js", ["llhttp.h"], ["llhttp"], pkg_config="libllhttp", brew="llhttp", apt="libllhttp-dev", pacman="llhttp", dnf="llhttp-devel"),
    _e("uriparser", "Strict URI parse/resolve/escape", ["uriparser/Uri.h"], ["uriparser"], pkg_config="liburiparser", brew="uriparser", apt="liburiparser-dev", pacman="uriparser", dnf="uriparser-devel"),
    # ── databases / storage ───────────────────────────────────────────────
    _e("libpq", "PostgreSQL client library", ["libpq-fe.h"], ["pq"], pkg_config="libpq", brew="libpq", apt="libpq-dev", pacman="postgresql-libs", dnf="libpq-devel", aliases=["postgresql", "pq"]),
    _e("mariadb", "MariaDB / MySQL client library", ["mysql.h"], ["mariadb"], pkg_config="libmariadb", brew="mariadb-connector-c", apt="libmariadb-dev", pacman="mariadb-libs", dnf="mariadb-connector-c-devel", aliases=["mysql", "libmariadb"]),
    _e("unixodbc", "ODBC driver manager", ["sql.h"], ["odbc"], pkg_config="odbc", brew="unixodbc", apt="unixodbc-dev", pacman="unixodbc", dnf="unixODBC-devel", aliases=["odbc"]),
    _e("lmdb", "Lightning Memory-Mapped Database", ["lmdb.h"], ["lmdb"], pkg_config="lmdb", brew="lmdb", apt="liblmdb-dev", pacman="lmdb", dnf="lmdb-devel"),
    _e("leveldb", "Fast key-value store (Google)", ["leveldb/c.h"], ["leveldb"], pkg_config="leveldb", brew="leveldb", apt="libleveldb-dev", pacman="leveldb", dnf="leveldb-devel"),
    # ── parsing / data formats ────────────────────────────────────────────
    _e("libxml2", "XML parser and toolkit", ["libxml/parser.h"], ["xml2"], pkg_config="libxml-2.0", brew="libxml2", apt="libxml2-dev", pacman="libxml2", dnf="libxml2-devel", aliases=["xml2"]),
    _e("libxslt", "XSLT processor (with libxml2)", ["libxslt/xslt.h"], ["xslt"], pkg_config="libxslt", brew="libxslt", apt="libxslt1-dev", pacman="libxslt", dnf="libxslt-devel", depends=["libxml2"]),
    _e("expat", "Stream-oriented XML parser", ["expat.h"], ["expat"], pkg_config="expat", brew="expat", apt="libexpat1-dev", pacman="expat", dnf="expat-devel"),
    _e("jansson", "C library for JSON", ["jansson.h"], ["jansson"], pkg_config="jansson", brew="jansson", apt="libjansson-dev", pacman="jansson", dnf="jansson-devel"),
    _e("cjson", "Ultralightweight JSON parser", ["cjson/cJSON.h"], ["cjson"], pkg_config="libcjson", brew="cjson", apt="libcjson-dev", pacman="cjson", dnf="cjson-devel", aliases=["cJSON"]),
    _e("libyaml", "YAML 1.1 parser/emitter", ["yaml.h"], ["yaml"], pkg_config="yaml-0.1", brew="libyaml", apt="libyaml-dev", pacman="libyaml", dnf="libyaml-devel", aliases=["yaml"]),
    _e("msgpack", "MessagePack C library", ["msgpack.h"], ["msgpackc"], pkg_config="msgpack", brew="msgpack", apt="libmsgpack-dev", pacman="msgpack-c", dnf="msgpack-devel"),
    _e("tidy-html5", "HTML tidy / corrector", ["tidy.h"], ["tidy"], pkg_config="tidy", brew="tidy-html5", apt="libtidy-dev", pacman="tidy", dnf="libtidy-devel", aliases=["tidy"]),
    _e("gumbo", "HTML5 parsing library (Google)", ["gumbo.h"], ["gumbo"], pkg_config="gumbo", brew="gumbo-parser", apt="libgumbo-dev", pacman="gumbo-parser", dnf="gumbo-parser-devel"),
    # ── images ────────────────────────────────────────────────────────────
    _e("libjpeg-turbo", "SIMD-accelerated JPEG", ["jpeglib.h"], ["jpeg"], pkg_config="libjpeg", brew="jpeg-turbo", apt="libjpeg-turbo8-dev", pacman="libjpeg-turbo", dnf="libjpeg-turbo-devel", aliases=["jpeg", "libjpeg"], force_include=["stdio.h"]),
    _e("libtiff", "TIFF image library", ["tiffio.h"], ["tiff"], pkg_config="libtiff-4", brew="libtiff", apt="libtiff-dev", pacman="libtiff", dnf="libtiff-devel", aliases=["tiff"]),
    _e("libwebp", "WebP image codec", ["webp/decode.h"], ["webp"], pkg_config="libwebp", brew="webp", apt="libwebp-dev", pacman="libwebp", dnf="libwebp-devel", aliases=["webp"]),
    _e("giflib", "GIF image library", ["gif_lib.h"], ["gif"], pkg_config="libgif", brew="giflib", apt="libgif-dev", pacman="giflib", dnf="giflib-devel"),
    _e("openjpeg", "JPEG 2000 codec", ["openjpeg.h"], ["openjp2"], pkg_config="libopenjp2", brew="openjpeg", apt="libopenjp2-7-dev", pacman="openjpeg2", dnf="openjpeg2-devel"),
    _e("lcms2", "Little CMS color management", ["lcms2.h"], ["lcms2"], pkg_config="lcms2", brew="little-cms2", apt="liblcms2-dev", pacman="lcms2", dnf="lcms2-devel"),
    _e("aom", "AV1 codec library", ["aom/aom.h"], ["aom"], pkg_config="aom", brew="aom", apt="libaom-dev", pacman="aom", dnf="libaom-devel"),
    _e("dav1d", "Fast AV1 decoder", ["dav1d/dav1d.h"], ["dav1d"], pkg_config="dav1d", brew="dav1d", apt="libdav1d-dev", pacman="dav1d", dnf="dav1d-devel"),
    _e("libheif", "HEIF / AVIF codec", ["libheif/heif.h"], ["heif"], pkg_config="libheif", brew="libheif", apt="libheif-dev", pacman="libheif", dnf="libheif-devel"),
    _e("vips", "Fast image processing (libvips)", ["vips/vips.h"], ["vips"], pkg_config="vips", brew="vips", apt="libvips-dev", pacman="libvips", dnf="vips-devel"),
    _e("imagemagick", "ImageMagick MagickWand API", ["MagickWand/MagickWand.h"], ["MagickWand", "MagickCore"], pkg_config="MagickWand", brew="imagemagick", apt="libmagickwand-dev", pacman="imagemagick", dnf="ImageMagick-devel", aliases=["magickwand"]),
    _e("freeimage", "Multi-format image support", ["FreeImage.h"], ["freeimage"], pkg_config="freeimage", brew="freeimage", apt="libfreeimage-dev", pacman="freeimage", dnf="freeimage-devel"),
    # ── audio ─────────────────────────────────────────────────────────────
    _e("portaudio", "Cross-platform audio I/O", ["portaudio.h"], ["portaudio"], pkg_config="portaudio-2.0", brew="portaudio", apt="portaudio19-dev", pacman="portaudio", dnf="portaudio-devel"),
    _e("openal-soft", "OpenAL 3D audio", ["AL/al.h"], ["openal"], pkg_config="openal", brew="openal-soft", apt="libopenal-dev", pacman="openal", dnf="openal-soft-devel", aliases=["openal"]),
    _e("libsndfile", "Audio file read/write", ["sndfile.h"], ["sndfile"], pkg_config="sndfile", brew="libsndfile", apt="libsndfile1-dev", pacman="libsndfile", dnf="libsndfile-devel"),
    _e("libogg", "Ogg bitstream library", ["ogg/ogg.h"], ["ogg"], pkg_config="ogg", brew="libogg", apt="libogg-dev", pacman="libogg", dnf="libogg-devel"),
    _e("libvorbis", "Vorbis audio codec", ["vorbis/codec.h"], ["vorbis", "vorbisenc", "vorbisfile"], pkg_config="vorbis", brew="libvorbis", apt="libvorbis-dev", pacman="libvorbis", dnf="libvorbis-devel", depends=["libogg"]),
    _e("flac", "Free Lossless Audio Codec", ["FLAC/stream_decoder.h"], ["FLAC"], pkg_config="flac", brew="flac", apt="libflac-dev", pacman="flac", dnf="flac-devel"),
    _e("opus", "Opus interactive audio codec", ["opus/opus.h"], ["opus"], pkg_config="opus", brew="opus", apt="libopus-dev", pacman="opus", dnf="opus-devel"),
    _e("opusfile", "High-level Opus decoding", ["opus/opusfile.h"], ["opusfile"], pkg_config="opusfile", brew="opusfile", apt="libopusfile-dev", pacman="opusfile", dnf="opusfile-devel", depends=["opus", "libogg"]),
    _e("mpg123", "MPEG audio decoder", ["mpg123.h"], ["mpg123"], pkg_config="libmpg123", brew="mpg123", apt="libmpg123-dev", pacman="mpg123", dnf="mpg123-devel"),
    _e("lame", "LAME MP3 encoder", ["lame/lame.h"], ["mp3lame"], pkg_config="lame", brew="lame", apt="libmp3lame-dev", pacman="lame", dnf="lame-devel"),
    # ── video / codecs ────────────────────────────────────────────────────
    _e("ffmpeg", "FFmpeg multimedia libraries", ["libavformat/avformat.h"], ["avformat", "avcodec", "avutil", "swscale", "swresample"], pkg_config="libavformat", brew="ffmpeg", apt="libavformat-dev", pacman="ffmpeg", dnf="ffmpeg-devel"),
    _e("x264", "H.264 / AVC encoder", ["x264.h"], ["x264"], pkg_config="x264", brew="x264", apt="libx264-dev", pacman="x264", dnf="x264-devel", force_include=["stdint.h"]),
    _e("x265", "H.265 / HEVC encoder", ["x265.h"], ["x265"], pkg_config="x265", brew="x265", apt="libx265-dev", pacman="x265", dnf="x265-devel"),
    _e("libvpx", "VP8 / VP9 codec", ["vpx/vpx_encoder.h"], ["vpx"], pkg_config="vpx", brew="libvpx", apt="libvpx-dev", pacman="libvpx", dnf="libvpx-devel"),
    # ── games / graphics ──────────────────────────────────────────────────
    _e("glfw", "OpenGL / Vulkan windowing", ["GLFW/glfw3.h"], ["glfw"], pkg_config="glfw3", brew="glfw", apt="libglfw3-dev", pacman="glfw", dnf="glfw-devel", aliases=["glfw3"]),
    _e("glew", "OpenGL Extension Wrangler", ["GL/glew.h"], ["GLEW"], pkg_config="glew", brew="glew", apt="libglew-dev", pacman="glew", dnf="glew-devel"),
    _e("freeglut", "OpenGL Utility Toolkit (free)", ["GL/freeglut.h"], ["glut"], pkg_config="glut", brew="freeglut", apt="freeglut3-dev", pacman="freeglut", dnf="freeglut-devel", aliases=["glut"]),
    _e("sdl2_image", "SDL2 image loading", ["SDL2/SDL_image.h"], ["SDL2_image"], pkg_config="SDL2_image", brew="sdl2_image", apt="libsdl2-image-dev", pacman="sdl2_image", dnf="SDL2_image-devel", depends=["sdl2"]),
    _e("sdl2_mixer", "SDL2 audio mixing", ["SDL2/SDL_mixer.h"], ["SDL2_mixer"], pkg_config="SDL2_mixer", brew="sdl2_mixer", apt="libsdl2-mixer-dev", pacman="sdl2_mixer", dnf="SDL2_mixer-devel", depends=["sdl2"]),
    _e("sdl2_ttf", "SDL2 TrueType fonts", ["SDL2/SDL_ttf.h"], ["SDL2_ttf"], pkg_config="SDL2_ttf", brew="sdl2_ttf", apt="libsdl2-ttf-dev", pacman="sdl2_ttf", dnf="SDL2_ttf-devel", depends=["sdl2"]),
    _e("sdl2_net", "SDL2 networking", ["SDL2/SDL_net.h"], ["SDL2_net"], pkg_config="SDL2_net", brew="sdl2_net", apt="libsdl2-net-dev", pacman="sdl2_net", dnf="SDL2_net-devel", depends=["sdl2"]),
    _e("allegro", "Allegro game programming library", ["allegro5/allegro.h"], ["allegro"], pkg_config="allegro-5", brew="allegro", apt="liballegro5-dev", pacman="allegro", dnf="allegro5-devel"),
    _e("physfs", "PhysicsFS virtual filesystem", ["physfs.h"], ["physfs"], pkg_config="physfs", brew="physfs", apt="libphysfs-dev", pacman="physfs", dnf="physfs-devel"),
    _e("enet", "Reliable UDP networking for games", ["enet/enet.h"], ["enet"], pkg_config="libenet", brew="enet", apt="libenet-dev", pacman="enet", dnf="enet-devel"),
    _e("box2d", "2D physics engine", ["box2d/box2d.h"], ["box2d"], pkg_config="box2d", brew="box2d", apt="libbox2d-dev", pacman="box2d", dnf="box2d-devel"),
    _e("chipmunk", "2D rigid body physics", ["chipmunk/chipmunk.h"], ["chipmunk"], pkg_config="chipmunk", brew="chipmunk-physics", apt="libchipmunk-dev", pacman="chipmunk", dnf="Chipmunk-devel"),
    _e("assimp", "Open Asset Import Library (C API)", ["assimp/cimport.h"], ["assimp"], pkg_config="assimp", brew="assimp", apt="libassimp-dev", pacman="assimp", dnf="assimp-devel"),
    # ── GUI / desktop ─────────────────────────────────────────────────────
    _e("gtk3", "GTK 3 widget toolkit", ["gtk/gtk.h"], ["gtk-3"], pkg_config="gtk+-3.0", brew="gtk+3", apt="libgtk-3-dev", pacman="gtk3", dnf="gtk3-devel", aliases=["gtk+3"]),
    _e("gtk4", "GTK 4 widget toolkit", ["gtk/gtk.h"], ["gtk-4"], pkg_config="gtk4", brew="gtk4", apt="libgtk-4-dev", pacman="gtk4", dnf="gtk4-devel"),
    _e("cairo", "2D vector graphics", ["cairo/cairo.h"], ["cairo"], pkg_config="cairo", brew="cairo", apt="libcairo2-dev", pacman="cairo", dnf="cairo-devel"),
    _e("pango", "Text layout / rendering", ["pango/pango.h"], ["pango-1.0"], pkg_config="pango", brew="pango", apt="libpango1.0-dev", pacman="pango", dnf="pango-devel"),
    _e("gdk-pixbuf", "Image loading for GDK", ["gdk-pixbuf/gdk-pixbuf.h"], ["gdk_pixbuf-2.0"], pkg_config="gdk-pixbuf-2.0", brew="gdk-pixbuf", apt="libgdk-pixbuf-2.0-dev", pacman="gdk-pixbuf2", dnf="gdk-pixbuf2-devel"),
    _e("glib", "GLib core utility library", ["glib.h"], ["glib-2.0", "gobject-2.0"], pkg_config="glib-2.0", brew="glib", apt="libglib2.0-dev", pacman="glib2", dnf="glib2-devel"),
    _e("harfbuzz", "Text shaping engine", ["harfbuzz/hb.h"], ["harfbuzz"], pkg_config="harfbuzz", brew="harfbuzz", apt="libharfbuzz-dev", pacman="harfbuzz", dnf="harfbuzz-devel"),
    _e("freetype", "Font rasterization", ["freetype/freetype.h"], ["freetype"], pkg_config="freetype2", brew="freetype", apt="libfreetype6-dev", pacman="freetype2", dnf="freetype-devel"),
    _e("fontconfig", "Font configuration / matching", ["fontconfig/fontconfig.h"], ["fontconfig"], pkg_config="fontconfig", brew="fontconfig", apt="libfontconfig-dev", pacman="fontconfig", dnf="fontconfig-devel"),
    _e("ncurses", "Terminal UI library", ["ncurses.h"], ["ncurses"], pkg_config="ncurses", brew="ncurses", apt="libncurses-dev", pacman="ncurses", dnf="ncurses-devel"),
    _e("wayland", "Wayland client library", ["wayland-client.h"], ["wayland-client"], pkg_config="wayland-client", brew="wayland", apt="libwayland-dev", pacman="wayland", dnf="wayland-devel", platforms=["linux"]),
    _e("libx11", "X11 client library", ["X11/Xlib.h"], ["X11"], pkg_config="x11", brew="libx11", apt="libx11-dev", pacman="libx11", dnf="libX11-devel", aliases=["x11"]),
    _e("libxcb", "X protocol C-language Binding", ["xcb/xcb.h"], ["xcb"], pkg_config="xcb", brew="libxcb", apt="libxcb1-dev", pacman="libxcb", dnf="libxcb-devel"),
    # ── text / regex / FFI ────────────────────────────────────────────────
    _e("icu", "International Components for Unicode", ["unicode/ustring.h"], ["icuuc", "icui18n", "icudata"], pkg_config="icu-uc", brew="icu4c@78", apt="libicu-dev", pacman="icu", dnf="libicu-devel", aliases=["icu4c"]),
    _e("pcre2", "Perl-compatible regular expressions", ["pcre2.h"], ["pcre2-8"], pkg_config="libpcre2-8", brew="pcre2", apt="libpcre2-dev", pacman="pcre2", dnf="pcre2-devel", defines=["PCRE2_CODE_UNIT_WIDTH=8"]),
    _e("oniguruma", "Modern regular expression library", ["oniguruma.h"], ["onig"], pkg_config="oniguruma", brew="oniguruma", apt="libonig-dev", pacman="oniguruma", dnf="oniguruma-devel"),
    _e("readline", "GNU readline line editing", ["readline/readline.h"], ["readline"], pkg_config="readline", brew="readline", apt="libreadline-dev", pacman="readline", dnf="readline-devel", force_include=["stdio.h"]),
    _e("libedit", "BSD editline (readline-compatible)", ["histedit.h"], ["edit"], pkg_config="libedit", brew="libedit", apt="libedit-dev", pacman="libedit", dnf="libedit-devel"),
    _e("libffi", "Foreign Function Interface", ["ffi.h"], ["ffi"], pkg_config="libffi", brew="libffi", apt="libffi-dev", pacman="libffi", dnf="libffi-devel"),
    # ── science / numerics / geo ──────────────────────────────────────────
    _e("fftw", "Fast Fourier Transforms", ["fftw3.h"], ["fftw3"], pkg_config="fftw3", brew="fftw", apt="libfftw3-dev", pacman="fftw", dnf="fftw-devel"),
    _e("openblas", "Optimized BLAS", ["cblas.h"], ["openblas"], pkg_config="openblas", brew="openblas", apt="libopenblas-dev", pacman="openblas", dnf="openblas-devel"),
    _e("lapack", "Linear Algebra PACKage", ["lapack.h"], ["lapack"], pkg_config="lapack", brew="lapack", apt="liblapack-dev", pacman="lapack", dnf="lapack-devel"),
    _e("hdf5", "Hierarchical Data Format 5", ["hdf5.h"], ["hdf5"], pkg_config="hdf5", brew="hdf5", apt="libhdf5-dev", pacman="hdf5", dnf="hdf5-devel"),
    _e("netcdf", "Network Common Data Form", ["netcdf.h"], ["netcdf"], pkg_config="netcdf", brew="netcdf", apt="libnetcdf-dev", pacman="netcdf", dnf="netcdf-devel"),
    _e("cfitsio", "FITS file I/O", ["fitsio.h"], ["cfitsio"], pkg_config="cfitsio", brew="cfitsio", apt="libcfitsio-dev", pacman="cfitsio", dnf="cfitsio-devel"),
    _e("geos", "Geometry Engine Open Source", ["geos_c.h"], ["geos_c"], pkg_config="geos", brew="geos", apt="libgeos-dev", pacman="geos", dnf="geos-devel"),
    _e("proj", "Cartographic projections", ["proj.h"], ["proj"], pkg_config="proj", brew="proj", apt="libproj-dev", pacman="proj", dnf="proj-devel"),
    _e("gdal", "Geospatial Data Abstraction Library", ["gdal.h"], ["gdal"], pkg_config="gdal", brew="gdal", apt="libgdal-dev", pacman="gdal", dnf="gdal-devel"),
    _e("suitesparse", "Sparse matrix suite (UMFPACK etc.)", ["suitesparse/umfpack.h"], ["umfpack", "amd", "cholmod", "colamd", "suitesparseconfig"], pkg_config="umfpack", brew="suite-sparse", apt="libsuitesparse-dev", pacman="suitesparse", dnf="suitesparse-devel"),
    # ── system / utils ────────────────────────────────────────────────────
    _e("dbus", "D-Bus message bus library", ["dbus/dbus.h"], ["dbus-1"], pkg_config="dbus-1", brew="dbus", apt="libdbus-1-dev", pacman="dbus", dnf="dbus-devel"),
    _e("libmagic", "file(1) magic number recognition", ["magic.h"], ["magic"], pkg_config="libmagic", brew="libmagic", apt="libmagic-dev", pacman="file", dnf="file-devel", aliases=["magic"]),
    _e("uuid", "UUID generation (libuuid / OSSP)", ["uuid.h"], ["ossp-uuid"], pkg_config="ossp-uuid", brew="ossp-uuid", apt="libossp-uuid-dev", pacman="ossp-uuid", dnf="uuid-devel", aliases=["libuuid", "ossp-uuid"]),
    _e("jemalloc", "General-purpose malloc implementation", ["jemalloc/jemalloc.h"], ["jemalloc"], pkg_config="jemalloc", brew="jemalloc", apt="libjemalloc-dev", pacman="jemalloc", dnf="jemalloc-devel"),
    _e("libfuse", "Filesystem in Userspace", ["fuse.h"], ["fuse"], pkg_config="fuse", brew="libfuse", apt="libfuse-dev", pacman="fuse2", dnf="fuse-devel", aliases=["fuse"], platforms=["linux"]),
    _e("acl", "POSIX Access Control Lists", ["sys/acl.h"], ["acl"], pkg_config="libacl", brew="acl", apt="libacl1-dev", pacman="acl", dnf="libacl-devel", platforms=["linux"]),
    _e("libcap", "POSIX capabilities (Linux)", ["sys/capability.h"], ["cap"], pkg_config="libcap", brew="libcap", apt="libcap-dev", pacman="libcap", dnf="libcap-devel", platforms=["linux"]),
    # ── extras / popular C libs ───────────────────────────────────────────
    _e("sdl3", "Simple DirectMedia Layer 3", ["SDL3/SDL.h"], ["SDL3"], pkg_config="sdl3", brew="sdl3", apt="libsdl3-dev", pacman="sdl3", dnf="SDL3-devel"),
    _e("libgit2", "Git core methods as a library", ["git2.h"], ["git2"], pkg_config="libgit2", brew="libgit2", apt="libgit2-dev", pacman="libgit2", dnf="libgit2-devel"),
    _e("json-c", "JSON parsing library (json-c)", ["json-c/json.h"], ["json-c"], pkg_config="json-c", brew="json-c", apt="libjson-c-dev", pacman="json-c", dnf="json-c-devel"),
    _e("libbson", "BSON library (MongoDB)", ["bson/bson.h"], ["bson-1.0"], pkg_config="libbson-1.0", brew="mongo-c-driver", apt="libbson-dev", pacman="libbson", dnf="libbson-devel"),
    _e("mongoc", "MongoDB C driver", ["mongoc/mongoc.h"], ["mongoc-1.0"], pkg_config="libmongoc-1.0", brew="mongo-c-driver", apt="libmongoc-dev", pacman="mongo-c-driver", dnf="mongo-c-driver-devel", depends=["libbson"], aliases=["mongo-c-driver"]),
    _e("libusb", "USB device access", ["libusb-1.0/libusb.h"], ["usb-1.0"], pkg_config="libusb-1.0", brew="libusb", apt="libusb-1.0-0-dev", pacman="libusb", dnf="libusb1-devel"),
    _e("hidapi", "USB HID device library", ["hidapi/hidapi.h"], ["hidapi"], pkg_config="hidapi-hidraw", brew="hidapi", apt="libhidapi-dev", pacman="hidapi", dnf="hidapi-devel"),
    _e("libsamplerate", "Secret Rabbit Code audio resampler", ["samplerate.h"], ["samplerate"], pkg_config="samplerate", brew="libsamplerate", apt="libsamplerate0-dev", pacman="libsamplerate", dnf="libsamplerate-devel"),
    _e("speex", "Speex audio codec", ["speex/speex.h"], ["speex"], pkg_config="speex", brew="speex", apt="libspeex-dev", pacman="speex", dnf="speex-devel"),
    _e("theora", "Theora video codec", ["theora/theora.h"], ["theora"], pkg_config="theora", brew="theora", apt="libtheora-dev", pacman="libtheora", dnf="libtheora-devel", depends=["libogg"]),
    _e("fluidsynth", "Software SoundFont synthesizer", ["fluidsynth.h"], ["fluidsynth"], pkg_config="fluidsynth", brew="fluid-synth", apt="libfluidsynth-dev", pacman="fluidsynth", dnf="fluidsynth-devel"),
    _e("pulseaudio", "PulseAudio client library", ["pulse/simple.h"], ["pulse", "pulse-simple"], pkg_config="libpulse", brew="pulseaudio", apt="libpulse-dev", pacman="libpulse", dnf="pulseaudio-libs-devel"),
    _e("alsa-lib", "Advanced Linux Sound Architecture", ["alsa/asoundlib.h"], ["asound"], pkg_config="alsa", brew="alsa-lib", apt="libasound2-dev", pacman="alsa-lib", dnf="alsa-lib-devel", aliases=["alsa"], platforms=["linux"]),
    _e("leptonica", "Image processing / analysis", ["leptonica/allheaders.h"], ["lept"], pkg_config="lept", brew="leptonica", apt="libleptonica-dev", pacman="leptonica", dnf="leptonica-devel"),
    _e("tesseract", "OCR engine (C API)", ["tesseract/capi.h"], ["tesseract"], pkg_config="tesseract", brew="tesseract", apt="libtesseract-dev", pacman="tesseract", dnf="tesseract-devel", depends=["leptonica"]),
    _e("poppler", "PDF rendering (poppler-glib)", ["poppler/glib/poppler.h"], ["poppler-glib"], pkg_config="poppler-glib", brew="poppler", apt="libpoppler-glib-dev", pacman="poppler-glib", dnf="poppler-glib-devel"),
    _e("qhull", "Convex hull / Delaunay library", ["libqhull_r/libqhull_r.h"], ["qhull_r"], pkg_config="qhull_r", brew="qhull", apt="libqhull-dev", pacman="qhull", dnf="qhull-devel"),
    _e("minizip", "zlib zip contrib (minizip)", ["minizip/unzip.h"], ["minizip"], pkg_config="minizip", brew="minizip", apt="libminizip-dev", pacman="minizip", dnf="minizip-devel", depends=["zlib"]),
    _e("cglm", "Highly optimized C math library for graphics", ["cglm/cglm.h"], ["cglm"], pkg_config="cglm", brew="cglm", apt="libcglm-dev", pacman="cglm", dnf="cglm-devel"),
    _e(
        "nuklear",
        "Immediate-mode GUI toolkit (header-only)",
        ["nuklear.h"],
        ["m"],
        git="https://github.com/Immediate-Mode-UI/Nuklear.git",
        brew="-",
        pacman="-",
    ),
    # ── expanded: scripting / embed ───────────────────────────────────────
    _e("lua", "Lua embeddable scripting language", ["lua.h"], ["lua"], pkg_config="lua", brew="lua", apt="liblua5.4-dev", pacman="lua", dnf="lua-devel"),
    _e("luajit", "LuaJIT tracing JIT compiler", ["luajit.h"], ["luajit"], pkg_config="luajit", brew="luajit", apt="libluajit-5.1-dev", pacman="luajit", dnf="luajit-devel"),
    _e("tree-sitter", "Incremental parsing library", ["tree_sitter/api.h"], ["tree-sitter"], pkg_config="tree-sitter", brew="tree-sitter", apt="libtree-sitter-dev", pacman="tree-sitter", dnf="libtree-sitter-devel"),
    # ── expanded: more compression / hashing ──────────────────────────────
    _e("libdeflate", "Fast DEFLATE compressor", ["libdeflate.h"], ["deflate"], pkg_config="libdeflate", brew="libdeflate", apt="libdeflate-dev", pacman="libdeflate", dnf="libdeflate-devel"),
    _e("xxhash", "Extremely fast hash algorithm", ["xxhash.h"], ["xxhash"], pkg_config="libxxhash", brew="xxhash", apt="libxxhash-dev", pacman="xxhash", dnf="xxhash-devel"),
    _e("blake3", "BLAKE3 cryptographic hash", ["blake3.h"], ["blake3"], pkg_config="libblake3", brew="blake3", apt="libblake3-dev", pacman="blake3", dnf="blake3-devel"),
    # ── expanded: networking / RPC ────────────────────────────────────────
    _e("libsoup", "HTTP client/server library (GNOME)", ["libsoup/soup.h"], ["soup-3.0"], pkg_config="libsoup-3.0", brew="libsoup", apt="libsoup-3.0-dev", pacman="libsoup3", dnf="libsoup3-devel"),
    _e("wolfssl", "Portable SSL/TLS library", ["wolfssl/ssl.h"], ["wolfssl"], pkg_config="wolfssl", brew="wolfssl", apt="libwolfssl-dev", pacman="wolfssl", dnf="wolfssl-devel"),
    _e("libcoap", "Constrained Application Protocol", ["coap3/coap.h"], ["coap-3"], pkg_config="libcoap-3", brew="libcoap", apt="libcoap3-dev", pacman="libcoap", dnf="libcoap-devel"),
    _e("czmq", "High-level C binding for ZeroMQ", ["czmq.h"], ["czmq"], pkg_config="libczmq", brew="czmq", apt="libczmq-dev", pacman="czmq", dnf="czmq-devel", depends=["zeromq"]),
    _e("libnet", "Packet construction / injection", ["libnet.h"], ["net"], pkg_config="libnet", brew="libnet", apt="libnet1-dev", pacman="libnet", dnf="libnet-devel"),
    _e("libpcap", "Packet capture library", ["pcap.h"], ["pcap"], pkg_config="libpcap", brew="libpcap", apt="libpcap-dev", pacman="libpcap", dnf="libpcap-devel"),
    # ── expanded: databases / caches ──────────────────────────────────────
    _e("rocksdb", "RocksDB (C API)", ["rocksdb/c.h"], ["rocksdb"], pkg_config="rocksdb", brew="rocksdb", apt="librocksdb-dev", pacman="rocksdb", dnf="rocksdb-devel"),
    _e("libmemcached", "Memcached client library", ["libmemcached/memcached.h"], ["memcached"], pkg_config="libmemcached", brew="libmemcached", apt="libmemcached-dev", pacman="libmemcached", dnf="libmemcached-devel"),
    _e("tokyocabinet", "Tokyo Cabinet DBM", ["tcutil.h"], ["tokyocabinet"], pkg_config="tokyocabinet", brew="tokyo-cabinet", apt="libtokyocabinet-dev", pacman="tokyocabinet", dnf="tokyocabinet-devel"),
    # ── expanded: serialization / schema ──────────────────────────────────
    _e("yyjson", "High-performance JSON library", ["yyjson.h"], ["yyjson"], pkg_config="yyjson", brew="yyjson", apt="libyyjson-dev", pacman="yyjson", dnf="yyjson-devel"),
    _e("libavro", "Apache Avro C library", ["avro.h"], ["avro"], pkg_config="avro-c", brew="avro-c", apt="libavro-dev", pacman="avro-c", dnf="avro-c-devel"),
    _e("libcsv", "CSV parser library", ["csv.h"], ["csv"], pkg_config="libcsv", brew="libcsv", apt="libcsv-dev", pacman="libcsv", dnf="libcsv-devel"),
    # ── expanded: graphics / GPU ──────────────────────────────────────────
    _e("vulkan-loader", "Vulkan ICD loader", ["vulkan/vulkan.h"], ["vulkan"], pkg_config="vulkan", brew="vulkan-loader", apt="libvulkan-dev", pacman="vulkan-icd-loader", dnf="vulkan-loader", depends=["vulkan-headers"]),
    _e("vulkan-headers", "Vulkan API headers", ["vulkan/vulkan.h"], ["vulkan"], brew="vulkan-headers", apt="libvulkan-dev", pacman="vulkan-headers", dnf="vulkan-headers"),
    _e("sdl3_image", "SDL3 image loading", ["SDL3_image/SDL_image.h"], ["SDL3_image"], pkg_config="sdl3-image", brew="sdl3_image", apt="libsdl3-image-dev", pacman="sdl3_image", dnf="SDL3_image-devel", depends=["sdl3"]),
    _e("sdl3_ttf", "SDL3 TrueType fonts", ["SDL3_ttf/SDL_ttf.h"], ["SDL3_ttf"], pkg_config="sdl3-ttf", brew="sdl3_ttf", apt="libsdl3-ttf-dev", pacman="sdl3_ttf", dnf="SDL3_ttf-devel", depends=["sdl3"]),
    _e("sokol", "Minimal cross-platform libraries (headers)", ["sokol_gfx.h"], ["m"], git="https://github.com/floooh/sokol.git", brew="-"),
    # ── expanded: audio / MIDI ────────────────────────────────────────────
    _e("jack", "JACK Audio Connection Kit", ["jack/jack.h"], ["jack"], pkg_config="jack", brew="jack", apt="libjack-dev", pacman="jack", dnf="jack-audio-connection-kit-devel"),
    _e("rtaudio", "Realtime audio I/O", ["rtaudio/RtAudio.h"], ["rtaudio"], pkg_config="rtaudio", brew="rtaudio", apt="librtaudio-dev", pacman="rtaudio", dnf="rtaudio-devel"),
    _e("rtmidi", "Realtime MIDI I/O", ["rtmidi/RtMidi.h"], ["rtmidi"], pkg_config="rtmidi", brew="rtmidi", apt="librtmidi-dev", pacman="rtmidi", dnf="rtmidi-devel"),
    _e("chromaprint", "Audio fingerprinting", ["chromaprint.h"], ["chromaprint"], pkg_config="libchromaprint", brew="chromaprint", apt="libchromaprint-dev", pacman="chromaprint", dnf="libchromaprint-devel"),
    _e("libsoxr", "High quality sample-rate conversion", ["soxr.h"], ["soxr"], pkg_config="soxr", brew="libsoxr", apt="libsoxr-dev", pacman="libsoxr", dnf="soxr-devel"),
    # ── expanded: images / docs ───────────────────────────────────────────
    _e("jpeg-xl", "JPEG XL codec", ["jxl/decode.h"], ["jxl"], pkg_config="libjxl", brew="jpeg-xl", apt="libjxl-dev", pacman="libjxl", dnf="libjxl-devel"),
    _e("libraw", "RAW image processing", ["libraw/libraw.h"], ["raw"], pkg_config="libraw", brew="libraw", apt="libraw-dev", pacman="libraw", dnf="LibRaw-devel"),
    _e("djvulibre", "DjVu document library", ["libdjvu/ddjvuapi.h"], ["djvulibre"], pkg_config="ddjvuapi", brew="djvulibre", apt="libdjvulibre-dev", pacman="djvulibre", dnf="djvulibre-devel"),
    _e("mupdf", "MuPDF lightweight PDF engine", ["mupdf/fitz.h"], ["mupdf"], pkg_config="mupdf", brew="mupdf", apt="libmupdf-dev", pacman="mupdf", dnf="mupdf-devel"),
    # ── expanded: science / numerics ──────────────────────────────────────
    _e("nlopt", "Nonlinear optimization library", ["nlopt.h"], ["nlopt"], pkg_config="nlopt", brew="nlopt", apt="libnlopt-dev", pacman="nlopt", dnf="NLopt-devel"),
    _e("sundials", "SUNDIALS ODE/DAE solvers", ["sundials/sundials_types.h"], ["sundials_cvode", "sundials_nvecserial"], pkg_config="sundials_cvode", brew="sundials", apt="libsundials-dev", pacman="sundials", dnf="sundials-devel"),
    _e("glpk", "GNU Linear Programming Kit", ["glpk.h"], ["glpk"], pkg_config="glpk", brew="glpk", apt="libglpk-dev", pacman="glpk", dnf="glpk-devel"),
    _e("igraph", "Network analysis library", ["igraph/igraph.h"], ["igraph"], pkg_config="igraph", brew="igraph", apt="libigraph-dev", pacman="igraph", dnf="igraph-devel"),
    _e("flint", "Fast Library for Number Theory", ["flint/flint.h"], ["flint"], pkg_config="flint", brew="flint", apt="libflint-dev", pacman="flint", dnf="flint-devel"),
    # ── expanded: system / IPC (Linux-focused marked) ─────────────────────
    _e("libseccomp", "High-level seccomp filter interface", ["seccomp.h"], ["seccomp"], pkg_config="libseccomp", brew="libseccomp", apt="libseccomp-dev", pacman="libseccomp", dnf="libseccomp-devel", platforms=["linux"]),
    _e("systemd", "systemd / sd-bus client library", ["systemd/sd-bus.h"], ["systemd"], pkg_config="libsystemd", brew="-", apt="libsystemd-dev", pacman="systemd-libs", dnf="systemd-devel", platforms=["linux"]),
    _e("keyutils", "Linux key management utilities", ["keyutils.h"], ["keyutils"], pkg_config="libkeyutils", brew="-", apt="libkeyutils-dev", pacman="keyutils", dnf="keyutils-libs-devel", platforms=["linux"]),
    # ── expanded: more backend / utils ────────────────────────────────────
    _e("libzip", "ZIP archive library", ["zip.h"], ["zip"], pkg_config="libzip", brew="libzip", apt="libzip-dev", pacman="libzip", dnf="libzip-devel"),
    _e("minizip-ng", "ZIP library (minizip-ng)", ["minizip/zip.h"], ["minizip"], pkg_config="minizip", brew="minizip-ng", apt="libminizip-dev", pacman="minizip", dnf="minizip-ng-devel"),
    _e("http-parser", "HTTP request/response parser", ["http_parser.h"], ["http_parser"], brew="-", apt="libhttp-parser-dev", pacman="http-parser", dnf="http-parser-devel", git="https://github.com/nodejs/http-parser.git"),
    _e("ngtcp2", "QUIC protocol library", ["ngtcp2/ngtcp2.h"], ["ngtcp2"], pkg_config="libngtcp2", brew="libngtcp2", apt="libngtcp2-dev", pacman="libngtcp2", dnf="libngtcp2-devel"),
    _e("cunit", "C Unit testing framework", ["CUnit/CUnit.h"], ["cunit"], pkg_config="cunit", brew="cunit", apt="libcunit1-dev", pacman="cunit", dnf="CUnit-devel"),
    _e("check", "Unit test framework for C", ["check.h"], ["check"], pkg_config="check", brew="check", apt="check", pacman="check", dnf="check-devel"),
    _e("cmocka", "Unit testing framework for C", ["cmocka.h"], ["cmocka"], pkg_config="cmocka", brew="cmocka", apt="libcmocka-dev", pacman="cmocka", dnf="cmocka-devel"),
    _e("apr", "Apache Portable Runtime", ["apr-1/apr_general.h"], ["apr-1"], pkg_config="apr-1", brew="apr", apt="libapr1-dev", pacman="apr", dnf="apr-devel"),
    _e("apr-util", "APR utilities", ["apr-1/apr_uri.h"], ["aprutil-1"], pkg_config="apr-util-1", brew="apr-util", apt="libaprutil1-dev", pacman="apr-util", dnf="apr-util-devel", depends=["apr"]),
    _e("serd", "Lightweight RDF syntax library", ["serd/serd.h"], ["serd-0"], pkg_config="serd-0", brew="serd", apt="libserd-dev", pacman="serd", dnf="serd-devel"),
    _e("sord", "Lightweight RDF store", ["sord/sord.h"], ["sord-0"], pkg_config="sord-0", brew="sord", apt="libsord-dev", pacman="sord", dnf="sord-devel", depends=["serd"]),
    _e("lilv", "LV2 plugin library", ["lilv/lilv.h"], ["lilv-0"], pkg_config="lilv-0", brew="lilv", apt="liblilv-dev", pacman="lilv", dnf="lilv-devel"),
    _e("sratom", "LV2 Atom RDF mapping", ["sratom/sratom.h"], ["sratom-0"], pkg_config="sratom-0", brew="sratom", apt="libsratom-dev", pacman="sratom", dnf="sratom-devel"),
    _e("rubberband", "Audio time-stretching / pitch-shifting", ["rubberband/rubberband-c.h"], ["rubberband"], pkg_config="rubberband", brew="rubberband", apt="librubberband-dev", pacman="rubberband", dnf="rubberband-devel"),
    _e("liblo", "Lightweight OSC library", ["lo/lo.h"], ["lo"], pkg_config="liblo", brew="liblo", apt="liblo-dev", pacman="liblo", dnf="liblo-devel"),
    _e("portmidi", "Realtime MIDI I/O (PortMidi)", ["portmidi.h"], ["portmidi"], pkg_config="portmidi", brew="portmidi", apt="libportmidi-dev", pacman="portmidi", dnf="portmidi-devel"),
    _e("freealut", "OpenAL Utility Toolkit", ["AL/alut.h"], ["alut"], pkg_config="freealut", brew="freealut", apt="libalut-dev", pacman="freealut", dnf="freealut-devel", depends=["openal-soft"]),
    _e("ode", "Open Dynamics Engine", ["ode/ode.h"], ["ode"], pkg_config="ode", brew="ode", apt="libode-dev", pacman="ode", dnf="ode-devel"),
    _e("duktape", "Embeddable JavaScript engine", ["duktape.h"], ["duktape"], pkg_config="duktape", brew="duktape", apt="libduktape-dev", pacman="duktape", dnf="duktape-devel"),
    _e("quickjs", "Small embeddable JavaScript engine", ["quickjs.h"], ["quickjs"], brew="quickjs", apt="libquickjs-dev", pacman="quickjs", dnf="quickjs-devel"),
    _e("wren", "Small class-based scripting language", ["wren.h"], ["wren"], brew="wren", apt="libwren-dev", pacman="wren", dnf="wren-devel"),
    _e("janet", "Janet programming language C API", ["janet.h"], ["janet"], pkg_config="janet", brew="janet", apt="libjanet-dev", pacman="janet", dnf="janet-devel"),
    _e("tcl", "Tool Command Language", ["tcl.h"], ["tcl"], pkg_config="tcl", brew="tcl-tk", apt="tcl-dev", pacman="tcl", dnf="tcl-devel"),
    _e("guile", "GNU Guile Scheme", ["libguile.h"], ["guile-3.0"], pkg_config="guile-3.0", brew="guile", apt="guile-3.0-dev", pacman="guile", dnf="guile22-devel"),
    _e("libgc", "Boehm-Demers-Weiser GC", ["gc.h"], ["gc"], pkg_config="bdw-gc", brew="bdw-gc", apt="libgc-dev", pacman="gc", dnf="gc-devel", aliases=["bdw-gc"]),
    _e("mimalloc", "Microsoft mimalloc", ["mimalloc.h"], ["mimalloc"], pkg_config="mimalloc", brew="mimalloc", apt="libmimalloc-dev", pacman="mimalloc", dnf="mimalloc-devel"),
    _e("tcmalloc", "Thread-caching malloc (gperftools)", ["gperftools/tcmalloc.h"], ["tcmalloc"], brew="gperftools", apt="libgoogle-perftools-dev", pacman="gperftools", dnf="gperftools-devel"),
    _e("libunwind", "Stack unwinding library", ["libunwind.h"], ["unwind"], pkg_config="libunwind", brew="libunwind", apt="libunwind-dev", pacman="libunwind", dnf="libunwind-devel", platforms=["linux"]),
    _e("elfutils", "ELF parsing (libelf)", ["libelf.h"], ["elf"], pkg_config="libelf", brew="elfutils", apt="libelf-dev", pacman="libelf", dnf="elfutils-libelf-devel", platforms=["linux"]),
    _e("capstone", "Disassembly framework", ["capstone/capstone.h"], ["capstone"], pkg_config="capstone", brew="capstone", apt="libcapstone-dev", pacman="capstone", dnf="capstone-devel"),
    _e("keystone", "Assembler framework", ["keystone/keystone.h"], ["keystone"], pkg_config="keystone", brew="keystone", apt="libkeystone-dev", pacman="keystone", dnf="keystone-devel"),
    _e("unicorn", "CPU emulator framework", ["unicorn/unicorn.h"], ["unicorn"], pkg_config="unicorn", brew="unicorn", apt="libunicorn-dev", pacman="unicorn", dnf="unicorn-devel"),
    _e("zydis", "Fast x86/x86-64 disassembler", ["Zydis/Zydis.h"], ["Zydis"], pkg_config="zydis", brew="zydis", apt="libzydis-dev", pacman="zydis", dnf="zydis-devel"),
    _e("yara", "Malware identification pattern matching", ["yara.h"], ["yara"], pkg_config="yara", brew="yara", apt="libyara-dev", pacman="yara", dnf="yara-devel"),
    _e("clamav", "ClamAV antivirus engine", ["clamav.h"], ["clamav"], pkg_config="libclamav", brew="clamav", apt="libclamav-dev", pacman="clamav", dnf="clamav-devel"),
    _e("libmaxminddb", "MaxMind DB reader", ["maxminddb.h"], ["maxminddb"], pkg_config="libmaxminddb", brew="libmaxminddb", apt="libmaxminddb-dev", pacman="libmaxminddb", dnf="libmaxminddb-devel"),
    _e("librsync", "rsync remote-delta algorithm", ["librsync.h"], ["rsync"], pkg_config="librsync", brew="librsync", apt="librsync-dev", pacman="librsync", dnf="librsync-devel"),
    _e("zookeeper", "Apache ZooKeeper C client", ["zookeeper/zookeeper.h"], ["zookeeper"], pkg_config="zookeeper", brew="zookeeper", apt="libzookeeper-mt-dev", pacman="zookeeper", dnf="zookeeper-devel"),
    # ══════════════════════════════════════════════════════════════════════
    # AI / ML — Phase 1 (core inference & numerics)
    # ══════════════════════════════════════════════════════════════════════
    _e("onnxruntime", "ONNX Runtime — cross-framework model inference", ["onnxruntime/onnxruntime_c_api.h"], ["onnxruntime"], pkg_config="libonnxruntime", brew="onnxruntime", apt="libonnxruntime-dev", pacman="onnxruntime", dnf="onnxruntime-devel", aliases=["onnx-runtime"]),
    _e("llama-cpp", "llama.cpp — local LLM inference (C/C++)", ["llama.h"], ["llama", "ggml", "ggml-base"], pkg_config="llama", brew="llama.cpp", apt="libllama-dev", pacman="llama.cpp", dnf="llama.cpp-devel", depends=["ggml"], aliases=["llama.cpp", "llamacpp"]),
    _e("opencv", "OpenCV computer vision (C API)", ["opencv2/core/core_c.h"], ["opencv_core", "opencv_imgproc", "opencv_imgcodecs", "opencv_highgui"], pkg_config="opencv4", brew="opencv", apt="libopencv-dev", pacman="opencv", dnf="opencv-devel", aliases=["opencv4"]),
    _e("onednn", "oneDNN (DNNL) — CPU deep-learning primitives", ["dnnl.h"], ["dnnl"], brew="onednn", apt="libdnnl-dev", pacman="onednn", dnf="onednn-devel", aliases=["dnnl", "mkl-dnn"]),
    _e("eigen", "Eigen C++ linear algebra (header-only)", ["Eigen/Core"], ["m"], brew="eigen", apt="libeigen3-dev", pacman="eigen", dnf="eigen3-devel", aliases=["eigen3"], cxx=True),
    _e("ggml", "GGML tensor library (llama.cpp foundation)", ["ggml.h"], ["ggml", "ggml-base"], pkg_config="ggml", brew="ggml", apt="libggml-dev", pacman="ggml", dnf="ggml-devel"),
    _e("sentencepiece", "SentencePiece unsupervised tokenizer", ["sentencepiece_processor.h"], ["sentencepiece"], pkg_config="sentencepiece", brew="sentencepiece", apt="libsentencepiece-dev", pacman="sentencepiece", dnf="sentencepiece-devel", cxx=True),
    _e(
        "tokenizers",
        "HuggingFace-style tokenizers (C++ API via tokenizers-cpp)",
        ["tokenizers_c.h"],
        ["tokenizers_c"],
        brew="-",
        apt="-",
        pacman="-",
        git="https://github.com/mlc-ai/tokenizers-cpp.git",
        aliases=["hf-tokenizers"],
    ),
    # ══════════════════════════════════════════════════════════════════════
    # AI / ML — Phase 2 (training frameworks & vector search)
    # ══════════════════════════════════════════════════════════════════════
    _e("libtorch", "LibTorch — PyTorch C++ / C tensor engine", ["torch/torch.h"], ["torch", "c10"], brew="pytorch", apt="libtorch-dev", pacman="python-pytorch", dnf="python3-torch-devel", aliases=["pytorch", "torch"], cxx=True),
    _e("tensorflow", "TensorFlow C API", ["tensorflow/c/c_api.h"], ["tensorflow"], brew="libtensorflow", apt="libtensorflow-dev", pacman="tensorflow", dnf="tensorflow-devel", aliases=["libtensorflow", "tf"]),
    _e("xgboost", "XGBoost gradient boosting (C API)", ["xgboost/c_api.h"], ["xgboost"], pkg_config="xgboost", brew="xgboost", apt="libxgboost-dev", pacman="xgboost", dnf="xgboost-devel", cxx=True),
    _e("lightgbm", "LightGBM gradient boosting (C API)", ["LightGBM/c_api.h"], ["_lightgbm"], brew="lightgbm", apt="liblightgbm-dev", pacman="lightgbm", dnf="lightgbm-devel", cxx=True),
    _e(
        "catboost",
        "CatBoost gradient boosting (C API)",
        ["c_api.h"],
        ["catboostmodel"],
        brew="-",
        apt="-",
        pacman="-",
        git="https://github.com/catboost/catboost.git",
    ),
    _e("faiss", "FAISS vector similarity search (C API)", ["faiss/c_api/Index_c.h"], ["faiss_c"], brew="faiss", apt="libfaiss-dev", pacman="faiss", dnf="faiss-devel", aliases=["libfaiss"], force_include=["stdint.h"]),
    _e("hnswlib", "HNSWLIB approximate nearest neighbor (header-only)", ["hnswlib/hnswlib.h"], ["m"], brew="-", apt="-", pacman="-", git="https://github.com/nmslib/hnswlib.git", cxx=True),
    _e(
        "annoy",
        "Spotify Annoy approximate nearest neighbors",
        ["annoylib.h"],
        ["m"],
        brew="-",
        apt="-",
        pacman="-",
        git="https://github.com/spotify/annoy.git",
    ),
    _e(
        "milvus",
        "Milvus vector database C++ SDK",
        ["milvus/MilvusClient.h"],
        ["milvus"],
        brew="-",
        apt="-",
        pacman="-",
        git="https://github.com/milvus-io/milvus-sdk-cpp.git",
    ),
    _e(
        "sqlite-vec",
        "SQLite vector search extension (embeddings)",
        ["sqlite-vec.h"],
        ["sqlite_vec"],
        brew="-",
        apt="-",
        pacman="-",
        git="https://github.com/asg017/sqlite-vec.git",
        depends=["sqlite3"],
        aliases=["sqlite_vec"],
    ),
    # ══════════════════════════════════════════════════════════════════════
    # AI / ML — Phase 3 (GPU)
    # ══════════════════════════════════════════════════════════════════════
    _e("cuda", "NVIDIA CUDA Toolkit (driver runtime)", ["cuda_runtime.h"], ["cudart"], brew="-", apt="nvidia-cuda-toolkit", pacman="cuda", dnf="cuda-toolkit", platforms=["linux"], aliases=["cuda-toolkit"]),
    _e("cublas", "NVIDIA cuBLAS — GPU BLAS", ["cublas_v2.h"], ["cublas"], brew="-", apt="libcublas-dev", pacman="cuda-tools", dnf="libcublas-devel", platforms=["linux"], depends=["cuda"]),
    _e("cudnn", "NVIDIA cuDNN — deep learning primitives", ["cudnn.h"], ["cudnn"], brew="-", apt="libcudnn-dev", pacman="cudnn", dnf="cudnn-devel", platforms=["linux"], depends=["cuda"]),
    _e("tensorrt", "NVIDIA TensorRT inference optimizer", ["NvInfer.h"], ["nvinfer"], brew="-", apt="libnvinfer-dev", pacman="tensorrt", dnf="tensorrt-devel", platforms=["linux"], depends=["cuda", "cudnn"]),
    _e("nccl", "NVIDIA NCCL — multi-GPU collectives", ["nccl.h"], ["nccl"], brew="-", apt="libnccl-dev", pacman="nccl", dnf="libnccl-devel", platforms=["linux"], depends=["cuda"]),
    _e("rocm", "AMD ROCm HIP runtime", ["hip/hip_runtime.h"], ["amdhip64"], brew="-", apt="hip-dev", pacman="rocm-hip-runtime", dnf="hip-devel", platforms=["linux"], aliases=["hip"]),
    _e("miopen", "AMD MIOpen — deep learning on ROCm", ["miopen/miopen.h"], ["MIOpen"], brew="-", apt="miopen-hip", pacman="miopen", dnf="miopen-devel", platforms=["linux"], depends=["rocm"]),
    _e("opencl", "OpenCL ICD loader + headers", ["CL/cl.h"], ["OpenCL"], brew="opencl-icd-loader", apt="ocl-icd-opencl-dev", pacman="ocl-icd", dnf="ocl-icd-devel", depends=["opencl-headers"], aliases=["ocl"]),
    _e("opencl-headers", "OpenCL C API headers", ["CL/cl.h"], ["OpenCL"], brew="opencl-headers", apt="opencl-headers", pacman="opencl-headers", dnf="opencl-headers"),
    # vulkan-loader / vulkan-headers already shipped
    # ══════════════════════════════════════════════════════════════════════
    # AI / ML — Phase 4 (media extras)
    # ══════════════════════════════════════════════════════════════════════
    _e("imath", "Imath half/float vector math (OpenEXR)", ["Imath/half.h"], ["Imath"], pkg_config="Imath", brew="imath", apt="libimath-dev", pacman="imath", dnf="Imath-devel", cxx=True),
    _e("openexr", "OpenEXR HDR image codec (C API)", ["OpenEXR/openexr.h"], ["OpenEXRCore"], pkg_config="OpenEXR", brew="openexr", apt="libopenexr-dev", pacman="openexr", dnf="OpenEXR-devel", aliases=["libilm"], depends=["imath"]),
    _e("torchvision", "LibTorch Vision helpers (torchvision C++ ops)", ["torchvision/vision.h"], ["torchvision"], brew="-", apt="-", pacman="-", depends=["libtorch"], git="https://github.com/pytorch/vision.git", cxx=True),
    # opencv / ffmpeg / leptonica / tesseract / jpeg / png / tiff / webp already shipped
    # ══════════════════════════════════════════════════════════════════════
    # AI / ML — Phase 5 (audio extras)
    # ══════════════════════════════════════════════════════════════════════
    _e("speexdsp", "SpeexDSP audio processing (resample / denoise)", ["speex/speex_preprocess.h"], ["speexdsp"], pkg_config="speexdsp", brew="speexdsp", apt="libspeexdsp-dev", pacman="speexdsp", dnf="speexdsp-devel"),
    _e(
        "rnnoise",
        "RNNoise — recurrent neural noise suppression",
        ["rnnoise.h"],
        ["rnnoise"],
        brew="-",
        apt="librnnoise-dev",
        pacman="rnnoise",
        dnf="rnnoise-devel",
        git="https://github.com/xiph/rnnoise.git",
    ),
    # portaudio / libsndfile / fftw / opus / flac already shipped
    # ══════════════════════════════════════════════════════════════════════
    # AI / ML — Phase 6 (serialization / infra extras)
    # ══════════════════════════════════════════════════════════════════════
    _e(
        "abseil",
        "Abseil C++ common libraries (protobuf dependency)",
        ["absl/strings/ascii.h"],
        ["absl_strings", "absl_base"],
        brew="abseil",
        apt="libabsl-dev",
        pacman="abseil-cpp",
        dnf="abseil-cpp-devel",
        aliases=["abseil-cpp", "absl"],
        cxx=True,
    ),
    _e(
        "protobuf",
        "Google Protocol Buffers (C++)",
        ["google/protobuf/message_lite.h"],
        ["protobuf"],
        pkg_config="protobuf",
        brew="protobuf",
        apt="libprotobuf-dev",
        pacman="protobuf",
        dnf="protobuf-devel",
        aliases=["libprotobuf"],
        depends=["abseil"],
        cxx=True,
    ),
    _e(
        "flatbuffers",
        "FlatBuffers serialization (TFLite etc.)",
        ["flatbuffers/util.h"],
        ["flatbuffers"],
        pkg_config="flatbuffers",
        brew="flatbuffers",
        apt="libflatbuffers-dev",
        pacman="flatbuffers",
        dnf="flatbuffers-devel",
        cxx=True,
    ),
    # zstd / xxhash / openssl / curl / json-c / libyaml / sqlite3 / protobuf-c already shipped
]


def by_name() -> dict[str, dict[str, Any]]:
    out: dict[str, dict[str, Any]] = {}
    for e in ENTRIES:
        n = e["name"]
        if n in out:
            raise ValueError(f"duplicate catalog entry: {n}")
        out[n] = e
    return out


def count() -> int:
    return len(ENTRIES)
