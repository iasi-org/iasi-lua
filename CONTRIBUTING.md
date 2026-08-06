# Contribuir

IASI Lua está abierto a aportaciones de profesionales, equipos y organizaciones.

## Principios

- El núcleo no debe depender de una publicación concreta.
- Cada compilador debe encapsular su transporte y validación.
- Los errores de contenido deben representarse cuando exista un diagnóstico útil.
- Los fallos de infraestructura deben detener la construcción con un mensaje claro.
- La caché solo debe almacenar resultados válidos y reproducibles.
- Los ejemplos y las pruebas deben funcionar sin rutas personales.

## Flujo de trabajo

1. Cree una rama desde `main`.
2. Añada o actualice pruebas.
3. Ejecute `tests/run.sh` o `tests/run.ps1`.
4. Renderice `example.qmd` contra un servidor PlantUML real.
5. Abra un pull request explicando el contrato afectado.

## Estilo

- Lua legible y modular.
- Funciones pequeñas con responsabilidades explícitas.
- Sin rutas, nombres de equipo o servicios personales en los valores predeterminados.
- Versionado semántico en `_extension.yml`, `VERSION` y el filtro correspondiente.
