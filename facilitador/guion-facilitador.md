# 🎙️ Guion del facilitador

> Speaker notes para los 120 minutos del workshop. Tiempos orientativos.  
> Mantén el ritmo: si vas largo en un bloque, recorta del siguiente — **nunca del cierre**.

---

## Antes de empezar (T-15 min)

- [ ] Sala/Teams abierto, audio probado, pantalla compartida ON.
- [ ] Repos sandbox precargados en pestañas.
- [ ] Terminal con `gh` autenticado, fuente 16pt.
- [ ] VS Code abierto en `payments-api` con un branch limpio `workshop-demo`.
- [ ] Mentimeter / Forms con la encuesta inicial cargada (QR visible).
- [ ] Botella de agua.

---

## 11:00–11:05 · Bienvenida

- Sonríe, saluda por nombre a quien conozcas.
- Recuerda: **"hoy es práctico, abrid el sandbox ya"**.
- Lanza la encuesta inicial (rol + dolor + palabra).
- Mientras responden, presenta el formato: 5 bloques cortos, 1 demo larga, 1 cierre con plan.
- Indica el canal de preguntas (chat o levantar mano).

> 💡 **Si la encuesta revela mayoría de FinOps** → enfatiza módulo 2.  
> **Si mayoría SecOps** → enfatiza módulo 1.  
> **Si mayoría devs** → enfatiza módulo 3 y 4.

---

## 11:05–11:30 · Gobernanza y control (25 min)

**Mensaje clave:** *"Copilot bien gobernado es Copilot rentable y seguro. Cada control que veremos vive en una URL concreta de GitHub. No es teoría."*

### Timing interno
- 0:00–0:01 — Mapa mental de las 4 capas.
- 0:01–0:09 — Accesos: SSO, SCIM, EMU, asignación por teams. **Mostrar URL real**.
- 0:09–0:17 — Policies: **abrir** `enterprise/.../copilot/policies` en sandbox. Recorrer la tabla.
- 0:17–0:21 — Content exclusions: mostrar el YAML, aplicarlo en vivo vía `gh api`.
- 0:21–0:24 — Audit log: abrir UI + mostrar 1 query KQL en Sentinel (si está conectado) o el JSON crudo.
- 0:24–0:25 — Checklist de salida + transición.

### Trampas frecuentes
- ❌ "Enterprise Managed Users" es irreversible — avísalo claramente.
- ❌ Content exclusions **no impiden lectura humana**, solo contexto a Copilot.
- ❌ El audit log tiene **180 días** en UI; recordar el streaming.

### Preguntas probables
- "¿Y si tenemos repos con datos cliente?" → exclusiones + secret scanning + ENS.
- "¿Puede SecOps ver mis prompts?" → Zero data retention en Enterprise, pero los **metadatos** sí van al audit log.

---

## 11:30–11:50 · Modelo de costes (20 min)

**Mensaje clave:** *"El 20 % de los seats no se usa. Antes de pedir más, optimicemos lo que tenemos. Con datos."*

### Timing interno
- 0:00–0:03 — Las 4 componentes del TCO (slide visual).
- 0:03–0:06 — SKUs y **AI Credits** (nuevo modelo desde 1 jun 2026, sustituye PRUs). Mostrar la página de pricing.
- 0:06–0:12 — Metrics API: ejecutar `pull-copilot-metrics.ps1` en vivo, mostrar CSV.
- 0:12–0:17 — Optimización: ejecutar `identify-idle-seats.ps1`. Mostrar ahorro.
- 0:17–0:19 — **AI Credits**: budget alerts per-user/org en UI.
- 0:19–0:20 — Checklist + transición.

### Trampas frecuentes
- ❌ Confundir "engagement" con "active_users". Aclarar definiciones.
- ❌ Pretender que el acceptance rate sea 80 %. Bueno es 25–45 %.

### Si va sobrado de tiempo
- Demo de A/B test: comparar acceptance rate de modelo A vs B en el dashboard.

### Si va corto de tiempo
- Saltar la sección de Coding Agent (queda en doc).

---

## 11:50–12:15 · Skills y conectores (25 min)

**Mensaje clave:** *"Copilot por defecto es bueno; Copilot que conoce vuestro repo y vuestras APIs internas es 10×."*

