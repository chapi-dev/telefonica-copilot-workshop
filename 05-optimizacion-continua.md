# 05 · Optimización continua (10 min)

> ⏱️ **12:45 – 12:55** · Speaker: Líder de Adopción + Plataforma DevEx  
> 🎯 **Outcome:** salir con un **plan de mejora continua a 90 días** específico para vuestra BU.

---

## 1. Por qué "continua" y no "proyecto cerrado" (1 min)

Copilot cambia **cada mes**: nuevos modelos, nuevas features (Agent, MCP, Extensions, Spaces…). La adopción y el ROI **decaen** si:

- Los devs siguen usando los patrones de hace 6 meses.
- No hay feedback loop hacia Plataforma.
- Las métricas no se miran.

> 🔁 La optimización continua **no es opcional**. Es la única manera de mantener Copilot rentable.

---

## 2. El ciclo D-M-A-I (Detect → Measure → Adapt → Iterate) (3 min)

```
        ┌──────────────────────────────────────────────┐
        │                                              ▼
   ┌─────────┐    ┌────────┐    ┌────────┐    ┌──────────────┐
   │ DETECT  │ →  │MEASURE │ →  │ ADAPT  │ →  │   ITERATE    │
   └─────────┘    └────────┘    └────────┘    └──────────────┘
        ▲                                              │
        └──────────────────────────────────────────────┘
```

### 2.1 Detect

Fuentes de señal:

- **Métricas Copilot** (acceptance, engagement, idle).
- **DevEx survey trimestral** (DORA + SPACE + 3 preguntas Copilot).
- **Chat con champions** (canal Slack/Teams `#copilot-champions`).
- **Tickets de soporte** etiquetados `copilot`.
- **Code review notes**: ¿qué cosas mete Copilot que tenemos que corregir siempre?

### 2.2 Measure

KPIs trimestrales mínimos:

| KPI | Origen | Target Telefónica |
|-----|--------|-------------------|
| % devs activos | Metrics API | ≥ 80 % |
| Acceptance rate | Metrics API | ≥ 30 % |
| Tiempo medio "idea → PR mergeado" | DORA | -20 % vs baseline pre-Copilot |
| NPS de devs con Copilot | DevEx survey | ≥ 50 |
| Coste por dev activo / mes | Billing + Metrics | Plano o descendente |
| Incidentes por código Copilot | Postmortems etiquetados | ~ 0 |

### 2.3 Adapt

Acciones según señales:

| Señal | Acción |
|-------|--------|
| Acceptance bajo en un lenguaje | Mejorar `copilot-instructions.md` para ese lenguaje |
| Idle ratio sube | Revisar política de asignación, encuesta a inactivos |
| Champions piden más MCP | Sprint de plataforma para MCP nuevos |
| Code review repite "no uses X" | Añadirlo a custom instructions |
| Pico de coste premium requests | Educación + prompt files reutilizables |
| Nuevo modelo disponible | A/B test 2 semanas en BU piloto |

### 2.4 Iterate

- Sprint de plataforma DevEx **dedicado a Copilot cada 6 semanas**.
- Backlog público en GitHub Projects.
- Retro trimestral con la red de champions.

---

## 3. Red de champions (2 min)

**Champion = dev senior** que ya domina Copilot y actúa como multiplicador en su equipo.

- 1 champion por cada 15–20 devs.
- Reunión quincenal de 30 min: comparten patterns, bugs, prompts que funcionan.
- Tienen un canal directo con Plataforma DevEx (issues con label `champion`).
- Reciben **early access** a nuevas features y MCP/Extensions internos.
- Reconocimiento explícito en performance review.

> 💡 Champions cuesta poco y multiplica adopción. Es la palanca con mejor ratio coste/impacto.

---

## 4. Hackathons internos y "Copilot Fridays" (1 min)

- **Hackathon trimestral** (medio día): equipos cruzados resuelven un reto real usando Copilot Agent y MCP.
- **Copilot Friday** (mensual): 1h streaming interno donde Plataforma muestra novedades y devs preguntan.
- **Concurso "best prompt file"**: los mejores entran al catálogo corporativo.

---

## 5. A/B testing de prompts y modelos (1 min)

Cuando dudéis entre modelo A y B, o entre `copilot-instructions.md` v1 y v2:

1. Definir **métrica clara** (acceptance rate, tiempo a PR, calidad subjetiva).
2. Dividir un equipo en dos cohorts de 2 semanas.
3. Comparar.
4. Decidir.

No es ciencia exacta pero evita opiniones por gusto personal.

---

## 6. Plan de 90 días para vuestra BU (2 min)

Rellenar en vivo (template; cada BU adapta):

### Mes 1 — Bases
- [ ] Policy matrix aprobada por SecOps + FinOps.
- [ ] `copilot-instructions.md` en top-10 repos críticos.
- [ ] Audit log → Sentinel funcionando.
- [ ] Idle seats: primera limpieza.
- [ ] 5 champions identificados.

### Mes 2 — Extensión
- [ ] Allow-list MCP definida; primer MCP interno productivo.
- [ ] 1 Knowledge Base por dominio principal.
- [ ] Catálogo inicial de prompt files (≥10).
- [ ] Dashboard Power BI en producción.
- [ ] Primera DevEx survey post-Copilot.

### Mes 3 — Aceleración
- [ ] Copilot Coding Agent piloto en 1 equipo.
- [ ] Primer hackathon interno.
- [ ] Revisión trimestral de policies y costes.
- [ ] Roadmap 6 meses publicado.

---

## 7. Recursos para seguir (1 min)

- **Changelog GitHub Copilot:** https://github.blog/changelog/label/copilot/
- **GitHub Universe** (octubre, anuncios anuales): tener equipo viéndolo en directo.
- **Comunidad GitHub:** https://github.com/orgs/community/discussions/categories/copilot
- **Suscribirse al podcast "GitHub Universe"** + boletín DevEx interno.

---

## ✅ Checklist de salida del módulo

- [ ] Plan 90 días redactado y con owners asignados.
- [ ] Champions identificados por BU.
- [ ] Cadencia de medición fijada (mensual mínimo).
- [ ] Cadencia de plataforma fijada (sprint cada 6 semanas).
- [ ] Próxima DevEx survey planificada con fecha.

---

# 🎬 Cierre del workshop (12:55 – 13:00)

## Resumen de los 5 bloques

1. **Gobernanza**: SSO, SCIM, policies, content exclusions, audit log → Sentinel.
2. **Costes**: TCO real, idle seats, premium requests, budgets, pool dinámico.
3. **Skills**: instructions, prompt files, MCP, Extensions, Knowledge bases.
4. **Práctica**: Ask / Edit / Agent + patrones + anti-patterns.
5. **Continua**: ciclo D-M-A-I, champions, hackathons, plan 90 días.

## Próximos pasos concretos

1. **Esta semana:** desplegar `copilot-instructions.md` en vuestros top-3 repos.
2. **Próximos 15 días:** primera limpieza de idle seats + budget alerts.
3. **Próximos 30 días:** primer MCP interno productivo + Knowledge Base.
4. **Trimestre:** ejecutar el plan 90 días.

## Feedback del workshop

Por favor, rellenad la encuesta (link en chat). 3 preguntas, 1 minuto.

## Contacto post-workshop

- Canal Slack: `#copilot-platform`
- Email: `copilot-platform@telefonica.com`
- Office hours: martes 16:00 – 17:00

---

> 🙏 **Gracias por vuestro tiempo. Vamos a hacer que Copilot rinda al máximo en Telefónica.**
