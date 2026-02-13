import client from './client';
import type {
  UserExam,
  UserProfile,
  ScoringResult,
  ScoreAnalysis,
  HistoryItem,
  SubmitRequest,
  UserProfileUpsertRequest,
  UserExamListResponse,
  UserExamDetailResponse,
  ScoringResultResponse,
  ScoreAnalysisResponse,
  HistoryListResponse,
  UserProfileResponse,
  UserProfileExistsResponse,
} from '../types/user';

const USER_ID_HEADER = 'X-User-Id';

// 사용자 ID 가져오기 (임시로 localStorage 사용)
export const getUserId = (): string => {
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

// 성적 비교/분석 조회
export const getScoreAnalysis = async (examCd: string): Promise<ScoreAnalysis> => {
  const response = await client.get<ScoreAnalysisResponse>(`/api/user/exams/${examCd}/analysis`, {
    headers: { [USER_ID_HEADER]: getUserId() },
  });
  return response.data.data;
};

// 채점 이력 조회
export const getUserHistory = async (): Promise<HistoryItem[]> => {
  const response = await client.get<HistoryListResponse>('/api/user/history', {
    headers: { [USER_ID_HEADER]: getUserId() },
  });
  return response.data.data;
};

// 내 프로필 조회
export const getMyProfile = async (): Promise<UserProfile | null> => {
  const response = await client.get<UserProfileResponse>('/api/user/profile', {
    headers: { [USER_ID_HEADER]: getUserId() },
  });
  return response.data.data;
};

// 프로필 존재 여부 확인
export const hasProfile = async (): Promise<boolean> => {
  const response = await client.get<UserProfileExistsResponse>('/api/user/profile/exists', {
    headers: { [USER_ID_HEADER]: getUserId() },
  });
  return response.data.data;
};

// 프로필 생성/수정
export const upsertProfile = async (request: UserProfileUpsertRequest): Promise<UserProfile> => {
  const response = await client.post<UserProfileResponse>(
    '/api/user/profile',
    request,
    {
      headers: { [USER_ID_HEADER]: request.userId },
    }
  );
  return response.data.data;
};
