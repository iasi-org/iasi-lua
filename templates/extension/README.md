# Nueva extensión IASI Lua

Copie esta carpeta como un nuevo directorio raíz del repositorio, cambie `extension-name` por el identificador real e implemente la extensión.

Los scripts descubren automáticamente cualquier directorio raíz que contenga `_extension.yml`; no hay que registrar la extensión en ningún archivo adicional.

Después ejecute:

```bash
./scripts/build-all.sh
./scripts/test-all.sh
```
