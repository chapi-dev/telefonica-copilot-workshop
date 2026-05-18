#requires -Version 7.0
<#
.SYNOPSIS
    Identifica seats de Copilot inactivos en una Org (idle seats).

.DESCRIPTION
    Llama a /orgs/{org}/copilot/billing/seats y filtra los seats cuya
    `last_activity_at` sea anterior a $DaysIdle dias.

    Devuelve CSV ordenado por dias inactivos, con ahorro mensual estimado
    en base a $SeatCost.

.PARAMETER Org
    Organizacion GitHub.

.PARAMETER DaysIdle
    Umbral en dias para considerar un seat idle. Default: 28.

.PARAMETER SeatCost
    Coste mensual por seat en EUR (Copilot Enterprise). Default: 39 EUR.
    Ajustar al precio negociado por Telefonica.

.PARAMETER Out
    Ruta del CSV de salida. Default: ./idle-seats-YYYY-MM-DD.csv

.EXAMPLE
    pwsh -File identify-idle-seats.ps1 -Org telefonica-sandbox

.EXAMPLE
    pwsh -File identify-idle-seats.ps1 -Org telefonica-payments -DaysIdle 21 -SeatCost 30
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Org,

    [int]$DaysIdle = 28,

    [decimal]$SeatCost = 39,

    [string]$Out = "./idle-seats-$(Get-Date -Format yyyy-MM-dd).csv"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "gh CLI no instalado."
}

Write-Host "[INFO] Pulling seats de $Org ..." -ForegroundColor Cyan

# Paginar todos los seats
$seats = @()
$page  = 1
do {
    $json = gh api -H "Accept: application/vnd.github+json" `
        "/orgs/$Org/copilot/billing/seats?per_page=100&page=$page" 2>$null
    if (-not $json) { break }
    $parsed = $json | ConvertFrom-Json
    if ($parsed.seats) { $seats += $parsed.seats }
    $total = $parsed.total_seats
    $page++
} while ($seats.Count -lt $total -and $page -lt 200)

if ($seats.Count -eq 0) {
    Write-Warning "No se encontraron seats. Comprueba permisos (manage_billing:copilot) y nombre de org."
    return
}

Write-Host "[INFO] Total seats encontrados: $($seats.Count)" -ForegroundColor Cyan

$threshold = (Get-Date).AddDays(-$DaysIdle)

$idle = foreach ($seat in $seats) {
    $lastActivity = if ($seat.last_activity_at) { [datetime]$seat.last_activity_at } else { $null }
    $daysIdle    = if ($lastActivity) {
        [math]::Floor(((Get-Date) - $lastActivity).TotalDays)
    } else {
        9999  # nunca activo
    }

    if ($daysIdle -ge $DaysIdle) {
        [pscustomobject]@{
            login                = $seat.assignee.login
            email                = $seat.assignee.email
            assignee_type        = $seat.assignee.type
            assigned_at          = $seat.created_at
            last_activity_at     = $lastActivity
            last_activity_editor = $seat.last_activity_editor
            days_idle            = $daysIdle
            assigning_team       = $seat.assigning_team.name
            plan_type            = $seat.plan_type
            monthly_saving_eur   = $SeatCost
        }
    }
}

$idleSorted = $idle | Sort-Object days_idle -Descending

if ($idleSorted.Count -eq 0) {
    Write-Host "[OK] No hay idle seats con threshold $DaysIdle dias." -ForegroundColor Green
    return
}

$idleSorted | Export-Csv -Path $Out -NoTypeInformation -Encoding utf8

$savings = $idleSorted.Count * $SeatCost

Write-Host "`n[RESULT] Idle seats detectados: $($idleSorted.Count)" -ForegroundColor Yellow
Write-Host "[RESULT] Ahorro mensual potencial: $savings EUR" -ForegroundColor Yellow
Write-Host "[RESULT] CSV: $Out" -ForegroundColor Yellow
Write-Host "`nTop 10:" -ForegroundColor Cyan
$idleSorted | Select-Object -First 10 | Format-Table login, days_idle, assigning_team, last_activity_at

Write-Host "`n[NEXT] Para revocar (despues de avisar al usuario):"
Write-Host '       gh api --method DELETE /orgs/' -NoNewline
Write-Host "$Org" -NoNewline -ForegroundColor Magenta
Write-Host '/copilot/billing/selected_users -f selected_usernames[]="<login>"'
