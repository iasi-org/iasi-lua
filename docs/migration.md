# Migración desde `iasi-standards`

## Antes

```yaml
filters:
  - ../../iasi-standards/resources/quarto/extensions/plantuml/plantuml.lua
```

## Después

Instale la extensión en el proyecto consumidor:

```powershell
quarto add P:\iasi\iasi-lua
```

Y configure:

```yaml
filters:
  - iasi-lua

filter-options:
  plantuml:
    enabled: true
    server: http://javier:1025
    format: png
    cache: true
```

Una vez verificado el proyecto consumidor, elimine la copia de desarrollo de:

```text
iasi-standards/resources/quarto/
```

La extensión instalada bajo `_extensions/` debe quedar versionada junto con la
publicación para conservar la reproducibilidad.
