export interface ExamResponse {
  examCd: string;
  examNm: string;
  examType: string;
  examYear: string;
  examRound: number | null;
  examDate: string | null;
  totalScore: number | null;
  passScore: number | null;
  isUse: string;
  regDt: string;
  updDt: string;
  subjectCnt: number;
  applicantCnt: number;
}

export interface ExamDetailResponse extends ExamResponse {
  subjects: SubjectResponse[];
}

export interface ExamRequest {
  examCd: string;
  examNm: string;
  examType: string;
  examYear: string;
  examRound?: number;
  examDate?: string;
  totalScore?: number;
  passScore?: number;
  isUse?: string;
  subjects?: SubjectRequest[];
}

export interface SubjectResponse {
  examCd: string;
  subjectCd: string;
  subjectNm: string;
  subjectType: string;
  questionCnt: number;
  scorePerQ: number;
  questionType: string;
  cutLine: number;
  sortOrder: number;
  isUse: string;
  regDt: string;
  answerCnt: number;
}

export interface SubjectRequest {
  subjectCd: string;
  subjectNm: string;
  subjectType?: string;
  questionCnt?: number;
  scorePerQ?: number;
  questionType?: string;
  cutLine?: number;
  sortOrder?: number;
  isUse?: string;
}

export interface AnswerKeyResponse {
  examCd: string;
  subjectCd: string;
  subjectNm?: string;
  questionNo: number;
  correctAns: string;
  score: number;
  isMultiAns: string;
  regDt: string;
  updDt: string;
}

export interface AnswerKeyBulkRequest {
  subjectCd: string;
  answers: AnswerItem[];
}

export interface AnswerItem {
  questionNo: number;
  correctAns: string;
  score?: number;
  isMultiAns?: string;
}

// Excel 가져오기 결과
export interface ExcelImportResult {
  totalRows: number;
  successCount: number;
  failCount: number;
  errors: string[];
  importedKeys: ImportedAnswerKey[];
}

export interface ImportedAnswerKey {
  subjectCode: string;
  subjectName: string;
  questionNo: number;
  correctAnswer: number;
  score: number | null;
}

// JSON 가져오기 결과
export interface JsonImportResult {
  totalCount: number;
  successCount: number;
  failCount: number;
  errors: string[];
  importedQuestions: ImportedQuestion[];
}

export interface ImportedQuestion {
  questionNo: number;
  questionText: string;
  category: string;
  difficulty: string;
  correctAnswer: number;
  title: string;
}
