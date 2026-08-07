# Arquitectura

## Estructura

```text
core/                       fuente común
plantuml/                   fuente específica PlantUML
        │
        ▼
scripts/build_extension.py
        │
        ▼
_extensions/iasi-plantuml/  distribución Quarto generada
```

La estructura de fuente evita capas `src/` y `manifest/` innecesarias. Cada extensión es un directorio raíz legible y autocontenido desde el punto de vista del desarrollo.

`core/` no es una extensión Quarto. Es la plataforma compartida que se copia dentro de cada distribución para que la extensión instalada sea autónoma.

## Responsabilidades

```text
core/engine.lua          ciclo del filtro, caché y publicación
core/config.lua          configuración global y por bloque
core/cache.lua           persistencia de resultados válidos
core/mediabag.lua        inserción de imágenes en Pandoc
core/filesystem.lua      operaciones de archivos
core/metadata.lua        normalización de metadatos
plantuml/compiler.lua    preparación y POST al servidor PlantUML
plantuml/defaults.lua    valores predeterminados
plantuml/iasi-plantuml.lua ensamblado del filtro
```

## Distribución

Todo lo situado bajo `_extensions/` se considera generado. La fuente de verdad permanece en `core/` y en cada directorio de extensión.
