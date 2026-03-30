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

// 시험 카테고리
export const EXAM_CATEGORIES = [
  { value: 'ACTUAL', label: '실제 시험' },
  { value: 'MOCK', label: '모의고사' },
  { value: 'PRACTICE', label: '연습' },
];

// 난이도
export const DIFFICULTY_LEVELS = [
  { value: 'EASY', label: '쉬움' },
  { value: 'MEDIUM', label: '보통' },
  { value: 'HARD', label: '어려움' },
];

// 문제은행 출처
export const QUESTION_SOURCES = [
  { value: 'ACTUAL', label: '기출문제' },
  { value: 'INTERNAL', label: '자체 출제' },
  { value: 'EXTERNAL', label: '외부 출제' },
];
