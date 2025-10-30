$ErrorActionPreference = "Stop"
Write-Host "== GudangFridge :: Fase 6 (Hotfix: backend em Docker) ==" -ForegroundColor Yellow

Write-Host ">> Subindo Docker Compose (oracle + backend)..." -ForegroundColor Cyan
docker compose up -d --build

Write-Host ">> Aguardando Oracle saudável..." -ForegroundColor Cyan
$maxTries = 60
$try = 0
do {
  Start-Sleep -Seconds 5
  $state = (docker inspect -f '{{json .State.Health.Status}}' gudang_oracle) 2>$null
  $try++
  Write-Host "   - Tentativa $try/$maxTries -> estado: $state"
} while ($state -notlike '"healthy"' -and $try -lt $maxTries)

if ($state -notlike '"healthy"') {
  Write-Error "Oracle não ficou saudável a tempo. Veja: docker logs gudang_oracle"
  exit 1
}

Write-Host ">> Testando backend em http://localhost:8080/actuator/health" -ForegroundColor Cyan
Start-Sleep -Seconds 5
try {
  $resp = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 10
  Write-Host $resp.Content
} catch {
  Write-Warning "Backend ainda iniciando. Veja logs: docker logs gudang_backend"
}

Write-Host ""
Write-Host "== Dicas ==" -ForegroundColor Yellow
Write-Host "Logs Oracle:  docker logs -f gudang_oracle"
Write-Host "Logs Backend: docker logs -f gudang_backend"
Write-Host "Saúde:        curl http://localhost:8080/actuator/health"