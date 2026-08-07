#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

"$SCRIPT_DIR/check-generated.sh"
"$SCRIPT_DIR/check-versions.sh"

found=false
while IFS= read -r source_dir; do
  test_runner="$source_dir/tests/run.sh"

  if [[ -x "$test_runner" ]]; then
    found=true
    printf 'Pruebas: %s\n' "$(extension_name "$source_dir")"
    "$test_runner"
  fi
done < <(extension_sources)

$found || fail "No se encontraron suites de pruebas"
printf 'Todas las pruebas son correctas\n'
