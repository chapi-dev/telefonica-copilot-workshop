<#
.SYNOPSIS
    Bootstrapping completo de un Enterprise EMU: Orgs + Teams + Security defaults + Copilot.

.DESCRIPTION
    Pensado para dejar un Enterprise EMU listo para trabajar en una sola pasada:
      1. Valida auth (scopes admin:enterprise + manage_billing:copilot).
      2. Verifica acceso al Enterprise.
      3. Crea N organizations (idempotente).
      4. Aplica security defaults a cada Org (secret scanning, push protection, dependabot).
      5. Crea teams dentro de cada Org.
      6. Configura el seat management de Copilot (selected_users | selected_teams).
      7. Asigna seats de Copilot a usuarios o a teams.
      8. Imprime URLs de las policies enterprise que (a 2026-05) sólo se tocan por UI.

    Idempotente: si una Org/Team ya existe, la salta sin error.

.PARAMETER Enterprise
    Slug del Enterprise EMU.

.PARAMETER Orgs
    Lista de logins de Organizations a crear. Default: 'chapi-platform','chapi-product'.

.PARAMETER ProfileNames
    Lista de display names (1:1 con $Orgs). Default: nombre formateado desde el login.

.PARAMETER AdminLogins
    Usernames EMU que serán admin de cada Org nueva. Default: el usuario autenticado.

.PARAMETER Teams
    Hashtable orgLogin -> array de team names a crear.
    Default:
        chapi-platform → platform-sre, platform-backend, platform-frontend
        chapi-product  → product-mobile, product-web

.PARAMETER CopilotUsers
    Usernames EMU a los que asignar Copilot directamente.

.PARAMETER CopilotTeams
    Names de teams a los que asignar Copilot (alternativa a CopilotUsers).
    Si se usa, el seat mode se pone a 'assign_selected' y los seats van por team.

.PARAMETER SeatMode
    'assign_selected' (default) | 'assign_all' | 'disabled'.

.PARAMETER SkipSecurityDefaults
    Si está presente, NO aplica los flags de secret scanning/push protection/dependabot.

.PARAMETER DryRun
    No ejecuta cambios, solo imprime lo que haría.

.EXAMPLE
    # Preview en seco
    pwsh -File bootstrap-emu-enterprise.ps1 -Enterprise chapi-enterprise -DryRun

.EXAMPLE
    # Bootstrap completo con defaults
    pwsh -File bootstrap-emu-enterprise.ps1 `
        -Enterprise chapi-enterprise `
        -AdminLogins 'admin_chapighe' `
        -CopilotUsers 'admin_chapighe'

.EXAMPLE
    # Asignar Copilot a teams en lugar de usuarios sueltos
    pwsh -File bootstrap-emu-enterprise.ps1 `
        -Enterprise chapi-enterprise `
        -AdminLogins 'admin_chapighe' `
        -CopilotTeams 'platform-sre','platform-backend'

