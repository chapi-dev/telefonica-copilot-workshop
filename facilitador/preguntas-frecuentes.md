# ❓ Preguntas frecuentes (FAQ) — Copilot en Telefónica

> Respuestas cortas y accionables a las dudas más comunes. Mantener actualizado tras cada workshop.

---

## Privacidad y datos

### ¿GitHub entrena modelos con nuestro código?
**No.** Con Copilot Business y Enterprise, GitHub **no usa** vuestros prompts ni código para entrenar modelos. Política de **zero data retention** para prompts/responses.

### ¿Dónde se procesan los prompts?
En infraestructura de GitHub/Microsoft. Con **EU Data Residency** activada (disponible en GHEC Enterprise), los datos en reposo se mantienen en la UE.

### ¿Qué pasa con los datos personales (PII) en el código?
- Mejor práctica: **no enviar PII** en prompts (custom instructions explícitas).
- Si pasa: el contenido del prompt **no se retiene** ni se entrena. Pero queda evidencia en el audit log de la acción (no del contenido).

### ¿Copilot puede ver código privado de OTRAS organizaciones?
**No.** Cada tenant está aislado. Copilot ve solo lo que tu cuenta puede ver en tu org.

### ¿Qué evita que Copilot devuelva código copyleft (GPL)?
La policy `Suggestions matching public code → Blocked`. Cuando una sugerencia coincide >150 caracteres con código público, se descarta.

---

## Seguridad

### ¿Copilot puede introducir vulnerabilidades?
Sí, igual que cualquier dev junior. Mitigación obligatoria:
- Code review humano.
- CodeQL / SAST en CI.
- Secret scanning + push protection.
- Tests.

### ¿Y si Copilot sugiere una librería maliciosa?
Defensa multi-capa:
- Allow-list de dependencias.
- Dependabot security alerts.
- Bloqueo en CI si una dep no está aprobada.
- Custom instruction: *"Nuevas dependencias requieren aprobación"*.

### ¿Cómo revoco Copilot a un usuario en 1 minuto?
```bash
gh api --method DELETE /orgs/<org>/copilot/billing/selected_users \
  -f selected_usernames[]="<login>"
```
O desde UI: `Org settings → Copilot → Access → buscar usuario → Remove`.

### ¿Cómo desactivo Copilot en una org completa en emergencia?
`Enterprise settings → Copilot → Access → desmarcar org`. Surte efecto en <5 min.

---

## Optimización de consumo

