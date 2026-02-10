# HopenVision

공무원 시험 채점 시스템

## 프로젝트 개요

HopenVision은 공무원 시험의 시험 정보, 과목, 정답, 응시자, 채점 결과를 통합 관리하는 웹 기반 시스템입니다.

## 주요 기능

- **시험 관리**: 시험 마스터 정보 (시험코드, 시험명, 유형, 년도, 합격기준)
- **과목 관리**: 시험별 과목 정보 (과목명, 문항수, 배점, 과락 기준)
- **정답 관리**: 문항별 정답 입력, Excel 일괄 가져오기
- **응시자 관리**: 수험번호, 이름, 응시지역, 답안 입력
- **자동 채점**: 정답 대비 자동 채점 및 성적 처리
- **통계 분석**: 평균, 최고점, 최저점, 순위, 합격률 통계

## 기술 스택

### Backend
| 항목 | 기술 |
|------|------|
| Framework | Spring Boot 3.2.2 |
| Language | Java 17 |
| Database | PostgreSQL 16 |
| ORM | Spring Data JPA |
| API 문서 | Springdoc OpenAPI (Swagger) |
| Excel 처리 | Apache POI |

### Frontend
| 항목 | 기술 |
|------|------|
| Framework | React 19 |
| Language | TypeScript 5.9 |
| Build Tool | Vite 7 |
| UI Library | Ant Design 6 |
| State | TanStack React Query |
| HTTP Client | Axios |

## 문서

| 문서 | 설명 |
|------|------|
| [PROJECT_OVERVIEW.md](doc/PROJECT_OVERVIEW.md) | 프로젝트 개요 및 아키텍처 |
| [GETTING_STARTED.md](doc/GETTING_STARTED.md) | 설치 및 실행 가이드 |
| [WBS.md](doc/WBS.md) | 작업 분류 체계 |
| [DEVELOPMENT_STANDARDS.md](doc/dev/DEVELOPMENT_STANDARDS.md) | 개발 표준 |
| [SERVER_CONFIGURATION.md](doc/dev/SERVER_CONFIGURATION.md) | 서버 설정 가이드 |

## 라이선스

Private - All Rights Reserved
