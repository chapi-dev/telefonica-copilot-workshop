# 04 · Caso práctico — Live coding (30 min)

> ⏱️ **12:15 – 12:45** · Speaker: TechLead / DevEx (con un dev "voluntario" del equipo)  
> 🎯 **Outcome:** ver Copilot resolviendo un caso **real y completo** aplicando los 3 modos (Ask, Edit, Agent) y los patrones que evitan los anti-patterns más comunes.

> 📌 Este módulo es **principalmente demo en vivo**, no slides. El facilitador comparte pantalla y va resolviendo paso a paso.

---

## 0. Setup del caso (2 min)

**Escenario:** el repo `telefonica-sandbox/payments-api` tiene un bug y dos feature requests pendientes:

| ID | Descripción | Complejidad | Modo Copilot ideal |
|----|-------------|-------------|---------------------|
| BUG-101 | El endpoint `POST /charges` devuelve 500 cuando el `currency` es nulo (debería ser 422) | Baja | **Ask** + **Edit** |
| FEAT-201 | Añadir soporte para `idempotency-key` (header) y test associated | Media | **Edit** (multi-archivo) |
| FEAT-202 | Migrar todo el módulo `notifications/` de `requests` a `httpx` async | Alta | **Agent mode** |

Vamos a resolver los tres en orden creciente de complejidad. Cada uno enseña un patrón distinto.

---

## 1. Los 3 modos de Copilot — cuándo usar cuál (3 min)

```
┌─────────────────────────────────────────────────────────────────┐
│ Modo      │ Qué hace                       │ Cuándo usarlo      │
├─────────────────────────────────────────────────────────────────┤
│ Ask       │ Responde preguntas, explica    │ Entender código,   │
│           │ código, sin tocarlo            │ docs, debugging    │
├─────────────────────────────────────────────────────────────────┤
│ Edit      │ Edita uno o varios archivos    │ Cambios concretos  │
│           │ con tu confirmación archivo a  │ con scope claro    │
│           │ archivo                        │                    │
├─────────────────────────────────────────────────────────────────┤
│ Agent     │ Itera por su cuenta: lee,     │ Tareas largas o   │
│           │ edita, ejecuta tests, corrige │ que requieren     │
│           │ hasta cumplir el objetivo     │ ejecutar y validar │
└─────────────────────────────────────────────────────────────────┘
```

**Regla práctica:**
> *"Si puedo describir el resultado pero no los pasos → Agent. Si tengo claros los archivos a tocar → Edit. Si necesito entender algo antes de cambiarlo → Ask."*

---

## 2. BUG-101 con Ask + Edit (6 min)

**Paso 1 — Ask:** abrir el archivo `app/routers/charges.py`, seleccionar la función `create_charge`, en Copilot Chat:

```
Explícame qué pasa cuando `request.currency` es None. ¿Dónde se valida?
```

Copilot responde mostrando dónde se llama al validador y por qué no captura el None (porque pydantic está en modo non-strict). 

**Paso 2 — Edit:** cambiar al modo Edit. Prompt:

```
En este archivo y en `app/schemas/charge.py`:
- Haz `currency` Required en el schema con `Field(..., min_length=3, max_length=3)`.
- Captura `ValidationError` en el router y devuelve `application/problem+json` con status 422.
- Añade un test en `tests/routers/test_charges.py` que cubra currency=null y currency="EU".
```

Copilot abre los 3 archivos, muestra el diff por archivo, lo aceptamos uno a uno.

**Paso 3 — Validar:** `pytest tests/routers/test_charges.py -q` debe pasar.

**Patrón enseñado:** *Ask primero para entender, Edit con scope claro y test asociado en la misma petición.*

---

## 3. FEAT-201 con Edit multi-archivo + custom instructions (8 min)

Aquí brilla el valor del `copilot-instructions.md` del módulo 3.

**Prompt en modo Edit:**

```
Añade soporte de Idempotency-Key al endpoint POST /charges siguiendo las reglas del repo:

Requisitos funcionales:
- Header opcional `Idempotency-Key` (uuid v4).
- Si se envía y ya existe → devolver la respuesta original cacheada.
- TTL del cache: 24h, en Redis.
- Si no se envía → comportamiento actual.

Quiero ver:
- Middleware nuevo en `app/middleware/idempotency.py`.
- Cliente Redis async (reusar el de `app/clients/redis_client.py`).
- Tests en `tests/middleware/test_idempotency.py` con casos: hit, miss, header inválido, TTL expirado.
- Actualizar `docs/openapi/charges.yaml` con el header.
```

Copilot:
1. Lee `.github/copilot-instructions.md` y aplica structlog, type hints, RFC 7807.
2. Lee `redis_client.py` para reutilizar la conexión async.
3. Genera 4 archivos en paralelo, mostrando diff por archivo.
4. Sugiere el comando `pytest tests/middleware/test_idempotency.py -q`.

**Cosas a hacer en vivo durante la demo:**

- **Rechazar** una sugerencia (p.ej. si propone instalar `redis` cuando ya existe `redis.asyncio` en el repo) y pedir alternativa.
- Mostrar cómo Copilot adapta el código tras el rechazo.
- Hacer **commit por archivo** para que el reviewer pueda revisar el PR fácilmente.

