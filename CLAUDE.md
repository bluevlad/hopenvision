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

## Project Structure

```
hopenvision/
├── api/                        # Spring Boot 백엔드
├── package.json                # 루트 (npm workspaces)
├── web-shared/                 # @hopenvision/shared (공유 코드)
│   └── src/
│       ├── api/client.ts       # Axios 인스턴스 + createApiClient 팩토리
│       ├── types/common.ts     # ApiResponse, PageResponse
│       ├── types/exam-constants.ts  # EXAM_TYPES, SUBJECT_TYPES, QUESTION_TYPES
│       └── index.ts            # barrel export
├── web-user/                   # 사용자 앱 (채점) - dev:5173, docker:4060
│   └── src/
│       ├── api/userApi.ts
│       ├── components/         # UserLayout, OMRCard, QuickInputCard, UserProfileModal
│       ├── pages/              # UserExamList, UserAnswerForm, UserScoreResult, UserHistory
│       └── types/user.ts
├── web-admin/                  # 관리자 앱 (시험관리) - dev:5174, docker:4061
│   └── src/
│       ├── api/                # adminClient.ts, examApi.ts, applicantApi.ts, statisticsApi.ts
│       ├── auth/               # AuthContext.tsx, AuthGuard.tsx, useAuth.ts, authTypes.ts
│       ├── components/         # AdminLayout, ApplicantModal
│       ├── pages/              # ApiKeyLogin, ExamList, ExamForm, AnswerKeyForm, ExcelImport, JsonImport, ApplicantList, Statistics
│       └── types/              # exam.ts, applicant.ts, statistics.ts
├── wiki/                       # MkDocs Material 위키 (wiki-hub 동기화)
│   ├── mkdocs.yml              # MkDocs 설정
│   ├── requirements.txt        # Python 의존성
│   └── docs/                   # 마크다운 콘텐츠
├── github-wiki/                # GitHub Wiki 마크다운 (저장소 Wiki 탭용)
├── docker-compose.yml          # 개발용
└── docker-compose.prod.yml     # 운영용
```

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

### Frontend (web-user/, web-admin/, web-shared/)

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
| Monorepo | npm workspaces |

## Build and Run Commands

```bash
# Backend 빌드/실행
cd api
./gradlew build
./gradlew bootRun

# Backend 테스트
./gradlew test

# Frontend 설치 (루트에서)
npm install

# Frontend 개발 서버
npm run dev:user        # 사용자 앱 (http://localhost:5173)
npm run dev:admin       # 관리자 앱 (http://localhost:5174)

# Frontend 빌드
npm run build           # 양쪽 모두 빌드
npm run build:user      # 사용자 앱만
npm run build:admin     # 관리자 앱만

# Lint
npm run lint            # 전체 workspace lint

# Docker (전체 서비스)
docker compose --profile all up -d
```

### Port Mapping

| 서비스 | 로컬 | Docker |
|--------|------|--------|
| Backend API | 8080 | 9050:8080 |
| Frontend User | 5173 (Vite dev) | 4060:80 |
| Frontend Admin | 5174 (Vite dev) | 4061:80 |

## Architecture Overview

```
com.hopenvision/
├── config/              # 설정 (CORS, Security, AdminController 등)
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
- 관리자 인증: X-Api-Key 헤더 (SecurityConfig에서 필터링)
- 관리자 검증: POST /api/admin/verify

### Spring Profiles

| 프로필 | DB | DDL 모드 | 용도 |
|--------|-----|---------|------|
| local | H2 인메모리 | create | 로컬 개발 (h2-console 사용 가능) |
| dev | PostgreSQL | create | 개발 서버 |
| prod | PostgreSQL | none | 운영 서버 |

## Help Page 관리

> 작성 표준: [HELP_PAGE_GUIDE.md](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/standards/documentation/HELP_PAGE_GUIDE.md)
> HTML 템플릿: [help-page-template.html](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/standards/documentation/templates/help-page-template.html)

- **기능 추가/변경/삭제 시 반드시 헬프 페이지도 함께 업데이트**
- 헬프 파일 위치:
  - User: `web-user/public/help/`
  - Admin: `web-admin/public/help/`
- 서비스 accent-color: `#10b981` (Emerald)
- 대상 가이드 파일:
  - `user-guide.html` — 사용자 포털 가이드 (web-user)
  - `admin-guide.html` — 관리자 콘솔 가이드 (web-admin)
  - `statistics-guide.html` — 통계/분석 기능 가이드

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

## Wiki

- **구현 표준**: [WIKI_HUB_GUIDE.md](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/standards/documentation/WIKI_HUB_GUIDE.md)
- **로컬 위키**: `wiki/` (MkDocs Material, 개발용)
- **운영 위키**: Wiki Hub 독립 서비스 (`wiki-hub/HopenVision/`)
- **접근 URL**: `https://study.unmong.com/wiki/HopenVision/`
- **Wiki Hub 포트**: 4075
- **GitHub Wiki**: `github-wiki/` (저장소 Wiki 탭에 push하는 원본)
- wiki 콘텐츠 수정 시 `wiki/docs/`와 `wiki-hub/HopenVision/docs/` 양쪽 동기화 필요

## Deployment

- **CI/CD**: GitHub Actions (prod 브랜치 push 시 자동 배포)
- **Docker Image**: hopenvision-api, hopenvision-web, hopenvision-admin
- **운영 포트**: Frontend User 4060, Frontend Admin 4061, Backend 9050
- **도메인**: study.unmong.com (사용자), admin.unmong.com (관리자)
- **네트워크**: database-network (외부)

> 로컬 환경 정보는 `CLAUDE.local.md` 참조 (git에 포함되지 않음)

## Fix 커밋 오류 추적

> 상세: [FIX_COMMIT_TRACKING_GUIDE.md](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/standards/git/FIX_COMMIT_TRACKING_GUIDE.md) | [ERROR_TAXONOMY.md](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/standards/git/ERROR_TAXONOMY.md)

`fix:` 커밋 시 footer에 오류 추적 메타데이터를 **필수** 포함합니다.

### 이 프로젝트에서 자주 발생하는 Root-Cause

| Root-Cause | 설명 | 예방 |
|-----------|------|------|
| `env-assumption` | profile별 설정 차이, 환경변수 가정 | `@Value` + `${VAR:?required}` 패턴 필수 |
| `null-handling` | NullPointerException | `Optional<T>` 반환, `@Nullable` 어노테이션 |
| `config-typo` | application.yml 키 오타, 들여쓰기 오류 | IDE YAML 검증, 프로파일별 설정 테스트 |
| `type-mismatch` | DTO ↔ Entity 매핑 타입 불일치 | MapStruct 또는 ModelMapper 사용, 단위 테스트 |
| `missing-auth` | API 인증/인가 누락 | `@PreAuthorize` 또는 SecurityFilterChain에 명시 |
| `cors-miscfg` | CORS 와일드카드 허용 | `allowedOrigins`에 명시적 도메인만 등록 |

### 예시

```
fix(auth): JWT 토큰 만료 검증 로직 수정

- JwtTokenProvider에서 만료 시간 비교 시 초/밀리초 단위 혼동
- Instant.now().getEpochSecond() 사용으로 통일

Root-Cause: unit-mismatch
Error-Category: logic-error
Affected-Layer: backend/auth
Recurrence: first
Prevention: 시간 비교 시 단위를 변수명에 명시 (epochSec, epochMs)

fixes #15
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
