$TasksPath = "specs/002-library-management/tasks.md"

if (!(Test-Path $TasksPath)) {
    Write-Error "No se encontró $TasksPath"
    exit 1
}

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "GitHub CLI no está autenticado"
    exit 1
}

$labels = @(
    "backend", "frontend", "domain", "database", "api",
    "tests", "performance", "documentation",
    "US1", "US2", "US3", "US4",
    "parallelizable", "blocking"
)

foreach ($label in $labels) {
    gh label create $label --color "ededed" 2>$null
}

$existingIssues = gh issue list --state all --limit 1000 --json title | ConvertFrom-Json
$existingTitles = $existingIssues.title

$currentPhase = ""
$created = 0
$skipped = 0

Get-Content $TasksPath | ForEach-Object {
    $line = $_

    if ($line -match "^##\s+(?<phase>Fase\s+\d+:.+)$") {
        $script:currentPhase = $Matches.phase.Trim()
        return
    }

    if ($line -notmatch "^\s*-\s\[\s\]\s(?<id>T\d{3})\s(?<rest>.+)$") {
        return
    }

    $id = $Matches.id
    $rest = $Matches.rest.Trim()

    if ($existingTitles | Where-Object { $_ -like "$id -*" }) {
        Write-Host "SKIP $id - ya existe"
        $script:skipped++
        return
    }

    $isParallel = $rest -match "\[P\]"
    $story = ""

    if ($rest -match "\[(US\d)\]") {
        $story = $Matches[1]
    }

    $cleanDescription = $rest
    $cleanDescription = $cleanDescription -replace "^\[P\]\s*", ""
    $cleanDescription = $cleanDescription -replace "^\[(US\d)\]\s*", ""
    $cleanDescription = $cleanDescription.Trim()

    $title = "$id - $cleanDescription"

    $refs = [regex]::Matches($line, "(FR-\d{3}|NFR-\d{3}|SC-\d{3}|US\d)") |
        ForEach-Object { $_.Value } |
        Sort-Object -Unique

    $issueLabels = @()

    if ($currentPhase -match "Fase [1-6]") { $issueLabels += "backend" }
    if ($currentPhase -match "Fase [7-9]") { $issueLabels += "frontend" }
    if ($currentPhase -match "Fase 10") { $issueLabels += "tests" }

    if ($line -match "domain|Dominio|entidad|enum|model") { $issueLabels += "domain" }
    if ($line -match "Flyway|migration|índice|indice|PostgreSQL|BD|tabla|Repository") { $issueLabels += "database" }
    if ($line -match "Controller|endpoint|REST|OpenAPI|Swagger|api") { $issueLabels += "api" }
    if ($line -match "Test|tests|JUnit|Mockito|Testcontainers") { $issueLabels += "tests" }
    if ($line -match "performance|100\.000|2s|2 segundos|SC-006|NFR-003") { $issueLabels += "performance" }

    if ($story -ne "") { $issueLabels += $story }
    if ($isParallel) { $issueLabels += "parallelizable" }
    if ($currentPhase -match "Fase 1|Fase 2") { $issueLabels += "blocking" }

    $issueLabels = $issueLabels | Sort-Object -Unique

    $body = @"
## Tarea

$id

## Fase

$currentPhase

## Descripción

$cleanDescription

## Historia de usuario

$(if ($story -ne "") { $story } else { "Transversal / no aplica" })

## Paralelizable

$(if ($isParallel) { "Sí" } else { "No" })

## Referencias

$(if ($refs.Count -gt 0) { ($refs -join ", ") } else { "Sin referencia detectada" })

## Fuente

Archivo: specs/002-library-management/tasks.md

## Línea original

$line

## Criterio de cierre

La tarea se considera terminada cuando se cumple lo indicado en tasks.md y no rompe los checkpoints de la fase.
"@

    $labelArgs = @()
    foreach ($label in $issueLabels) {
        $labelArgs += "--label"
        $labelArgs += $label
    }

    gh issue create --title "$title" --body "$body" @labelArgs

    if ($LASTEXITCODE -eq 0) {
        Write-Host "CREATED $id"
        $script:created++
    } else {
        Write-Warning "No se pudo crear $id"
    }
}

Write-Host ""
Write-Host "Issues creados: $created"
Write-Host "Issues salteados por duplicados: $skipped"