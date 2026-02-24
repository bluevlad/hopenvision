import { adminClient as client } from './adminClient';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type {
  GosiMstResponse,
  GosiCodResponse,
  GosiAreaResponse,
  GosiSubjectResponse,
  GosiPassMstResponse,
  GosiPassStaResponse,
  GosiRstMstResponse,
  GosiRstDetailResponse,
  GosiStatMstResponse,
  GosiSbjMstResponse,
  GosiVodResponse,
  GosiMemberResponse,
} from '../types/gosi';

export const gosiApi = {
  // === 시험 관리 ===
  getExamList: async (): Promise<ApiResponse<GosiMstResponse[]>> => {
    const response = await client.get('/api/gosi/exams');
    return response.data;
  },

  getExamDetail: async (gosiCd: string): Promise<ApiResponse<GosiMstResponse>> => {
    const response = await client.get(`/api/gosi/exams/${gosiCd}`);
    return response.data;
  },

  getTypeList: async (): Promise<ApiResponse<GosiCodResponse[]>> => {
    const response = await client.get('/api/gosi/exams/types');
    return response.data;
  },

  getAreaList: async (gosiType?: string): Promise<ApiResponse<GosiAreaResponse[]>> => {
    const response = await client.get('/api/gosi/exams/areas', { params: { gosiType } });
    return response.data;
  },

  // === 정답 관리 ===
  getPassList: async (params: {
    gosiCd: string;
    subjectCd?: string;
    examType?: string;
    page?: number;
    size?: number;
  }): Promise<ApiResponse<PageResponse<GosiPassMstResponse>>> => {
    const response = await client.get('/api/gosi/pass', { params });
    return response.data;
  },

  getPassStaList: async (gosiCd: string): Promise<ApiResponse<GosiPassStaResponse[]>> => {
    const response = await client.get('/api/gosi/pass/standards', { params: { gosiCd } });
    return response.data;
  },

  // === 성적 관리 ===
  getResultList: async (params: {
    gosiCd: string;
    gosiType?: string;
    gosiArea?: string;
    keyword?: string;
    page?: number;
    size?: number;
  }): Promise<ApiResponse<PageResponse<GosiRstMstResponse>>> => {
    const response = await client.get('/api/gosi/results', { params });
    return response.data;
  },

  getResultDetail: async (gosiCd: string, rstNo: string): Promise<ApiResponse<GosiRstDetailResponse>> => {
    const response = await client.get(`/api/gosi/results/${gosiCd}/${rstNo}`);
    return response.data;
  },

  // === 통계 ===
  getStatList: async (params: {
    gosiCd: string;
    gosiType?: string;
    page?: number;
    size?: number;
  }): Promise<ApiResponse<PageResponse<GosiStatMstResponse>>> => {
    const response = await client.get('/api/gosi/statistics', { params });
    return response.data;
  },

  getDashboard: async (gosiCd: string): Promise<ApiResponse<GosiStatMstResponse[]>> => {
    const response = await client.get('/api/gosi/statistics/dashboard', { params: { gosiCd } });
    return response.data;
  },

  getSbjMstList: async (gosiCd: string): Promise<ApiResponse<GosiSbjMstResponse[]>> => {
    const response = await client.get('/api/gosi/statistics/subjects', { params: { gosiCd } });
    return response.data;
  },

  // === 과목/VOD ===
  getSubjectList: async (gosiType?: string): Promise<ApiResponse<GosiSubjectResponse[]>> => {
    const response = await client.get('/api/gosi/subjects', { params: { gosiType } });
    return response.data;
  },

  getVodList: async (params: {
    gosiCd?: string;
    keyword?: string;
    page?: number;
    size?: number;
  }): Promise<ApiResponse<PageResponse<GosiVodResponse>>> => {
    const response = await client.get('/api/gosi/subjects/vods', { params });
    return response.data;
  },

  // === 회원 관리 ===
  getMemberList: async (params: {
    keyword?: string;
    page?: number;
    size?: number;
  }): Promise<ApiResponse<PageResponse<GosiMemberResponse>>> => {
    const response = await client.get('/api/gosi/members', { params });
    return response.data;
  },

  getMemberDetail: async (userId: string): Promise<ApiResponse<GosiMemberResponse>> => {
    const response = await client.get(`/api/gosi/members/${userId}`);
    return response.data;
  },
};