> Pricing, SKUs y modelos de licenciamiento están fuera del alcance del workshop. Para precios actualizados, consultar [github.com/features/copilot/plans](https://github.com/features/copilot/plans) o el contrato enterprise de Telefónica.

### ¿Qué acciones de Copilot consumen tokens y cuáles no?
**Gratis:** code completions inline + Next Edit Suggestions.
**Consumen:** Copilot Chat, Inline Chat, Edit mode, Coding Agent, Copilot en PRs, MCP server invocations.
La mayor parte del día a día (autocomplete) no consume. El gasto real viene del Chat largo y del Agent mal usado.

### ¿Cómo reduzco consumo sin perder valor?
1. **Cambiar el modelo default** a uno eficiente (Mini / Haiku). Escalar a Opus solo cuando lo requiera la tarea.
2. **Evitar Coding Agent** para tareas simples — usar Inline Chat o Edit mode.
3. **1 chat = 1 tarea**: cerrar y abrir uno nuevo en vez de arrastrar 200 turnos.
4. **Custom instructions** que pidan respuestas concisas.
5. **Prompt files** reutilizables con modelo fijado para tareas repetitivas.
6. **Acotar el contexto** del chat (cerrar archivos irrelevantes, usar `#file:` explícito, evitar `@workspace` cuando no aporta).

### ¿Cuándo SÍ vale lanzar el Coding Agent?
- Migración mecánica en N archivos.
- Bug que requiere ejecutar tests e iterar hasta verde.
- Tareas con criterio de "done" claro.
- Tareas en background mientras haces otra cosa.
- **No** para una edición de 2 líneas — eso es Inline Chat.

---

## Adopción

### Mi equipo no usa Copilot. ¿Qué hago?
1. Identificar a un campeón en el equipo.
2. Diagnosticar barreras (tooling, formación, miedo, mala UX).
3. Sesión de 30 min de patrones (basada en módulo 4).
4. Acompañar 2 semanas, medir.

### ¿Cómo mido si Copilot está funcionando?
Métricas trimestrales:
- Acceptance rate ≥ 30 %.
- Lead time PR ↓ vs baseline.
- NPS dev ≥ 50.
- Coste/dev activo plano o ↓.

### Mi equipo dice que las sugerencias son malas. ¿Por qué?
Típicamente:
1. No hay `copilot-instructions.md` → sugerencias genéricas.
2. Repo sin tests → Copilot no tiene "ground truth".
3. Modelo mal elegido (autocompletar con modelo de chat caro).
4. Falta de formación en prompting.

---

## Técnicas

### Diferencia entre Ask, Edit y Agent
| Modo | Output | Cuándo |
|------|--------|--------|
| Ask | Texto/explicación | Entender, diseñar |
| Edit | Diffs por archivo, con confirmación | Cambio acotado |
| Agent | Múltiples archivos, ejecuta tests, itera | Tarea larga con criterio claro |

### ¿Qué modelo elijo?
- **Autocompletado** → modelo rápido (default).
- **Edits acotados** → modelo medio (Sonnet, GPT-4.1).
- **Agent en tareas complejas** → modelo grande (Sonnet 4.6, Opus, GPT-5).
- **Reasoning extremo** (arquitectura) → modelos "high reasoning".

### ¿Custom instructions a nivel personal sobrescriben las del repo?
Se **combinan**. Las del repo tienen prioridad práctica porque suelen ser más específicas. Las del usuario suelen ser preferencias generales ("respóndeme en español").

### ¿Puedo versionar prompt files?
Sí, viven en `.github/prompts/` y se versionan como cualquier archivo. Recomendable hacer code review de los importantes.

### ¿Qué pasa si un MCP server interno cae?
Copilot sigue funcionando, sólo pierde el tool concreto. Mostrará error en el panel MCP. Aplicar **timeouts** y **circuit breakers** en los MCP corporativos.

---

## Gobernanza

### ¿Quién aprueba un nuevo MCP server interno?
SecOps + Plataforma DevEx. Proceso:
1. Repo en `telefonica-platform/mcp-*`.
2. Threat model.
3. SAST.
4. Release firmada.
5. Add al allow-list enterprise.

### ¿Puedo dar Copilot solo a algunos repos?
Sí, indirectamente:
- Asignación por **teams** sincronizados con Entra ID.
- Acceso a repos via team membership.
- Si el usuario no tiene acceso al repo → Copilot no ve el repo.

### ¿Cómo audito qué tool MCP invocó un dev concreto?
El audit log registra activaciones de MCP. **No registra el contenido** del prompt/respuesta. Si necesitáis más detalle, instrumentar el propio MCP server interno con logs.

---

## Coding Agent

### ¿Es seguro dejar a un agente abrir PRs solo?
Sí **si**:
- Allowed users acotado.
- Allowed repos acotado.
- CODEOWNERS estricto → toda PR del agente requiere review humana.
- Branch protection bloquea merge sin status checks.

### ¿El agente puede ejecutar comandos arbitrarios?
Tiene un runner sandbox de GitHub. Puede ejecutar lo que el repo permita (tests, lints, builds). No tiene acceso a infra interna salvo que se configure.

### ¿Y si necesito que un workflow llegue a recursos privados de Azure (Key Vault, AKS, ACR)?
Activar **Hosted Compute Networking**: GitHub inyecta una NIC del runner dentro de tu VNet corporativa. Mantienes runners gestionados (cero operación) y a la vez tu workflow accede a private endpoints sin exponer IPs públicas. Ventaja clave para Telefónica: cumple políticas DORA/NIS2 y se combina con OIDC trust hacia Azure (elimina secretos de service principal). Detalle en [§2.5 del módulo 01](../01-gobernanza-y-control.md#25-hosted-compute-networking--runners-conectados-a-tu-red-corporativa).

### ¿Puedo asignar Copilot como reviewer en PRs?
Sí. Útil para primer pase ligero. **No sustituye** la revisión humana en repos críticos.

---

## Compliance

### ¿Copilot es compatible con ISO 27001 / ENS?
Sí, GitHub Copilot Enterprise está certificado en SOC 2 Type II, ISO 27001/17/18, CSA STAR Level 2. Documentación en el [Trust Center](https://copilot.github.trust.page/).

### ¿RGPD?
- DPA disponible.
- EU Data Residency disponible.
- Zero data retention.
- DPIA recomendada para usos con datos sensibles.

### ¿DORA / NIS2?
- Audit log + retención WORM → cumple evidencia.
- Streaming a Sentinel → cumple monitorización.
- Runbooks de respuesta → cumple respuesta a incidentes.

---

## Cosas que NO se pueden hacer (hoy)

- ❌ Fine-tuning del modelo con código privado de Telefónica.
- ❌ Restringir respuestas de Copilot solo a knowledge base específica (en Chat IDE).
- ❌ Cifrado con clave gestionada por el cliente para prompts (BYOK).
- ❌ Air-gapped on-prem (no existe versión on-prem de Copilot).

Si alguna de estas es bloqueante para un caso de uso, escalar a GitHub para roadmap.