### Timing interno
- 0:00–0:02 — 4 palancas (slide).
- 0:02–0:08 — Custom instructions: **abrir** `.github/copilot-instructions.md` en `payments-api`. Modificar y probar en vivo con Chat.
- 0:08–0:11 — Prompt files: `/generate-rest-endpoint` en vivo.
- 0:11–0:19 — MCP: **demo real**. Conectar `.vscode/mcp.json`, hacer una pregunta a Copilot que invoque un tool (ej. listar issues con el MCP github).
- 0:19–0:22 — Extensions: mostrar marketplace + describir caso `@telefonica-sre`.
- 0:22–0:24 — Knowledge bases: abrir KB de demo, hacer 1 pregunta.
- 0:24–0:25 — Checklist + transición.

### Trampas frecuentes
- ❌ MCP no carga si hay typos en JSON o token vacío. Tener un fallback.
- ❌ Custom instructions demasiado genéricas → no aportan. Mostrar la versión "concreta" del template.

### Preguntas probables
- "¿Quién puede aprobar un MCP nuevo?" → SecOps + plataforma; explicar proceso.
- "¿Copilot recuerda entre sesiones?" → No. Las instructions son el "memory".

---

## 12:15–12:45 · Caso práctico (30 min) — ⭐ Pieza clave

**Mensaje clave:** *"Ahora la prueba real. Los 3 modos resolviendo 3 problemas en un repo real, paso a paso."*

### Timing interno
- 0:00–0:02 — Presentar el escenario (3 tareas, 3 modos).
- 0:02–0:05 — Slide rápido Ask/Edit/Agent.
- 0:05–0:11 — **BUG-101** (Ask + Edit). Mostrar el flujo, ejecutar pytest verde.
- 0:11–0:19 — **FEAT-201** (Edit multi-archivo). Demostrar valor de custom instructions.
- 0:19–0:27 — **FEAT-202** (Agent mode). Lanzar, comentar mientras itera, **interrumpir** una vez para mostrar el control.
- 0:27–0:30 — Patrones y anti-patterns (slide).

### Trampas frecuentes
- ⚠️ **Agent puede tardar varios minutos**. Tener una versión "pre-cocinada" para no perder tiempo si el modelo va lento.
- ⚠️ Tener red de respaldo (móvil 5G) por si la corporativa cae.
- ⚠️ Si Copilot devuelve algo raro, **no escondas el error**: úsalo para enseñar cómo iterar.

### Frases de transición útiles
- *"Fijaos cómo respeta el RFC 7807 sin pedírselo: lo lee del `copilot-instructions.md`."*
- *"Aquí Copilot ha asumido X — voy a corregirle y veremos cómo se adapta."*
- *"Esto en producción nunca lo aceptaríamos sin revisar. Por eso Edit pide confirmación archivo a archivo."*

---

## 12:45–12:55 · Optimización continua (10 min)

**Mensaje clave:** *"Esto no se acaba hoy. Lo que cambia es vuestro plan de los próximos 90 días."*

### Timing interno
- 0:00–0:01 — Por qué continua.
- 0:01–0:03 — Ciclo D-M-A-I (visual).
- 0:03–0:05 — Champions y hackathons.
- 0:05–0:08 — Plan 90 días: **rellenar en vivo** con input del grupo.
- 0:08–0:10 — Recursos y cadencia.

### Tip
- Pide voluntarios para ser champions. Apunta nombres en pizarra/chat.

---

## 12:55–13:00 · Cierre

- Resume los 5 bloques en 1 frase cada uno.
- 3 próximos pasos concretos (esta semana / 15 días / 30 días).
- Encuesta final (link en chat).
- Canal de soporte + office hours.
- Foto de grupo (si presencial) — opcional, con permiso.

### Frase final sugerida
> *"Copilot no es magia. Es una palanca. Hoy os habéis llevado las plantillas, los scripts y el plan para que esa palanca multiplique de verdad. Nos vemos en `#copilot-platform`. Gracias."*

---

## Plan B si algo falla

| Falla | Plan B |
|-------|--------|
| Red caída | Hotspot móvil + vídeos pregrabados en `facilitador/backup/` |
| `gh api` 4xx | Mostrar la respuesta y explicar por qué falla, usar curl |
| Agent muy lento | Pasar a la versión pre-cocinada en branch `workshop-agent-result` |
| Copilot Chat no responde | Reiniciar VS Code, validar SSO |
| Asistente sin Copilot asignado | Asignarle un seat del pool en vivo (`gh api --method POST ...`) |

---

## Métricas de éxito del workshop

- ≥ 80 % asistentes responden la encuesta final.
- ≥ 70 % declaran que se llevan ≥ 1 acción concreta.
- ≥ 1 champion identificado por BU presente.
- ≥ 3 dudas técnicas resueltas durante el workshop.
- 0 incidentes de fuga de información en demos.
