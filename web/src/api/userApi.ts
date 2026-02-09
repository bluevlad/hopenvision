import client from './client';
import type {
  UserExam,
  ScoringResult,
  SubmitRequest,
  UserExamListResponse,
  UserExamDetailResponse,
  ScoringResultResponse,
} from '../types/user';

const USER_ID_HEADER = 'X-User-Id';

// 사용자 ID 가져오기 (임시로 localStorage 사용)
const getUserId = (): string => {
  return localStorage.getItem('userId') || 'guest';
};

// 사용자 ID 설정
export const setUserId = (userId: string): void => {
  localStorage.setItem('userId', userId);
};

// 채점 가능한 시험 목록 조회
export const getAvailableExams = async (): Promise<UserExam[]> => {
  const response = await client.get<UserExamListResponse>('/api/user/exams', {
    headers: { [USER_ID_HEADER]: getUserId() },
  });
  return response.data.data;
};

// 시험 상세 조회
export const getExamDetail = async (examCd: string): Promise<UserExam> => {
  const response = await client.get<UserExamDetailResponse>(`/api/user/exams/${examCd}`, {
    headers: { [USER_ID_HEADER]: getUserId() },
  });
  return response.data.data;
};

// 답안 제출 및 채점
export const submitAnswers = async (examCd: string, request: SubmitRequest): Promise<ScoringResult> => {
  const response = await client.post<ScoringResultResponse>(
    `/api/user/exams/${examCd}/submit`,
    request,
    {
      headers: { [USER_ID_HEADER]: getUserId() },
    }
  );
  return response.data.data;
};

// 내 채점 결과 조회
export const getMyResult = async (examCd: string): Promise<ScoringResult> => {
  const response = await client.get<ScoringResultResponse>(`/api/user/exams/${examCd}/result`, {
    headers: { [USER_ID_HEADER]: getUserId() },
  });
  return response.data.data;
};
