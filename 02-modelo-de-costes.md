# 02 · Modelo de costes (20 min)

> ⏱️ **11:30 – 11:50** · Speaker: FinOps + Plataforma  
> 🎯 **Outcome:** salir sabiendo **cuánto cuesta hoy** Copilot en vuestra BU, qué seats están idle y cómo medir ROI con datos reales.

---

## 1. Mapa del coste real (3 min)

Copilot no es una sola línea en la factura. El coste total ("TCO") tiene 4 componentes:

```
┌─────────────────────────────────────────────────────────────┐
│ COSTE TOTAL DE COPILOT EN TELEFÓNICA                        │
├─────────────────────────────────────────────────────────────┤
│ 1. Licencias Copilot (per seat / mes)                       │
│ 2. GitHub AI Credits (consumo por tokens — antes "PRUs")    │
│ 3. Copilot Coding Agent (GitHub Actions minutes + storage)  │
│ 4. Coste oculto: idle seats + sobreasignación               │
└─────────────────────────────────────────────────────────────┘
```

> 💡 En la mayoría de tenants enterprise, **el coste oculto (#4) supera el 20 %**. Es el primer objetivo a atacar.

> 🔄 **Cambio de modelo de billing — 1 de junio de 2026:** GitHub sustituye las **Premium Requests (PRUs)** por **GitHub AI Credits**. El consumo se mide ahora por **tokens** (input + output + cache), con tarifa propia por modelo. **1 AI Credit = $0.01 USD**. Code completions y Next Edit Suggestions **siguen siendo gratis** (no consumen credits). Más detalle en §2.

---

## 2. SKUs y modelo de licenciamiento (3 min)

| SKU | Pensado para | Incluye | No incluye |
|-----|--------------|---------|-----------|
| **Copilot Business** | Empresas estándar | Code completion, Chat IDE, modelos base, content exclusions, audit log | Knowledge bases, Copilot en GitHub.com avanzado, fine-tuning |
| **Copilot Enterprise** | Grandes empresas reguladas (Telefónica) | Todo Business + Knowledge bases, Copilot en PRs, custom instructions a nivel org, EU data residency, Coding Agent ilimitado en repos privados | – |

**GitHub AI Credits** (modelo vigente desde el **1 junio 2026**, sustituye a Premium Requests):

- **Unidad de cuenta:** **1 AI Credit = $0.01 USD**.
- **Métrica:** se factura por **tokens** consumidos (input + output + cache).
- **Cada modelo tiene su tarifa** por millón de tokens; Claude Opus consume muchos más credits que GPT-5 mini para la misma tarea.
- **Cada plan incluye una cuota mensual** de credits:
  - Copilot Pro: 1.000 credits ($10).
  - Copilot Pro+: ~3.900 credits ($39).
  - Copilot Business / Enterprise: cuota negociada en el contrato.
- **Una vez agotada la cuota:** se factura por consumo (overage) o se bloquea (según `budget action`).
- **Code completions inline y Next Edit Suggestions: GRATIS, no consumen credits.**
- **Lo que SÍ consume credits:** Copilot Chat, Coding Agent, Code Review by Copilot, sesiones agénticas multi-step.
- ⚠️ **No hay fallback** automático a modelo barato cuando se acaba la cuota (a diferencia del modelo PRU antiguo).

> 🔑 Para Telefónica recomendamos **Copilot Enterprise** con **budgets por cost center** (1 CC = 1 BU/proyecto) y **monitoring per-user vía Metrics API** para detectar power-users antes de que agoten la cuota del equipo. Los budgets de la UI no soportan scope "per user" (solo Enterprise / Org / Cost center).

> 🗓️ **Migración:** los clientes con **annual plans** mantienen el esquema PRU hasta la fecha de renovación; tras la renovación pasan automáticamente al modelo AI Credits.

---

## 3. Métricas de adopción y consumo (6 min)

### 3.1 Copilot Metrics API (la fuente de la verdad)

Endpoint principal:

```
GET /orgs/{org}/copilot/metrics
GET /enterprises/{enterprise}/copilot/metrics
```

Devuelve, para cada uno de los **últimos 28 días**:

- Usuarios activos en IDE / Chat / PR.
- Sugerencias mostradas vs aceptadas (acceptance rate).
- Líneas de código sugeridas vs aceptadas.
- Breakdown por **lenguaje** y por **editor** (VS Code, JetBrains, Visual Studio, Neovim, etc.).
- Uso de Copilot Chat: turnos, % chats útiles.

**Ejemplo de consulta:**

```bash
gh api /enterprises/telefonica-copilot-lab/copilot/metrics \
  -H "Accept: application/vnd.github+json" > metrics-28d.json

# Aceptance rate medio últimos 28 días
jq '[.[].copilot_ide_code_completions.editors[].models[].languages[] 
     | {lang: .name, ar: (.total_code_acceptances / (.total_code_suggestions+1))}]
     | group_by(.lang) | map({lang: .[0].lang, ar_avg: (map(.ar) | add / length)})' metrics-28d.json
```

> 📂 Script PowerShell completo: `anexos/scripts/pull-copilot-metrics.ps1`

### 3.2 KPIs que hay que mirar (no todos)

| KPI | Cómo se calcula | Bueno | Alerta |
|-----|----------------|-------|--------|
| **Adopción activa** | Active users ÷ Seats asignados (28d) | ≥ 80 % | < 60 % |
| **Engagement** | Active users IDE ÷ Active users totales | ≥ 70 % | < 50 % |
| **Acceptance rate (suggestion)** | Acepts ÷ Suggestions mostradas | 25–45 % | < 15 % |
| **Chat utility** | Chats con acepts ÷ Chats totales | ≥ 40 % | < 20 % |
| **Idle ratio** | Seats sin actividad 28d ÷ Seats totales | < 10 % | > 20 % |
| **Coste por dev activo / mes** | Coste total ÷ Active users | – | Crece sin razón |

### 3.3 Dashboard recomendado

Tres opciones, según el ecosistema interno:

1. **GitHub native** → Copilot Usage page (UI built-in) — bueno para empezar.
2. **Power BI** (Telefónica estándar) → conector custom contra Copilot Metrics API. Refresh diario.
3. **Grafana / Datadog** → para equipos de SRE que ya tienen stack.

---

## 4. Optimización del consumo (6 min)

### 4.1 Cazar idle seats (quick win #1)

Definición operativa: seat asignado **sin actividad en 28 días**.

```bash
pwsh -File anexos/scripts/identify-idle-seats.ps1 -Org telefonica-sandbox -DaysIdle 28
```

El script:
1. Pulla seats de `/orgs/{org}/copilot/billing/seats`.
2. Cruza con `last_activity_at`.
3. Devuelve CSV con: usuario · team · días sin actividad · ahorro mensual estimado.

**Política recomendada para Telefónica:**

| Días sin actividad | Acción |
|--------------------|--------|
| 14 | Aviso por email al usuario + manager |
| 21 | Aviso final |
| 28 | Revocación automática vía SCIM/grupo |

> ⚠️ Documentar la política en intranet. No revocar sin warning previo.

### 4.2 Controlar AI Credits / Premium Requests (quick win #2)

- Activar **budget alerts**: `Enterprise settings → Billing → Budgets and alerts → New budget`.
- **Scopes disponibles** (a 2026-05, los 3 únicos):
  - **Enterprise** → techo global. Opción "Exclude cost center usage" para no doblar control.
  - **Organization** → por BU.
  - **Cost center** → patrón recomendado, alineado con FinOps (1 CC por BU/proyecto).
- ⚠️ **No existe scope "per user"** en la UI de budgets. El control per-user real proviene de:
  1. La **cuota incluida en cada seat** Business/Enterprise (límite hardcoded del SKU).
  2. **Cost center de 1 solo user** (workaround para casos críticos puntuales, no escalable).
  3. **Alertas custom** sobre la Metrics API (pull diario por user, alerta en Sentinel/PagerDuty).
- Alertas: 50 %, 75 %, 90 % del presupuesto.
- **Stop usage when budget limit is reached** ✅ (hard-stop) en prod; sólo notificar en lab.

**Buenas prácticas para reducir consumo sin perder valor:**

1. **Custom instructions** que indiquen a Copilot usar **modelo eficiente por defecto** (GPT-5 mini, Claude Haiku) y reservar Opus / GPT-5.x para refactors complejos.
2. **Educar al equipo:** un mismo prompt resuelto por Claude Opus puede consumir **10×–30× más credits/requests** que con GPT-5 mini. Importa qué modelo eliges.
3. **Prompt files reutilizables** para tareas repetitivas (evitan iteraciones que queman cuota).
4. **Acotar el contexto del chat:** cerrar archivos irrelevantes, no incluir todo el repo. El contexto cuenta como input tokens.
5. **Mirar ratio de aceptación de modelos premium:** si la aceptación es baja, el modelo no está dando valor → revisar política.
6. **Limitar Coding Agent** (la actividad más cara): timeouts cortos, allow-list de repos, revisión semanal de tareas largas.
7. **Monitoring per-user con Metrics API**: el único camino para detectar al "power-user" que se come la cuota del team antes de que pase.

### 4.3 Coding Agent: el coste invisible

Cada tarea del **Copilot Coding Agent** consume:
- Minutos de GitHub Actions (en un runner gestionado por GitHub).
- Storage temporal.
- **AI Credits** del modelo elegido (tokens de input + output + cache de las herramientas que invoca el agente).

Controles:

- Limitar quién puede invocarlo (`Settings → Copilot → Coding agent → Allowed users`).
- Limitar repos donde puede operar (allow-list).
- Establecer **timeout por tarea** (default 30 min).
- Auditar tareas completadas semanalmente.

### 4.4 Reasignación inteligente

- Crear un **pool dinámico** de seats: en lugar de asignar a personas, asignar a teams.
- Si un dev se va de un team → pierde el seat automáticamente (vía Entra ID).
- Si entra → lo gana automáticamente.

---

## 🧪 Lab guiado (incluido en los 20 min)

```bash
# 1. Pull de métricas (snapshot del día)
pwsh -File anexos/scripts/pull-copilot-metrics.ps1 -Org telefonica-sandbox -Out metrics

# 2. Identificar idle seats últimos 28 días
pwsh -File anexos/scripts/identify-idle-seats.ps1 -Org telefonica-sandbox -DaysIdle 28

# 3. Calcular acceptance rate ponderado por lenguaje
jq '[.copilot_ide_code_completions.editors[].models[].languages[] 
     | select(.total_code_suggestions > 100)
     | {lang: .name, ar: (100*.total_code_acceptances/.total_code_suggestions)}]
     | sort_by(.ar) | reverse' metrics/latest.json

# 4. (Opcional) Revocar un seat de prueba
gh api --method DELETE /orgs/telefonica-sandbox/copilot/billing/selected_users \
  -f selected_usernames[]="usuario-de-prueba"
```

---

## 📊 Plantilla de TCO mensual (rellenar en vivo)

| Concepto | Cantidad | Precio unidad | Total |
|----------|----------|---------------|-------|
| Copilot Enterprise seats | __ | __ €/mes | __ € |
| AI Credits incluidos en el plan | __ | (incluidos) | 0 € |
| AI Credits adicionales (overage) | __ credits | 0,01 $/credit | __ € |
| Actions minutes (Coding Agent) | __ | __ €/min | __ € |
| Storage adicional | __ GB | __ €/GB | __ € |
| **Subtotal** | | | __ € |
| Idle seats detectados | __ | __ €/mes | **-__ € (ahorro)** |
| **TCO neto** | | | **__ €/mes** |

---

## ✅ Checklist de salida del módulo

- [ ] Política de **idle seats** definida y comunicada.
- [ ] **Budget alerts** activadas en cada org productiva.
- [ ] **Dashboard** (GitHub native / Power BI) accesible para FinOps y líderes.
- [ ] **Snapshot semanal** de métricas programado (Action o pipeline).
- [ ] **Pool dinámico** vía teams sincronizados desde Entra ID.
- [ ] Plantilla TCO rellena para al menos una BU.

➡️ Siguiente: [`03-skills-y-conectores.md`](./03-skills-y-conectores.md)
