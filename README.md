# IASI Lua

**IASI Lua** es el repositorio de extensiones Lua para Quarto del ecosistema IASI.

La estructura de desarrollo es deliberadamente plana:

```text
core/                    plataforma Lua común
plantuml/                fuente de IASI PlantUML
shiny/                   fuente de IASI Shiny
_extensions/             distribuciones Quarto generadas
scripts/                 automatización Bash
```

`_extensions/` es un artefacto de distribución. No es la fuente de desarrollo.

## Entorno operativo

Toda la automatización del repositorio está escrita en **Bash**.

```text
Linux       Bash nativo
Windows     WSL u otro entorno Bash compatible
```

No se mantiene una implementación paralela en PowerShell o Python para las operaciones del proyecto.

## Extensiones

| Extensión | Versión | Filtro |
|---|---:|---|
| IASI PlantUML | 0.4.0 | `iasi-plantuml` |
| IASI Shiny | 0.1.0 | `iasi-shiny` |

## IASI Shiny

IASI Shiny integra aplicaciones Shiny para R en documentos HTML estáticos
mediante Shinylive y webR. Durante el render requiere el paquete R
`shinylive`; la publicación resultante puede alojarse en GitHub Pages.

```r
install.packages("shinylive")
```

```yaml
filters:
  - iasi-shiny
```

Los bloques interactivos utilizan la clase `{shinylive-r}` y deben declarar
`standalone: true`. Consulta `shiny/example.qmd` para un ejemplo completo.

## IASI PlantUML

Valores predeterminados actuales:

```yaml
enabled: true
server: http://javier:1025
format: png
cache: true
styles: []
```

Un proyecto consumidor carga la extensión explícitamente:

```yaml
filters:
  - iasi-plantuml
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

La extensión envía la fuente al servidor mediante `POST /png/`. Si PlantUML devuelve un PNG de diagnóstico con un HTTP de error, esa imagen se inserta en el documento, no entra en caché y el render continúa.

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

La distribución se genera en:

```text
_extensions/iasi-plantuml/
```

No se editan manualmente archivos dentro de `_extensions/`.

## Comandos del proyecto

Construir todas las extensiones:

```bash
./scripts/build-all.sh
```

Construir una extensión:

```bash
./scripts/build-extension.sh plantuml
```

Comprobar que las distribuciones generadas coinciden con las fuentes:

```bash
./scripts/check-generated.sh
```

Comprobar las versiones:

```bash
./scripts/check-versions.sh
```

Ejecutar todas las pruebas:

```bash
./scripts/test-all.sh
```

Instalar la distribución local en un proyecto Quarto:

```bash
./scripts/install-local.sh /ruta/al/proyecto
```

Sin argumento, `install-local.sh` utiliza el directorio actual como proyecto consumidor.

## Distribución

El build genera una extensión Quarto autónoma:

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

La versión editable de IASI PlantUML vive únicamente en:

```text
plantuml/_extension.yml
```

El build genera `version.lua` y copia el manifiesto a la distribución.

## Licencia

Apache License 2.0.
