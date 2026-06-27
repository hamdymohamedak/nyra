#!/usr/bin/env bash
# Build smoke for Apps/Basics and Apps/Graphics (optional raylib).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

# shellcheck source=nyra-bin.sh
source "$ROOT/make/lib/nyra-bin.sh"
if [[ -z "${NYRA_BIN:-}" ]]; then nyra_export_cli; fi
NYRA="${NYRA:-$NYRA_BIN}"
log() { echo "apps-smoke: $*" >&2; }
fail() { log "FAILED: $*"; exit 1; }

BASICS=(
  MergeSort
  AllSorts
  AVLTree
  BTree
  Base64
  SHA256
  AES
  RSA
  UuidGenerator
  AStar
  RedBlackTree
  Binary_Search
  Calculator
  TodoCLI
  Timer
  PasswordGenerator
  UnitConverter
  CsvReader
  UrlParser
  Dijkstra
  Graph
  Huffman
  LZW
)

for app in "${BASICS[@]}"; do
  dir="$ROOT/Apps/Basics/$app"
  if [[ ! -f "$dir/main.ny" && ! -f "$dir/nyra.mod" ]]; then
    log "skip Basics/$app (no project)"
    continue
  fi
  log "build Basics/$app"
  (cd "$dir" && $NYRA build .) || fail "Basics/$app build"
done

raylib_ok=0
for libdir in /opt/homebrew/opt/raylib/lib /usr/local/opt/raylib/lib; do
  if [[ -d "$libdir" ]]; then
    raylib_ok=1
    break
  fi
done

GRAPHICS=(
  ImageViewer
  Paint
  PhotoEditor
  RayTracer
  Renderer2D
  SpriteEngine
  ParticleEngine
  FontRenderer
  PDFViewer
)

if [[ "$raylib_ok" -eq 1 ]]; then
  for app in "${GRAPHICS[@]}"; do
    dir="$ROOT/Apps/Graphics/$app"
    log "build Graphics/$app"
    (cd "$dir" && $NYRA build .) || fail "Graphics/$app build"
  done
else
  log "skip Graphics/* (raylib not found — brew install raylib)"
fi

log "ok — Apps smoke"
