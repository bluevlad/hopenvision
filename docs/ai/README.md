# HopenVision AI 합격예측 시스템

> 본 디렉토리는 ADR-002 (레거시는 학습 자료, AI 모델 우선 전략) 의 후속 트랙 작업 공간입니다.

## 목적

레거시 운영 데이터(academy 통합 후 V2~V28 의 202 테이블) + EduFit 의 학원/강사 평판 트렌드 시그널 → **합격예측 모델** 입력으로 통합. 모델 출력은 HopenVision 운영 화면 (개인 대시보드, 통계 페이지) 에 자동 반영.

## 작업 트랙

| 트랙 | 범위 | 산출물 |
|---|---|---|
| **T1. 학습 데이터 ETL** | academy 운영 DB → hopenvision (V2~V28 schemas) 데이터 적재. 읽기 전용 corpus | `scripts/etl/`, ETL 결과 검증 리포트 |
| **T2. Feature Store** | 응시/성적/회원/강의 feature 추출. 모델 입력 스키마 정의 | `feature/` schema, FeatureExtractor JPA Service |
| **T3. EduFit 연동** | 평판/트렌드 시그널 자동 인입 (DB-share or REST or Kafka 검토) | ADR-003, `integration/edufit/` 모듈 |
| **T4. 합격예측 모델 v0** | baseline (회귀/규칙) → ML | `ai/predictor/`, Python 분리 or Spring `DJL`/`ONNX` 로 인하우스 |
| **T5. 모델 서빙 API** | `POST /api/predict/pass-rate` → 응시자별 합격 확률 | `prediction/` 도메인 (Controller/Service) |
| **T6. 자동 학습/배포 파이프라인** | 트렌드 변화 감지 → 모델 재학습 → 자동 배포 | GitHub Actions 또는 별도 스케줄러 |

## 입력 시그널 (초기 가설)

| 출처 | 시그널 | 활용 |
|---|---|---|
| `exam_applicant_score` | 과목별 점수, 표준점수 | 기준선 — 핵심 입력 |
| `gosi_rst_*` (legacy) | 과거 고시 응시 결과 | 학습 corpus |
| `TB_LEC_MST` (legacy) | 강의 수강 이력 | 응시자 학습 강도 |
| `TB_MA_MEMBER` (legacy) | 응시자 프로파일 (성별/연령/지역) | 인구통계 분포 |
| **EduFit `teacher_review`** | 강사 평판 점수 | 학원/강사 품질 시그널 |
| **EduFit `academy_trend`** | 학원 트렌드 변화 | 시계열 영향도 |

## 우선순위

ADR-002 §2.3:
```
P0  T1  레거시 데이터 ETL
P0  T2  Feature Store
P1  T3  EduFit 연동 인터페이스
P1  T4  모델 v0 (baseline)
P2  T5  모델 서빙 API
P2  T6  자동 학습/배포
```

## 다음 액션

- [ ] **T1 시작**: academy MariaDB → hopenvision PostgreSQL ETL 스크립트 (선택 테이블만 단계적)
- [ ] **T3 ADR-003**: EduFit 연동 방식 (DB-share vs REST vs Kafka) 결정
- [ ] T4 baseline: 단순 OLS 회귀 (점수 + 수강 강도 → 합격여부) 부터 시작 검증
