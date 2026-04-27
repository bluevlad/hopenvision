# HopenVision 포털 소개화면 작성 가이드

> **대상 파일**: `unmong-main/src/main/resources/static/services/hopenvision.html`
> **배포 URL**: https://www.unmong.com/services/hopenvision.html
> **마지막 동기화 기준 커밋**: `HopenVision@c78aaa6` (2026-04-15, 통합 도메인 라우팅 정리)

---

## 1. 이 문서의 용도

**언제 여는가**
- HopenVision 의 사용자/관리자 접점 기능이 추가·변경·제거되어 게이트웨이(unmong-main) 포털 카드 또는 히어로 버튼을 갱신해야 할 때
- 포털 HTML 편집 직전에 이 파일을 한 번 열고, 작성이 끝난 뒤 체크리스트(§6)를 훑으면 1회차 작업이 종료된다

**무엇을 하지 않는가**
- 자동화 파이프라인·빌드 스크립트·기계 파싱은 고려 대상이 아니다. 필요해지면 그 때 별도 문서로 분리한다.
- 다른 서비스(`allergyinsight.html`, `companyanalyzer.html` …)의 포털 페이지는 범위 밖이다.
- HopenVision 내부 앱의 UI 가이드(Help 페이지, Wiki)는 본 저장소의 `web-user/public/help/`, `web-admin/public/help/`, `wiki/` 를 따른다.

---

## 2. 포털 페이지 레이아웃 개요

`hopenvision.html` 은 아래 4개 블록으로 구성된다. **이 가이드는 ①②만 다룬다.** ③④는 소개 문구/기술 스택 서술이므로 편집자가 자유롭게 작성한다.

| # | 블록 | 이 가이드 범위 | 비고 |
|---|---|:---:|---|
| ① | 히어로 영역 (페이지 상단 버튼 그룹) | ✅ | Primary 1 + Outline 여러 개 |
| ② | `<div class="sl-features">` 카드 그리드 | ✅ | 12 카드, 4 카테고리 |
| ③ | Architecture 섹션 | ❌ | Frontend(React 19) → Backend(Spring Boot 3.2) → Data(PostgreSQL) 다이어그램 |
| ④ | Service Flow / Tech Stack / Connected Services | ❌ | 서술 영역 |

> **서비스 accent-color**: `#10b981` (Emerald). 카드 강조선·히어로 버튼 Primary 색상 모두 동일하게 맞춘다.

---

## 3. 카드 작성 규칙 (5 줄 체크리스트)

카드 한 장을 작성할 때 아래 5개 항목을 맞춘다.

1. **아이콘**: HTML 엔티티 (`&#128221;`) 또는 이모지 직접 입력 중 **기존 파일의 스타일과 일치**시킨다. 신규 파일이면 HTML 엔티티 사용을 권장(렌더링 일관성).
2. **라벨(`sl-feature-name`)**: 한글 최대 10자. 앱 내부 사이드바 라벨과 동일하게 (예: 관리자 콘솔 메뉴가 "응시자 관리" 이면 포털도 "응시자 관리").
3. **설명(`sl-feature-desc`)**: 한 문장, 공백 포함 **50~80자**. "무엇을 어디서 어떻게" 가 한 줄에 들어가도록. 마지막에 괄호로 부가 정보(인증·Phase·메뉴 수 등)를 달 수 있다.
4. **태그(`sl-feature-tag`)**: `카테고리 · 키워드` 2단 구성 (예: `Public · Exam`, `Admin · Statistics`, `Admin · QuestionBank`). 카테고리는 **§4** 의 4분류를 따른다.
5. **URL**: 절대 URL (`https://study.unmong.com/...` 또는 `https://admin.unmong.com/...`) + `target="_blank" rel="noopener"`.

> **NEW 표시**: 별도 CSS 배지가 없으므로 새 기능은 태그를 `Admin · Phase 1` 처럼 **단계/상태 정보가 드러나게** 짓고, 설명 문구 맨 앞에 `[NEW]` 를 붙일 수 있다. 안정화 후 다음 편집에서 해당 접두어를 제거한다.

---

## 4. 12 카드 작성 예시 (복붙용)

카드는 4 카테고리 · 12 개. 그리드 순서는 **Public → Admin(운영) → Admin(콘텐츠) → Admin(분석)** 을 권장한다.

