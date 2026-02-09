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

// API Response 타입
export type UserExamListResponse = ApiResponse<UserExam[]>;
export type UserExamDetailResponse = ApiResponse<UserExam>;
export type ScoringResultResponse = ApiResponse<ScoringResult>;
