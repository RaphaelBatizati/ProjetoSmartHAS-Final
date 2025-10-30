#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/setup-db.sh
# Requires: docker-compose up -d oracle (container: smarthas-oracle)
# It will exec into the container and run the SQL files in order.

echo ">>> Waiting for Oracle to be healthy..."
for i in {1..60}; do
  if [ "$(docker inspect -f '{{.State.Health.Status}}' smarthas-oracle 2>/dev/null || echo starting)" = "healthy" ]; then
    echo "Oracle is healthy."
    break
  fi
  sleep 5
done

echo ">>> Running schema/seed/functions/procedures..."
docker exec -i smarthas-oracle bash -lc '
  . /opt/oracle/scripts/setPassword.sh >/dev/null 2>&1 || true
  echo "CONNECT system/oracle@//localhost:1521/XEPDB1" > /tmp/run.sql
  echo "@/container-entrypoint-initdb.d/schema.sql"    >> /tmp/run.sql
  echo "@/container-entrypoint-initdb.d/seed.sql"      >> /tmp/run.sql
  echo "@/container-entrypoint-initdb.d/functions.sql" >> /tmp/run.sql
  echo "@/container-entrypoint-initdb.d/procedures.sql">> /tmp/run.sql
  echo "@/container-entrypoint-initdb.d/views.sql"     >> /tmp/run.sql
  echo "EXIT"                                          >> /tmp/run.sql
  sqlplus -s /nolog @/tmp/run.sql
'
echo ">>> Done."
