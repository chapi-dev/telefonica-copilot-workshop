#requires -Version 7.0
<#
.SYNOPSIS
    Exporta eventos del Audit Log de Enterprise relacionados con Copilot.

.DESCRIPTION
    Llama al endpoint /enterprises/{enterprise}/audit-log con un filtro
    action:copilot y descarga los eventos de las ultimas N horas.

    Salida:
      - JSONL crudo (un evento por linea)
      - CSV resumido con campos clave para SecOps

    Requiere `gh` autenticado con scope read:audit_log.

.PARAMETER Enterprise
    Slug del enterprise.

.PARAMETER Hours
    Horas hacia atras a exportar. Default: 24.

.PARAMETER Out
    Carpeta de salida. Default: ./audit-export

.EXAMPLE
    pwsh -File export-audit-log.ps1 -Enterprise telefonica-copilot-lab -Hours 24

.EXAMPLE
    pwsh -File export-audit-log.ps1 -Enterprise telefonica -Hours 168 -Out evidencia-semana
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Enterprise,

    [int]$Hours = 24,

    [string]$Out = "./audit-export"
)

$ErrorActionPreference = "Stop"

$null = New-Item -ItemType Directory -Path $Out -Force

$since      = (Get-Date).ToUniversalTime().AddHours(-$Hours)
$sinceISO   = $since.ToString("yyyy-MM-ddTHH:mm:ssZ")
$todayLabel = Get-Date -Format "yyyy-MM-dd-HHmm"

$phrase = "action:copilot created:>$sinceISO"
$encodedPhrase = [System.Net.WebUtility]::UrlEncode($phrase)

$jsonlPath = Join-Path $Out "audit-copilot-$todayLabel.jsonl"
$csvPath   = Join-Path $Out "audit-copilot-$todayLabel.csv"

Write-Host "[INFO] Exportando audit log copilot desde $sinceISO (UTC)" -ForegroundColor Cyan
Write-Host "[INFO] Enterprise: $Enterprise" -ForegroundColor Cyan

# Paginar
$allEvents = @()
$page = 1
do {
    $resp = gh api -H "Accept: application/vnd.github+json" `
        "/enterprises/$Enterprise/audit-log?phrase=$encodedPhrase&include=all&per_page=100&page=$page" 2>$null

    if (-not $resp) { break }

    try {
        $events = $resp | ConvertFrom-Json
    } catch {
        Write-Warning "Respuesta no parseable en pagina $page. Cortando."
        break
    }

    if (-not $events -or $events.Count -eq 0) { break }

    $allEvents += $events
    $events | ForEach-Object { ($_ | ConvertTo-Json -Compress -Depth 20) } | Add-Content -Path $jsonlPath -Encoding utf8

    $page++
} while ($events.Count -eq 100 -and $page -lt 100)

Write-Host "[INFO] Eventos totales: $($allEvents.Count)" -ForegroundColor Cyan

if ($allEvents.Count -eq 0) {
    Write-Host "[OK] Sin eventos copilot en la ventana indicada." -ForegroundColor Green
    return
}

# CSV resumido
$allEvents |
    Select-Object @{n="ts";e={[datetime]::FromFileTimeUtc(0).AddMilliseconds($_."@timestamp")}},
                  action,
                  actor,
                  actor_ip,
                  org,
                  repo,
                  business,
                  user,
                  @{n="extra";e={
                      $_ | Select-Object -Property * -ExcludeProperty action,actor,actor_ip,org,repo,business,user,"@timestamp" |
                      ConvertTo-Json -Compress -Depth 5
                  }} |
    Export-Csv -Path $csvPath -NoTypeInformation -Encoding utf8

# Top actions
Write-Host "`n[STATS] Top acciones:" -ForegroundColor Yellow
$allEvents | Group-Object action | Sort-Object Count -Descending |
    Select-Object Count, Name | Format-Table -AutoSize

Write-Host "[OK] JSONL: $jsonlPath" -ForegroundColor Green
Write-Host "[OK] CSV  : $csvPath"  -ForegroundColor Green
Write-Host "`n[NEXT] Subir a almacenamiento WORM corporativo para evidencia."