> **도메인 매핑**
> - 사용자 앱: `https://study.unmong.com` (web-user, port 4060)
> - 관리자 콘솔: `https://admin.unmong.com` (web-admin, port 4061)
> - 통합 진입(레거시 호환): `https://hopenvision.unmong.com` → `/admin/` 은 관리자, 그 외는 사용자로 라우팅

### 4.1 Public (3 카드 · 응시자/학생, 로그인 불필요)

#### 4.1.1 시험 채점 · `exam-grading`
- URL: `https://study.unmong.com/`
- 아이콘: `&#128221;` (📝)
- 설명: `OMR/약식 답안 입력 후 즉시 채점 — 과목별 점수와 합격 예측을 한 화면에 표시`
- 태그: `Public · Exam`

#### 4.1.2 모의고사 · `mock-exam`
- URL: `https://study.unmong.com/exams`
- 아이콘: `&#128203;` (📋)
- 설명: `문제세트 기반 온라인 모의고사 응시 — 시간 제한·자동 채점·해설 제공`
- 태그: `Public · Mock`

#### 4.1.3 응시 이력 · `history`
- URL: `https://study.unmong.com/history`
- 아이콘: `&#128202;` (📊)
- 설명: `과거 응시 결과·점수 추이·과목별 정답률을 누적 조회`
- 태그: `Public · History`

### 4.2 Admin · 운영 (5 카드 · X-Api-Key 필요)

#### 4.2.1 시험 관리 · `exam-admin`
- URL: `https://admin.unmong.com/exams`
- 아이콘: `&#128203;` (📋)
- 설명: `시험 회차 등록·수정·답안지 매핑·임포트 진입 통합 (관리자 전용)`
- 태그: `Admin · Exam`

#### 4.2.2 답안지 등록 · `answer-key`
- URL: `https://admin.unmong.com/exams`
- 아이콘: `&#128273;` (🔑)
- 설명: `과목·문항별 정답·배점·문제유형(객관식/주관식) 일괄 입력`
- 태그: `Admin · AnswerKey`

#### 4.2.3 Excel 임포트 · `excel-import`
- URL: `https://admin.unmong.com/import/preview`
- 아이콘: `&#128194;` (📂)
- 설명: `정답표·응시자 명단 Excel 업로드 → 미리보기 → 일괄 저장 (Apache POI)`
- 태그: `Admin · Import`

#### 4.2.4 응시자 관리 · `applicants`
- URL: `https://admin.unmong.com/applicants`
- 아이콘: `&#128101;` (👥)
- 설명: `응시자 명부·CSV 업로드·임시점수 등록·시험별 응시자 매핑 통합 운영`
- 태그: `Admin · Applicant`

#### 4.2.5 통계 대시보드 · `statistics`
- URL: `https://admin.unmong.com/statistics`
- 아이콘: `&#128200;` (📈)
- 설명: `과목별 평균·합격률·점수 분포 시각화 (Recharts, exam_applicant 기반)`
- 태그: `Admin · Statistics`

### 4.3 Admin · 콘텐츠 (3 카드 · 문제 자산 관리)

#### 4.3.1 과목 관리 · `subjects`
- URL: `https://admin.unmong.com/subjects`
- 아이콘: `&#128218;` (📚)
- 설명: `과목 마스터 코드·명칭·표시 순서 관리 — 시험 등록 시 참조 카탈로그`
- 태그: `Admin · Master`

#### 4.3.2 문제은행 · `question-bank`
- URL: `https://admin.unmong.com/question-bank`
- 아이콘: `&#127974;` (🏦)
- 설명: `문항 그룹·문항·정답·해설 등록 + CSV/Excel 일괄 임포트·갱신 지원`
- 태그: `Admin · QuestionBank`

#### 4.3.3 문제세트 · `question-sets`
- URL: `https://admin.unmong.com/question-sets`
- 아이콘: `&#128196;` (📄)
- 설명: `문제은행에서 문항을 골라 모의고사용 시험지 세트를 구성·발행`
- 태그: `Admin · QuestionSet`

### 4.4 Admin · 분석 (1 카드 · 도메인 인사이트)

