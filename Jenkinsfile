pipeline {
  agent any
  stages {
    stage('Checkout'){ steps{ checkout scm } }
    stage('Oracle XE'){
      steps{
        sh '''
          docker rm -f oracle-xe || true
          docker run -d --name oracle-xe -p 1521:1521 -e ORACLE_PASSWORD=oracle gvenzl/oracle-xe:21-slim
          sleep 30
        '''
      }
    }
    stage('Seed DB'){
      steps{
        sh '''
          CID=$(docker ps -q --filter "name=oracle-xe")
          for f in schema.sql seed.sql functions.sql procedures.sql 06_packages.sql 07_triggers.sql; do
            if [ -f db/sql/$f ]; then
              docker cp db/sql/$f $CID:/tmp/$f
              docker exec $CID bash -lc "echo '@/tmp/$f' | sqlplus -s system/oracle@localhost/XEPDB1"
            fi
          done
        '''
      }
    }
    stage('Build & Test'){
      steps{
        sh '''
          if [ -f server-backend/pom.xml ]; then
            (cd server-backend && mvn -B -DskipTests=false clean verify)
          else
            mvn -B -DskipTests=false clean verify
          fi
        '''
      }
      post {
        always {
          junit '**/target/surefire-reports/*.xml'
          archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
        }
      }
    }
  }
}