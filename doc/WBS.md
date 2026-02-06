# HopenVision WBS (Work Breakdown Structure)

## 개요
이 문서는 HopenVision 프로젝트의 전체 작업을 단계별로 정의합니다.

---

## Phase 1: 프로젝트 기반 구축

### 1.1 개발 환경 설정
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 1.1.1 | 프로젝트 저장소 통합 | 완료 | hopenvision/ 폴더 구조 |
| 1.1.2 | Git 저장소 초기화 | 완료 | .git, .gitignore |
| 1.1.3 | Docker Compose 설정 | 완료 | docker-compose.yml |
| 1.1.4 | 개발 표준 문서화 | 진행중 | doc/dev/*.md |
| 1.1.5 | VS Code 설정 | 대기 | .vscode/settings.json |

### 1.2 Backend 프로젝트 구조화
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 1.2.1 | 패키지 구조 정리 | 대기 | common/, exam/ 패키지 |
| 1.2.2 | 공통 모듈 구현 | 대기 | ApiResponse, Exception Handler |
| 1.2.3 | 설정 파일 정리 | 대기 | application-{profile}.yml |
| 1.2.4 | Dockerfile 작성 | 대기 | api/Dockerfile |

### 1.3 Frontend 프로젝트 구조화
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 1.3.1 | 디렉토리 구조 정리 | 대기 | components/, pages/, hooks/ |
| 1.3.2 | 공통 컴포넌트 정의 | 대기 | components/common/* |
| 1.3.3 | API 클라이언트 표준화 | 대기 | api/client.ts |
| 1.3.4 | Dockerfile 작성 | 대기 | web/Dockerfile |

---

## Phase 2: 시험 관리 모듈

### 2.1 시험 마스터 관리
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 2.1.1 | Entity 설계 | 완료 | Exam.java |
| 2.1.2 | Repository 구현 | 완료 | ExamRepository.java |
| 2.1.3 | Service 구현 | 완료 | ExamService.java |
| 2.1.4 | Controller 구현 | 완료 | ExamController.java |
| 2.1.5 | 시험 목록 페이지 | 완료 | ExamList.tsx |
| 2.1.6 | 시험 등록/수정 페이지 | 완료 | ExamForm.tsx |

### 2.2 과목 관리
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 2.2.1 | Entity 설계 | 완료 | ExamSubject.java |
| 2.2.2 | Repository 구현 | 완료 | ExamSubjectRepository.java |
| 2.2.3 | Service 통합 | 완료 | ExamService.java |
| 2.2.4 | 과목 관리 UI | 완료 | ExamForm.tsx 내 통합 |

### 2.3 정답 관리
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 2.3.1 | Entity 설계 | 완료 | ExamAnswerKey.java |
| 2.3.2 | Repository 구현 | 완료 | ExamAnswerKeyRepository.java |
| 2.3.3 | Service 구현 | 완료 | ExamService.java |
| 2.3.4 | 정답 입력 페이지 | 완료 | AnswerKeyForm.tsx |
| 2.3.5 | Excel 가져오기 | 완료 | ExcelImport.tsx, ExcelImportService.java |

---

## Phase 3: 응시자 관리 모듈

### 3.1 응시자 정보 관리
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 3.1.1 | Entity 설계 | 대기 | ExamApplicant.java |
| 3.1.2 | Repository 구현 | 대기 | ExamApplicantRepository.java |
| 3.1.3 | Service 구현 | 대기 | ApplicantService.java |
| 3.1.4 | Controller 구현 | 대기 | ApplicantController.java |
| 3.1.5 | 응시자 목록 페이지 | 대기 | ApplicantList.tsx |
| 3.1.6 | 응시자 등록 페이지 | 대기 | ApplicantForm.tsx |
| 3.1.7 | 응시자 Excel 가져오기 | 대기 | ApplicantImport.tsx |

### 3.2 답안 입력
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 3.2.1 | 답안 Entity 설계 | 대기 | ExamApplicantAnswer.java |
| 3.2.2 | 답안 입력 페이지 | 대기 | AnswerSheet.tsx |
| 3.2.3 | OMR 스타일 UI | 대기 | OMRSheet 컴포넌트 |
| 3.2.4 | 답안 Excel 가져오기 | 대기 | AnswerImport.tsx |

---

## Phase 4: 채점 및 성적 처리

### 4.1 자동 채점
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 4.1.1 | 채점 Service 구현 | 대기 | ScoringService.java |
| 4.1.2 | 개별 채점 API | 대기 | POST /api/scoring/{applicantNo} |
| 4.1.3 | 일괄 채점 API | 대기 | POST /api/scoring/batch |
| 4.1.4 | 채점 실행 UI | 대기 | ScoringPanel.tsx |

### 4.2 성적 처리
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 4.2.1 | 과목별 성적 Entity | 대기 | ExamApplicantScore.java |
| 4.2.2 | 순위 계산 로직 | 대기 | SP_CALC_RANKING 프로시저 |
| 4.2.3 | 과락 판정 로직 | 대기 | SP_JUDGE_PASS 프로시저 |
| 4.2.4 | 성적 조회 페이지 | 대기 | ScoreList.tsx |

### 4.3 합격 판정
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 4.3.1 | 합격선 Entity | 대기 | ExamPassLine.java |
| 4.3.2 | 합격선 설정 UI | 대기 | PassLineSettings.tsx |
| 4.3.3 | 합격 판정 로직 | 대기 | SP_JUDGE_PASS 프로시저 |
| 4.3.4 | 합격자 조회 페이지 | 대기 | PassList.tsx |

---

## Phase 5: 통계 및 분석

### 5.1 시험 통계
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 5.1.1 | 통계 Entity | 대기 | ExamStat.java |
| 5.1.2 | 통계 생성 Service | 대기 | StatisticsService.java |
| 5.1.3 | 통계 API | 대기 | GET /api/statistics/{examCd} |
| 5.1.4 | 통계 대시보드 | 대기 | StatisticsDashboard.tsx |

### 5.2 차트 및 시각화
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 5.2.1 | 점수 분포 차트 | 대기 | ScoreDistribution.tsx |
| 5.2.2 | 과목별 평균 차트 | 대기 | SubjectAverage.tsx |
| 5.2.3 | 지역별 통계 | 대기 | RegionalStats.tsx |
| 5.2.4 | Excel 내보내기 | 대기 | ExcelExport.tsx |

---

## Phase 6: 시스템 기능

### 6.1 사용자 관리 (향후)
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 6.1.1 | 회원 Entity | 대기 | User.java |
| 6.1.2 | JWT 인증 구현 | 대기 | JwtTokenProvider.java |
| 6.1.3 | 로그인/로그아웃 | 대기 | Login.tsx |
| 6.1.4 | 권한 관리 | 대기 | Role, Permission Entity |

### 6.2 시스템 설정
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 6.2.1 | 공통 코드 관리 | 대기 | CommonCode Entity, API |
| 6.2.2 | 시스템 설정 UI | 대기 | Settings.tsx |
| 6.2.3 | 감사 로그 | 대기 | AuditLog Entity |

---

## Phase 7: 배포 및 운영

### 7.1 컨테이너화
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 7.1.1 | Backend Dockerfile | 대기 | api/Dockerfile |
| 7.1.2 | Frontend Dockerfile | 대기 | web/Dockerfile |
| 7.1.3 | 개발용 Docker Compose | 대기 | docker/docker-compose.local.yml |
| 7.1.4 | 운영용 Docker Compose | 대기 | docker/docker-compose.prod.yml |

### 7.2 CI/CD
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 7.2.1 | GitHub Actions 설정 | 대기 | .github/workflows/deploy.yml |
| 7.2.2 | Self-hosted Runner | 대기 | 로컬 Runner 설정 |
| 7.2.3 | 자동 배포 스크립트 | 대기 | scripts/deploy.ps1 |

### 7.3 Nginx 설정
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 7.3.1 | Reverse Proxy 설정 | 대기 | docker/nginx/hopenvision.conf |
| 7.3.2 | SSL 인증서 설정 | 대기 | certbot 설정 |

---

## 작업 요약

### 완료 현황
| Phase | 전체 | 완료 | 진행률 |
|-------|------|------|--------|
| Phase 1 | 13 | 4 | 31% |
| Phase 2 | 15 | 15 | 100% |
| Phase 3 | 11 | 0 | 0% |
| Phase 4 | 11 | 0 | 0% |
| Phase 5 | 8 | 0 | 0% |
| Phase 6 | 7 | 0 | 0% |
| Phase 7 | 9 | 0 | 0% |
| **전체** | **74** | **19** | **26%** |

### 우선순위 작업 (다음 단계)
1. **Phase 1 완료**: 개발 표준 문서화, 패키지 구조 정리
2. **Phase 3 시작**: 응시자 관리 모듈 구현
3. **Phase 4**: 채점 로직 구현

---

## 의존 관계

```
Phase 1 (기반 구축)
    │
    ├──► Phase 2 (시험 관리) ──┐
    │                         │
    └──► Phase 3 (응시자 관리) ─┼──► Phase 4 (채점/성적)
                              │         │
                              │         ▼
                              └──► Phase 5 (통계)
                                         │
Phase 6 (사용자 관리) ◄──────────────────┘
    │
    ▼
Phase 7 (배포/운영)
```

---

## 변경 이력

| 버전 | 일자 | 변경 내용 |
|------|------|----------|
| 1.0 | 2025-02-06 | 초안 작성 |
