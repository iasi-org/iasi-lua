#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT/scripts/lib/common.sh"

TEST_ROOT="$ROOT/plantuml/tests"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

require_file() {
  [[ -f "$1" ]] || {
    printf 'ERROR: Falta %s\n' "$1" >&2
    exit 1
  }
}

command -v pandoc >/dev/null 2>&1 || {
  printf 'ERROR: No se encuentra pandoc\n' >&2
  exit 1
}

require_file "$TEST_ROOT/fixtures/valid.md"
require_file "$TEST_ROOT/fixtures/invalid.md"
require_file "$TEST_ROOT/test-filter.lua"

mkdir -p "$WORK/valid" "$WORK/invalid"

cd "$WORK/valid"
if ! FAKE_STATUS=200 pandoc \
  "$TEST_ROOT/fixtures/valid.md" \
  --from markdown \
  --to native \
  --lua-filter "$TEST_ROOT/test-filter.lua" \
  > valid.native \
  2> valid.err; then
  cat valid.err >&2
  exit 1
fi

grep -q 'fig-valid' valid.native || {
  printf 'ERROR: No se conservó el identificador de figura\n' >&2
  exit 1
}

grep -q '80%' valid.native || {
  printf 'ERROR: No se conservó width\n' >&2
  exit 1
}

cd "$WORK/invalid"
if ! FAKE_STATUS=400 pandoc \
  "$TEST_ROOT/fixtures/invalid.md" \
  --from markdown \
  --to native \
  --lua-filter "$TEST_ROOT/test-filter.lua" \
  > invalid.native \
  2> invalid.err; then
  cat invalid.err >&2
  exit 1
fi

grep -q 'plantuml/' invalid.native || {
  printf 'ERROR: No se publicó la imagen de diagnóstico\n' >&2
  exit 1
}

grep -q 'imagen de diagnostico' invalid.err || {
  printf 'ERROR: No se emitió el aviso de diagnóstico\n' >&2
  exit 1
}

if [[ -d .quarto/plantuml ]] && find .quarto/plantuml -type f -print -quit | grep -q .; then
  printf 'ERROR: La imagen de diagnóstico entró en caché\n' >&2
  exit 1
fi

printf 'Pruebas PlantUML correctas\n'
