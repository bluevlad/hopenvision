# HopenVision WBS (Work Breakdown Structure)

## 개요
이 문서는 HopenVision 프로젝트의 전체 작업을 단계별로 정의합니다.

**시스템 구분:**
- **사용자 시스템 (User)**: 답안 입력, 채점, 순위/분포 확인
- **관리자 시스템 (Admin)**: 시험/정답 관리, 통계 대시보드
- **배치 시스템 (Batch)**: 통계 집계, 순위 계산

---

## Phase 1: 프로젝트 기반 구축

### 1.1 개발 환경 설정
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 1.1.1 | 프로젝트 저장소 통합 | 완료 | hopenvision/ 폴더 구조 |
| 1.1.2 | Git 저장소 초기화 | 완료 | .git, .gitignore |
| 1.1.3 | Docker Compose 설정 | 완료 | docker-compose.yml |
| 1.1.4 | 개발 표준 문서화 | 완료 | doc/dev/*.md |
| 1.1.5 | VS Code 설정 | 완료 | .vscode/settings.json |
| 1.1.6 | 구현 방안 문서화 | 완료 | doc/IMPLEMENTATION_PROPOSAL.md |

### 1.2 Backend 프로젝트 구조화
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 1.2.1 | 패키지 구조 정리 | 완료 | config/, exam/, user/ 패키지 |
| 1.2.2 | 공통 모듈 구현 | 완료 | GlobalExceptionHandler, WebConfig |
| 1.2.3 | 설정 파일 정리 | 완료 | application-{local,dev,prod}.yml |
| 1.2.4 | Dockerfile 작성 | 완료 | api/Dockerfile |

### 1.3 Frontend 프로젝트 구조화
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 1.3.1 | 사용자/관리자 라우팅 분리 | 완료 | /user/*, /exam/*, /applicant/*, /statistics |
| 1.3.2 | 공통 컴포넌트 정의 | 완료 | Layout.tsx, OMRCard.tsx, QuickInputCard.tsx |
| 1.3.3 | 차트 라이브러리 설치 | 대기 | @ant-design/charts |
| 1.3.4 | Dockerfile 작성 | 완료 | web/Dockerfile |

---

## Phase 2: 관리자 시스템 (Admin)

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

### 2.4 통계 대시보드
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 2.4.1 | 통계 API | 완료 | StatisticsController.java |
| 2.4.2 | 통계 조회 Service | 완료 | StatisticsService.java |
| 2.4.3 | 통계 페이지 | 완료 | Statistics.tsx |
| 2.4.4 | 점수 분포 차트 | 대기 | 차트 라이브러리 도입 후 구현 |
| 2.4.5 | 과목별 평균 차트 | 대기 | 차트 라이브러리 도입 후 구현 |
| 2.4.6 | 응시자 현황 차트 | 대기 | 차트 라이브러리 도입 후 구현 |

### 2.5 응시자 관리
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 2.5.1 | 응시자 CRUD API | 완료 | ApplicantController.java, ApplicantService.java |
| 2.5.2 | 응시자 목록 페이지 | 완료 | ApplicantList.tsx |
| 2.5.3 | 응시자 등록/수정 모달 | 완료 | ApplicantModal.tsx |
| 2.5.4 | 응시자 Excel 내보내기 | 대기 | ExcelExportService.java |

---

## Phase 3: 사용자 시스템 (User)

### 3.1 시험 조회
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 3.1.1 | 채점 가능 시험 목록 API | 완료 | UserExamController.java |
| 3.1.2 | 시험 목록 페이지 | 완료 | UserExamList.tsx |
| 3.1.3 | 시험 상세 조회 API | 완료 | UserExamController.java |

### 3.2 답안 입력 및 채점
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 3.2.1 | 사용자 답안 Entity | 완료 | UserAnswer.java |
| 3.2.2 | 사용자 점수 Entity | 완료 | UserScore.java, UserSubjectScore.java |
| 3.2.3 | 답안 제출/채점 API | 완료 | UserExamController.java |
| 3.2.4 | 즉시 채점 Service | 완료 | UserScoringService.java |
| 3.2.5 | OMR 카드 UI 컴포넌트 | 완료 | OMRCard.tsx, QuickInputCard.tsx |
| 3.2.6 | 답안 입력 페이지 | 완료 | UserAnswerForm.tsx |
| 3.2.7 | 채점 결과 페이지 | 완료 | UserScoreResult.tsx |

### 3.3 성적 비교 및 분석
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 3.3.1 | 순위 조회 API | 대기 | UserRankingController.java |
| 3.3.2 | 분포도 API | 대기 | UserDistributionController.java |
| 3.3.3 | 내 순위 페이지 | 대기 | UserRanking.tsx |
| 3.3.4 | 점수 분포 차트 (내 위치) | 대기 | MyScoreDistribution.tsx |
| 3.3.5 | 과목별 분석 차트 | 대기 | SubjectAnalysis.tsx |
| 3.3.6 | 다른 응시자 비교 | 대기 | ScoreComparison.tsx |

### 3.4 채점 이력
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 3.4.1 | 이력 조회 API | 대기 | UserHistoryController.java |
| 3.4.2 | 채점 이력 페이지 | 대기 | UserHistory.tsx |
| 3.4.3 | 오답 노트 기능 | 대기 | WrongAnswerNote.tsx |

---

## Phase 4: 배치 시스템 (Batch)

### 4.1 배치 인프라
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 4.1.1 | Spring Batch 설정 | 대기 | BatchConfig.java |
| 4.1.2 | 스케줄러 설정 | 대기 | SchedulerConfig.java |
| 4.1.3 | 배치 이력 Entity | 대기 | BatchJobHistory.java |
| 4.1.4 | 배치 모니터링 API | 대기 | BatchController.java |

### 4.2 통계 집계 배치
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 4.2.1 | 점수 분포 집계 Job | 대기 | ScoreDistributionJob.java |
| 4.2.2 | 과목별 통계 집계 Job | 대기 | SubjectStatisticsJob.java |
| 4.2.3 | 전체 통계 집계 Job | 대기 | TotalStatisticsJob.java |

### 4.3 순위 계산 배치
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 4.3.1 | 전체 순위 계산 Job | 대기 | TotalRankingJob.java |
| 4.3.2 | 지역별 순위 계산 Job | 대기 | AreaRankingJob.java |
| 4.3.3 | 유형별 순위 계산 Job | 대기 | TypeRankingJob.java |
| 4.3.4 | 상위 % 계산 Job | 대기 | PercentileJob.java |

### 4.4 관리자 배치 기능
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 4.4.1 | 수동 배치 실행 API | 대기 | AdminBatchController.java |
| 4.4.2 | 배치 이력 조회 페이지 | 대기 | AdminBatchHistory.tsx |
| 4.4.3 | 배치 상태 모니터링 | 대기 | BatchStatusPanel.tsx |

---

## Phase 5: 회원 시스템

### 5.1 인증/인가
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 5.1.1 | 회원 Entity | 대기 | User.java, Role.java |
| 5.1.2 | JWT 인증 구현 | 대기 | JwtTokenProvider.java |
| 5.1.3 | Spring Security 설정 | 대기 | SecurityConfig.java |
| 5.1.4 | 로그인 API | 대기 | AuthController.java |
| 5.1.5 | 로그인 페이지 | 대기 | Login.tsx |
| 5.1.6 | 회원가입 페이지 | 대기 | Register.tsx |

### 5.2 소셜 로그인 (선택)
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 5.2.1 | 카카오 로그인 | 대기 | KakaoOAuth2Service.java |
| 5.2.2 | 네이버 로그인 | 대기 | NaverOAuth2Service.java |
| 5.2.3 | 구글 로그인 | 대기 | GoogleOAuth2Service.java |

---

## Phase 6: 배포 및 운영

### 6.1 컨테이너화
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 6.1.1 | Backend Dockerfile | 완료 | api/Dockerfile |
| 6.1.2 | Frontend Dockerfile | 완료 | web/Dockerfile |
| 6.1.3 | 개발용 Docker Compose | 완료 | docker-compose.yml |
| 6.1.4 | 운영용 Docker Compose | 완료 | docker-compose.prod.yml |

### 6.2 CI/CD
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 6.2.1 | GitHub Actions 설정 | 완료 | .github/workflows/deploy-prod.yml |
| 6.2.2 | Self-hosted Runner | 완료 | macOS Runner 구성 |
| 6.2.3 | 자동화 스크립트 | 완료 | scripts/start-all.ps1, stop-all.ps1, status.ps1 |

### 6.3 Nginx 설정
| ID | 작업 | 상태 | 산출물 |
|----|------|------|--------|
| 6.3.1 | Reverse Proxy 설정 | 완료 | web/nginx.conf |
| 6.3.2 | SSL 인증서 설정 | 대기 | certbot 설정 |

---

## 작업 요약

### 완료 현황
| Phase | 전체 | 완료 | 진행률 |
|-------|------|------|--------|
| Phase 1: 기반 구축 | 14 | 13 | 93% |
| Phase 2: 관리자 시스템 | 21 | 18 | 86% |
| Phase 3: 사용자 시스템 | 17 | 10 | 59% |
| Phase 4: 배치 시스템 | 14 | 0 | 0% |
| Phase 5: 회원 시스템 | 9 | 0 | 0% |
| Phase 6: 배포/운영 | 9 | 8 | 89% |
| **전체** | **84** | **49** | **58%** |

### 우선순위 작업 (다음 단계)
1. **차트 라이브러리 도입**: 통계 시각화 (Phase 1.3.3, 2.4.4~2.4.6)
2. **성적 비교/분석**: Phase 3.3 구현
3. **채점 이력**: Phase 3.4 구현
4. **배치 시스템**: Phase 4 착수

---

## 의존 관계

```
Phase 1 (기반 구축)
    │
    ├──► Phase 2 (관리자) ──────────────┐
    │         │                        │
    │         └──► Phase 4 (배치) ─────┤
    │                                  │
    └──► Phase 3 (사용자) ─────────────┤
                                       │
                    Phase 5 (회원) ◄────┘
                         │
                         ▼
                  Phase 6 (배포)
```

---

## 변경 이력

| 버전 | 일자 | 변경 내용 |
|------|------|----------|
| 1.0 | 2025-02-06 | 초안 작성 |
| 2.0 | 2025-02-06 | 사용자/관리자/배치 시스템 구분, 회원 시스템 추가 |
| 2.1 | 2026-02-10 | 실제 구현 상태 반영 (Phase 1.2~1.3, 2.4~2.5, 3.1~3.2, 6.1~6.3 업데이트) |
