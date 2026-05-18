# 01 · Gobernanza y control (25 min)

> ⏱️ **11:05 – 11:30** · Speaker: Líder de Plataforma + SecOps  
> 🎯 **Outcome:** salir con una **policy matrix** definida y conociendo exactamente dónde se configura cada control en GitHub.

---

## 0. Mapa mental (1 min)

La gobernanza de Copilot en GitHub Enterprise se aplica en **4 capas** que se aplican en cascada:

```
┌──────────────────────────────────────────────────────────┐
│ 1. Enterprise Account                                    │  ← Políticas globales (no override)
│    ├─ 2. Organizations                                   │  ← Policies por BU
│    │    ├─ 3. Repositories                               │  ← Reglas de repo, CODEOWNERS
│    │    │    └─ 4. Branches / Files                      │  ← Branch protection, content exclusions
└──────────────────────────────────────────────────────────┘
```

> 🔑 **Regla de oro:** lo que se decide en Enterprise gana siempre. Las Orgs pueden ser más restrictivas, nunca más permisivas.

---

## 1. Gestión de accesos (8 min)

### 1.1 Identidad: SSO + SCIM

- **SAML SSO** contra el IdP corporativo (Azure AD / Entra ID en Telefónica).
- **SCIM** para provisioning automático: alta/baja de usuarios sincronizada con HR.
- **Enterprise Managed Users (EMU)**: cuentas dedicadas, no personales. Recomendado para Telefónica.

**Pasos exactos (Enterprise Owner):**

1. `https://github.com/enterprises/<telefonica>/settings/single_sign_on` → habilitar SAML.
2. `…/settings/scim` → habilitar SCIM, generar token y configurar la app empresarial en Entra ID.
3. `…/people/policies/enterprise_managed_users` → activar EMU (requiere coordinación con GitHub Support; **no es reversible**).

### 1.2 Asignación de Copilot

Tres modos:

| Modo | Cuándo usarlo | Riesgo |
|------|---------------|--------|
| **Asignación manual** | <50 usuarios, piloto | Olvidas dar de baja → idle seats |
| **Grupos de Entra ID** (recomendado) | Estándar Telefónica | Ninguno si los grupos están bien mantenidos |
| **Asignación a toda la Org** | Equipos donde el 100 % usa Copilot | Idle seats si la adopción real es <80 % |

**Configurar grupos en GitHub Enterprise (UI):**

1. `https://github.com/enterprises/<telefonica>/copilot/seat_management`
2. Pestaña **Access** → "Assign seats to selected users or teams".
3. Sincronizar grupos: `Settings → Identity provider → Synced teams` (los teams se rellenan desde Entra ID).
4. Marcar los teams que reciben licencia.

**Vía API (auditable y reproducible):**

```bash
# Listar todos los seats actualmente asignados en una org
gh api -H "Accept: application/vnd.github+json" \
  /orgs/<org>/copilot/billing/seats --paginate

# Asignar Copilot a un team completo
gh api --method POST \
  /orgs/<org>/copilot/billing/selected_teams \
  -f selected_teams[]="plataforma-backend" \
  -f selected_teams[]="plataforma-frontend"

# Quitar Copilot a usuarios concretos
gh api --method DELETE \
  /orgs/<org>/copilot/billing/selected_users \
  -f selected_usernames[]="usuario1" \
  -f selected_usernames[]="usuario2"
```

### 1.3 Roles mínimos necesarios

| Función | Rol mínimo |
|---------|-----------|
| Cambiar policies de Copilot | Enterprise Owner |
| Asignar seats | Org Owner o **Copilot Admin** (custom role) |
| Ver métricas de uso | `read:enterprise` + `manage_billing:copilot` |
| Leer audit log enterprise | Enterprise Owner o Security Manager |
| Aplicar content exclusions | Org Owner / Repo Admin |

