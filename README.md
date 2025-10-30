# GudangFridge – Challenge

Este projeto é parte da evolução do **GudangFridge**, integrando múltiplas tecnologias (Flutter, Spring Boot e Oracle PL/SQL com Docker).  
O objetivo é entregar um sistema robusto de **gerenciamento e integração**, com camadas **mobile, back-end e banco de dados**.

---

## 📂 Estrutura da Pasta

```
gudangfridge_starter/
│── android/                # Projeto Android nativo (gerado pelo Flutter)
│── ios/                    # Projeto iOS (gerado pelo Flutter)
│── lib/                    # Código principal Flutter
│── springboot-backend/     # API REST em Spring Boot
│── oracle/                 # Scripts SQL (schema.sql, seed.sql, functions.sql, procedures.sql)
│── docker-compose.yml      # Orquestração para Oracle XE + backend
│── .gitignore              # Arquivos e pastas ignorados no Git
│── README.md               # Este documento
```

---

## 🚀 Tecnologias Utilizadas

- **Flutter/Dart** → Aplicativo mobile
- **Spring Boot (Java 17+)** → API REST para integração
- **Oracle XE (Docker)** → Banco de dados com procedures e functions PL/SQL
- **Docker Compose** → Subida dos containers
- **Maven** → Build e dependências do back-end

---

## 🛠️ Pré-requisitos

Antes de rodar, instale:

- [Docker](https://www.docker.com/get-started) + Docker Compose
- [Java 17+](https://adoptium.net/) e [Maven](https://maven.apache.org/)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (caso rode o app mobile)
- Android Studio ou VS Code (com plugins Flutter/Dart)

---

## ▶️ Como Rodar o Projeto

### 1. Subir o Banco Oracle XE via Docker
```bash
docker-compose up -d
```

### 2. Rodar o Back-end (Spring Boot)
```bash
cd springboot-backend
mvn spring-boot:run
```
O back-end ficará disponível em:  
👉 [http://localhost:8080](http://localhost:8080)

### 3. Rodar o Aplicativo Flutter
```bash
flutter pub get
flutter run
```

---

## 📜 Observações

- Os **arquivos de dados pesados do Oracle XE (.dbf, .log, .dat)** foram excluídos e não são versionados (mantidos apenas localmente).
- O repositório contém apenas os **scripts SQL necessários** para recriar o banco.
- Caso precise resetar o banco:  
  ```bash
  docker-compose down -v
  docker-compose up -d
  ```

---

