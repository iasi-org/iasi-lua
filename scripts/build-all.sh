#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

found=false
while IFS= read -r source_dir; do
  found=true
  id="$(extension_id "$source_dir")"
  target="$IASI_ROOT/_extensions/$id"
  build_extension "$source_dir" "$target"
  printf 'Generada: %s\n' "$target"
done < <(extension_sources)

$found || fail "No se encontraron extensiones"
