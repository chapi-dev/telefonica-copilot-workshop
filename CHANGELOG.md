# 📋 Changelog

Todas las mejoras notables de este workshop se documentan aquí.

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y versionado [SemVer](https://semver.org/lang/es/).

## [Unreleased] · 2026-05-20

### 🔄 Cambiado
- **Migración global de "Premium Requests" a "GitHub AI Credits"** (modelo vigente desde el 1 jun 2026):
  - `02-modelo-de-costes.md`: §1 mapa actualizado + nueva nota de migración, §2 sección SKUs reescrita con explicación completa de AI Credits (precio, cuotas, modelos, fallback), §4.2 budgets en los 3 scopes reales (Enterprise / Org / Cost center — no per-user) + workarounds per-user vía Metrics API, §4.3 Coding Agent actualizado, tabla TCO ajustada.
  - `05-optimizacion-continua.md`: triggers de mejora continua y resumen final.
  - `facilitador/guion-facilitador.md`: timing interno del módulo 02.
  - `facilitador/preguntas-frecuentes.md`: FAQ "¿Qué son AI Credits?" reescrita; FAQ de coste del Coding Agent.
  - `anexos/plantillas/policy-matrix.md`: línea de presupuesto.
  - `anexos/recursos-y-enlaces.md`: enlace al overview de billing + post del blog de GitHub.

### 🚀 Añadido

#### Identidad, EMU y SSO/SCIM (Entra ID + on-prem)
- Reorganización en profundidad de `01-gobernanza-y-control.md §1` en 6 sub-bloques:
  - 1.1 **Estructura jerárquica Enterprise · Organizations · Teams** con ejemplo Telefónica multi-país y convenciones de naming.
  - 1.2 **Enterprise Managed Users (EMU)** en profundidad: EMU vs GHEC estándar, pasos de activación, limitaciones, decisiones irreversibles.
  - 1.3 **SSO + SCIM con Entra ID (Azure)** paso a paso, push de grupos y Conditional Access mínimo.
  - 1.4 **SSO con IdPs on-prem** (AD FS, Keycloak, PingFederate, Okta on-prem) con matriz de soporte y patrón híbrido recomendado.
  - 1.5 Asignación de Copilot por teams sincronizados (refinada).
  - 1.6 Roles mínimos necesarios (refinada).
- Nuevo anexo `anexos/identidad-emu-sso.md` (deep dive ~580 líneas):
  - Diagramas mermaid de flujos SAML, SCIM y group sync.
  - Setup completo Entra ID, AD FS (UI + PowerShell + WAP), Keycloak (con plugin SCIM).
  - Tabla comparativa EMU vs GHEC estándar y árbol de decisión.
  - Patrón híbrido recomendado para Telefónica.
  - Troubleshooting con 12 fallos típicos y fix.
  - Runbook de rotación de certificados y PAT SCIM.

#### Granularidad de policies y Hosted Compute Networking
- Nueva sección `01-gobernanza-y-control.md §2.4 — Granularidad real de las policies`:
  - Tabla "lo que SÍ existe nativo" (Repository policies, Rulesets, Custom Properties, Required workflows, Templates).
  - Tabla "lo que NO existe nativo" (regex de nombres, descripción/topics/README/license obligatorios) y cómo conseguirlo (webhook + automatización o GitHub App).
  - Patrón recomendado para Telefónica (Properties REQUIRED + Rulesets condicionales + Required workflow + GitHub App).
  - Diagrama mermaid de granularidad por capa (Enterprise → Org → Repo → File/Path → Branch/Tag).
- Nueva sub-sección `01-gobernanza-y-control.md §2.5 — Hosted Compute Networking`:
  - Explicación del problema (runners GitHub en IPs públicas vs recursos privados de Azure).
  - Diagrama mermaid runner → VNet → Key Vault / AKS / ACR / APIs internas.
  - Tabla "Ventajas a nivel Enterprise" (zero IP pública, zero ops, pay-per-minute, NSG/Firewall, OIDC trust, NSG flow logs, aislamiento por BU).
  - Casos de uso típicos para Telefónica.
  - Decisiones de gobernanza.
- Nueva FAQ en `facilitador/preguntas-frecuentes.md` sobre conexión de workflows a recursos privados de Azure (apunta al §2.5).

#### Operación: bootstrap de Enterprise EMU
- Nuevo script `anexos/scripts/bootstrap-emu-enterprise.ps1` (PowerShell 7, idempotente):
  - Crea Organizations en un Enterprise EMU vía API (`POST /enterprises/{enterprise}/organizations`).
  - Aplica security defaults por Org (secret scanning, push protection, dependabot alerts + security updates).
  - Crea teams configurables por Org (default: `platform-sre`, `platform-backend`, `platform-frontend`, `product-mobile`, `product-web`).
  - Configura seat management mode de Copilot por Org.
  - Asigna seats a usuarios y/o teams (`-CopilotUsers`, `-CopilotTeams`).
  - Modo `-DryRun` para preview sin mutaciones.
  - Imprime URLs de las policies enterprise que requieren UI.

#### Checklist de gobernanza
- `anexos/checklist-gobernanza.md` sección 1 ampliada en 4 sub-bloques:
  - 1.a Estructura (Enterprise, Orgs, naming, owners ≤ 5).
  - 1.b EMU (suffix decidido, plan de roll-out, comunicación a devs, BUs con OSS público).
  - 1.c SSO + SCIM (Entra ID o IdP on-prem, Conditional Access, plan B BUs on-prem).
  - 1.d Hardening cuenta admin (recovery codes, IP allow list, 2FA, break-glass).

## [1.0.0] · 2026-05-18

### ✨ Inicial

- 5 módulos completos: gobernanza, costes, skills/conectores, caso práctico, optimización continua.
- 4 plantillas listas para usar: `copilot-instructions.md`, `content-exclusions.yml`, `mcp-config.json`, `policy-matrix.md`.
- 3 scripts PowerShell 7: `pull-copilot-metrics.ps1`, `identify-idle-seats.ps1`, `export-audit-log.ps1`.
- 10 queries KQL listas para Sentinel.
- Checklists pre-workshop y de gobernanza.
- Guion del facilitador minuto a minuto + FAQ con 40+ entradas.
- Licencia MIT, código de conducta, política de seguridad y guía de contribución.
- GitHub Pages con tema Cayman.
- CI/CD: validación de PowerShell, JSON, YAML y enlaces Markdown en cada PR.
- Issue/PR templates.

[1.0.0]: https://github.com/chapi-dev/telefonica-copilot-workshop/releases/tag/v1.0.0
