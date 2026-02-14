export interface ApplicantResponse {
  examCd: string;
  applicantNo: string;
  userId: string | null;
  userNm: string;
  applyArea: string | null;
  applyType: string | null;
  addScore: number;
  totalScore: number | null;
  avgScore: number | null;
  ranking: number | null;
  passYn: string | null;
  scoreStatus: string;
  regDt: string;
  updDt: string;
}

export interface ApplicantRequest {
  applicantNo: string;
  userId?: string;
  userNm: string;
  applyArea?: string;
  applyType?: string;
  addScore?: number;
}

export const APPLY_AREAS = [
  { value: 'SEOUL', label: '서울' },
  { value: 'BUSAN', label: '부산' },
  { value: 'DAEGU', label: '대구' },
  { value: 'INCHEON', label: '인천' },
  { value: 'GWANGJU', label: '광주' },
  { value: 'DAEJEON', label: '대전' },
  { value: 'ULSAN', label: '울산' },
  { value: 'SEJONG', label: '세종' },
  { value: 'GYEONGGI', label: '경기' },
  { value: 'GANGWON', label: '강원' },
  { value: 'CHUNGBUK', label: '충북' },
  { value: 'CHUNGNAM', label: '충남' },
  { value: 'JEONBUK', label: '전북' },
  { value: 'JEONNAM', label: '전남' },
  { value: 'GYEONGBUK', label: '경북' },
  { value: 'GYEONGNAM', label: '경남' },
  { value: 'JEJU', label: '제주' },
];

export const APPLY_TYPES = [
  { value: 'GENERAL', label: '일반' },
  { value: 'DISABLED', label: '장애인' },
  { value: 'VETERAN', label: '보훈' },
  { value: 'LOCAL', label: '지역인재' },
  { value: 'LOWCLASS', label: '저소득층' },
];
