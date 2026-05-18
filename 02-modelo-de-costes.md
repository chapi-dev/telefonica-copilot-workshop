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
│ 2. Premium requests (Claude, GPT-5, modelos grandes)        │
│ 3. Copilot Coding Agent (GitHub Actions minutes + storage)  │
│ 4. Coste oculto: idle seats + sobreasignación               │
└─────────────────────────────────────────────────────────────┘
```

> 💡 En la mayoría de tenants enterprise, **el coste oculto (#4) supera el 20 %**. Es el primer objetivo a atacar.

---

## 2. SKUs y modelo de licenciamiento (3 min)

| SKU | Pensado para | Incluye | No incluye |
|-----|--------------|---------|-----------|
| **Copilot Business** | Empresas estándar | Code completion, Chat IDE, modelos base, content exclusions, audit log | Knowledge bases, Copilot en GitHub.com avanzado, fine-tuning |
| **Copilot Enterprise** | Grandes empresas reguladas (Telefónica) | Todo Business + Knowledge bases, Copilot en PRs, custom instructions a nivel org, EU data residency, Coding Agent ilimitado en repos privados | – |

**Premium requests** (modelo de "uso adicional" desde 2025):

- Cada interacción con modelos premium (Claude Sonnet, GPT-5, Gemini 2.x) **consume 1 premium request**.
- Cada plan trae una cuota mensual incluida; el resto se factura como consumo.
- **Coste típico**: muy bajo por request, pero **se acumula rápido en equipos grandes** si no se controla.

> 🔑 Para Telefónica recomendamos **Copilot Enterprise** con un **budget mensual de premium requests** por org/BU.

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

### 4.2 Controlar premium requests (quick win #2)

- Activar **budget alerts**: `Enterprise settings → Billing → Budgets and alerts → New budget`.
- Definir budget por **org** (no global): permite atribuir al cost center correcto.
- Alertas al 50 %, 75 %, 90 % del presupuesto.
- Si se supera el 100 %, decidir si: (a) cortar acceso a premium o (b) seguir con cargo extra (configurable).

**Buenas prácticas para reducir gasto premium sin perder valor:**

1. **Custom instructions** que indiquen a Copilot usar modelo base salvo necesidad explícita.
2. **Educar**: no usar Claude Sonnet 4.6 para autocompletar imports. Dejarlo para refactors complejos.
3. **Prompt files** reutilizables para tareas repetitivas (evitan iteraciones que queman requests).
4. **Mirar el ratio acceptance** de modelos premium: si es bajo, el modelo no está dando valor.

### 4.3 Coding Agent: el coste invisible

Cada tarea del **Copilot Coding Agent** consume:
- Minutos de GitHub Actions (en un runner gestionado por GitHub).
- Storage temporal.
- Premium requests del modelo elegido.

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
| Premium requests extra | __ | __ €/req | __ € |
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