> 📌 **Recomendación:** crear un **custom role** `copilot-admin` en cada Org con solo los permisos necesarios (no usar Org Owner para esto).

---

## 2. Políticas de uso (8 min)

### 2.1 Catálogo de policies de Copilot (Enterprise)

Ruta: `https://github.com/enterprises/<telefonica>/settings/copilot/policies`

| Policy | Recomendación Telefónica | Por qué |
|--------|--------------------------|---------|
| **Suggestions matching public code** | `Blocked` | Evita riesgo de copyleft; obliga a Copilot a no devolver matches públicos |
| **Copilot Chat in the IDE** | `Allowed` | Necesario para productividad |
| **Copilot in GitHub.com** | `Allowed` | Habilita Copilot Chat, PR summaries, Spaces |
| **Copilot in the CLI** | `Allowed` | Útil para SRE/DevOps |
| **MCP servers** | `Allowed con allow-list` | Solo MCP servers aprobados por SecOps (ver anexo) |
| **Copilot can search the web (Bing)** | `Allowed` con awareness | Útil pero loggear queries |
| **Copilot Extensions** | `Allowed con allow-list` | Igual que MCP: catálogo aprobado |
| **Copilot Coding Agent** | `Allowed` en sandbox / `Restricted` en repos críticos | Ejecuta tareas autónomas — requiere CODEOWNERS estrictos |
| **Editor preview features** | `Disabled` en producción | Estabilidad |
| **Model selection (Claude, GPT, Gemini...)** | `Allowed` modelos aprobados | Telefónica aprueba modelo a modelo |
| **Data retention for prompts** | `Zero data retention` (Enterprise) | Por defecto en Copilot Enterprise |

### 2.2 Content exclusions (clave para Telefónica)

Bloquea archivos/rutas que Copilot **no debe leer ni usar como contexto**. Ideal para:
- Carpetas con datos regulados (PII, datos financieros).
- Algoritmos propietarios (`/src/pricing/core/**`).
- Configs con secretos (aunque deberían estar en un vault).

**Ruta UI:** `Org settings → Copilot → Content exclusion`

**Archivo de ejemplo** (también en `anexos/plantillas/content-exclusions.yml`):

```yaml
# Aplica a TODOS los repos de la org
"*":
  - "**/secrets/**"
  - "**/*.pem"
  - "**/*.key"
  - "**/customer-data/**"

# Por repo específico
"telefonica-payments/pricing-core":
  - "src/algorithms/proprietary/**"
  - "docs/internal/strategy/**"
```

> ⚠️ **Limitación importante:** las exclusiones **no impiden** que un dev abra el archivo manualmente; solo evitan que Copilot lo use como contexto/inspiración.

### 2.3 Defensas complementarias en el repo

Copilot no es la única superficie de riesgo. Activar **siempre**:

- **Secret scanning + push protection**: bloquea push si detecta credenciales.
- **Dependabot**: alertas y PRs automáticos de seguridad.
- **CodeQL** o herramienta SAST equivalente.
- **Branch protection rules** + **Repository rulesets** (ver §3).
- **CODEOWNERS** obligatorio para revisión.

**Activar a nivel Org de golpe:**

```bash
gh api --method PATCH /orgs/<org> \
  -F secret_scanning_enabled_for_new_repositories=true \
  -F secret_scanning_push_protection_enabled_for_new_repositories=true \
  -F dependabot_alerts_enabled_for_new_repositories=true \
  -F dependabot_security_updates_enabled_for_new_repositories=true
```

---

## 3. Cumplimiento normativo (6 min)

### 3.1 Marco aplicable a Telefónica

| Norma | Implicación práctica |
|-------|----------------------|
| **GDPR / LOPDGDD** | Datos personales no deben fluir a modelos sin base legal |
| **ISO 27001 / ENS** | Auditoría continua, control de accesos, cifrado en tránsito |
| **DORA** (sector financiero del grupo) | Resiliencia operativa: registro de incidentes con proveedores tech |
| **NIS2** | Reporte de incidentes en <24/72h |
| **Política interna de IA generativa** | Catálogo aprobado de modelos + casos de uso |

