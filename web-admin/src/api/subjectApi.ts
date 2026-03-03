import { adminClient as client } from './adminClient';
import type {
  SubjectMasterResponse,
  SubjectMasterRequest,
  SubjectSearchParams,
} from '../types/subject';

const BASE_PATH = '/api/subjects';

export const subjectApi = {
  // 과목 목록 조회 (트리 구조)
  getSubjectList: async (category?: string): Promise<{ success: boolean; data: SubjectMasterResponse[] }> => {
    const response = await client.get(BASE_PATH, { params: { category } });
    return response.data;
  },

  // 과목 검색 (페이징)
  searchSubjects: async (params: SubjectSearchParams): Promise<{
    success: boolean;
    data: SubjectMasterResponse[];
    totalElements: number;
    totalPages: number;
    page: number;
    size: number;
  }> => {
    const response = await client.get(`${BASE_PATH}/search`, { params });
    return response.data;
  },

  // 과목 상세 조회
  getSubjectDetail: async (subjectCd: string): Promise<{ success: boolean; data: SubjectMasterResponse }> => {
    const response = await client.get(`${BASE_PATH}/${subjectCd}`);
    return response.data;
  },

  // 과목 등록
  createSubject: async (data: SubjectMasterRequest): Promise<{ success: boolean; data: SubjectMasterResponse }> => {
    const response = await client.post(BASE_PATH, data);
    return response.data;
  },

  // 과목 수정
  updateSubject: async (subjectCd: string, data: SubjectMasterRequest): Promise<{ success: boolean; data: SubjectMasterResponse }> => {
    const response = await client.put(`${BASE_PATH}/${subjectCd}`, data);
    return response.data;
  },

  // 과목 삭제 (soft delete)
  deleteSubject: async (subjectCd: string): Promise<{ success: boolean }> => {
    const response = await client.delete(`${BASE_PATH}/${subjectCd}`);
    return response.data;
  },
};
