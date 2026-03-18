import { adminClient as client } from './adminClient';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type {
  QuestionBankGroupResponse,
  QuestionBankGroupDetailResponse,
  QuestionBankGroupRequest,
  QuestionBankItemResponse,
  QuestionBankItemRequest,
} from '../types/questionBank';

const BASE_PATH = '/api/question-bank';

export const questionBankApi = {
  // 그룹 목록 조회
  getGroupList: async (params: {
    keyword?: string;
    category?: string;
    examYear?: string;
    source?: string;
    isUse?: string;
    page?: number;
    size?: number;
  }): Promise<ApiResponse<PageResponse<QuestionBankGroupResponse>>> => {
    const response = await client.get(BASE_PATH, { params });
    return response.data;
  },

  // 그룹 상세 조회
  getGroupDetail: async (groupId: number): Promise<ApiResponse<QuestionBankGroupDetailResponse>> => {
    const response = await client.get(`${BASE_PATH}/${groupId}`);
    return response.data;
  },

  // 그룹 등록
  createGroup: async (data: QuestionBankGroupRequest): Promise<ApiResponse<QuestionBankGroupResponse>> => {
    const response = await client.post(BASE_PATH, data);
    return response.data;
  },

  // 그룹 수정
  updateGroup: async (groupId: number, data: QuestionBankGroupRequest): Promise<ApiResponse<QuestionBankGroupResponse>> => {
    const response = await client.put(`${BASE_PATH}/${groupId}`, data);
    return response.data;
  },

  // 그룹 삭제
  deleteGroup: async (groupId: number): Promise<ApiResponse<void>> => {
    const response = await client.delete(`${BASE_PATH}/${groupId}`);
    return response.data;
  },

  // 항목 목록 조회
  getItemList: async (groupId: number, subjectCd?: string): Promise<ApiResponse<QuestionBankItemResponse[]>> => {
    const response = await client.get(`${BASE_PATH}/${groupId}/items`, {
      params: { subjectCd },
    });
    return response.data;
  },

  // 항목 등록
  createItem: async (groupId: number, data: QuestionBankItemRequest): Promise<ApiResponse<QuestionBankItemResponse>> => {
    const response = await client.post(`${BASE_PATH}/${groupId}/items`, data);
    return response.data;
  },

  // 항목 수정
  updateItem: async (groupId: number, itemId: number, data: QuestionBankItemRequest): Promise<ApiResponse<QuestionBankItemResponse>> => {
    const response = await client.put(`${BASE_PATH}/${groupId}/items/${itemId}`, data);
    return response.data;
  },

  // 항목 삭제
  deleteItem: async (groupId: number, itemId: number): Promise<ApiResponse<void>> => {
    const response = await client.delete(`${BASE_PATH}/${groupId}/items/${itemId}`);
    return response.data;
  },
};
