#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_ROOT="$ROOT/plantuml/tests"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

python3 "$ROOT/scripts/check-generated.py"
export PATH="$TEST_ROOT/fake-bin:$PATH"

mkdir -p "$WORK/valid" "$WORK/invalid"

cd "$WORK/valid"
FAKE_STATUS=200 pandoc \
  "$TEST_ROOT/fixtures/valid.md" \
  --from markdown \
  --to native \
  --lua-filter "$TEST_ROOT/test-filter.lua" \
  > valid.native \
  2> valid.err

grep -q 'width.*80%' valid.native
grep -q 'fig-valid' valid.native

cd "$WORK/invalid"
FAKE_STATUS=400 pandoc \
  "$TEST_ROOT/fixtures/invalid.md" \
  --from markdown \
  --to native \
  --lua-filter "$TEST_ROOT/test-filter.lua" \
  > invalid.native \
  2> invalid.err

grep -q 'plantuml/' invalid.native
grep -q 'imagen de diagnostico' invalid.err

if find .quarto/plantuml -type f 2>/dev/null | grep -q .; then
  echo "La imagen de diagnóstico entró en caché" >&2
  exit 1
fi

echo "Pruebas correctas"
