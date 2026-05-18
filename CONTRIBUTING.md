# 🤝 Contribuir

¡Gracias por querer mejorar este workshop! Esta es una guía corta para que las contribuciones encajen sin fricción.

## ¿Cómo puedo contribuir?

- **Erratas o mejoras de redacción** → abre directamente un PR.
- **Nuevas plantillas o scripts** → abre antes un Issue para alinear el alcance.
- **Adaptaciones a otras empresas/sectores** → ¡bienvenidas! Mantenlas en una carpeta separada (`/variantes/<empresa>/`) para no contaminar la base.
- **Correcciones técnicas** (URLs, parámetros API, comandos `gh` que cambian) → PR directo con referencia a la doc oficial actualizada.

## Convenciones

- Commits en **Conventional Commits**: `feat:`, `fix:`, `docs:`, `chore:`.
- Markdown con headings en español salvo términos técnicos (API, MCP, etc.).
- Scripts PowerShell con `#requires -Version 7.0` y `[CmdletBinding()]`.
- Validar JSON/YAML antes de hacer commit.
- No commitear secretos. Nunca. El `.gitignore` ayuda pero la responsabilidad es tuya.

## Estilo

- Frases cortas. Listas y tablas mejor que párrafos largos.
- Cada control técnico → con la **URL exacta** de GitHub o el comando `gh` equivalente.
- Si añades un módulo nuevo, replica la estructura:
  1. Contexto (1 min)
  2. Desarrollo (X min con sub-tiempos)
  3. Lab guiado
  4. Checklist de salida

## Proceso de PR

1. Fork → branch (`feat/...`, `fix/...`, `docs/...`).
2. PR contra `main`.
3. Descripción clara + capturas si aplica.
4. Espera review (24-72h).

## Código de conducta

Respeto, asume buenas intenciones, ningún ataque personal. Si te incomoda algo, abre un Issue privado o escribe al maintainer.
