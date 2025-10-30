#!/usr/bin/env bash
set -euo pipefail
echo "[1/3] Subindo Oracle XE..."
docker rm -f oracle-xe || true
docker run -d --name oracle-xe -p 1521:1521 -e ORACLE_PASSWORD=oracle gvenzl/oracle-xe:21-slim
sleep 20

CID=$(docker ps -q --filter "name=oracle-xe")
echo "[2/3] Aplicando schema + objetos..."
for f in db/sql/schema.sql db/sql/seed.sql db/sql/functions.sql db/sql/procedures.sql db/sql/06_packages.sql db/sql/07_triggers.sql; do
  echo "-> $f"
  docker cp "$f" $CID:/tmp/$(basename $f)
  docker exec $CID bash -lc "echo '@/tmp/$(basename $f)' | sqlplus -s system/oracle@localhost/XEPDB1"
done

echo "[3/3] Build & Test Spring Boot"
( cd server-backend && mvn -B -DskipTests=false clean verify )
echo "OK"
