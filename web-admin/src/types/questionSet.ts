export interface QuestionSetResponse {
  setId: number;
  setCd: string;
  setNm: string;
  subjectCd: string;
  subjectNm: string;
  questionCnt: number;
  totalScore: number;
  category: string | null;
  difficultyLevel: string | null;
  description: string | null;
  isUse: string;
  regDt: string;
  updDt: string;
}

export interface QuestionSetDetailResponse extends QuestionSetResponse {
  items: QuestionSetItemResponse[];
}

export interface QuestionSetRequest {
  setCd: string;
  setNm: string;
  subjectCd: string;
  category?: string;
  difficultyLevel?: string;
  description?: string;
  isUse?: string;
}

export interface QuestionSetItemResponse {
  setItemId: number;
  setId: number;
  itemId: number;
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
  questionNo?: number;
  score?: number;
  sortOrder?: number;
}
