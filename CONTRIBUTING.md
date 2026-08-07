# Contribuir

## Regla principal

Se editan únicamente las fuentes:

```text
core/
plantuml/
```

Dentro de `plantuml/`, los archivos de código y metadatos están todos al mismo nivel. Las pruebas viven en `plantuml/tests/`.

No se edita directamente:

```text
_extensions/iasi-plantuml/
```

Ese directorio es la distribución Quarto generada. Se reconstruye con:

```powershell
python scripts\build-all.py
```

## Antes de un commit

```powershell
python scripts\build-all.py
python scripts\check-generated.py
python scripts\check-versions.py
.\scripts\test-all.ps1
```

## Nueva extensión

1. Copiar `templates/extension/` a un nuevo directorio raíz, por ejemplo `graphviz/`.
2. Implementar allí `_extension.yml`, filtro, compilador, valores predeterminados y pruebas.
3. Registrar la extensión en `scripts/extensions.py`.
4. Generar `_extensions/<id>/`.
5. Documentarla en el README.

`core/` permanece común. Cada distribución generada recibe una copia autónoma del core que necesita.
