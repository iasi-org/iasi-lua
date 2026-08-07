from pathlib import Path
import re

from extensions import EXTENSIONS

ROOT = Path(__file__).resolve().parents[1]
errors = []
checked = []


def version_from_yaml(path: Path) -> str | None:
    match = re.search(
        r"^version:\s*['\"]?([^'\"\s]+)",
        path.read_text(encoding="utf-8"),
        re.MULTILINE,
    )
    return match.group(1) if match else None


for name, specification in sorted(EXTENSIONS.items()):
    source = ROOT / specification["source"]
    distribution = ROOT / specification["distribution"]
    source_manifest = source / "_extension.yml"
    generated_manifest = distribution / "_extension.yml"
    version_file = distribution / "version.lua"

    expected = version_from_yaml(source_manifest)
    actual = version_from_yaml(generated_manifest) if generated_manifest.exists() else None

    if expected is None:
        errors.append(f"Falta version en {source_manifest}")
        continue
    if actual != expected:
        errors.append(
            f"Version generada incoherente en {generated_manifest}: "
            f"{actual} != {expected}"
        )
    if not version_file.exists():
        errors.append(f"Falta {version_file}")
    else:
        match = re.search(
            r'return\s+"([^"]+)"',
            version_file.read_text(encoding="utf-8"),
        )
        internal = match.group(1) if match else None
        if internal != expected:
            errors.append(
                f"Version interna incoherente en {version_file}: "
                f"{internal} != {expected}"
            )

    checked.append(f"{specification['id']} {expected}")

if errors:
    raise SystemExit("\n".join(errors))

print("Versiones coherentes:")
for item in checked:
    print(f"- {item}")
