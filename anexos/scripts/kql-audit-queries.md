# KQL Queries — Audit Log de GitHub Copilot en Sentinel

> Asume que el audit log enterprise está siendo **streameado a Sentinel** (vía Event Hub) y que los eventos aterrizan en la tabla custom `GitHubAuditLogs_CL` (o el nombre que defina vuestro DCR).  
> Adaptar los nombres de columna a vuestro Data Collection Rule.

---

## 1. Resumen 24h: eventos Copilot

```kql
GitHubAuditLogs_CL
| where TimeGenerated > ago(24h)
| where action_s startswith "copilot."
| summarize Count = count() by action_s
| sort by Count desc
```

## 2. Cambios de policy de Copilot (alerta crítica)

```kql
GitHubAuditLogs_CL
| where TimeGenerated > ago(7d)
| where action_s in (
    "business.update_copilot_business_policy",
    "enterprise.update_copilot_business_policy",
    "copilot.update_policy"
  )
| project TimeGenerated, action_s, actor_s, actor_ip_s, business_s, org_s, ChangeDetails = additional_data_dynamic
| sort by TimeGenerated desc
```

> 🚨 Crear regla: si esta consulta devuelve >0 fuera de horario laboral → alerta P2.

## 3. Asignación masiva de seats (posible exfiltración o coste)

```kql
GitHubAuditLogs_CL
| where TimeGenerated > ago(1h)
| where action_s == "copilot.seat_assigned"
| summarize Assignments = count() by actor_s, org_s, bin(TimeGenerated, 5m)
| where Assignments >= 20
| project TimeGenerated, actor_s, org_s, Assignments
```

> 🚨 Alerta si Assignments ≥ 20 en 5 min y actor no es la cuenta de servicio SCIM.

## 4. Activación de MCP server NO en allow-list

```kql
let allow_list = dynamic([
    "github",
    "telefonica-jira",
    "telefonica-api-catalog",
    "sentinel-readonly",
    "vault-ephemeral",
    "adr-knowledge"
]);
GitHubAuditLogs_CL
| where TimeGenerated > ago(24h)
| where action_s == "copilot.mcp_server_activated"
| where mcp_server_name_s !in (allow_list)
| project TimeGenerated, actor_s, org_s, repo_s, mcp_server_name_s, mcp_server_url_s
```

> 🚨 Alerta P1 si devuelve resultados. Posible bypass de gobernanza.

## 5. Acceso a Copilot desde IPs no whitelisted

```kql
let allow_cidrs = dynamic(["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "<corp_egress_cidr>"]);
GitHubAuditLogs_CL
| where TimeGenerated > ago(24h)
| where action_s startswith "copilot."
| extend ip_match = iff(ipv4_is_in_any_range(actor_ip_s, allow_cidrs), "internal", "external")
| where ip_match == "external"
| summarize Events = count() by actor_s, actor_ip_s
| sort by Events desc
```

## 6. Uso de Copilot Chat fuera de horario laboral

```kql
GitHubAuditLogs_CL
| where TimeGenerated > ago(7d)
| where action_s == "copilot.chat_event"
| extend hour = hourofday(TimeGenerated)
| where hour < 7 or hour > 22
| summarize Chats = count() by actor_s, bin(TimeGenerated, 1d)
| sort by Chats desc
```

> 💡 No es necesariamente sospechoso, pero útil para entender patrones (on-call, equipos en otros husos horarios).

## 7. Top usuarios por interacciones Chat (28d)

```kql
GitHubAuditLogs_CL
| where TimeGenerated > ago(28d)
| where action_s == "copilot.chat_event"
| summarize Chats = count() by actor_s
| top 50 by Chats desc
```

## 8. Content exclusions modificadas

```kql
GitHubAuditLogs_CL
| where TimeGenerated > ago(30d)
| where action_s in (
    "copilot.content_exclusion_created",
    "copilot.content_exclusion_updated",
    "copilot.content_exclusion_deleted"
  )
| project TimeGenerated, action_s, actor_s, org_s, repo_s, pattern = additional_data_dynamic
| sort by TimeGenerated desc
```

## 9. Cambios en el allow-list de Extensions

```kql
GitHubAuditLogs_CL
| where TimeGenerated > ago(30d)
| where action_s in (
    "copilot.extension_enabled",
    "copilot.extension_disabled",
    "copilot.extension_added_to_allowlist",
    "copilot.extension_removed_from_allowlist"
  )
| project TimeGenerated, action_s, actor_s, extension = extension_slug_s, org_s
```

## 10. Tareas del Coding Agent en repos críticos

```kql
let critical_repos = dynamic([
    "telefonica-payments/pricing-core",
    "telefonica-platform/identity-broker"
]);
GitHubAuditLogs_CL
| where TimeGenerated > ago(7d)
| where action_s startswith "copilot.coding_agent"
| where repo_s in (critical_repos)
| project TimeGenerated, action_s, actor_s, repo_s, task_id = task_id_s, status = status_s
| sort by TimeGenerated desc
```

> 🚨 En repos críticos, esto debe ser cercano a 0 o estar precedido por aprobación.

---

## 📋 Recomendación: dashboards

Crear un **Sentinel Workbook** con:

1. Tile: eventos Copilot 24h/7d/30d (line chart).
2. Tile: top 10 actores.
3. Tile: cambios de policy (tabla, 30d).
4. Tile: idle seats (cruzar con script `identify-idle-seats.ps1`).
5. Tile: MCP no autorizados (debe estar siempre vacío).
6. Tile: Coding Agent en repos críticos.

---

## 📋 Alertas (Analytics Rules)

| Nombre | Frecuencia | Severidad |
|--------|-----------|-----------|
| Copilot policy modificada | 1h | High |
| MCP fuera de allow-list activado | 15min | Critical |
| Asignación masiva de seats | 5min | Medium |
| Content exclusion eliminada | 1h | High |
| Coding Agent en repo crítico | 5min | High |
| Acceso desde IP externa | 1h | Low |
