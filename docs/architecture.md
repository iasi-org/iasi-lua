# Arquitectura

## Estructura

```text
core/                       fuente común
plantuml/                   fuente específica PlantUML
        │
        ▼
scripts/build-all.sh
        │
        ▼
_extensions/iasi-plantuml/  distribución Quarto generada
```

La estructura de fuente evita capas `src/` y `manifest/` innecesarias. Cada extensión es un directorio raíz legible.

`core/` no es una extensión Quarto. Es la plataforma compartida que se copia dentro de cada distribución para que la extensión instalada sea autónoma.

## Descubrimiento

Los scripts Bash descubren automáticamente las extensiones buscando directorios raíz que contienen `_extension.yml`. No existe un registro paralelo que haya que mantener.

## Responsabilidades

```text
core/engine.lua             ciclo del filtro, caché y publicación
core/config.lua             configuración global y por bloque
core/cache.lua              persistencia de resultados válidos
core/mediabag.lua           inserción de imágenes en Pandoc
core/filesystem.lua         operaciones de archivos
core/metadata.lua           normalización de metadatos
plantuml/compiler.lua       preparación y POST al servidor PlantUML
plantuml/defaults.lua       valores predeterminados
plantuml/iasi-plantuml.lua  ensamblado del filtro
```

## Distribución

Todo lo situado bajo `_extensions/` se considera generado. La fuente de verdad permanece en `core/` y en cada directorio de extensión.
