#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

require_command quarto

project="${1:-$PWD}"
project="$(cd "$project" && pwd)"

"$SCRIPT_DIR/build-all.sh"

(
  cd "$project"
  quarto add "$IASI_ROOT" --no-prompt
)

printf 'Extensiones instaladas en: %s\n' "$project"
