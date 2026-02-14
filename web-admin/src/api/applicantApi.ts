import { adminClient as client } from './adminClient';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type { ApplicantResponse, ApplicantRequest } from '../types/applicant';

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
};