#### 4.4.1 고시 분석 · `gosi-analytics`
- URL: `https://admin.unmong.com/gosi/analytics`
- 아이콘: `&#128269;` (🔍)
- 설명: `공무원 시험 회차·과목별 정답률·난이도·오답 패턴 심층 리포트`
- 태그: `Admin · Analytics`

### 4.5 카드 HTML 스니펫 (포털 파일 포맷 그대로)

아래 틀에 §4.1~4.4 의 필드를 대입하면 된다. **"&amp;"** (앰퍼샌드 HTML 이스케이프)에 주의.

```html
<a class="sl-feature" href="{{url}}" target="_blank" rel="noopener">
    <span class="sl-feature-icon">{{icon_entity}}</span>
    <div class="sl-feature-name">{{label}}</div>
    <div class="sl-feature-desc">{{description}}</div>
    <span class="sl-feature-tag">{{tag}}</span>
</a>
```

예시 — 통계 대시보드 카드:

```html
<a class="sl-feature" href="https://admin.unmong.com/statistics" target="_blank" rel="noopener">
    <span class="sl-feature-icon">&#128200;</span>
    <div class="sl-feature-name">통계 대시보드</div>
    <div class="sl-feature-desc">과목별 평균·합격률·점수 분포 시각화 (Recharts, exam_applicant 기반)</div>
    <span class="sl-feature-tag">Admin · Statistics</span>
</a>
```

---

## 5. 히어로 버튼 그룹 작성 예시

히어로 영역은 페이지 최상단의 강조 링크 집합이다. **Primary 1 + Outline 4** 를 권장한다.

| 버튼 | 클래스 | 대상 | 이유 |
|---|---|---|---|
| 시험 채점 | `sl-btn sl-btn-primary` | `https://study.unmong.com/` | 가장 널리 쓰이는 공개 진입점 |
| 모의고사 | `sl-btn sl-btn-outline` | `https://study.unmong.com/exams` | 응시자 모의 응시 경로 |
| 응시 이력 | `sl-btn sl-btn-outline` | `https://study.unmong.com/history` | 누적 결과 조회 |
| 통계 대시보드 | `sl-btn sl-btn-outline` | `https://admin.unmong.com/statistics` | 운영 데이터 시각화 |
| 관리자 | `sl-btn sl-btn-outline` | `https://admin.unmong.com/login` | 운영자 진입점 (X-Api-Key) |

스니펫:

```html
<a href="https://study.unmong.com/" target="_blank" rel="noopener" class="sl-btn sl-btn-primary">시험 채점</a>
<a href="https://study.unmong.com/exams" target="_blank" rel="noopener" class="sl-btn sl-btn-outline">모의고사</a>
<a href="https://study.unmong.com/history" target="_blank" rel="noopener" class="sl-btn sl-btn-outline">응시 이력</a>
<a href="https://admin.unmong.com/statistics" target="_blank" rel="noopener" class="sl-btn sl-btn-outline">통계 대시보드</a>
<a href="https://admin.unmong.com/login" target="_blank" rel="noopener" class="sl-btn sl-btn-outline">관리자</a>
```

> **원칙**: 히어로 버튼에는 카드에 이미 있는 기능만 넣는다. 히어로에 노출되는 기능은 §4 카드 그리드에도 반드시 존재해야 한다.

---

## 6. 변경 시 체크리스트

포털 HTML 편집을 저장·배포하기 전에 아래 7 문항을 스스로 답한다.

- [ ] 신규 기능이 있다면 §4 의 4 카테고리 중 하나를 정했는가?
- [ ] 설명 문구가 50~80자 범위이고 한 문장인가?
- [ ] 태그가 `카테고리 · 키워드` 2단 형식인가?
- [ ] URL 에 `target="_blank" rel="noopener"` 가 붙었는가?
- [ ] 앱 사이드바 라벨과 포털 카드 라벨이 일치하는가?
- [ ] 히어로 버튼에 올린 기능은 §4 카드 그리드에도 존재하는가?
- [ ] 안정화된 기존 카드에 `[NEW]` 접두어나 Phase 태그가 남아 있지 않은가?

---

## 7. 변경 이력

| 날짜 | 변경 내용 | 작성자 |
|------|----------|--------|
| 2026-04-15 | 최초 작성 — Public 3 + Admin 9 = 12 카드 기준 가이드 신설 (게이트웨이 제안용) | Claude Code |
