#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

require_command diff

temporary="$(mktemp -d)"
trap 'rm -rf "$temporary"' EXIT

errors=0
found=false

while IFS= read -r source_dir; do
  found=true
  id="$(extension_id "$source_dir")"
  expected="$temporary/$id"
  actual="$IASI_ROOT/_extensions/$id"

  build_extension "$source_dir" "$expected"

  if [[ ! -d "$actual" ]]; then
    printf 'Falta la distribución: %s\n' "$actual" >&2
    errors=1
    continue
  fi

  if ! diff -qr "$expected" "$actual"; then
    errors=1
  fi
done < <(extension_sources)

$found || fail "No se encontraron extensiones"

if (( errors != 0 )); then
  fail "Hay distribuciones desactualizadas"
fi

printf 'Distribuciones sincronizadas\n'
