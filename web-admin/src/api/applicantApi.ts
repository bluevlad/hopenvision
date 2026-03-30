import { adminClient as client } from './adminClient';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type { ApplicantResponse, ApplicantRequest, CsvResultImportResult } from '../types/applicant';

export const applicantApi = {
  getApplicantList: async (examCd: string, params: {
    keyword?: string;
    page?: number;
    size?: number;
  }): Promise<ApiResponse<PageResponse<ApplicantResponse>>> => {
    const response = await client.get(`/api/exams/${examCd}/applicants`, { params });
    return response.data;
  },

  getApplicant: async (examCd: string, applicantNo: string): Promise<ApiResponse<ApplicantResponse>> => {
    const response = await client.get(`/api/exams/${examCd}/applicants/${applicantNo}`);
    return response.data;
  },

  createApplicant: async (examCd: string, data: ApplicantRequest): Promise<ApiResponse<ApplicantResponse>> => {
    const response = await client.post(`/api/exams/${examCd}/applicants`, data);
    return response.data;
  },

  updateApplicant: async (examCd: string, applicantNo: string, data: ApplicantRequest): Promise<ApiResponse<ApplicantResponse>> => {
    const response = await client.put(`/api/exams/${examCd}/applicants/${applicantNo}`, data);
    return response.data;
  },

  deleteApplicant: async (examCd: string, applicantNo: string): Promise<ApiResponse<void>> => {
    const response = await client.delete(`/api/exams/${examCd}/applicants/${applicantNo}`);
    return response.data;
  },

  // CSV 응시결과 등록 미리보기
  csvResultPreview: async (examCd: string, file: File): Promise<ApiResponse<CsvResultImportResult>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await client.post(`/api/exams/${examCd}/applicants/csv-result/preview`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 120000,
    });
    return response.data;
  },

  // CSV 응시결과 등록 적용
  csvResultApply: async (examCd: string, file: File): Promise<ApiResponse<CsvResultImportResult>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await client.post(`/api/exams/${examCd}/applicants/csv-result/apply`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 120000,
    });
    return response.data;
  },

  // 임시점수결과 미리보기
  tempScorePreview: async (examCd: string, file: File): Promise<ApiResponse<CsvResultImportResult>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await client.post(`/api/exams/${examCd}/applicants/temp-score/preview`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 120000,
    });
    return response.data;
  },

  // 임시점수결과 적용
  tempScoreApply: async (examCd: string, file: File): Promise<ApiResponse<CsvResultImportResult>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await client.post(`/api/exams/${examCd}/applicants/temp-score/apply`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      timeout: 120000,
    });
    return response.data;
  },
};
