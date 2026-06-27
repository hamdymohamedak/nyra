#!/usr/bin/env sh
# Package a release archive for GitHub Releases.
# Usage: ./scripts/package-release.sh <version> <target-triple>
# Example: ./scripts/package-release.sh 0.1.0 aarch64-apple-darwin
set -eu

VERSION="${1:?version required (e.g. 0.1.0)}"
TRIPLE="${2:?target triple required (e.g. x86_64-unknown-linux-gnu)}"

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

ARCH="${TRIPLE%%-*}"
OS="${TRIPLE#*-}"
OS="${OS%%-*}"

case "$OS" in
  unknown) OS="linux" ;;
  apple) OS="darwin" ;;
  pc-windows) OS="windows" ;;
esac

IS_WINDOWS=0
if [ "$OS" = "windows" ]; then
  IS_WINDOWS=1
  ASSET="nyra-${ARCH}-windows.zip"
else
  ASSET="nyra-${ARCH}-${OS}.tar.gz"
fi

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/nyra-pkg.XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT INT TERM

mkdir -p "$STAGE/bin" "$STAGE/share/stdlib"

echo "Building cli for $TRIPLE ..."
if [ "$TRIPLE" = "$(rustc -vV | sed -n 's/^host: //p')" ]; then
  cargo build --release -p cli
  if [ "$IS_WINDOWS" -eq 1 ]; then
    cp "target/release/nyra.exe" "$STAGE/bin/nyra.exe"
  else
    cp "target/release/nyra" "$STAGE/bin/nyra"
  fi
else
  rustup target add "$TRIPLE" 2>/dev/null || true
  cargo build --release -p cli --target "$TRIPLE"
  if [ "$IS_WINDOWS" -eq 1 ]; then
    cp "target/$TRIPLE/release/nyra.exe" "$STAGE/bin/nyra.exe"
  else
    cp "target/$TRIPLE/release/nyra" "$STAGE/bin/nyra"
  fi
fi

echo "Copying stdlib (full tree) ..."
# Full stdlib tree — imports resolve under share/stdlib/{net,crypto,...}
cp -R stdlib/. "$STAGE/share/stdlib/"
# Trim dev-only artifacts if present
rm -rf "$STAGE/share/stdlib/target" 2>/dev/null || true

printf '%s\n' "$VERSION" > "$STAGE/version"

# Shell env helper (Unix)
cat > "$STAGE/env" <<EOF
# Nyra release $VERSION — source this file or copy into your profile
export NYRA_HOME="\$(CDPATH= cd -- "\$(dirname "\${BASH_SOURCE[0]:-\$0}")" && pwd)"
export PATH="\${NYRA_HOME}/bin:\${PATH}"
EOF

# PowerShell env helper (Windows)
cat > "$STAGE/env.ps1" <<'EOF'
# Nyra release — dot-source: . "$env:USERPROFILE\.nyra\env.ps1"
$NyraHome = Split-Path -Parent $MyInvocation.MyCommand.Path
$env:NYRA_HOME = $NyraHome
$env:PATH = "$NyraHome\bin;$env:PATH"
EOF

mkdir -p dist
if [ "$IS_WINDOWS" -eq 1 ]; then
  if command -v zip >/dev/null 2>&1; then
    (cd "$STAGE" && zip -r "$ROOT/dist/$ASSET" bin share version env.ps1)
  else
    powershell.exe -NoProfile -Command "Compress-Archive -Path '${STAGE}\\*' -DestinationPath '${ROOT}\\dist\\${ASSET}' -Force"
  fi
else
  tar -czf "dist/$ASSET" -C "$STAGE" bin share version env
fi
echo "Wrote dist/$ASSET"
