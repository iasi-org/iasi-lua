$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Work = Join-Path $env:TEMP ("iasi-lua-test-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $Work | Out-Null

try {
  $FakeCurl = Join-Path $Work "curl.cmd"
  @'
@echo off
more > nul
<nul set /p="‰PNG
"
<nul set /p="IASI-TEST"
<nul set /p="
IASI_PLANTUML_HTTP_STATUS:%FAKE_STATUS%"
'@ | Set-Content -Path $FakeCurl -Encoding ASCII

  $env:PATH = "$Work;$env:PATH"
  Push-Location $Work

  $env:FAKE_STATUS = "200"
  pandoc `
    (Join-Path $Root "tests\fixtures\valid.md") `
    --from markdown `
    --to native `
    --lua-filter (Join-Path $Root "tests\test-filter.lua") `
    1> valid.native `
    2> valid.err

  if ($LASTEXITCODE -ne 0) {
    throw "Falló la prueba válida"
  }

  $env:FAKE_STATUS = "400"
  pandoc `
    (Join-Path $Root "tests\fixtures\invalid.md") `
    --from markdown `
    --to native `
    --lua-filter (Join-Path $Root "tests\test-filter.lua") `
    1> invalid.native `
    2> invalid.err

  if ($LASTEXITCODE -ne 0) {
    throw "Falló la prueba de diagnóstico"
  }

  if (-not (Select-String -Path invalid.err -Pattern "imagen de diagnostico" -Quiet)) {
    throw "No se emitió el aviso de diagnóstico"
  }

  Write-Host "Pruebas correctas"
}
finally {
  Pop-Location -ErrorAction SilentlyContinue
  Remove-Item -Recurse -Force $Work -ErrorAction SilentlyContinue
}
