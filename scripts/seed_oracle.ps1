docker rm -f oracle-xe 2>$null
docker run -d --name oracle-xe -p 1521:1521 -e ORACLE_PASSWORD=oracle gvenzl/oracle-xe:21-slim
Write-Host "Aguardando Oracle iniciar..."
Start-Sleep -Seconds 40
$cid = (docker ps -q --filter "name=oracle-xe")
$files = @("schema.sql","seed.sql","functions.sql","procedures.sql","06_packages.sql","07_triggers.sql")
foreach ($f in $files) {
  $p = "db/sql/$f"
  if (Test-Path $p) {
    docker cp $p ${cid}:/tmp/$f
    docker exec $cid bash -lc "echo '@/tmp/$f' | sqlplus -s system/oracle@localhost/XEPDB1"
  }
}
Write-Host "Concluído." 