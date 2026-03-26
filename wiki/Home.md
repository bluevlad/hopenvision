# HopenVision

![Version](https://img.shields.io/badge/version-0.2.0-blue)
![Status](https://img.shields.io/badge/status-Active-brightgreen)
![License](https://img.shields.io/badge/license-Private-lightgrey)

> **공무원 시험 성적 관리 및 채점 시스템**

HopenVision은 공무원 시험의 시험 정보, 과목, 정답, 응시자, 채점 결과를 통합 관리하는 웹 기반 시스템입니다. Excel 업로드를 통한 일괄 데이터 관리, 자동 채점, 표준점수 산출, 통계 대시보드를 제공하며, 수험생이 직접 답안을 입력하고 채점 결과를 확인할 수 있는 사용자 포털을 포함합니다.

---

## 목차

| # | 페이지 | 설명 |
|---|--------|------|
| 1 | [Project Overview](./1.-Project-Overview) | 프로젝트 소개, 비전, 목표, 핵심 기능 |
| 2 | [Architecture](./2.-Architecture) | 시스템 아키텍처, 기술 스택, 보안 |
| 3 | [Domain Model](./3.-Domain-Model) | 도메인 모델, ER 다이어그램, 엔티티 명세 |
| 4 | [API Specification](./4.-API-Specification) | REST API 명세, 인증, 엔드포인트 |
| 5 | [Development Guide](./5.-Development-Guide) | 개발 환경 설정, 빌드, 코드 컨벤션 |
| 6 | [Deployment](./6.-Deployment) | Docker 배포, CI/CD, 도메인 설정 |
| 7 | [Roadmap](./7.-Roadmap) | 릴리스 이력, 개발 현황, 향후 계획 |
| 8 | [User Guide](./8.-User-Guide) | 사용자 포털 / 관리자 콘솔 사용법 |

---

## 핵심 기능

### 관리자 콘솔 (Admin)

| 기능 | 설명 |
|------|------|
| **시험 관리** | 시험 마스터 정보 (시험코드, 시험명, 유형, 년도, 합격기준) CRUD |
| **과목 관리** | 시험별 과목 정보 (과목명, 문항수, 배점, 과락 기준) |
| **정답 관리** | 문항별 정답 입력, Excel/JSON 일괄 가져오기 |
| **응시자 관리** | 수험번호, 이름, 응시지역, 답안 입력 및 Excel 업로드 |
| **자동 채점** | 정답 대비 자동 채점, 과목별/총점 산출, 재채점 |
| **통계 분석** | 평균, 최고/최저점, 순위, 합격률, 문항 변별도, 취약점 분석 |
| **문제은행** | 문제은행 그룹/아이템 관리 |
| **문제세트** | 문제세트 구성 및 시험 배포 |
| **Excel 가져오기** | 정답지, 응시자 목록 Excel 일괄 업로드 |
| **공지사항** | 시험별 공지사항 관리 |

### 사용자 포털 (User)

| 기능 | 설명 |
|------|------|
| **시험 목록** | 참여 가능한 시험 목록 조회 |
| **OMR 답안 입력** | OMR 카드 형식의 답안 입력 UI |
| **빠른 입력** | 숫자키 기반 빠른 답안 입력 |
| **자동 채점** | 답안 제출 시 즉시 채점 결과 확인 |
| **성적 분석** | 과목별 점수, 순위, 표준점수, 취약 영역 분석 |
| **응시 이력** | 과거 응시 기록 및 성적 추이 확인 |
| **프로필 관리** | 사용자 정보 수정 |

---

## 시스템 구조

```
┌─────────────────────────────────────────────────────┐
│                   Client Layer                       │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │  User Portal  │  │ Admin Console│                 │
│  │ (React :4060) │  │ (React :4061)│                 │
│  └──────┬───────┘  └──────┬───────┘                 │
└─────────┼──────────────────┼────────────────────────┘
          │                  │
          ▼                  ▼
┌─────────────────────────────────────────────────────┐
│              Nginx Reverse Proxy                     │
│         /api/** → hopenvision-api:8080               │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│           Backend (Spring Boot :9050)                 │
│  ┌────────┐ ┌────────┐ ┌──────────┐ ┌───────────┐  │
│  │  Exam  │ │  User  │ │ Admin    │ │ Statistics │  │
│  │ Domain │ │ Domain │ │ (Config) │ │  Service   │  │
│  └────┬───┘ └────┬───┘ └────┬─────┘ └─────┬─────┘  │
│       └──────────┴──────────┴──────────────┘        │
│                      │                               │
│              Spring Data JPA                         │
└──────────────────────┼──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│              PostgreSQL (External)                    │
│           database-network (shared)                  │
└─────────────────────────────────────────────────────┘
```

---

## 기술 스택

### Backend

| 기술 | 버전 | 용도 |
|------|------|------|
| Java | 17 | 런타임 |
| Spring Boot | 3.2.2 | Web Framework |
| Spring Data JPA | — | ORM |
| PostgreSQL | 16+ | Database |
| MapStruct | 1.5.5 | DTO ↔ Entity 매핑 |
| Apache POI | 5.2.5 | Excel 처리 |
| SpringDoc OpenAPI | 2.3.0 | API 문서 (Swagger) |
| Lombok | — | 보일러플레이트 제거 |

### Frontend

| 기술 | 버전 | 용도 |
|------|------|------|
| React | 19 | UI Framework |
| TypeScript | 5.9 | 타입 안정성 |
| Vite | 7 | Build Tool |
| Ant Design | 6 | UI 컴포넌트 |
| TanStack React Query | 5 | 서버 상태 관리 |
| Recharts | 3 | 차트/시각화 |
| React Router | 7 | Routing |
| Axios | — | HTTP Client |

### Infrastructure

| 기술 | 용도 |
|------|------|
| Docker Compose | 3-서비스 오케스트레이션 |
| Nginx | 리버스 프록시 + SPA 서빙 |
| GitHub Actions | CI/CD (Self-hosted Runner) |
| npm workspaces | 프론트엔드 모노레포 관리 |

---

## 빠른 시작

```bash
# 1. 저장소 클론
git clone https://github.com/bluevlad/hopenvision.git
cd hopenvision

# 2. Backend 실행
cd api
./gradlew bootRun

# 3. Frontend 실행 (루트로 이동)
cd ..
npm install
npm run dev:user    # 사용자 앱 (http://localhost:5173)
npm run dev:admin   # 관리자 앱 (http://localhost:5174)

# 4. Docker 전체 서비스 (선택)
docker compose --profile all up -d
```

---

## 버전 정보

| 항목 | 값 |
|------|-----|
| 현재 버전 | 0.2.0 |
| 라이선스 | Private |
| 저장소 | [bluevlad/hopenvision](https://github.com/bluevlad/hopenvision) |

---

## 프로젝트 구조

```
hopenvision/
├── api/                        # Spring Boot 백엔드
│   └── src/main/java/com/hopenvision/
│       ├── config/             # 설정 (CORS, Security)
│       ├── exam/               # 시험/채점 도메인 (DDD)
│       │   ├── controller/     # REST API
│       │   ├── dto/            # DTO
│       │   ├── entity/         # JPA Entity
│       │   ├── repository/     # JPA Repository
│       │   └── service/        # Business Logic
│       └── user/               # 사용자 도메인 (DDD)
├── web-shared/                 # @hopenvision/shared (공유 코드)
├── web-user/                   # 사용자 앱 (채점)
├── web-admin/                  # 관리자 앱 (시험관리)
├── doc/                        # 프로젝트 문서
│   ├── adr/                    # Architecture Decision Records
│   └── sql/                    # DB 스키마, 프로시저
├── wiki/                       # GitHub Wiki 원본
├── wiki-site/                  # MkDocs 위키 사이트
├── docker-compose.yml          # 개발용
└── docker-compose.prod.yml     # 운영용
```

---

## 관련 문서

- [API 문서 (Swagger)](http://localhost:8080/swagger-ui.html) — 로컬 개발 환경
- [ADR-001: 시스템 아키텍처](../doc/adr/ADR-001-system-architecture.md)
- [ADR-002: 배치 시스템 설계](../doc/adr/ADR-002-batch-system-design.md)
- [ADR-003: 차트 라이브러리 선정](../doc/adr/ADR-003-chart-library-selection.md)
