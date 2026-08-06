# Arquitectura

## Separación de responsabilidades

```text
core/
  configuración
  caché
  sistema de archivos
  publicación en mediabag
  recorrido del documento

plantuml/
  preparación de fuente
  estilos
  transporte HTTP
  validación de respuesta
  política de diagnóstico
```

El núcleo desconoce PlantUML. El compilador desconoce cómo se publica una imagen
en Pandoc.

## Contrato del compilador

```lua
Compiler.normalize_config(config)
Compiler.prepare(source, config)
Compiler.mime_type(config)
Compiler.compile(source, config)
```

`compile()` devuelve:

```lua
mime_type, contents, metadata
```

Los metadatos admiten:

```lua
{
  cacheable = true,
  diagnostic = false
}
```

Un diagnóstico gráfico utiliza:

```lua
{
  cacheable = false,
  diagnostic = true
}
```

## Identidad de caché

La identidad incluye:

- fuente preparada;
- servidor;
- formato;
- versión del compilador.

Los atributos de presentación, como `width` y `height`, no forman parte de la
identidad porque no modifican la imagen compilada.
