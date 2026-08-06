from pathlib import Path
import re
import sys

root = Path(__file__).resolve().parents[1]
expected = (root / "VERSION").read_text(encoding="utf-8").strip()

targets = {
    root / "_extensions" / "iasi-lua" / "_extension.yml": r"^version:\s*([^\s]+)",
    root / "_extensions" / "iasi-lua" / "plantuml" / "plantuml.lua": r'version\s*=\s*"([^"]+)"',
}

for path, pattern in targets.items():
    match = re.search(pattern, path.read_text(encoding="utf-8"), re.MULTILINE)
    if match is None:
        raise SystemExit(f"No se encontró la versión en {path}")
    if match.group(1) != expected:
        raise SystemExit(
            f"Versión inconsistente en {path}: {match.group(1)} != {expected}"
        )

print(f"Versión coherente: {expected}")
