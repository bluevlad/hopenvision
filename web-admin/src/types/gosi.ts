// 시험 마스터
export interface GosiMstResponse {
  gosiCd: string;
  gosiNm: string;
  gosiType: string;
  startDt: string | null;
  endDt: string | null;
  isuse: string;
  regDt: string | null;
  gosiYear: string | null;
  gosiRound: string | null;
  totalScore: number | null;
  passScore: number | null;
}

// 시험 유형 코드
export interface GosiCodResponse {
  gosiType: string;
  gosiTypeNm: string;
  isuse: string;
  pos: string;
}

// 지역
export interface GosiAreaResponse {
  gosiType: string;
  gosiArea: string;
  gosiAreaNm: string;
  isuse: string;
  pos: string;
}

// 과목
export interface GosiSubjectResponse {
  gosiType: string;
  gosiSubjectCd: string;
  gosiSubjecNm: string;
  isuse: string;
  pos: string;
}

// 정답
export interface GosiPassMstResponse {
  gosiCd: string;
  subjectCd: string;
  examType: string;
  itemNo: number;
  answerData: string;
  subjectNm: string;
}

// 합격선
export interface GosiPassStaResponse {
  gosiCd: string;
  gosiType: string;
  gosiTypeNm: string;
  passScore: number | null;
  isuse: string;
}

// 성적 마스터
export interface GosiRstMstResponse {
  gosiCd: string;
  rstNo: string;
  userId: string;
  gosiType: string;
  gosiArea: string;
  totalScore: number | null;
  avgScore: number | null;
  passYn: string;
  regDt: string | null;
}

// 성적 상세 (답안)
export interface GosiRstDetResponse {
  gosiCd: string;
  rstNo: string;
  subjectCd: string;
  itemNo: number;
  userId: string;
  answerData: string;
  isCorrect: string;
  regDt: string | null;
}

// 성적 과목별
export interface GosiRstSbjResponse {
  gosiCd: string;
  rstNo: string;
  subjectCd: string;
  subjectNm: string;
  score: number | null;
  correctCnt: number | null;
  totalCnt: number | null;
}

// 성적 상세 (전체)
export interface GosiRstDetailResponse {
  master: GosiRstMstResponse;
  subjects: GosiRstSbjResponse[];
  details: GosiRstDetResponse[];
}

// 통계
export interface GosiStatMstResponse {
  gosiCd: string;
  gosiType: string;
  gosiArea: string;
  gosiSubjectCd: string;
  gosiTypeNm: string;
  gosiAreaNm: string;
  gosiSubjectNm: string;
  totalCnt: number | null;
  avgScore: number | null;
  maxScore: number | null;
  minScore: number | null;
  passCnt: number | null;
  passRate: number | null;
}

// 과목 구분
export interface GosiSbjMstResponse {
  gosiCd: string;
  sbjType: string;
  subjectCd: string;
  subjectNm: string;
  isuse: string;
  pos: string;
}

// VOD
export interface GosiVodResponse {
  gosiCd: string;
  prfId: string;
  idx: number;
  subjectCd: string;
  subjectNm: string;
  prfNm: string;
  vodUrl: string;
  vodNm: string;
  isuse: string;
}

// 회원
export interface GosiMemberResponse {
  userId: string;
  userNm: string;
  userNicknm: string | null;
  userPosition: string | null;
  sex: string | null;
  userRole: string | null;
  adminRole: string | null;
  birthDay: string | null;
  categoryCode: string | null;
  userPoint: number | null;
  payment: number | null;
  isuse: string;
}
