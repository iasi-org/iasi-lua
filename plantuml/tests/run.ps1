$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TestRoot = $PSScriptRoot
$Work = Join-Path $env:TEMP ("iasi-lua-test-" + [guid]::NewGuid())
$ValidWork = Join-Path $Work "valid"
$InvalidWork = Join-Path $Work "invalid"
New-Item -ItemType Directory -Path $ValidWork | Out-Null
New-Item -ItemType Directory -Path $InvalidWork | Out-Null

try {
  python (Join-Path $Root "scripts\check-generated.py")
  if ($LASTEXITCODE -ne 0) { throw "La distribución no está sincronizada" }

  $env:PATH = "$(Join-Path $TestRoot 'fake-bin');$env:PATH"

  Push-Location $ValidWork
  $env:FAKE_STATUS = "200"
  pandoc `
    (Join-Path $TestRoot "fixtures\valid.md") `
    --from markdown `
    --to native `
    --lua-filter (Join-Path $TestRoot "test-filter.lua") `
    1> valid.native `
    2> valid.err

  if ($LASTEXITCODE -ne 0) { throw "Falló la prueba válida" }
  if (-not (Select-String -Path valid.native -Pattern "fig-valid" -Quiet)) {
    throw "No se conservó el identificador de figura"
  }
  if (-not (Select-String -Path valid.native -Pattern "80%" -Quiet)) {
    throw "No se conservó width"
  }
  Pop-Location

  Push-Location $InvalidWork
  $env:FAKE_STATUS = "400"
  pandoc `
    (Join-Path $TestRoot "fixtures\invalid.md") `
    --from markdown `
    --to native `
    --lua-filter (Join-Path $TestRoot "test-filter.lua") `
    1> invalid.native `
    2> invalid.err

  if ($LASTEXITCODE -ne 0) { throw "Falló la prueba de diagnóstico" }
  if (-not (Select-String -Path invalid.err -Pattern "imagen de diagnostico" -Quiet)) {
    throw "No se emitió el aviso de diagnóstico"
  }

  $Cache = Join-Path $InvalidWork ".quarto\plantuml"
  if ((Test-Path $Cache) -and (Get-ChildItem $Cache -File -ErrorAction SilentlyContinue)) {
    throw "La imagen de diagnóstico entró en caché"
  }

  Write-Host "Pruebas correctas"
}
finally {
  Pop-Location -ErrorAction SilentlyContinue
  Pop-Location -ErrorAction SilentlyContinue
  Remove-Item -Recurse -Force $Work -ErrorAction SilentlyContinue
}