GitHub Copilot Enterprise cubre de serie:
- **EU Data Residency** (disponible en GHEC desde 2024).
- **Zero data retention** para prompts y respuestas en Copilot Business/Enterprise.
- **SOC 2 Type II**, **ISO 27001/17/18**, **CSA STAR Level 2**.

### 3.2 Audit log — la herramienta clave

El audit log de Enterprise registra **todo evento** relevante de Copilot:

- Asignación/desasignación de seats (`copilot.seat_assigned`, `copilot.seat_cancelled`).
- Cambios de política (`business.update_copilot_business_policy`).
- Acceso a chat (`copilot.chat_event`).
- MCP/Extension activations.

**Consultar desde la UI:**

`https://github.com/enterprises/<telefonica>/audit-log?q=action:copilot`

**Consultar vía API (los últimos 7 días de eventos Copilot):**

```bash
gh api -H "Accept: application/vnd.github+json" \
  "/enterprises/<telefonica>/audit-log?phrase=action:copilot&include=all&per_page=100" \
  --paginate > audit-copilot.json
```

**Streaming continuo** (recomendado para SecOps):

Configurar streaming hacia:
- **Azure Event Hubs** → Sentinel (Telefónica usa Microsoft Sentinel).
- **Splunk HEC**.
- **AWS S3 / Kinesis**.
- **Datadog**.

Ruta: `Enterprise settings → Audit log → Log streaming`.

> 📂 Ver consultas KQL listas para Sentinel en `anexos/scripts/kql-audit-queries.md`.

### 3.3 Retención y evidencia

- Audit log: **180 días** consultables en UI; **infinito** si se hace streaming a almacén propio.
- Métricas Copilot: **28 días** rolling (¡guardar snapshots semanales!).
- Recomendado: job semanal que dumpea métricas y audit a un blob storage corporativo con **immutability policy** (WORM) para evidencia.

---

## 🧪 Lab guiado (incluido en los 25 min)

**Objetivo:** dejar la org `telefonica-sandbox` con la baseline mínima de gobernanza.

```bash
# 1. Verificar el set de policies aplicado
gh api /enterprises/telefonica-copilot-lab/copilot/billing | jq '.seat_breakdown, .public_code_suggestions'

# 2. Activar content exclusions con la plantilla
gh api --method PUT \
  /orgs/telefonica-sandbox/copilot/content-exclusions \
  --input anexos/plantillas/content-exclusions.yml

# 3. Comprobar que las defensas de repo están activas en repos nuevos
gh api /orgs/telefonica-sandbox | jq '{ss: .secret_scanning_enabled_for_new_repositories, pp: .secret_scanning_push_protection_enabled_for_new_repositories, dep: .dependabot_alerts_enabled_for_new_repositories}'

# 4. Exportar audit log de las últimas 24h relacionadas con Copilot
pwsh -File anexos/scripts/export-audit-log.ps1 -Enterprise telefonica-copilot-lab -Hours 24
```

---

## ✅ Checklist de salida del módulo

- [ ] SSO + SCIM operativos y revisados (responsable: IT corporativo).
- [ ] Asignación de Copilot vía **grupos** de Entra ID, no manual.
- [ ] Policies enterprise alineadas con la tabla §2.1.
- [ ] `content-exclusions.yml` desplegado y versionado.
- [ ] Secret scanning + push protection ON por defecto en toda Org nueva.
- [ ] Audit log haciendo streaming a Sentinel (o equivalente).
- [ ] Custom role `copilot-admin` creado.
- [ ] **Policy matrix** rellena para al menos una BU (plantilla en `anexos/plantillas/policy-matrix.md`).

➡️ Siguiente: [`02-modelo-de-costes.md`](./02-modelo-de-costes.md)
