# IASI Lua

**IASI Lua** es el repositorio de extensiones Lua para Quarto del ecosistema IASI.

La estructura de desarrollo es deliberadamente plana:

```text
core/                    plataforma Lua común
plantuml/                fuente de IASI PlantUML
_extensions/             distribuciones Quarto generadas
scripts/                 build, comprobaciones y pruebas
```

`_extensions/` es un artefacto de distribución. No es la fuente de desarrollo.

## Extensiones

| Extensión | Versión | Filtro |
|---|---:|---|
| IASI PlantUML | 0.4.0 | `iasi-plantuml` |

## Instalación y selección

El repositorio genera las extensiones instalables bajo `_extensions/`. En un proyecto Quarto consumidor, la distribución puede añadirse desde el repositorio y cada filtro se carga de forma explícita.

```powershell
quarto add iasi/iasi-lua
```

Instalar el repositorio no obliga a ejecutar todas sus extensiones. El proyecto decide cuáles cargar:

```yaml
filters:
  - iasi-plantuml
```

Cuando existan nuevas extensiones podrán convivir bajo `_extensions/` y declararse de forma independiente en `filters`.

## IASI PlantUML

Valores predeterminados actuales:

```yaml
enabled: true
server: http://javier:1025
format: png
cache: true
styles: []
```

Configuración mínima de un proyecto consumidor:

```yaml
filters:
  - iasi-plantuml

filter-options:
  plantuml:
    enabled: true
    server: http://javier:1025
    format: png
    cache: true
```

Uso:

````qmd
```{.plantuml #fig-pipeline width="80%" fig-cap="Pipeline documental"}
@startuml
Documento -> Filtro
Filtro -> PlantUML
PlantUML -> Imagen
@enduml
```
````

La extensión envía la fuente al servidor mediante `POST /png/`. Si PlantUML devuelve un PNG de diagnóstico con un HTTP de error, la imagen de diagnóstico se inserta en el documento, no entra en caché y el render continúa.

## Desarrollo

La fuente de PlantUML vive directamente en:

```text
plantuml/
├── _extension.yml
├── iasi-plantuml.lua
├── compiler.lua
├── defaults.lua
├── README.md
├── CHANGELOG.md
├── example.qmd
└── tests/
```

El core común vive en:

```text
core/
```

Reconstruir las distribuciones:

```powershell
python scripts\build-all.py
```

Comprobar que lo generado coincide con la fuente:

```powershell
python scripts\check-generated.py
python scripts\check-versions.py
```

Ejecutar pruebas:

```powershell
.\scripts\test-all.ps1
```

## Distribución

El build genera:

```text
_extensions/
└── iasi-plantuml/
    ├── core/
    ├── _extension.yml
    ├── iasi-plantuml.lua
    ├── compiler.lua
    ├── defaults.lua
    ├── version.lua
    └── ...
```

Cuando existan nuevas extensiones se añadirán como directorios hermanos de `plantuml/` y como distribuciones hermanas bajo `_extensions/`.

La versión editable de IASI PlantUML vive únicamente en:

```text
plantuml/_extension.yml
```

El build genera `version.lua` y copia el manifiesto a la distribución.

## Licencia

Apache License 2.0.
