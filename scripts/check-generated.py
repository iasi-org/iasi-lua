from __future__ import annotations

import filecmp
import tempfile
from pathlib import Path

from build_extension import ROOT, build
from extensions import EXTENSIONS


def relative_files(root: Path) -> set[Path]:
    return {
        path.relative_to(root)
        for path in root.rglob("*")
        if path.is_file()
    }


errors: list[str] = []

with tempfile.TemporaryDirectory(prefix="iasi-lua-check-") as temporary:
    temporary_root = Path(temporary)

    for name, specification in sorted(EXTENSIONS.items()):
        expected = temporary_root / specification["id"]
        build(name, expected)
        actual = ROOT / specification["distribution"]

        if not actual.exists():
            errors.append(f"Falta la distribucion: {actual}")
            continue

        expected_files = relative_files(expected)
        actual_files = relative_files(actual)

        for missing in sorted(expected_files - actual_files):
            errors.append(f"Falta en generado: {actual / missing}")
        for extra in sorted(actual_files - expected_files):
            errors.append(f"Sobra en generado: {actual / extra}")
        for relative in sorted(expected_files & actual_files):
            if not filecmp.cmp(expected / relative, actual / relative, shallow=False):
                errors.append(f"Desactualizado: {actual / relative}")

if errors:
    raise SystemExit("\n".join(errors))

print("Distribuciones sincronizadas")
