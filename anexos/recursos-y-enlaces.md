# 📚 Recursos y enlaces

> Listado curado de **documentación oficial y recursos prácticos** organizados por módulo del workshop.

---

## Documentación oficial GitHub (raíz)

- [GitHub Docs — Copilot](https://docs.github.com/en/copilot)
- [GitHub Copilot Trust Center](https://copilot.github.trust.page/)
- [GitHub Copilot Changelog](https://github.blog/changelog/label/copilot/)
- [GitHub Roadmap (público)](https://github.com/orgs/github/projects/4247)
- [GitHub Status](https://www.githubstatus.com/)

---

## 1. Gobernanza y control

### Accesos e identidad
- [SAML SSO for Enterprise](https://docs.github.com/en/enterprise-cloud@latest/admin/identity-and-access-management/using-saml-for-enterprise-iam)
- [SCIM provisioning](https://docs.github.com/en/enterprise-cloud@latest/admin/identity-and-access-management/provisioning-user-accounts-with-scim)
- [Enterprise Managed Users (EMU)](https://docs.github.com/en/enterprise-cloud@latest/admin/identity-and-access-management/using-enterprise-managed-users-for-iam)
- [Custom organization roles](https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)

### Copilot policies
- [Managing Copilot policies for your enterprise](https://docs.github.com/en/enterprise-cloud@latest/admin/copilot-business-only/setting-policies-for-copilot-business-in-your-enterprise/managing-policies-and-features-for-copilot-in-your-enterprise)
- [Excluding content from Copilot](https://docs.github.com/en/copilot/managing-copilot/configuring-and-auditing-content-exclusion)
- [Copilot privacy FAQs](https://github.com/features/copilot#faq)

### Seguridad de repos
- [Secret scanning](https://docs.github.com/en/code-security/secret-scanning)
- [Push protection](https://docs.github.com/en/code-security/secret-scanning/push-protection-for-repositories-and-organizations)
- [Repository rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets)
- [CodeQL](https://codeql.github.com/)
- [Dependabot](https://docs.github.com/en/code-security/dependabot)

### Auditoría
- [Audit log REST API](https://docs.github.com/en/rest/orgs/orgs?apiVersion=2022-11-28#get-the-audit-log-for-an-organization)
- [Audit log streaming](https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/streaming-the-audit-log-for-your-enterprise)
- [Audit log events reference](https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/audit-log-events-for-your-enterprise)

---

## 2. Modelo de costes

- [About billing for Copilot](https://docs.github.com/en/billing/managing-billing-for-github-copilot/about-billing-for-github-copilot)
- [Copilot REST API — Billing & seats](https://docs.github.com/en/rest/copilot/copilot-user-management)
- [Copilot Metrics API](https://docs.github.com/en/rest/copilot/copilot-metrics)
- [Premium requests overview](https://docs.github.com/en/copilot/managing-copilot/understanding-and-managing-requests-in-copilot)
- [Setting budgets and alerts](https://docs.github.com/en/billing/managing-the-plan-for-your-github-account/about-budgets-for-your-github-account)
- [Copilot pricing page](https://github.com/features/copilot/plans)

---

## 3. Skills y conectores

### Custom instructions y prompts
- [Custom instructions for Copilot](https://docs.github.com/en/copilot/customizing-copilot/adding-custom-instructions-for-github-copilot)
- [Prompt files (.prompt.md)](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [Awesome Copilot instructions (community)](https://github.com/github/awesome-copilot)

### MCP — Model Context Protocol
- [MCP — spec oficial](https://modelcontextprotocol.io/)
- [MCP GitHub server](https://github.com/github/github-mcp-server)
- [MCP en VS Code](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Catálogo público de MCP servers](https://github.com/modelcontextprotocol/servers)

### Extensions
- [Building Copilot Extensions](https://docs.github.com/en/copilot/building-copilot-extensions)
- [Copilot Extensions Marketplace](https://github.com/marketplace?type=apps&copilot_app=true)

### Knowledge bases (Enterprise)
- [Knowledge bases for Copilot](https://docs.github.com/en/enterprise-cloud@latest/copilot/customizing-copilot/managing-copilot-knowledge-bases)

### Coding Agent
- [Copilot Coding Agent](https://docs.github.com/en/copilot/using-github-copilot/using-copilot-coding-agent-to-work-on-tasks)

---

## 4. Caso práctico — Buenas prácticas

- [Prompt engineering for Copilot Chat](https://docs.github.com/en/copilot/copilot-chat-cookbook)
- [Best practices for Copilot in the IDE](https://docs.github.com/en/copilot/using-github-copilot/best-practices-for-using-github-copilot)
- [Microsoft Learn — Copilot prompt engineering](https://learn.microsoft.com/en-us/training/paths/copilot-developer-prompt-engineering/)

---

## 5. Optimización continua

- [DORA metrics overview](https://dora.dev/)
- [SPACE framework](https://queue.acm.org/detail.cfm?id=3454124)
- [GitHub Skills (cursos interactivos)](https://skills.github.com/)
- [GitHub Universe (sesiones en YouTube)](https://www.youtube.com/githubuniverse)

---

## Comunidad y soporte

- [GitHub Community — Copilot](https://github.com/orgs/community/discussions/categories/copilot)
- [GitHub Support](https://support.github.com/)
- [GitHub Status RSS](https://www.githubstatus.com/history.rss)

---

## Herramientas útiles

- [`gh` CLI](https://cli.github.com/) — interactuar con la API.
- [`jq`](https://jqlang.github.io/jq/) — procesar JSON.
- [`yq`](https://github.com/mikefarah/yq) — procesar YAML.
- [Postman / Bruno](https://www.usebruno.com/) — probar APIs.
- [`act`](https://github.com/nektos/act) — ejecutar Actions en local.
