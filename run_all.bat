@echo off
setlocal enabledelayedexpansion
echo == GudangFridge :: Fase 6 (Hotfix: backend em Docker) ==

echo >> Subindo Docker Compose (oracle + backend)...
docker compose up -d --build
if errorlevel 1 (
  echo [ERRO] Falha ao subir docker compose.
  exit /b 1
)

set maxTries=60
set try=0
:loop
  timeout /t 5 >nul
  for /f "delims=" %%a in ('docker inspect -f "{{json .State.Health.Status}}" gudang_oracle 2^>nul') do set state=%%a
  set /a try+=1
  echo    - Tentativa !try!/ %maxTries% -> estado: !state!
  if "!state!"=="\"healthy\"" goto healthy
  if !try! GEQ %maxTries% goto nothealthy
goto loop

:healthy
echo >> Oracle saudavel. Testando backend em http://localhost:8080/actuator/health
timeout /t 5 >nul
curl -s http://localhost:8080/actuator/health || echo "Backend iniciando. Veja: docker logs gudang_backend"
goto end

:nothealthy
echo [ERRO] Oracle nao ficou saudavel. Veja: docker logs gudang_oracle
exit /b 1

:end
echo Logs Oracle:  docker logs -f gudang_oracle
echo Logs Backend: docker logs -f gudang_backend
endlocal