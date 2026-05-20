# 02 · Optimización de consumo (20 min)

> ⏱️ **11:30 – 11:50** · Speaker: Plataforma + DevEx  
> 🎯 **Outcome:** salir sabiendo **qué consume tokens y qué no**, cuándo evitar el Coding Agent, cómo elegir modelo y los patrones diarios que reducen el consumo sin perder valor.

> 📌 **Alcance del módulo:** este bloque trata exclusivamente de **optimización táctica del consumo** (cómo "gastar menos tokens" en el día a día). Pricing, SKUs, billing y plantillas TCO viven en la documentación oficial de GitHub — aquí nos centramos en lo que el **dev y el tech lead** pueden controlar.

---

## 1. La regla mental del consumo (2 min)

Antes de optimizar, hay que tener clara una distinción que casi nadie conoce: **no todas las acciones de Copilot consumen igual**.

| Acción Copilot | ¿Consume tokens? | Notas |
|----------------|:----------------:|-------|
| **Inline code completions** (autocomplete gris) | ❌ Gratis | Tu pan de cada día |
| **Next Edit Suggestions** | ❌ Gratis | Las sugerencias del cursor siguiente |
| **Inline Chat** (`Ctrl+I` / `Cmd+I` en VS Code) | ✅ Consume | Bajo si la ventana es corta |
| **Copilot Chat panel** | ✅ Consume | Crece con el historial |
| **Edit mode** (multi-file edits guiados) | ✅ Consume | Medio |
| **Coding Agent / Agent mode** | ✅✅ Consume mucho | Multi-step + ejecución de herramientas |
| **Copilot en PRs** (descripción, review, summary) | ✅ Consume | Por evento |
| **MCP server invocations** | ✅ Consume | Cuenta como tool calls |

> 🔑 **Mensaje clave:** la mayor parte del día a día (autocomplete) es **gratis**. El consumo viene de chats largos, modelos sobredimensionados y agentes lanzados para tareas triviales.

---

## 2. Elegir el modelo correcto (4 min)

Como regla práctica, **al subir de modelo subes 5×–30× los tokens consumidos para la misma tarea**. Elegir el modelo es la palanca de optimización más grande.

### Tabla rápida: qué modelo para qué tarea

| Tarea | Modelo recomendado | Por qué |
|-------|--------------------|---------|
| Autocomplete inline | El built-in (gratis) | Automático, sin elegir |
| "¿Qué hace esta función?" | **GPT-5 mini / Claude Haiku** | Tarea trivial, sin razonamiento |
| Generar tests unitarios | Mini / Haiku | Patrón mecánico |
| Generar regex / SQL simple | Mini | Salida corta |
| Explicar un stack trace | Mini / Haiku | Lectura + síntesis |
| Refactor de 1 archivo | Sonnet / GPT-5 base | Equilibrio coste/calidad |
| Bug complejo multi-archivo | Sonnet | Mejor manejo de contexto |
| Diseño de arquitectura | Opus / GPT-5.x | Razonamiento profundo |
| Migración masiva (Cobol → Java) | Opus + Agent | Vale lo que cuesta |
| "Hello world" / pruebas exploratorias | Mini | No tires Opus al aire |

### Anti-patrón del default mal puesto

❌ Dejar **Claude Opus** como modelo default del equipo → cualquier "explícame este import" cuesta 30× lo razonable.

✅ Configurar **modelo eficiente como default** (Mini / Haiku) y **escalar manualmente** solo cuando la tarea lo exige. Ese único cambio reduce el consumo del equipo entre 40 % y 70 %.

Dónde se cambia el default:

- **Per-user**: VS Code → Copilot Chat → selector de modelo en la cabecera.
- **Per-org / enterprise** (recomendado): policy `Model selection` con allow-list que pone delante los modelos eficientes y restringe Opus a casos justificados.

---

## 3. Cuándo NO usar Coding Agent (3 min)

El Coding Agent es la herramienta **más cara por sesión**: ejecuta múltiples turnos, invoca herramientas y arrastra mucho contexto. Para la mayoría de tareas hay alternativas más baratas y rápidas.

