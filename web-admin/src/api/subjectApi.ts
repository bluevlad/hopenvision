import { adminClient as client } from './adminClient';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type {
  SubjectMasterResponse,
  SubjectMasterRequest,
  SubjectMasterTreeResponse,
  SubjectSearchParams,
} from '../types/subject';

const BASE_PATH = '/api/subjects';

export const subjectApi = {
  // 과목 목록 조회 (페이징)
  getSubjectList: async (params: SubjectSearchParams): Promise<ApiResponse<PageResponse<SubjectMasterResponse>>> => {
    const response = await client.get(BASE_PATH, { params });
    return response.data;
  },

  // 과목 트리 조회
  getSubjectTree: async (category?: string): Promise<ApiResponse<SubjectMasterTreeResponse[]>> => {
    const response = await client.get(`${BASE_PATH}/tree`, { params: { category } });
    return response.data;
  },

  // 카테고리별 과목 목록 (드롭다운용)
  getSubjectsByCategory: async (category?: string): Promise<ApiResponse<SubjectMasterResponse[]>> => {
    const response = await client.get(`${BASE_PATH}/by-category`, { params: { category } });
    return response.data;
  },

  // 과목 검색 (페이징)
  searchSubjects: async (params: SubjectSearchParams): Promise<ApiResponse<PageResponse<SubjectMasterResponse>>> => {
    const response = await client.get(`${BASE_PATH}/search`, { params });
    return response.data;
  },

  // 과목 상세 조회
  getSubjectDetail: async (subjectCd: string): Promise<ApiResponse<SubjectMasterResponse>> => {
    const response = await client.get(`${BASE_PATH}/${subjectCd}`);
    return response.data;
  },

  // 과목 등록
  createSubject: async (data: SubjectMasterRequest): Promise<ApiResponse<SubjectMasterResponse>> => {
    const response = await client.post(BASE_PATH, data);
    return response.data;
  },

  // 과목 수정
  updateSubject: async (subjectCd: string, data: SubjectMasterRequest): Promise<ApiResponse<SubjectMasterResponse>> => {
    const response = await client.put(`${BASE_PATH}/${subjectCd}`, data);
    return response.data;
  },

  // 과목 삭제
  deleteSubject: async (subjectCd: string): Promise<ApiResponse<void>> => {
    const response = await client.delete(`${BASE_PATH}/${subjectCd}`);
    return response.data;
  },
};