.NOTES
    Requisitos:
    - PowerShell 7+ (pwsh)
    - gh CLI autenticado con cuenta EMU (Enterprise Owner)
    - Token con scopes: admin:enterprise, manage_billing:copilot, read:enterprise, write:org

    Pre-auth:
        gh auth login --hostname github.com `
                      --scopes "admin:enterprise,manage_billing:copilot,read:enterprise,write:org,repo"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Enterprise,

    [string[]]$Orgs = @('chapi-platform', 'chapi-product'),

    [string[]]$ProfileNames = @(),

    [string[]]$AdminLogins = @(),

    [hashtable]$Teams = @{
        'chapi-platform' = @('platform-sre', 'platform-backend', 'platform-frontend')
        'chapi-product'  = @('product-mobile', 'product-web')
    },

    [string[]]$CopilotUsers = @(),

    [string[]]$CopilotTeams = @(),

    [ValidateSet('assign_selected','assign_all','disabled')]
    [string]$SeatMode = 'assign_selected',

    [switch]$SkipSecurityDefaults,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# ---------- Helpers ----------

function Write-Section { param($Title)
    Write-Host ""
    Write-Host "════════ $Title ════════" -ForegroundColor Cyan
}

function Invoke-GhJson {
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Endpoint,
        [hashtable]$Body,
        [switch]$IgnoreErrors
    )
    if ($DryRun) {
        $bodyStr = if ($Body) { ($Body | ConvertTo-Json -Compress -Depth 5) } else { '<empty>' }
        Write-Host "  [DryRun] $Method $Endpoint  $bodyStr" -ForegroundColor DarkGray
        return $null
    }
    try {
        if ($Body) {
            $tmp = New-TemporaryFile
            $Body | ConvertTo-Json -Depth 5 | Set-Content -Path $tmp -Encoding UTF8
            try {
                return (gh api --method $Method $Endpoint --input $tmp 2>&1) | Out-String | ConvertFrom-Json
            } finally {
                Remove-Item $tmp -ErrorAction SilentlyContinue
            }
        }
        return (gh api --method $Method $Endpoint 2>&1) | Out-String | ConvertFrom-Json
    } catch {
        if ($IgnoreErrors) { return $null }
        throw
    }
}

function Test-Authentication {
    Write-Section "1/7 · Auth & permisos"

    $status = gh auth status 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "gh no autenticado. Ejecuta: gh auth login --scopes 'admin:enterprise,manage_billing:copilot,read:enterprise,write:org,repo'"
    }

    $required = @('admin:enterprise','manage_billing:copilot')
    $missing  = $required | Where-Object { $status -notmatch $_ }
    if ($missing.Count -gt 0) {
        Write-Warning "Scopes faltantes en el token: $($missing -join ', ')"
        Write-Host "Ejecuta:" -ForegroundColor Yellow
        Write-Host "  gh auth login --scopes 'admin:enterprise,manage_billing:copilot,read:enterprise,write:org,repo'" -ForegroundColor Yellow
        throw "Re-auth required"
    }

    $me = gh api /user --jq '.login'
    Write-Host "  ✅ Autenticado como: $me" -ForegroundColor Green
    return $me
}

function Test-EnterpriseAccess {
    param($Slug)
    Write-Host "  → Verificando acceso a /enterprises/$Slug ..."
    try {
        $ent = gh api "/enterprises/$Slug" | ConvertFrom-Json
        Write-Host "  ✅ Enterprise: $($ent.name)  (slug: $($ent.slug))" -ForegroundColor Green
        return $ent
    } catch {
        throw "No puedo leer /enterprises/$Slug. ¿Eres Enterprise Owner? ¿Slug correcto?"
    }
}

function New-EnterpriseOrganization {
    param($Slug, $Login, $ProfileName, [string[]]$Admins)

    try {
        $existing = gh api "/orgs/$Login" 2>$null | ConvertFrom-Json
        if ($existing) {
            Write-Host "  ⚠️  Org '$Login' ya existe → salto creación" -ForegroundColor Yellow
            return $existing
        }
    } catch {
        Write-Verbose "Org '$Login' no existe todavía (esperado): $_"
    }

    Write-Host "  → Creando '$Login' (admin: $($Admins -join ', '))..." -ForegroundColor White
    $body = @{
        login        = $Login
        profile_name = $ProfileName
        admin_logins = $Admins
    }
    $org = Invoke-GhJson -Method POST -Endpoint "/enterprises/$Slug/organizations" -Body $body
    if ($org) {
        Write-Host "  ✅ Creada: https://github.com/$Login" -ForegroundColor Green
    }
    return $org
}

function Set-OrgSecurityDefaults {
    param($OrgLogin)
    Write-Host "  → '$OrgLogin' · security defaults (secret scanning, push protection, dependabot)..." -ForegroundColor White
    $body = @{
        secret_scanning_enabled_for_new_repositories                  = $true
        secret_scanning_push_protection_enabled_for_new_repositories  = $true
        dependabot_alerts_enabled_for_new_repositories                = $true
        dependabot_security_updates_enabled_for_new_repositories      = $true
    }
    $res = Invoke-GhJson -Method PATCH -Endpoint "/orgs/$OrgLogin" -Body $body -IgnoreErrors
    if ($res -or $DryRun) {
        Write-Host "  ✅ Defaults aplicados" -ForegroundColor Green
    } else {
        Write-Warning "  ⚠️  No se pudieron aplicar defaults (¿permisos? ¿Org no Advanced Security?)"
    }
}

function New-OrgTeam {
    param($OrgLogin, $TeamName)
    try {
        $existing = gh api "/orgs/$OrgLogin/teams/$TeamName" 2>$null | ConvertFrom-Json
        if ($existing) {
            Write-Host "  ⚠️  Team '$OrgLogin/$TeamName' ya existe → salto" -ForegroundColor Yellow
            return $existing
        }
    } catch {
        Write-Verbose "Team '$TeamName' no existe en '$OrgLogin' (esperado): $_"
    }

    Write-Host "  → Creando team '$OrgLogin/$TeamName'..." -ForegroundColor White
    $body = @{
        name        = $TeamName
        description = "Auto-creado por bootstrap-emu-enterprise.ps1"
        privacy     = 'closed'
    }
    $team = Invoke-GhJson -Method POST -Endpoint "/orgs/$OrgLogin/teams" -Body $body
    if ($team) {
        Write-Host "  ✅ Team creado" -ForegroundColor Green
    }
    return $team
}

function Set-OrgCopilotSeatMode {
    param($OrgLogin, $Mode)
    Write-Host "  → '$OrgLogin' · Copilot seat mode = $Mode" -ForegroundColor White
    $body = @{ seat_management_setting = $Mode }
    $res = Invoke-GhJson -Method PUT `
        -Endpoint "/orgs/$OrgLogin/copilot/billing/seat_management_setting" `
        -Body $body -IgnoreErrors
    if ($res -or $DryRun) {
        Write-Host "  ✅ Aplicado" -ForegroundColor Green
    } else {
        Write-Warning "  ⚠️  No se pudo aplicar (¿Copilot no habilitado aún en la Org?)"
    }
}

function Add-CopilotSeatsToOrg {
    param($OrgLogin, [string[]]$Users)
    if ($Users.Count -eq 0) { return }
    Write-Host "  → '$OrgLogin' · asignando $($Users.Count) seat(s) a usuarios: $($Users -join ', ')" -ForegroundColor White
    $body = @{ selected_usernames = $Users }
    $res = Invoke-GhJson -Method POST `
        -Endpoint "/orgs/$OrgLogin/copilot/billing/selected_users" `
        -Body $body -IgnoreErrors
    if ($res -and $null -ne $res.seats_created) {
        Write-Host "  ✅ Seats creados: $($res.seats_created)" -ForegroundColor Green
    } elseif ($DryRun) {
        Write-Host "  ✅ (dry-run)" -ForegroundColor Green
    } else {
        Write-Warning "  ⚠️  Llamada hecha pero sin confirmación de seats_created (revisa UI)"
    }
}

function Add-CopilotSeatsToTeams {
    param($OrgLogin, [string[]]$TeamNames)
    if ($TeamNames.Count -eq 0) { return }
    Write-Host "  → '$OrgLogin' · asignando Copilot a $($TeamNames.Count) team(s): $($TeamNames -join ', ')" -ForegroundColor White
    $body = @{ selected_teams = $TeamNames }
    $res = Invoke-GhJson -Method POST `
        -Endpoint "/orgs/$OrgLogin/copilot/billing/selected_teams" `
        -Body $body -IgnoreErrors
    if ($res -and $null -ne $res.seats_created) {
        Write-Host "  ✅ Seats creados: $($res.seats_created)" -ForegroundColor Green
    } elseif ($DryRun) {
        Write-Host "  ✅ (dry-run)" -ForegroundColor Green
    } else {
        Write-Warning "  ⚠️  Llamada hecha pero sin confirmación de seats_created (revisa UI)"
    }
}

function Show-PolicyUiGuide {
    param($Slug)
    Write-Section "7/7 · Policies enterprise (UI obligatoria, sin API pública en 2026-05)"

    $copilotUi = "https://github.com/enterprises/$Slug/settings/copilot/policies"
    $aiControlsUi = "https://github.com/enterprises/$Slug/settings/ai_controls"
    Write-Host "Copilot policies:" -ForegroundColor Cyan
    Write-Host "  $copilotUi" -ForegroundColor White
    Write-Host "AI Controls (interfaz moderna):" -ForegroundColor Cyan
    Write-Host "  $aiControlsUi" -ForegroundColor White
    Write-Host ""
    Write-Host "Configurar al menos:" -ForegroundColor White
    @(
        @{ Policy = 'Suggestions matching public code'; Value = 'Blocked' }
        @{ Policy = 'Copilot Chat in the IDE';          Value = 'Allowed' }
        @{ Policy = 'Copilot in GitHub.com';            Value = 'Allowed' }
        @{ Policy = 'MCP servers';                       Value = 'Allowed con allow-list' }
        @{ Policy = 'Copilot Extensions';                Value = 'Allowed con allow-list' }
        @{ Policy = 'Editor preview features';           Value = 'Disabled (en prod)' }
        @{ Policy = 'Copilot Coding Agent';              Value = 'Allowed sandbox / Restricted prod' }
        @{ Policy = 'Model selection';                   Value = 'Solo modelos aprobados' }
        @{ Policy = 'Prompt data retention';             Value = 'Zero (default Enterprise)' }
    ) | ForEach-Object {
        Write-Host ("  • {0,-40} → {1}" -f $_.Policy, $_.Value) -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "Detalle completo en: 01-gobernanza-y-control.md §2.1" -ForegroundColor DarkGray
}

# ---------- Main ----------

$me = Test-Authentication
$null = Test-EnterpriseAccess -Slug $Enterprise

# Defaults derivados
if ($AdminLogins.Count -eq 0) { $AdminLogins = @($me) }
if ($ProfileNames.Count -eq 0) {
    $ProfileNames = $Orgs | ForEach-Object {
        ($_ -split '-' | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) }) -join ' '
    }
}
if ($ProfileNames.Count -ne $Orgs.Count) {
    throw "ProfileNames ($($ProfileNames.Count)) debe tener la misma longitud que Orgs ($($Orgs.Count))"
}

if ($DryRun) {
    Write-Host "`n🔎 MODO DRY-RUN — no se ejecutarán cambios" -ForegroundColor Yellow
}

