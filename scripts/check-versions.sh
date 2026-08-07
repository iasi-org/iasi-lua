#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

errors=0
found=false
checked=()

while IFS= read -r source_dir; do
  found=true
  id="$(extension_id "$source_dir")"
  expected="$(extension_version "$source_dir")"
  distribution="$IASI_ROOT/_extensions/$id"
  generated_manifest="$distribution/_extension.yml"
  version_file="$distribution/version.lua"

  if [[ ! -f "$generated_manifest" ]]; then
    printf 'Falta %s\n' "$generated_manifest" >&2
    errors=1
    continue
  fi

  actual="$(extension_version "$distribution")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'Versión generada incoherente en %s: %s != %s\n' \
      "$generated_manifest" "$actual" "$expected" >&2
    errors=1
  fi

  if [[ ! -f "$version_file" ]]; then
    printf 'Falta %s\n' "$version_file" >&2
    errors=1
  else
    internal="$(awk -F '"' '/^[[:space:]]*return[[:space:]]*"/ { print $2; exit }' "$version_file")"
    if [[ "$internal" != "$expected" ]]; then
      printf 'Versión interna incoherente en %s: %s != %s\n' \
        "$version_file" "${internal:-<vacía>}" "$expected" >&2
      errors=1
    fi
  fi

  checked+=("$id $expected")
done < <(extension_sources)

$found || fail "No se encontraron extensiones"

if (( errors != 0 )); then
  exit 1
fi

printf 'Versiones coherentes:\n'
for item in "${checked[@]}"; do
  printf -- '- %s\n' "$item"
done
