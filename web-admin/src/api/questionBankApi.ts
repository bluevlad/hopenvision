import { adminClient as client } from './adminClient';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type {
  QuestionBankGroupResponse,
  QuestionBankGroupDetailResponse,
  QuestionBankGroupRequest,
  QuestionBankItemResponse,
  QuestionBankItemRequest,
  GroupSearchParams,
  ItemSearchParams,
  CsvUpdateResult,
} from '../types/questionBank';

const BASE_PATH = '/api/question-bank';

export const questionBankApi = {
  // ==================== Group ====================

  // 그룹 목록 조회
  getGroupList: async (params: GroupSearchParams): Promise<ApiResponse<PageResponse<QuestionBankGroupResponse>>> => {
    const response = await client.get(BASE_PATH, { params });
    return response.data;
  },

  // 그룹 상세 조회 (문제 포함)
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

  // ==================== Item ====================

  // 문제 목록 조회
  getItemList: async (params: ItemSearchParams): Promise<ApiResponse<PageResponse<QuestionBankItemResponse>>> => {
    const response = await client.get(`${BASE_PATH}/items`, { params });
    return response.data;
  },

  // 문제 상세 조회
  getItemDetail: async (itemId: number): Promise<ApiResponse<QuestionBankItemResponse>> => {
    const response = await client.get(`${BASE_PATH}/items/${itemId}`);
    return response.data;
  },

  // 문제 등록
  createItem: async (groupId: number, data: QuestionBankItemRequest): Promise<ApiResponse<QuestionBankItemResponse>> => {
    const response = await client.post(`${BASE_PATH}/${groupId}/items`, data);
    return response.data;
  },

  // 문제 수정
  updateItem: async (groupId: number, itemId: number, data: QuestionBankItemRequest): Promise<ApiResponse<QuestionBankItemResponse>> => {
    const response = await client.put(`${BASE_PATH}/${groupId}/items/${itemId}`, data);
    return response.data;
  },

  // 문제 삭제
  deleteItem: async (groupId: number, itemId: number): Promise<ApiResponse<void>> => {
    const response = await client.delete(`${BASE_PATH}/${groupId}/items/${itemId}`);
    return response.data;
  },

  // 문제 일괄 등록
  bulkImportItems: async (groupId: number, items: QuestionBankItemRequest[]): Promise<ApiResponse<QuestionBankItemResponse[]>> => {
    const response = await client.post(`${BASE_PATH}/${groupId}/bulk-import`, { items });
    return response.data;
  },

  // CSV 정답/배점/난이도 업데이트 미리보기
  csvUpdatePreview: async (file: File): Promise<ApiResponse<CsvUpdateResult>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await client.post(`${BASE_PATH}/csv-update/preview`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },

  // CSV 정답/배점/난이도 업데이트 적용
  csvUpdateApply: async (file: File): Promise<ApiResponse<CsvUpdateResult>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await client.post(`${BASE_PATH}/csv-update/apply`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },

  // Excel 정답/배점/난이도 업데이트 미리보기
  excelUpdatePreview: async (file: File): Promise<ApiResponse<CsvUpdateResult>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await client.post(`${BASE_PATH}/excel-update/preview`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },

  // Excel 정답/배점/난이도 업데이트 적용
  excelUpdateApply: async (file: File): Promise<ApiResponse<CsvUpdateResult>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await client.post(`${BASE_PATH}/excel-update/apply`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },
};