Write-Section "2/7 · Crear organizations"
$createdOrgs = @()
for ($i = 0; $i -lt $Orgs.Count; $i++) {
    $org = New-EnterpriseOrganization `
        -Slug $Enterprise `
        -Login $Orgs[$i] `
        -ProfileName $ProfileNames[$i] `
        -Admins $AdminLogins
    if ($org -or $DryRun) { $createdOrgs += $Orgs[$i] }
}

if (-not $SkipSecurityDefaults) {
    Write-Section "3/7 · Security defaults por Org"
    foreach ($org in $createdOrgs) {
        Set-OrgSecurityDefaults -OrgLogin $org
    }
} else {
    Write-Section "3/7 · Security defaults — SKIPPED (-SkipSecurityDefaults)"
}

Write-Section "4/7 · Crear teams"
foreach ($org in $createdOrgs) {
    if ($Teams.ContainsKey($org)) {
        foreach ($t in $Teams[$org]) {
            New-OrgTeam -OrgLogin $org -TeamName $t | Out-Null
        }
    } else {
        Write-Host "  (Sin teams definidos para '$org', salto)" -ForegroundColor DarkGray
    }
}

Write-Section "5/7 · Copilot seat management mode"
foreach ($org in $createdOrgs) {
    Set-OrgCopilotSeatMode -OrgLogin $org -Mode $SeatMode
}

