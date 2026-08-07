# Contribuir

## Regla principal

Se editan únicamente las fuentes:

```text
core/
plantuml/
```

No se edita directamente:

```text
_extensions/
```

Ese directorio contiene las distribuciones Quarto generadas.

## Automatización

Todas las operaciones del repositorio se implementan en Bash. En Windows se utiliza WSL u otro entorno Bash compatible. No se crean scripts equivalentes en PowerShell o Python.

## Antes de un commit

```bash
./scripts/build-all.sh
./scripts/check-generated.sh
./scripts/check-versions.sh
./scripts/test-all.sh
```

## Nueva extensión

1. Copiar `templates/extension/` a un nuevo directorio raíz, por ejemplo `graphviz/`.
2. Implementar `_extension.yml`, filtro, compilador, valores predeterminados y pruebas.
3. Ejecutar `./scripts/build-all.sh`.
4. Verificar con `./scripts/test-all.sh`.
5. Documentar el filtro público.

No existe un registro manual de extensiones: los scripts descubren automáticamente los directorios raíz que contienen `_extension.yml`.

`core/` permanece común. Cada distribución generada recibe una copia autónoma del core que necesita.
