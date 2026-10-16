param([int]$Port = 8511)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$env:PYTHONPATH = Join-Path $PSScriptRoot 'src'
Write-Host "Lummings creator app: http://127.0.0.1:$Port"
python -m lummings.server --port $Port
exit $LASTEXITCODE
