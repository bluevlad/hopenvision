export interface SubjectMasterResponse {
  subjectCd: string;
  subjectNm: string;
  parentSubjectCd: string | null;
  subjectDepth: number;
  category: string | null;
  description: string | null;
  sortOrder: number;
  isUse: string;
  regDt: string;
  updDt: string;
  childCount: number;
  examCount: number | null;
}

export interface SubjectMasterRequest {
  subjectCd: string;
  subjectNm: string;
  parentSubjectCd?: string;
  subjectDepth?: number;
  category?: string;
  description?: string;
  sortOrder?: number;
  isUse?: string;
}

export interface SubjectMasterTreeResponse {
  subjectCd: string;
  subjectNm: string;
  parentSubjectCd: string | null;
  subjectDepth: number;
  category: string | null;
  description: string | null;
  sortOrder: number;
  isUse: string;
  children: SubjectMasterTreeResponse[];
}
