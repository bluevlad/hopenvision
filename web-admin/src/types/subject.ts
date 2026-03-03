export interface SubjectMasterResponse {
  subjectCd: string;
  subjectNm: string;
  parentSubjectCd: string | null;
  subjectDepth: number;
  sortOrder: number;
  category: string | null;
  description: string | null;
  isUse: string;
  regDt: string;
  updDt: string;
  children?: SubjectMasterResponse[];
}

export interface SubjectMasterRequest {
  subjectCd: string;
  subjectNm: string;
  parentSubjectCd?: string | null;
  subjectDepth?: number;
  sortOrder?: number;
  category?: string | null;
  description?: string | null;
  isUse?: string;
}

export interface SubjectSearchParams {
  keyword?: string;
  category?: string;
  isUse?: string;
  page?: number;
  size?: number;
}
