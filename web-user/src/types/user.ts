import type { ApiResponse } from '@hopenvision/shared';

// 사용자 시험 정보
export interface UserExam {
  examCd: string;
  examNm: string;
  examType: string;
  examYear: string;
  examRound: number;
  examDate: string;
  totalScore: number;
  passScore: number;
  applicantCount: number;
  hasSubmitted: boolean;
  subjects: SubjectInfo[];
}

export interface SubjectInfo {
  subjectCd: string;
  subjectNm: string;
  subjectType: string;
  questionCnt: number;
  scorePerQ: number;
  questionType: string;
  cutLine: number;
  timeLimit: number;
  groupId: number | null;
}

// 모의고사 문제 조회
export interface ExamQuestionData {
  subjectCd: string;
  subjectNm: string;
  timeLimit: number;
  questionCnt: number;
  questions: QuestionItem[];
}

export interface QuestionItem {
  questionNo: number;
  questionText: string;
  contextText: string | null;
  choices: string[];
  imageUrl: string | null;
}

// 답안 제출 요청
export interface SubmitRequest {
  examCd: string;
  subjects: SubjectAnswer[];
}

export interface SubjectAnswer {
  subjectCd: string;
  answers: QuestionAnswer[];
}

export interface QuestionAnswer {
  questionNo: number;
  answer: string;
}

// 채점 결과
export interface ScoringResult {
  examCd: string;
  examNm: string;
  totalScore: number;
  avgScore: number;
  totalCorrect: number;
  totalWrong: number;
  totalQuestions: number;
  correctRate: number;
  estimatedRanking: number;
  totalApplicants: number;
  passYn: string;
  cutFailYn: string;
  subjectResults: SubjectResult[];
}

export interface SubjectResult {
  subjectCd: string;
  subjectNm: string;
  score: number;
  correctCnt: number;
  wrongCnt: number;
  totalQuestions: number;
  correctRate: number;
  cutLine: number;
  cutFailYn: string;
  questionResults: QuestionResult[];
}

export interface QuestionResult {
  questionNo: number;
  userAns: string;
  correctAns: string;
  isCorrect: string;
  score: number;
}

// 성적 분석
export interface ScoreAnalysis {
  examCd: string;
  examNm: string;
  myTotalScore: number;
  myAvgScore: number;
  ranking: number;
  totalApplicants: number;
  percentile: number;
  passYn: string;
  scoreDistributions: AnalysisScoreDistribution[];
  subjectComparisons: SubjectComparison[];
}

export interface AnalysisScoreDistribution {
  range: string;
  count: number;
  percentage: number;
  isUserInRange: boolean;
}

export interface SubjectComparison {
  subjectCd: string;
  subjectNm: string;
  myScore: number;
  avgScore: number;
  maxScore: number;
  minScore: number;
  ranking: number;
  totalCount: number;
}

// 채점 이력
export interface HistoryItem {
  examCd: string;
  examNm: string;
  totalScore: number;
  avgScore: number;
  passYn: string;
  regDt: string;
}

// 사용자 프로필
export interface UserProfile {
  userId: string;
  userNm: string;
  email: string | null;
  newsletterYn: string;
  regDt: string;
  updDt: string;
}

export interface UserProfileUpsertRequest {
  userId: string;
  userNm: string;
  email?: string;
  newsletterYn: string;
}

// 성적 추이
export interface ScoreTrendItem {
  examCd: string;
  examNm: string;
  totalScore: number;
  avgScore: number;
  passYn: string;
  regDt: string;
}

// 약점 진단
export interface WeaknessItem {
  subjectCd: string;
  subjectNm: string;
  correctRate: number;
  correctCnt: number;
  wrongCnt: number;
  totalQuestions: number;
  level: string;
}

// API Response 타입
export type UserExamListResponse = ApiResponse<UserExam[]>;
export type UserExamDetailResponse = ApiResponse<UserExam>;
export type ScoringResultResponse = ApiResponse<ScoringResult>;
export type ScoreAnalysisResponse = ApiResponse<ScoreAnalysis>;
export type HistoryListResponse = ApiResponse<HistoryItem[]>;
export type UserProfileResponse = ApiResponse<UserProfile>;
export type UserProfileExistsResponse = ApiResponse<boolean>;
export type ExamQuestionResponse = ApiResponse<ExamQuestionData>;
