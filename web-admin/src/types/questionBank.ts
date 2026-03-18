export interface QuestionBankGroupResponse {
  groupId: number;
  groupCd: string;
  groupNm: string;
  examYear: string | null;
  examRound: number | null;
  category: string | null;
  source: string | null;
  description: string | null;
  isUse: string;
  regDt: string;
  updDt: string;
  itemCount: number;
}

export interface QuestionBankGroupDetailResponse {
  groupId: number;
  groupCd: string;
  groupNm: string;
  examYear: string | null;
  examRound: number | null;
  category: string | null;
  source: string | null;
  description: string | null;
  isUse: string;
  regDt: string;
  updDt: string;
  items: QuestionBankItemResponse[];
}

export interface QuestionBankGroupRequest {
  groupCd: string;
  groupNm: string;
  examYear?: string;
  examRound?: number;
  category?: string;
  source?: string;
  description?: string;
  isUse?: string;
}

export interface QuestionBankItemResponse {
  itemId: number;
  groupId: number;
  subjectCd: string;
  subjectNm: string;
  questionNo: number;
  questionTitle: string | null;
  questionText: string | null;
  contextText: string | null;
  choice1: string | null;
  choice2: string | null;
  choice3: string | null;
  choice4: string | null;
  choice5: string | null;
  correctAns: string;
  isMultiAns: string;
  score: number | null;
  category: string | null;
  difficulty: string | null;
  questionType: string;
  tags: string | null;
  explanation: string | null;
  correctionNote: string | null;
  imageFile: string | null;
  useCount: number;
  correctRate: number | null;
  isUse: string;
  regDt: string;
  updDt: string;
}

export interface QuestionBankItemRequest {
  subjectCd: string;
  questionNo: number;
  questionTitle?: string;
  questionText?: string;
  contextText?: string;
  choice1?: string;
  choice2?: string;
  choice3?: string;
  choice4?: string;
  choice5?: string;
  correctAns: string;
  isMultiAns?: string;
  score?: number;
  category?: string;
  difficulty?: string;
  questionType?: string;
  tags?: string;
  explanation?: string;
  correctionNote?: string;
  imageFile?: string;
}