### Si quieres…

| Tarea | NO uses Agent. Usa… |
|-------|---------------------|
| Cambiar 1 línea | Inline edit (`Ctrl+I`) |
| Renombrar una variable / símbolo | Refactor nativo del IDE |
| Generar 1 test | Inline Chat con prompt corto |
| "Documentame esta función" | Inline Chat |
| Cambio multi-archivo guiado (tú decides los pasos) | **Edit mode** (no Agent) |
| Hotfix urgente de 2 líneas | Inline Chat |
| "Explícame este código" | Inline Chat |

### Cuándo SÍ vale el Agent

- **Migración mecánica** repetida en N archivos (donde paso a paso humano sería tedioso).
- **Bug que requiere ejecutar tests + iterar** hasta verde.
- **Tarea con criterio de "done" claro** (tests pasan, lint pasa, build verde).
- **Repos con CODEOWNERS estricto** que garantizan review humana del PR del agente.
- **Tareas en background** mientras tú haces otra cosa.

### Cómo lanzar Agent de forma frugal

1. **Prompt concreto y acotado**: *"Migra estos 3 archivos de class components a hooks. No cambies tests"*. Evita *"refactoriza el frontend"*.
2. **Limitar archivos en el contexto** (no toda la app).
3. **Modelo intermedio por defecto** (Sonnet/GPT-5 base), no Opus salvo casos complejos.
4. **Timeouts cortos** para que no se eternice.
5. **Revisar el PR rápido** para abortar a tiempo si el agente se desvía.

---

## 4. Acotar el contexto del chat (3 min)

Los **input tokens** cuentan, y son fáciles de inflar sin darse cuenta. Si tu chat arrastra 50 archivos abiertos y un historial de 200 mensajes, cada turno cuesta varias veces más de lo necesario.

### Buenas prácticas con ahorro estimado

| Práctica | Ahorro |
|----------|:------:|
| **Cerrar archivos irrelevantes** antes de abrir Chat | 20–40 % |
| Usar `#file:auth.ts` explícito en vez de "el archivo de auth" | 30–60 % |
| **Empezar chat nuevo** en vez de continuar uno de 200 turnos | 50–80 % |
| Quitar imágenes / screenshots pesados que no aportan | ~30 % |
| Evitar `@workspace` cuando la pregunta es local a un archivo | ~40 % |
| Usar slash-commands cortos (`/explain`, `/fix`, `/tests`) | ~10 % |
| Pegar fragmentos relevantes en vez de archivos enteros | 30–50 % |

### El anti-patrón "chat eterno"

❌ Dev abre Chat al empezar el sprint, no lo cierra en 2 semanas → cada turno arrastra cientos de mensajes de contexto, y el coste por respuesta crece linealmente.

✅ **1 tarea = 1 chat nuevo**. Cierra al terminar. Si vas a otra tarea, abre uno limpio.

---

## 5. Custom instructions para forzar concisión (2 min)

Cada vez que Copilot responde con un texto verboso, estás pagando por tokens que no usas. Añadir al `.github/copilot-instructions.md` del repo (o nivel Org) una sección de eficiencia:

```markdown
## Optimización de consumo

- Responde de forma concisa, sin verbosidad innecesaria.
- No repitas el código del usuario en la respuesta — solo el cambio.
- Si dudas, pregunta antes de generar 500 líneas.
- Prefiere modelos eficientes (Haiku, Mini) salvo que el problema lo requiera.
- Para tareas mecánicas (tests, docs), genera de una pasada sin iterar.
- No incluyas explicaciones largas tras el código a menos que se te pidan.
- Si el contexto es ambiguo, pide aclaración en vez de asumir y producir N variantes.
```

Esto reduce típicamente **30–50 % de los output tokens** de cualquier sesión, y mejora la legibilidad de las respuestas como efecto colateral.

> 📂 La plantilla `anexos/plantillas/copilot-instructions.md` incluye esta sección lista para copiar.

---

## 6. Prompt files reutilizables (2 min)

