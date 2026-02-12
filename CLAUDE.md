# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> 상위 `C:/GIT/CLAUDE.md`의 Git-First Workflow를 상속합니다.

## Project Overview

HopenVision - 공무원 시험 성적 관리 및 채점 시스템 (Excel 업로드 → 자동 채점 → 통계 대시보드)

## Environment

- **Database**: PostgreSQL (Oracle/H2 문법 사용 금지)
- **Target Server**: MacBook Docker (172.30.1.72) / Windows 로컬 개발
- **Docker Strategy**: DB-only Docker (명시적 요청 없으면 전체 Docker 미사용)
- **Java Version**: 17
- **Spring Boot Version**: 3.2.2
- **Node.js**: React 19 + Vite 7

## Tech Stack

### Backend (api/)

| 항목 | 기술 |
|------|------|
| Language | Java 17 |
| Framework | Spring Boot 3.2.2 |
| ORM | Spring Data JPA |
| Database | PostgreSQL |
| Build Tool | Gradle |
| API Docs | SpringDoc OpenAPI 2.3.0 |
| Excel | Apache POI 5.2.5 |
| DTO Mapping | MapStruct 1.5.5 |
| Utility | Lombok |

### Frontend (web/)

| 항목 | 기술 |
|------|------|
| Language | TypeScript 5.9 |
| Framework | React 19 |
| UI Library | Ant Design 6 |
| State | TanStack React Query 5 |
| Chart | Recharts 3 |
| HTTP Client | Axios |
| Router | React Router 7 |
| Build Tool | Vite 7 |

## Build and Run Commands

```bash
# Backend 빌드/실행
cd api
./gradlew build
./gradlew bootRun

# Backend 테스트
./gradlew test

# Frontend 설치/실행
cd web
npm install
npm run dev         # 개발 서버 (Vite)
npm run build       # 프로덕션 빌드
npm run lint        # ESLint

# Docker (전체 서비스)
docker compose --profile all up -d
```

### Port Mapping

| 서비스 | 로컬 | Docker |
|--------|------|--------|
| Backend API | 8080 | 9050:8080 |
| Frontend | 5173 (Vite dev) | 4060:80 |

## Architecture Overview

```
com.hopenvision/
├── config/              # 설정 (CORS, Security 등)
├── exam/                # 시험/채점 도메인 (DDD)
│   ├── controller/      # REST API
│   ├── dto/             # DTO
│   ├── entity/          # JPA Entity
│   ├── repository/      # JPA Repository
│   └── service/         # Business Logic
├── user/                # 사용자 도메인 (DDD)
│   ├── controller/
│   ├── dto/
│   ├── entity/
│   ├── repository/
│   └── service/
└── HopenvisionApiApplication.java
```

### API 패턴
- DDD 도메인별: Controller → Service → Repository → Entity
- DTO ↔ Entity 변환: MapStruct
- API 문서: http://localhost:8080/swagger-ui.html

### Spring Profiles

| 프로필 | DB | DDL 모드 | 용도 |
|--------|-----|---------|------|
| local | H2 인메모리 | create | 로컬 개발 (h2-console 사용 가능) |
| dev | PostgreSQL | create | 개발 서버 |
| prod | PostgreSQL | none | 운영 서버 |

## Do NOT

- Oracle 문법 사용 금지 (예: NVL → COALESCE, SYSDATE → CURRENT_TIMESTAMP)
- H2 호환성 가정 금지 — PostgreSQL 전용 기능 사용 가능
- 운영 Docker 컨테이너 직접 조작 금지 (hopenvision-api, hopenvision-web)
- 서버 주소, 비밀번호, 컨테이너명 추측 금지 — 반드시 확인 후 사용
- .env, credentials 파일 커밋 금지
- 자격증명(비밀번호, API 키)을 소스코드에 하드코딩하지 마라
- CORS에 allow_origins=["*"] 또는 origins="*" 사용하지 마라
- API 엔드포인트를 인증 없이 노출하지 마라
- console.log/print로 민감 정보를 출력하지 마라
- 파일 업로드 시 사용자 입력 파일명을 검증 없이 사용하지 마라 (Path Traversal 방지)

## Database Notes

- SQL 문법: PostgreSQL 호환만 사용
- 페이지네이션: `LIMIT/OFFSET` 사용 (ROWNUM 금지)
- 날짜 함수: `CURRENT_TIMESTAMP`, `NOW()` 사용
- DDL: 운영은 `validate` (수동 마이그레이션), 개발은 `create`
- 공유 DB: `database-network` 외부 네트워크 (다른 서비스와 PostgreSQL 공유)

## Deployment

- **CI/CD**: GitHub Actions (prod 브랜치 push 시 자동 배포)
- **Docker Image**: hopenvision-api, hopenvision-web
- **운영 포트**: Frontend 4060, Backend 9050
- **도메인**: study.unmong.com
- **네트워크**: database-network (외부)

> 로컬 환경 정보는 `CLAUDE.local.md` 참조 (git에 포함되지 않음)
