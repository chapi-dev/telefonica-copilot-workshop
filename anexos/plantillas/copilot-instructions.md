# Plantilla `copilot-instructions.md`

> Copia este archivo a `.github/copilot-instructions.md` en tu repo y **adáptalo**.  
> No dejes nada genérico: cuanto más concreto, mejor responde Copilot.

---

# Contexto del proyecto

<!-- Describe brevemente el servicio o producto, su dominio y stack -->
Este es el servicio **<NOMBRE-DEL-SERVICIO>** del dominio **<DOMINIO>** de Telefónica.

- **Lenguaje principal:** <Python 3.11 / Node 20 / Java 21 / .NET 8 / Go 1.22 / ...>
- **Framework:** <FastAPI / Express / Spring Boot / ASP.NET / Gin / ...>
- **Almacenamiento:** <PostgreSQL 15 / MongoDB / DynamoDB / ...>
- **Cache / cola:** <Redis / Kafka / Service Bus / ...>
- **Despliegue:** <AKS / EKS / App Service / Lambda / ...>
- **Observabilidad:** <Sentinel / Datadog / Grafana + Loki / ...>

# Convenciones de código

- **Formato/Lint:** <black + ruff / prettier + eslint / spotless / dotnet-format>. CI rechaza PRs no conformes.
- **Tipado:** estricto. Nada de `any`/`Any` salvo justificación en comentario `# noqa: explicación`.
- **Imports:** ordenados automáticamente. No mezclar imports absolutos y relativos arbitrariamente.
- **Naming:** clases `PascalCase`, funciones/variables `snake_case` (Py) o `camelCase` (TS/JS).
- **Tests:** cobertura mínima **80 %**. Tests en `tests/` con espejo de estructura.

# Convenciones de commits y PRs

- **Conventional Commits** en inglés: `feat(scope): ...`, `fix(scope): ...`, `chore: ...`.
- PRs con título descriptivo + plantilla del repo rellena.
- Squash merge obligatorio en `main`.
- 1+ reviewer obligatorio (CODEOWNERS).

# Logging y observabilidad

- **Logger:** <structlog / pino / Serilog / slog>. **NO** `console.log` / `print` / `Console.WriteLine`.
- Campos obligatorios en todo log: `trace_id`, `tenant_id`, `service`, `env`.
- Niveles: `debug` solo en dev, `info` para eventos de negocio, `warn` recuperable, `error` con stacktrace.
- Métricas a Prometheus/OpenTelemetry. Nada de métricas custom sin documentar.

# Manejo de errores

- **HTTP APIs:** devolver `application/problem+json` (RFC 7807).
- Validación de entrada **siempre** en frontera con <pydantic v2 / zod / class-validator / FluentValidation>.
- **No** capturar `Exception` genérica; capturar tipos concretos.
- Reintentos con backoff exponencial usando <tenacity / p-retry / Polly>.

# Seguridad (obligatorio)

- Secretos vía **Azure Key Vault / AWS Secrets Manager**, **nunca** en código ni en env files commiteados.
- Autenticación entre servicios: **mTLS** o **JWT firmado**. Nada de API keys planas.
- Validar y sanitizar **toda** entrada externa.
- No usar `eval`, `exec`, deserialización insegura.
- **Nuevas dependencias** requieren aprobación SecOps; verificar en `https://security.telefonica.internal/deps`.
- Output sanitizado para evitar XSS (frontend) e inyección de logs (backend).

# Datos

- Datos personales (PII) **no** loguear nunca. Usar `redact_pii()` o helpers equivalentes.
- Esquemas de DB: migraciones idempotentes y reversibles.
- Consultas SQL: **nunca** `SELECT *` en código productivo. Indexar columnas de filtro.

# Cómo quiero que respondas, Copilot

- Cuando sugieras código nuevo, **incluye también el test** asociado.
- Cuando sugieras un cambio en un endpoint, **actualiza la spec OpenAPI**.
- Cuando introduzcas una dependencia nueva, **justifícala en una línea**.
- Si propones una solución con trade-offs, explícame los trade-offs en 2-3 bullets.
- Si la petición es ambigua, **pregunta** antes de generar.
- **No inventes** APIs internas: si no las conoces, pídelas o márcalas como TODO.

# Lo que NO quiero

- Comentarios redundantes (`# incrementa i`).
- Try/except que silencian errores.
- Código copiado de Stack Overflow sin adaptar.
- Soluciones "creativas" cuando hay un patrón estándar del repo.

---

# (Opcional) Instrucciones granulares

Crear `.github/instructions/<nombre>.instructions.md` con frontmatter `applyTo:` para reglas que aplican solo a ciertos archivos.

Ejemplo `.github/instructions/terraform.instructions.md`:

```markdown
---
applyTo: "**/*.tf"
---
- Módulos en `modules/`, root en `envs/<env>/`.
- Variables con `description` y `type` obligatorios.
- Outputs con `description`.
- Nada de recursos `*-test-*` en repos de prod.
- Tags obligatorios: `owner`, `cost-center`, `env`, `service`.
```
