#requires -Version 7.0
<#
.SYNOPSIS
    Pull Copilot Metrics (28 dias rolling) para una Org o Enterprise.

.DESCRIPTION
    Llama a la Copilot Metrics API y guarda:
      - Snapshot JSON crudo (metrics-YYYY-MM-DD.json)
      - Resumen CSV con KPIs clave por dia (resumen-YYYY-MM-DD.csv)
      - Symlink/copia "latest.json" -> ultimo snapshot

    Requiere `gh` autenticado con scope manage_billing:copilot y/o read:enterprise.

.PARAMETER Org
    Nombre de la organizacion. Excluyente con -Enterprise.

.PARAMETER Enterprise
    Slug del enterprise. Excluyente con -Org.

.PARAMETER Out
    Carpeta de salida (se crea si no existe). Default: ./metrics

.EXAMPLE
    pwsh -File pull-copilot-metrics.ps1 -Org telefonica-sandbox -Out metrics

.EXAMPLE
    pwsh -File pull-copilot-metrics.ps1 -Enterprise telefonica-copilot-lab
#>
[CmdletBinding(DefaultParameterSetName = "Org")]
param(
    [Parameter(ParameterSetName = "Org", Mandatory)]
    [string]$Org,

    [Parameter(ParameterSetName = "Enterprise", Mandatory)]
    [string]$Enterprise,

    [string]$Out = "./metrics"
)

$ErrorActionPreference = "Stop"

# 1. Verificar gh
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "gh CLI no esta instalado. Instalalo desde https://cli.github.com/"
}

gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "gh no esta autenticado. Ejecuta: gh auth login --scopes 'manage_billing:copilot,read:enterprise,read:org'"
}

# 2. Crear carpeta de salida
$null = New-Item -ItemType Directory -Path $Out -Force

# 3. Construir endpoint
if ($PSCmdlet.ParameterSetName -eq "Org") {
    $endpoint = "/orgs/$Org/copilot/metrics"
    $scope    = "org-$Org"
} else {
    $endpoint = "/enterprises/$Enterprise/copilot/metrics"
    $scope    = "enterprise-$Enterprise"
}

# 4. Pull JSON
$date     = Get-Date -Format "yyyy-MM-dd"
$jsonPath = Join-Path $Out "$scope-$date.json"

Write-Host "[INFO] Pulling $endpoint -> $jsonPath" -ForegroundColor Cyan
gh api -H "Accept: application/vnd.github+json" $endpoint > $jsonPath

if ($LASTEXITCODE -ne 0) {
    throw "Fallo la llamada a $endpoint. Revisa permisos del token."
}

# 5. Resumen CSV diario
Write-Host "[INFO] Generando resumen CSV..." -ForegroundColor Cyan
$raw = Get-Content $jsonPath -Raw | ConvertFrom-Json

$rows = foreach ($day in $raw) {
    $ide          = $day.copilot_ide_code_completions
    $chat         = $day.copilot_ide_chat
    $github       = $day.copilot_dotcom_chat
    $prSummaries  = $day.copilot_dotcom_pull_requests

    $suggestions = 0
    $acceptances = 0
    if ($ide -and $ide.editors) {
        foreach ($editor in $ide.editors) {
            foreach ($model in $editor.models) {
                foreach ($lang in $model.languages) {
                    $suggestions += [int]($lang.total_code_suggestions ?? 0)
                    $acceptances += [int]($lang.total_code_acceptances ?? 0)
                }
            }
        }
    }
    $accRate = if ($suggestions -gt 0) { [math]::Round(100 * $acceptances / $suggestions, 2) } else { 0 }

    [pscustomobject]@{
        date                  = $day.date
        active_users_ide      = $ide.total_engaged_users      ?? 0
        active_users_chat     = $chat.total_engaged_users     ?? 0
        active_users_dotcom   = $github.total_engaged_users   ?? 0
        active_users_pr       = $prSummaries.total_engaged_users ?? 0
        suggestions_shown     = $suggestions
        suggestions_accepted  = $acceptances
        acceptance_rate_pct   = $accRate
    }
}

$csvPath = Join-Path $Out "$scope-$date.csv"
$rows | Sort-Object date | Export-Csv -Path $csvPath -NoTypeInformation -Encoding utf8

# 6. Copia "latest"
$latestJson = Join-Path $Out "$scope-latest.json"
$latestCsv  = Join-Path $Out "$scope-latest.csv"
Copy-Item -Force $jsonPath $latestJson
Copy-Item -Force $csvPath  $latestCsv

# 7. Print resumen
Write-Host "`n[OK] Snapshot guardado:" -ForegroundColor Green
Write-Host "     JSON: $jsonPath"
Write-Host "     CSV : $csvPath"
Write-Host "     Latest -> $latestJson, $latestCsv"

# Top 5 dias por aceptance rate
Write-Host "`n[INFO] Top 5 dias por acceptance rate:" -ForegroundColor Yellow
$rows | Sort-Object acceptance_rate_pct -Descending | Select-Object -First 5 |
    Format-Table date, active_users_ide, suggestions_shown, suggestions_accepted, acceptance_rate_pct
