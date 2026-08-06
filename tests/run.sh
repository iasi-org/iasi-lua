#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

export PATH="$ROOT/tests/fake-bin:$PATH"

(
  cd "$WORK"
  FAKE_STATUS=200 pandoc \
    "$ROOT/tests/fixtures/valid.md" \
    --from markdown \
    --to native \
    --lua-filter "$ROOT/tests/test-filter.lua" \
    > valid.native \
    2> valid.err

  grep -q 'width.*80%' valid.native
  grep -q 'fig-valid' valid.native

  FAKE_STATUS=400 pandoc \
    "$ROOT/tests/fixtures/invalid.md" \
    --from markdown \
    --to native \
    --lua-filter "$ROOT/tests/test-filter.lua" \
    > invalid.native \
    2> invalid.err

  grep -q 'plantuml/' invalid.native
  grep -q 'imagen de diagnostico' invalid.err
)

echo "Pruebas correctas"
