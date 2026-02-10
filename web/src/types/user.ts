import type { ApiResponse } from './exam';

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

// API Response 타입
export type UserExamListResponse = ApiResponse<UserExam[]>;
export type UserExamDetailResponse = ApiResponse<UserExam>;
export type ScoringResultResponse = ApiResponse<ScoringResult>;
export type ScoreAnalysisResponse = ApiResponse<ScoreAnalysis>;
export type HistoryListResponse = ApiResponse<HistoryItem[]>;