Para las **5–10 tareas más repetitivas** del equipo, crear `.github/prompts/*.prompt.md`. Ejemplo:

```markdown
---
mode: edit
model: gpt-5-mini
description: Genera test unitario vitest
---

# Generar test unitario

Toma la función seleccionada y genera un test unitario:

- Framework: vitest
- Cobertura: happy path + 2 edge cases + 1 error case
- Sin comentarios redundantes
- No expliques nada — solo el código
```

Beneficios:

- **Reproducible** (no reinventa cada dev cada vez).
- **Modelo fijado** al eficiente — evita que un dev escoja Opus por inercia.
- **Acota el output esperado** → menos tokens generados.
- **Compartible** vía repo: el equipo entero converge en patrones eficientes.

---

## 7. Anti-patterns que disparan el consumo (2 min)

| Anti-pattern | Sobrecoste típico |
|--------------|-------------------|
| Chat de 200 turnos sin cerrar | 5–10× más tokens por turno |
| Pegar README completo al preguntar algo de un path | 50× output esperado |
| Agent para una sola edición | 20× más que Inline Chat |
| Opus como modelo default | 10–30× cualquier modelo eficiente |
| `@workspace` activado siempre por defecto | 3–5× input tokens |
| Re-preguntar lo mismo en chat nuevo sin reutilizar prompt file | Coste constante repetido |
| Pedir "rewriteme la app entera" | Sesión explosiva, suele acabar mal |
| Encadenar 10 agent runs por mismo bug en vez de re-acotar prompt | 10× consumo |

> 🎯 **Si el equipo elimina solo los 3 primeros, el consumo baja típicamente un 40–60 %.**

---

## 8. Medición rápida de éxito (2 min)

Tres indicadores que sí merece la pena mirar semanalmente:

| Indicador | Cómo se mide | Por qué importa |
|-----------|--------------|------------------|
| **Acceptance rate por modelo** | Metrics API → suggestions aceptadas / mostradas | Si Opus tiene <30 % y Mini 60 %, estás pagando de más por menos valor |
| **Ratio Agent vs Inline Chat** | Eventos en audit log | Ratio alto de Agent suele indicar abuso para tareas simples |
| **Tokens por sesión por dev** (proxy) | Metrics API por usuario | Percentil 90 identifica power-users con hábitos mal acostumbrados |

> 📂 Script de snapshot: `anexos/scripts/pull-copilot-metrics.ps1`.

---

## 🧪 Lab guiado (5 min)

```powershell
# 1. Snapshot de métricas actuales
pwsh -File anexos/scripts/pull-copilot-metrics.ps1 -Org chapi-platform

# 2. Identificar seats sin actividad (oportunidad de reasignación)
pwsh -File anexos/scripts/identify-idle-seats.ps1 -Org chapi-platform -DaysIdle 28

# 3. Ver acceptance rate por modelo (en jq)
jq '.copilot_ide_chat.editors[].models[]
    | {model: .name, ar: (.total_chats_acceptances/(.total_chats+0.0001))}' metrics/latest.json
```

> Objetivo del lab: ver con datos reales **qué modelo tiene mejor acceptance** y dónde está la fricción que hace que un dev cambie a Opus innecesariamente.

---

## ✅ Checklist de salida del módulo

- [ ] Custom instructions con sección de optimización en cada repo productivo.
- [ ] **Modelo default** cambiado a uno eficiente (Mini / Haiku) en `Settings → Copilot → Default model` o vía policy enterprise.
- [ ] **Prompt files corporativos** para las 5–10 tareas más repetitivas, con modelo fijado.
- [ ] Mensaje "1 chat = 1 tarea" comunicado al equipo (champions, onboarding, intranet).
- [ ] Acceptance rate por modelo revisado en el dashboard mensual.
- [ ] Política clara de cuándo SÍ y cuándo NO usar el Coding Agent.
- [ ] Revisión trimestral de los 3 anti-patterns top.

---

➡️ Siguiente: [`03-skills-y-conectores.md`](./03-skills-y-conectores.md)
