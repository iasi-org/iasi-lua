#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

[[ $# -ge 1 && $# -le 2 ]] || fail "Uso: $0 <extension> [destino]"

name="$1"
source_dir="$(extension_source "$name")"
id="$(extension_id "$source_dir")"
target="${2:-$IASI_ROOT/_extensions/$id}"

build_extension "$source_dir" "$target"
printf 'Generada: %s\n' "$target"
