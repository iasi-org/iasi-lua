# Migración desde IASI Lua 0.3.x

La antigua extensión única `iasi-lua` pasa a ser un repositorio contenedor. PlantUML tiene identidad propia:

```yaml
filters:
  - iasi-plantuml
```

La fuente común vive en `core/` y la fuente específica directamente en `plantuml/`.

Antes de esta simplificación, PlantUML estaba separado artificialmente en `plantuml/src/`, `plantuml/manifest/` y `plantuml/_extensions/`. Esas capas desaparecen.

La distribución Quarto común del repositorio se genera en:

```text
_extensions/iasi-plantuml/
```

La automatización se unifica en Bash para Linux y Windows mediante WSL u otro entorno Bash compatible.
