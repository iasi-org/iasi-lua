# Añadir una extensión

Una nueva extensión se crea como hermana de `plantuml/`:

```text
iasi-lua/
├── core/
├── plantuml/
├── graphviz/
└── _extensions/
```

El directorio de la nueva extensión contiene directamente:

```text
graphviz/
├── _extension.yml
├── iasi-graphviz.lua
├── compiler.lua
├── defaults.lua
└── tests/
```

Después:

1. Registrar la extensión en `scripts/extensions.py`.
2. Ejecutar `python scripts/build-all.py`.
3. Verificar `python scripts/check-generated.py`.
4. Añadir sus pruebas a `scripts/test-all.*`.
5. Documentar el filtro público.

El build crea una distribución autónoma bajo `_extensions/<id>/` incluyendo una copia del `core/` común.
