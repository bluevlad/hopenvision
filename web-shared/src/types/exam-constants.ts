// 시험 유형
export const EXAM_TYPES = [
  { value: '9LEVEL', label: '9급 공무원' },
  { value: '7LEVEL', label: '7급 공무원' },
  { value: 'POLICE', label: '경찰 공무원' },
  { value: 'FIRE', label: '소방 공무원' },
  { value: 'COURT', label: '법원직' },
  { value: 'TAX', label: '세무직' },
  { value: 'OTHER', label: '기타' },
];

// 과목 유형
export const SUBJECT_TYPES = [
  { value: 'M', label: '필수' },
  { value: 'S', label: '선택' },
];

// 문제 유형
export const QUESTION_TYPES = [
  { value: 'CHOICE', label: '객관식' },
  { value: 'ESSAY', label: '주관식' },
  { value: 'MIX', label: '혼합' },
];
