#!/usr/bin/env bash
set -euo pipefail
SCHEMA="${1:-smarthas}"
PASS="${2:-smarthas}"
PDB="${3:-XEPDB1}"
echo ">> Waiting DB..."
until docker exec oracle-xe bash -lc "echo 'SELECT 1 FROM dual;' | sqlplus -s / as sysdba > /dev/null"; do
  sleep 5
done
docker exec oracle-xe bash -lc "sqlplus -s / as sysdba <<'SQL'
WHENEVER SQLERROR EXIT SQL.SQLCODE
DECLARE v NUMBER; BEGIN
  SELECT COUNT(*) INTO v FROM dba_users WHERE username = UPPER('${SCHEMA}');
  IF v = 0 THEN
    EXECUTE IMMEDIATE 'CREATE USER ${SCHEMA} IDENTIFIED BY ${PASS} DEFAULT TABLESPACE users QUOTA UNLIMITED ON users';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, UNLIMITED TABLESPACE TO ${SCHEMA}';
  END IF;
END;
/ 
EXIT
SQL"
docker cp ../../db/sql oracle-xe:/opt/sql
for f in 01_schema_tables.sql 02_sample_data.sql 03_plsql_functions.sql 04_plsql_procedures.sql 05_views_indexes.sql; do
  docker exec oracle-xe bash -lc "sqlplus -s ${SCHEMA}/${PASS}@${PDB} @/opt/sql/${f}"
done
echo "OK"