Write-Section "6/7 · Asignar seats de Copilot"
if ($createdOrgs.Count -eq 0) {
    Write-Host "  (Sin orgs creadas, salto)" -ForegroundColor DarkGray
} else {
    $firstOrg = $createdOrgs[0]
    if ($CopilotUsers.Count -gt 0) {
        Add-CopilotSeatsToOrg -OrgLogin $firstOrg -Users $CopilotUsers
    }
    if ($CopilotTeams.Count -gt 0) {
        Add-CopilotSeatsToTeams -OrgLogin $firstOrg -TeamNames $CopilotTeams
    }
    if ($CopilotUsers.Count -eq 0 -and $CopilotTeams.Count -eq 0) {
        Write-Host "  (Sin -CopilotUsers ni -CopilotTeams, salto)" -ForegroundColor DarkGray
    }
}

Show-PolicyUiGuide -Slug $Enterprise

Write-Host ""
Write-Host "🎉 Bootstrap completado." -ForegroundColor Green
Write-Host "    Enterprise: https://github.com/enterprises/$Enterprise" -ForegroundColor Cyan
Write-Host "    Orgs:        $($createdOrgs -join ', ')" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "`n💡 Vuelve a ejecutar SIN -DryRun para aplicar los cambios." -ForegroundColor Yellow
}
