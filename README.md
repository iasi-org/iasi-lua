# IASI Lua

**IASI Lua** es una infraestructura de extensiones para Quarto basada en filtros Lua.
Separa el motor común, los compiladores especializados y la publicación que los
consume.

PlantUML es la primera implementación, no el límite del proyecto.

```text
bloque Quarto
  -> filtro Lua
  -> compilador especializado
  -> caché
  -> mediabag de Pandoc
  -> HTML o PDF
```

## Estado

Versión inicial independiente: **0.3.2**.

Incluye:

- motor común reutilizable;
- compilador PlantUML mediante `POST`;
- salida PNG común para HTML y PDF;
- caché por contenido y configuración;
- estilos PlantUML compartidos;
- atributos de presentación como `width`, `height`, `fig-cap` y `fig-alt`;
- imágenes de diagnóstico dentro del documento cuando PlantUML rechaza un diagrama.

## Instalación local

Desde el proyecto Quarto consumidor:

```powershell
quarto add P:\iasi\iasi-lua
```

Cuando el repositorio esté publicado en la organización IASI:

```bash
quarto add iasi/iasi-lua
```

Quarto copiará la extensión dentro del directorio `_extensions` del proyecto
consumidor.

## Configuración

```yaml
filters:
  - iasi-lua

filter-options:
  plantuml:
    enabled: true
    server: http://localhost:1025
    format: png
    cache: true
    styles:
      - resources/plantuml/iasi.puml
```

La clave histórica `engines.plantuml` sigue aceptándose por compatibilidad, pero
el contrato público es `filter-options.plantuml`.

## Uso

````qmd
```{.plantuml #fig-pipeline width="80%" fig-cap="Pipeline documental"}
@startuml
Documento -> Filtro
Filtro -> PlantUML
PlantUML -> Imagen
@enduml
```
````

## Errores de diagramas

PlantUML devuelve sus errores de sintaxis como imágenes. IASI Lua incorpora esa
imagen en el lugar del diagrama, emite un aviso y continúa el renderizado. Las
imágenes de diagnóstico no se almacenan en caché.

Los errores de transporte, las respuestas vacías y los contenidos no gráficos
sí detienen la construcción.

## Estructura

```text
iasi-lua/
├── _extensions/
│   └── iasi-lua/
│       ├── _extension.yml
│       ├── core/
│       └── plantuml/
├── templates/
│   └── engine/
├── tests/
├── docs/
├── example.qmd
├── CHANGELOG.md
├── CONTRIBUTING.md
└── LICENSE
```

Todo lo situado por encima de `_extensions/` pertenece al repositorio de
desarrollo. Quarto instala únicamente la extensión distribuible.

## Licencia

Código publicado bajo Apache License 2.0.
