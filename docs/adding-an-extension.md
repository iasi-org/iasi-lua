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

1. Implementar la extensión.
2. Ejecutar `./scripts/build-all.sh`.
3. Verificar `./scripts/check-generated.sh` y `./scripts/check-versions.sh`.
4. Añadir `tests/run.sh`.
5. Ejecutar `./scripts/test-all.sh`.
6. Documentar el filtro público.

No hay que registrar la extensión en ningún archivo adicional. Los scripts la descubren por su `_extension.yml`.

El build crea una distribución autónoma bajo `_extensions/<id>/` incluyendo una copia del `core/` común.
