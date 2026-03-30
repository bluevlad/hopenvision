export interface SubjectSummary {
  subjectCd: string;
  subjectNm: string;
  itemCount: number;
}

export interface QuestionSetResponse {
  setId: number;
  setCd: string;
  setNm: string;
  questionCnt: number;
  totalScore: number;
  subjectCnt: number;
  category: string | null;
  difficultyLevel: string | null;
  description: string | null;
  isUse: string;
  regDt: string;
  updDt: string;
  subjectSummaries: SubjectSummary[];
}

export interface QuestionSetDetailResponse extends QuestionSetResponse {
  items: QuestionSetItemResponse[];
}

export interface QuestionSetRequest {
  setCd: string;
  setNm: string;
  category?: string;
  difficultyLevel?: string;
  description?: string;
  isUse?: string;
}

export interface QuestionSetItemResponse {
  setItemId: number;
  setId: number;
  itemId: number;
  subjectCd: string;
  subjectNm: string;
  questionNo: number;
  score: number | null;
  sortOrder: number;
  questionTitle: string | null;
  questionText: string | null;
  correctAns: string | null;
  difficulty: string | null;
  questionType: string | null;
  bankScore: number | null;
}

export interface QuestionSetItemRequest {
  itemId: number;
  subjectCd: string;
  questionNo?: number;
  score?: number;
  sortOrder?: number;
}
