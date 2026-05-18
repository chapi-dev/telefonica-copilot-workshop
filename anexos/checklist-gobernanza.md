# ✅ Checklist de Gobernanza Copilot — Telefónica

> Checklist completa para auditar el estado de gobernanza de Copilot en una **Org** o en el **Enterprise** completo.  
> Pensada para usarse trimestralmente por SecOps + Plataforma + FinOps.

---

## 1. Identidad y accesos

- [ ] **SAML SSO** activo y forzado contra Entra ID.
- [ ] **SCIM** provisioning funcionando (alta/baja automáticas).
- [ ] **Enterprise Managed Users (EMU)** activado.
- [ ] Recovery codes guardados en vault corporativo.
- [ ] IP allow list configurada para acceso administrativo.
- [ ] 2FA obligatorio (`Settings → Authentication security → Require two-factor`).
- [ ] Rol `copilot-admin` (custom role) creado en cada Org y asignado a personas, no a usuarios genéricos.
- [ ] Lista de Enterprise Owners revisada y con mínimo necesario (≤ 5).

## 2. Asignación de Copilot

- [ ] Asignación **vía teams** sincronizados desde Entra ID, **no manual**.
- [ ] Política documentada de cuándo se asigna un seat (rol/equipo/aprobación).
- [ ] Política documentada de baja (Mover, Cese, Vacaciones largas).
- [ ] Revisión mensual de seats asignados vs activos.
- [ ] Idle seats > 28 días = revocación automática.

## 3. Policies de Copilot (Enterprise)

Comprobar en `https://github.com/enterprises/<telefonica>/settings/copilot/policies`:

- [ ] `Suggestions matching public code` → **Blocked**
- [ ] `Copilot Chat in the IDE` → Allowed
- [ ] `Copilot in GitHub.com` → Allowed
- [ ] `Copilot in the CLI` → Allowed
- [ ] `MCP servers` → Allowed con allow-list
- [ ] `Copilot Extensions` → Allowed con allow-list
- [ ] `Copilot can search the web` → revisado caso por caso
- [ ] `Copilot Coding Agent` → Allowed sandbox / Restricted prod
- [ ] `Editor preview features` → Disabled en prod
- [ ] `Model selection` → solo modelos aprobados por SecOps
- [ ] `Prompt data retention` → Zero (default en Enterprise)
- [ ] `Telemetry` → revisada y conforme

## 4. Content exclusions

- [ ] Archivo `content-exclusions.yml` versionado en repo de plataforma.
- [ ] Cubre como mínimo:
  - [ ] `**/secrets/**`, `**/*.pem`, `**/*.key`
  - [ ] Datos de cliente y PII
  - [ ] Algoritmos propietarios críticos
- [ ] Despliegue automatizado (no manual) vía Action/Workflow.
- [ ] Revisión trimestral con dueños de dominio.

## 5. Defensas complementarias en cada repo

- [ ] **Secret scanning** ON por defecto en Orgs.
- [ ] **Push protection** ON por defecto.
- [ ] **Dependabot alerts + security updates** ON.
- [ ] **CodeQL** o SAST equivalente corriendo en CI.
- [ ] **Branch protection** en `main`/`master`:
  - [ ] PR obligatoria
  - [ ] Mínimo 1 reviewer
  - [ ] Status checks requeridos
  - [ ] Lineal history o squash forzado
- [ ] **CODEOWNERS** definido y poblado.
- [ ] **Repository rulesets** (más nuevo, recomendado sobre branch protection).

## 6. MCP y Extensions

- [ ] Allow-list de MCP servers documentada y publicada.
- [ ] Cada MCP server interno:
  - [ ] Repo en `telefonica-platform/mcp-*`
  - [ ] Review SecOps + threat model
  - [ ] Releases firmadas
  - [ ] Monitorización (logs y latencia)
- [ ] Allow-list de Copilot Extensions revisada.
- [ ] Proceso para solicitar nuevos MCP/Extensions documentado.

## 7. Audit log

- [ ] Streaming de audit log configurado hacia **Sentinel** (o equivalente).
- [ ] Storage destino con **immutability/WORM**.
- [ ] Retención mínima **2 años** (alineado con políticas corporativas).
- [ ] Alertas activas para:
  - [ ] Cambio de policy de Copilot
  - [ ] Asignación masiva de seats
  - [ ] Activación de MCP/Extension fuera del allow-list
  - [ ] Acceso a settings desde IPs no whitelisted
- [ ] Revisión mensual de alertas (incluso si están en verde).

## 8. Datos y cumplimiento

- [ ] **EU Data Residency** activada en GHEC.
- [ ] Política interna de IA generativa firmada.
- [ ] Catálogo aprobado de modelos publicado y consumible vía API interna.
- [ ] DPA con GitHub firmado y archivado.
- [ ] Registro de actividades (RGPD art. 30) actualizado incluyendo Copilot.
- [ ] DPIA realizada para uso de Copilot con datos sensibles (si aplica).

## 9. Operación

- [ ] Runbook de incidente "fuga via Copilot" preparado y probado.
- [ ] Persona de guardia conoce el escalado a GitHub Support (Premium Plus).
- [ ] Tested: cómo revocar Copilot a un usuario en < 5 min.
- [ ] Tested: cómo desactivar Copilot en una Org completa en < 15 min.

## 10. Mejora continua

- [ ] Métricas Copilot recogidas semanalmente (snapshot).
- [ ] Dashboard FinOps actualizado mensualmente.
- [ ] Revisión trimestral de este checklist por SecOps + Plataforma + FinOps.
- [ ] Acta de revisión publicada en repo de gobernanza.

---

## Resumen ejecutivo (para CISO / CIO)

| Bloque | % completado |
|--------|--------------|
| Identidad y accesos | __ % |
| Policies | __ % |
| Content exclusions | __ % |
| Defensas en repo | __ % |
| MCP / Extensions | __ % |
| Audit log | __ % |
| Compliance | __ % |
| Operación | __ % |
| Mejora continua | __ % |
| **Global** | **__ %** |
