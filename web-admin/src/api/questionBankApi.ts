import { adminClient as client } from './adminClient';
import type {
  QuestionBankGroupResponse,
  QuestionBankGroupDetailResponse,
  QuestionBankGroupRequest,
  QuestionBankItemResponse,
  QuestionBankItemRequest,
  GroupSearchParams,
  ItemSearchParams,
} from '../types/questionBank';

const BASE_PATH = '/api/question-bank';

export const questionBankApi = {
  // ==================== Group ====================

  // 그룹 목록 조회
  getGroupList: async (params: GroupSearchParams): Promise<{
    success: boolean;
    data: QuestionBankGroupResponse[];
    totalElements: number;
    totalPages: number;
    page: number;
    size: number;
  }> => {
    const response = await client.get(`${BASE_PATH}/groups`, { params });
    return response.data;
  },

  // 그룹 상세 조회 (문제 포함)
  getGroupDetail: async (groupId: number): Promise<{ success: boolean; data: QuestionBankGroupDetailResponse }> => {
    const response = await client.get(`${BASE_PATH}/groups/${groupId}`);
    return response.data;
  },

  // 그룹 등록
  createGroup: async (data: QuestionBankGroupRequest): Promise<{ success: boolean; data: QuestionBankGroupResponse }> => {
    const response = await client.post(`${BASE_PATH}/groups`, data);
    return response.data;
  },

  // 그룹 수정
  updateGroup: async (groupId: number, data: QuestionBankGroupRequest): Promise<{ success: boolean; data: QuestionBankGroupResponse }> => {
    const response = await client.put(`${BASE_PATH}/groups/${groupId}`, data);
    return response.data;
  },

  // 그룹 삭제
  deleteGroup: async (groupId: number): Promise<{ success: boolean }> => {
    const response = await client.delete(`${BASE_PATH}/groups/${groupId}`);
    return response.data;
  },

  // ==================== Item ====================

  // 문제 목록 조회
  getItemList: async (params: ItemSearchParams): Promise<{
    success: boolean;
    data: QuestionBankItemResponse[];
    totalElements: number;
    totalPages: number;
    page: number;
    size: number;
  }> => {
    const response = await client.get(`${BASE_PATH}/items`, { params });
    return response.data;
  },

  // 문제 상세 조회
  getItemDetail: async (itemId: number): Promise<{ success: boolean; data: QuestionBankItemResponse }> => {
    const response = await client.get(`${BASE_PATH}/items/${itemId}`);
    return response.data;
  },

  // 문제 등록
  createItem: async (data: QuestionBankItemRequest): Promise<{ success: boolean; data: QuestionBankItemResponse }> => {
    const response = await client.post(`${BASE_PATH}/items`, data);
    return response.data;
  },

  // 문제 수정
  updateItem: async (itemId: number, data: QuestionBankItemRequest): Promise<{ success: boolean; data: QuestionBankItemResponse }> => {
    const response = await client.put(`${BASE_PATH}/items/${itemId}`, data);
    return response.data;
  },

  // 문제 삭제
  deleteItem: async (itemId: number): Promise<{ success: boolean }> => {
    const response = await client.delete(`${BASE_PATH}/items/${itemId}`);
    return response.data;
  },

  // 문제 일괄 등록
  bulkImportItems: async (groupId: number, items: QuestionBankItemRequest[]): Promise<{
    success: boolean;
    data: QuestionBankItemResponse[];
    count: number;
  }> => {
    const response = await client.post(`${BASE_PATH}/groups/${groupId}/bulk-import`, { items });
    return response.data;
  },
};