**Patrón enseñado:** *prompts estructurados con "Qué quiero / Qué archivos / Qué tests / Qué docs". Los custom instructions hacen el resto.*

---

## 4. FEAT-202 con Agent mode (8 min)

Cuando la tarea es **larga, mecánica y testeable**, Agent mode es el modo correcto.

**Pre-condiciones para que Agent funcione bien:**

1. Tests existentes que cubran el módulo a migrar (si no hay, hacérselos pedir primero a Copilot en Edit mode).
2. `copilot-instructions.md` claro.
3. Permitir a Agent ejecutar el runner de tests (configurado en VS Code).

**Prompt en modo Agent:**

```
Migra todo el módulo `app/notifications/` de `requests` (sync) a `httpx` async.

Criterios de aceptación:
1. Todos los call sites usan `await client.post(...)`, no `requests.post(...)`.
2. Conexión reutilizada vía `httpx.AsyncClient` inyectado por FastAPI dependency.
3. Timeouts: 5s connect, 10s read.
4. Reintentos: 3 con backoff exponencial usando `tenacity`.
5. Todos los tests existentes en `tests/notifications/` deben pasar.
6. Añade test nuevo que verifique los reintentos.
7. Elimina `requests` de `pyproject.toml`.

Ejecuta `pytest tests/notifications/ -q` después de cada cambio sustancial. Si falla, arregla.
```

Copilot Agent va a:
- Inventariar los archivos a tocar.
- Modificar incrementalmente.
- Ejecutar pytest periódicamente.
- Iterar si los tests fallan.
- Mostrar un resumen final con todos los cambios y un diagrama de qué pasó.

**Mostrar en vivo:**

- El panel **Steps** que muestra el razonamiento turno a turno.
- Cómo **interrumpir** si va por mal camino (`Stop` y reformular).
- Cómo **revisar el diff completo** antes de aceptar.

**Coding Agent en la nube** (avanzado, mencionar 1 min):

- Esta misma tarea se puede asignar a Copilot **desde un issue de GitHub**: `Assignee → Copilot`.
- Copilot abre un PR cuando termina; los revisores humanos validan.
- Útil para tareas largas que no quieres tener atadas a tu IDE.

**Patrón enseñado:** *Agent = objetivo claro + criterios de aceptación + tests que validan + supervisión humana.*

---

## 5. Patrones que funcionan y anti-patterns (3 min)

### ✅ Patrones que funcionan

| Patrón | Por qué |
|--------|---------|
| **"Show me the test you would write"** antes de pedir el código | Fuerza pensar el contrato primero |
| **Adjuntar el archivo de error** (`@workspace` + traceback) | Copilot tiene contexto completo |
| **Pedir alternativas** ("dame 2 enfoques y compáralos") | Salir del primer impulso |
| **Citar el `copilot-instructions.md`** explícitamente cuando hay duda | Refuerza convenciones |
| **Iterar en pequeños diffs** | Más fácil revisar y revertir |
| **Pedir explicación + cambio**: "explica antes de cambiar y luego cambia" | Aprendes mientras Copilot trabaja |

### ❌ Anti-patterns a evitar

| Anti-pattern | Qué pasa | Alternativa |
|--------------|----------|-------------|
| "Refactoriza todo el proyecto" sin scope | Cambios masivos, imposibles de revisar | Trocear en módulos |
| Aceptar sugerencia sin leerla | Bugs sutiles, deuda técnica | Diff + 30s de lectura |
| Compartir código sensible en el prompt | Riesgo de fuga a logs | Usar variables placeholder |
| Usar siempre el modelo premium más caro | Coste alto, no siempre mejor | Reservar premium para tareas complejas |
| Ignorar tests "porque Copilot lo escribió bien" | Falsos positivos, regresiones | Pytest siempre |
| Prompts ambiguos ("hazlo mejor") | Cambios aleatorios | "Refactoriza X para que Y, manteniendo Z" |

---

## 🧪 Mini-lab paralelo para asistentes (durante la demo)

Mientras el facilitador hace la demo principal, los asistentes resuelven en su sandbox:

> En el repo `telefonica-sandbox/payments-api`, abre el issue `#TASK-DEMO`:
> 
> *"Añade un endpoint `GET /charges/{id}/receipt` que devuelva un PDF generado con `reportlab`. Incluye test, manejo de errores y entrada en OpenAPI."*
> 
> Resuélvelo usando primero **Ask**, luego **Edit**. ¿Cuántos turnos te llevó?

---

## ✅ Checklist de salida del módulo

- [ ] Has visto los 3 modos (Ask, Edit, Agent) resolviendo casos reales.
- [ ] Has escrito al menos un prompt **estructurado** (Qué / Archivos / Tests / Docs).
- [ ] Sabes cuándo NO usar Agent (tarea ambigua, sin tests, scope abierto).
- [ ] Conoces los anti-patterns y los puedes citar a tu equipo.
- [ ] Has visto cómo Copilot Coding Agent en la nube resuelve issues sin IDE.

➡️ Siguiente: [`05-optimizacion-continua.md`](./05-optimizacion-continua.md)
