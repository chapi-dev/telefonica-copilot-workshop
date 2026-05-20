# ✅ Checklist Pre-Workshop

> Para el **facilitador** y para cada **asistente**. Completar **48h antes** del workshop.

---

## A · Facilitador / Organización

### Logística

- [ ] Sala reservada (presencial) o link de Teams/Zoom enviado (online).
- [ ] Proyector + HDMI + adaptador USB-C probados.
- [ ] WiFi corporativo + WiFi guest como backup.
- [ ] Cuenta de demo (`copilot-demo@telefonica.com`) con Copilot Enterprise asignado.
- [ ] Pantalla compartida con fuente **≥ 16pt** para que se lea bien.
- [ ] Modo "no molestar" en Teams/Slack durante el workshop.
- [ ] Grabación: confirmar política con asistentes y RGPD antes de pulsar Record.

### Sandbox preparado

- [ ] Enterprise `telefonica-copilot-lab` creado y configurado.
- [ ] Org `telefonica-sandbox` con policies de demostración.
- [ ] Repos plantilla creados y poblados:
  - [ ] `telefonica-sandbox/payments-api`
  - [ ] `telefonica-sandbox/legacy-cobol-port`
  - [ ] `telefonica-sandbox/copilot-instructions-demo`
- [ ] Token `gh` con todos los scopes necesarios cargado.
- [ ] MCP servers de demo activos (al menos `github` y un mock interno).
- [ ] Knowledge Base de demo poblada con docs sintéticas.
- [ ] Encuesta inicial preparada (Mentimeter / Forms).
- [ ] Encuesta de cierre preparada con link corto.

### Materiales

- [ ] README, módulos y anexos revisados y sincronizados.
- [ ] Plantillas listas para descargar (zip o repo público interno).
- [ ] Backup offline de la demo (vídeo de 2 min) por si falla la red.

---

## B · Asistente

### Cuenta y acceso

- [ ] Acceso a GitHub.com con SSO Telefónica funcionando.
- [ ] **Copilot asignado** verificado en `https://github.com/settings/copilot`.
- [ ] Acceso de lectura a la org `telefonica-sandbox`.
- [ ] (Solo perfiles gov): rol `Org Owner` o `copilot-admin` en sandbox.

### Herramientas locales

- [ ] **VS Code** versión más reciente.
- [ ] Extensiones instaladas:
  - [ ] `GitHub Copilot`
  - [ ] `GitHub Copilot Chat`
  - [ ] `GitHub Pull Requests`
- [ ] **GitHub CLI** `gh` instalado.
  ```bash
  gh --version   # debe ser ≥ 2.50
  ```
- [ ] Autenticado con scopes correctos:
  ```bash
  gh auth login --scopes "repo,read:org,workflow,manage_billing:copilot,read:audit_log"
  gh auth status
  ```
- [ ] **Node.js 20+**: `node --version`
- [ ] **Python 3.11+**: `python --version`
- [ ] **jq** instalado: `jq --version`
- [ ] **PowerShell 7+** (Windows) o `pwsh` instalado.
- [ ] **Git** ≥ 2.40 configurado con vuestro email corporativo.

### Verificación rápida (1 comando)

Ejecutar antes del workshop:

```powershell
@(
  @{n="gh";        cmd="gh --version"},
  @{n="git";       cmd="git --version"},
  @{n="node";      cmd="node --version"},
  @{n="python";    cmd="python --version"},
  @{n="jq";        cmd="jq --version"},
  @{n="pwsh";      cmd="pwsh --version"}
) | ForEach-Object {
  try { $v = Invoke-Expression $_.cmd 2>&1 | Select-Object -First 1; "[OK]  $($_.n.PadRight(8)) → $v" }
  catch { "[FAIL] $($_.n) NO instalado" }
}
```

Si todo marca `[OK]` → estáis listos.

---

## C · Roles esperados

| Perfil | Cosas extra a traer |
|--------|---------------------|
| Org/Enterprise Owner | Acceso a settings del enterprise sandbox |
| SecOps | Vuestra matriz de controles ISO/ENS/DORA |
| FinOps | Datos actuales de adopción y acceptance rate (opcional) |
| TechLead | Lista de los 3 repos donde queréis empezar |
| Champion | Vuestros 3 prompts favoritos para compartir |
