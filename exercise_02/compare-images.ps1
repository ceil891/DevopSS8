$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    docker info
    if ($LASTEXITCODE -ne 0) { throw 'Docker Engine is unavailable. Start Docker Desktop in Linux containers mode.' }
    docker build -f Dockerfile.single-stage -t cart-service:single cart-service
    if ($LASTEXITCODE -ne 0) { throw 'Single-stage build failed.' }
    docker build -f Dockerfile -t cart-service:multi cart-service
    if ($LASTEXITCODE -ne 0) { throw 'Multi-stage build failed.' }
    docker images cart-service
    $singleBytes = docker image inspect cart-service:single --format '{{.Size}}'
    if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect single-stage image.' }
    $multiBytes = docker image inspect cart-service:multi --format '{{.Size}}'
    if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect multi-stage image.' }
    $reduction = (1 - [double]$multiBytes / [double]$singleBytes) * 100
    Write-Output ('Single: {0} bytes; Multi: {1} bytes; Reduction: {2:N2}%' -f $singleBytes, $multiBytes, $reduction)
} finally {
    Pop-Location
}
