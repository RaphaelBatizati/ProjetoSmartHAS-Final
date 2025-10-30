#!/usr/bin/env bash
set -euo pipefail

echo "== Smart HAS :: Fase 6 (Oracle + PL/SQL) =="
echo ">> Subindo Docker Compose (oracle + adminer)..."

docker compose up -d

echo ">> Aguardando Oracle ficar healthy..."
for i in {1..60}; do
  state=$(docker inspect -f '{{json .State.Health.Status}}' smart_has_oracle 2>/dev/null || echo "null")
  echo "   - Tentativa $i/60 -> estado: $state"
  if [[ "$state" == ""healthy"" ]]; then
    break
  fi
  sleep 5
done

if [[ "$state" != ""healthy"" ]]; then
  echo "Oracle não ficou saudável a tempo. Veja logs: docker logs smart_has_oracle"
  exit 1
fi

echo ">> Oracle saudável. Adminer: http://localhost:8081 (System: Oracle, Server: oracle, User: smarthas, Pass: smarthas, DB: XEPDB1)"

cat > oracle/init/_test.sql <<'SQL'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0
ALTER SESSION SET CURRENT_SCHEMA=smarthas;
SELECT FN_AVG_POWER(1, 24) FROM dual;
SELECT FN_DEVICE_STATUS_JSON(1) FROM dual;
BEGIN
  PR_CHECK_AND_REGISTER_ALERTS(2, 150, 0, 8);
END;
/
VAR x CLOB
BEGIN
  PR_SUMMARY_USER_CONSUMPTION(1, :x);
END;
/

PRINT x
EXIT
SQL

docker exec -i smart_has_oracle bash -lc "echo "@oracle/init/_test.sql" | sqlplus -s smarthas/smarthas@//localhost:1521/XEPDB1"

echo ">> Testes finalizados."
echo
echo "== Próximos passos =="
echo "1) Integre o backend Spring Boot com backend_integration/*"
echo "2) Ajuste application.yml para apontar para Oracle"
echo "3) Rode seu app mobile (Flutter/Kotlin) com o backend ativo"