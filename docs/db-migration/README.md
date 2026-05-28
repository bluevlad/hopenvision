# DB 마이그레이션 — 본 저장소 잔여 자산

본 폴더에는 **마이그레이션 작업의 입력 자료 (덤프)** 만 남깁니다. 전략·계획·의사결정 문서는 모두 private repo 로 이동되었습니다.

## 잔여 자산

| 파일/폴더 | 내용 |
|----------|------|
| [`source/`](source/) | academy `acm_basic` MariaDB 11.8 의 DDL 덤프 (215 KB), routines 덤프 (115 KB), views 덤프, inventory.md, tables.tsv |

상세 안내: [`source/README.md`](source/README.md)

## 관련 전략 문서 (Claude-Opus-bluevlad)

본 입력 자료를 사용하여 작성될 PostgreSQL Flyway 스크립트의 변환 계획·의사결정은 다음 위치에서 관리합니다.

| 문서 | 위치 |
|------|------|
| Phase 1 Flyway 분할 계획 | [`services/hopenvision/plans/phase1-flyway-plan.md`](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/services/hopenvision/plans/phase1-flyway-plan.md) |
| 비즈니스 프로시저 → JPA 매핑 | [`services/hopenvision/analysis/procedures-to-jpa.md`](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/services/hopenvision/analysis/procedures-to-jpa.md) |
| Phase 1 의사결정 로그 (D-1 ~ D-6) | [`services/hopenvision/reports/2026-04-28-phase1-decisions.md`](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/services/hopenvision/reports/2026-04-28-phase1-decisions.md) |
| Sprint 0 Revert 계획 | [`services/hopenvision/reports/2026-04-28-revert-sprint0.md`](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/services/hopenvision/reports/2026-04-28-revert-sprint0.md) |
| ADR-001 Academy 통합 | [`services/hopenvision/adr/001-academy-integration.md`](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/services/hopenvision/adr/001-academy-integration.md) |
| ADR-002 AI 우선 전략 | [`services/hopenvision/adr/002-ai-first-strategy.md`](https://github.com/bluevlad/Claude-Opus-bluevlad/blob/main/services/hopenvision/adr/002-ai-first-strategy.md) |

## 실제 Flyway 스크립트

생성될 PostgreSQL Flyway 스크립트는 본 입력 자료를 변환한 결과로 다음 위치에 작성됩니다.

```
api/src/main/resources/db/migration/V8~V??.sql
```

---

## 변경 이력

| 날짜 | 변경 내용 |
|------|----------|
| 2026-04-29 | 최초 작성. PHASE1_FLYWAY_PLAN.md, PROCEDURES_TO_JPA.md, REVERT_SPRINT0.md, decisions/ 가 private repo 로 이동되어 본 인덱스로 대체 |
