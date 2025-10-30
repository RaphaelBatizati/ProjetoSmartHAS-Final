#!/usr/bin/env bash
set -euo pipefail
# Bring up Oracle and initialize schema

docker compose up -d oracle
./scripts/setup-db.sh

echo ">>> Next steps: configure Spring Boot (application.yml) and run the backend."
