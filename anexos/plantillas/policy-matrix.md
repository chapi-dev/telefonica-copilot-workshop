# Policy Matrix — Copilot en Telefónica

> Plantilla que cada BU **debe rellenar y firmar** con SecOps + FinOps.  
> Una vez aprobada, se traduce a configuración real en Enterprise/Org settings.

---

## Metadatos

| Campo | Valor |
|-------|-------|
| **Unidad de Negocio (BU)** | <ej. Telefónica España — Payments> |
| **Org GitHub** | `<telefonica-payments>` |
| **Aprobado por SecOps** | Nombre + fecha |
| **Aprobado por FinOps** | Nombre + fecha |
| **Aprobado por DPO** | Nombre + fecha |
| **Vigencia** | 12 meses (revisar antes de YYYY-MM-DD) |
| **Versión** | v1.0 |

---

## 1. Asignación de seats

| Aspecto | Decisión |
|---------|----------|
| Modo de asignación | ☐ Manual ☐ Grupos Entra ID ☐ Toda la org |
| Aprobador para nuevos seats | <rol/persona> |
| SLA alta | <horas/días> |
| Política idle seats | Días sin actividad → acción: 14d aviso, 21d aviso final, 28d revocación |
| Coste por seat / mes | __ € |
| Seats máximos autorizados | __ |

## 2. Policies enterprise aplicables

| Policy | Valor decidido | Justificación |
|--------|----------------|---------------|
| Suggestions matching public code | Blocked | Compliance copyleft |
| Copilot Chat in IDE | Allowed | Productividad |
| Copilot in GitHub.com | Allowed | PR summaries útiles |
| Copilot in CLI | Allowed | SRE/DevOps |
| MCP servers | Allowed (allow-list) | Catálogo aprobado por SecOps |
| Copilot Extensions | Allowed (allow-list) | Igual que MCP |
| Web search (Bing) | Allowed con logging | Productividad |
| Coding Agent | <Allowed sandbox / Restricted prod> | <razón> |
| Editor preview features | Disabled en prod | Estabilidad |
| Modelos aprobados | <lista: GPT-4.1, Claude Sonnet 4.6, ...> | Validados por SecOps |
| Prompt data retention | Zero | Default Enterprise |

## 3. Content exclusions

Rutas/patrones excluidos a nivel org (ver `content-exclusions.yml`):

| Patrón | Motivo | Owner |
|--------|--------|-------|
| `**/secrets/**` | Defensa en profundidad | SecOps |
| `**/customer-data/**` | RGPD | DPO |
| `src/algorithms/proprietary/**` | IP propietaria | CTO |
| <añadir> | | |

## 4. Roles y responsabilidades

| Rol | Responsable |
|-----|-------------|
| Enterprise Owner | <persona> (1-2 backup) |
| Org Owner | <persona> |
| `copilot-admin` (custom) | <equipo> |
| SecOps liaison | <persona> |
| FinOps liaison | <persona> |
| Champions (≥1 por team grande) | Lista en intranet |

## 5. Auditoría

| Aspecto | Decisión |
|---------|----------|
| Audit log streaming a | <Sentinel workspace> |
| Retención evidencia | 24 meses WORM |
| Alertas configuradas | Cambio policy, asignación masiva, MCP/Ext fuera allow-list |
| Revisión SecOps | Mensual |

## 6. Presupuesto (referencia, no scope del workshop)

> Pricing y budgets de Copilot se gestionan a nivel **contrato enterprise + Billing/Budgets de la UI**. Esta tabla es solo para alinear FinOps con la BU; el workshop no entra en este detalle.

| Aspecto | Decisión |
|---------|----------|
| Modelo default aprobado (eficiente) | ☐ Mini ☐ Haiku ☐ Otro: __ |
| Modelos premium permitidos solo bajo justificación | ☐ Opus ☐ GPT-5.x ☐ Sonnet |
| Política Coding Agent | ☐ Permitido siempre ☐ Allow-list de repos ☐ Solo background tasks |
| Revisión trimestral de adopción + acceptance rate | ☐ Sí ☐ No |

## 7. MCP servers y Extensions aprobados

### MCP servers
| Nombre | Propósito | Owner | Revisado SecOps el |
|--------|-----------|-------|---------------------|
| `github` (oficial) | API GitHub | Plataforma | YYYY-MM-DD |
| `telefonica-jira` | Lectura Jira | DevEx | YYYY-MM-DD |
| <añadir> | | | |

### Extensions
| Nombre | Propósito | Owner | Revisado SecOps el |
|--------|-----------|-------|---------------------|
| <añadir> | | | |

## 8. Operación (runbooks listos)

- [ ] Runbook "Revocar seat individual"
- [ ] Runbook "Desactivar Copilot en org completa"
- [ ] Runbook "Investigar incidente sospechoso en audit log"
- [ ] Runbook "Onboarding de nuevo MCP server"

## 9. Excepciones autorizadas

| Excepción | Justificación | Caduca | Aprobada por |
|-----------|---------------|--------|--------------|
| <ej. Editor preview features en sandbox> | Validar features beta | YYYY-MM-DD | <persona> |

---

## Firma

| Rol | Nombre | Fecha | Firma |
|-----|--------|-------|-------|
| Owner BU | | | |
| CISO / SecOps | | | |
| FinOps | | | |
| DPO | | | |
