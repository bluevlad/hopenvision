import { adminClient as client } from './adminClient';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type {
  QuestionSetResponse,
  QuestionSetDetailResponse,
  QuestionSetRequest,
  QuestionSetItemResponse,
  QuestionSetItemRequest,
} from '../types/questionSet';

const BASE_PATH = '/api/question-sets';

export const questionSetApi = {
  // 세트 목록 조회
  getSetList: async (params: {
    keyword?: string;
    subjectCd?: string;
    category?: string;
    isUse?: string;
    page?: number;
    size?: number;
  }): Promise<ApiResponse<PageResponse<QuestionSetResponse>>> => {
    const response = await client.get(BASE_PATH, { params });
    return response.data;
  },

  // 세트 상세 조회
  getSetDetail: async (setId: number): Promise<ApiResponse<QuestionSetDetailResponse>> => {
    const response = await client.get(`${BASE_PATH}/${setId}`);
    return response.data;
  },

  // 세트 등록
  createSet: async (data: QuestionSetRequest): Promise<ApiResponse<QuestionSetResponse>> => {
    const response = await client.post(BASE_PATH, data);
    return response.data;
  },

  // 세트 수정
  updateSet: async (setId: number, data: QuestionSetRequest): Promise<ApiResponse<QuestionSetResponse>> => {
    const response = await client.put(`${BASE_PATH}/${setId}`, data);
    return response.data;
  },

  // 세트 삭제
  deleteSet: async (setId: number): Promise<ApiResponse<void>> => {
    const response = await client.delete(`${BASE_PATH}/${setId}`);
    return response.data;
  },

  // 세트에 항목 추가
  addItem: async (setId: number, data: QuestionSetItemRequest): Promise<ApiResponse<QuestionSetItemResponse>> => {
    const response = await client.post(`${BASE_PATH}/${setId}/items`, data);
    return response.data;
  },

  // 세트 항목 수정
  updateItem: async (setId: number, setItemId: number, data: QuestionSetItemRequest): Promise<ApiResponse<QuestionSetItemResponse>> => {
    const response = await client.put(`${BASE_PATH}/${setId}/items/${setItemId}`, data);
    return response.data;
  },

  // 세트에서 항목 제거
  removeItem: async (setId: number, setItemId: number): Promise<ApiResponse<void>> => {
    const response = await client.delete(`${BASE_PATH}/${setId}/items/${setItemId}`);
    return response.data;
  },

  // 시험에 배치
  deployToExam: async (setId: number, examCd: string): Promise<ApiResponse<{ deployedCount: number; examCd: string }>> => {
    const response = await client.post(`${BASE_PATH}/${setId}/deploy/${examCd}`);
    return response.data;
  },
};
