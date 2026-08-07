from build_extension import build
from extensions import EXTENSIONS

for name in sorted(EXTENSIONS):
    target = build(name)
    print(f"Generada: {target}")
