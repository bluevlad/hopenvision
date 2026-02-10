# HopenVision 시작하기

## 사전 요구사항

- Java 17+
- Node.js 20+
- Docker & Docker Compose

## 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/bluevlad/hopenvision.git
cd hopenvision

# 데이터베이스 시작
docker compose up -d

# Backend 실행 (api 폴더)
cd api
./gradlew bootRun

# Frontend 실행 (web 폴더, 새 터미널)
cd web
npm install
npm run dev
```

## 접속 URL

| 서비스 | URL |
|--------|-----|
| Frontend | http://localhost:5173 |
| Backend API | http://localhost:8080 |
| Swagger UI | http://localhost:8080/swagger-ui.html |

## 스크립트 사용 (Windows)

```powershell
# 전체 서비스 시작
.\scripts\start-all.ps1

# 서비스 상태 확인
.\scripts\status.ps1

# 전체 서비스 중지
.\scripts\stop-all.ps1
```

## 환경 설정

### Backend (application.yml)

| 프로필 | 용도 | 데이터베이스 |
|--------|------|------------|
| local | 로컬 개발 | H2 인메모리 |
| dev | 개발 서버 | PostgreSQL |
| prod | 운영 서버 | PostgreSQL |

### Frontend (.env)

```bash
VITE_API_URL=http://localhost:8080
```

> 상세 서버 설정은 [SERVER_CONFIGURATION.md](dev/SERVER_CONFIGURATION.md)를 참고하세요.
