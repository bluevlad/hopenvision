# HopenVision 코드 저장소 문서 (`docs/`)

본 폴더는 **운영·개발에 직접 결합된 자료**만 둡니다 (How — 어떻게).

전략·의사결정·계획·로드맵 등 **왜(Why) + 무엇을(What)** 에 해당하는 문서는 모두 private 저장소 [`Claude-Opus-bluevlad/services/hopenvision/`](https://github.com/bluevlad/Claude-Opus-bluevlad/tree/main/services/hopenvision) 로 이동되어 관리됩니다.

> 이원화 표준: [SERVICE_FOLDER_STRUCTURE.md §1.2](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/standards/documentation/SERVICE_FOLDER_STRUCTURE.md)

## 본 폴더의 잔여 자산

| 경로 | 내용 |
|------|------|
| [`db-migration/source/`](db-migration/source/) | academy `acm_basic` MariaDB 마이그레이션 입력 자료 (DDL/routines/views 덤프 + inventory) |

## 전략 문서 (private 저장소)

서비스 전략·의사결정·계획·로드맵·분석 문서는 다음 위치에서 확인합니다:

| 카테고리 | 위치 |
|---------|------|
| ADR (의사결정) | [`services/hopenvision/adr/`](https://github.com/bluevlad/Claude-Opus-bluevlad/tree/main/services/hopenvision/adr) |
| 구현 플랜 | [`services/hopenvision/plans/`](https://github.com/bluevlad/Claude-Opus-bluevlad/tree/main/services/hopenvision/plans) |
| 분석 문서 | [`services/hopenvision/analysis/`](https://github.com/bluevlad/Claude-Opus-bluevlad/tree/main/services/hopenvision/analysis) |
| 보고서 | [`services/hopenvision/reports/`](https://github.com/bluevlad/Claude-Opus-bluevlad/tree/main/services/hopenvision/reports) |
| 로드맵 | [`services/hopenvision/roadmap/`](https://github.com/bluevlad/Claude-Opus-bluevlad/tree/main/services/hopenvision/roadmap) |
| 서비스 README | [`services/hopenvision/README.md`](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/services/hopenvision/README.md) |

## 신규 문서 작성 시 위치 결정

[SERVICE_FOLDER_STRUCTURE.md §6 배치 결정 트리](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/standards/documentation/SERVICE_FOLDER_STRUCTURE.md)를 따릅니다.

대략적인 분류:

- 일상 개발/운영/배포/트러블슈팅 가이드 (How) → **이 저장소** `docs/dev/`, `docs/api/`
- API 명세, CHANGELOG → **이 저장소** `docs/api/`
- 마이그레이션 입력 자료 → **이 저장소** (현재 `docs/db-migration/source/`)
- 의사결정·계획·로드맵·분석·보안 (Why/What) → **private repo** `services/hopenvision/`

---

## 변경 이력

| 날짜 | 변경 내용 |
|------|----------|
| 2026-04-29 | 최초 작성. 전략 문서를 Claude-Opus-bluevlad/services/hopenvision/ 로 이동하고 본 폴더는 운영/입력 자료만 보관 |
