import { adminClient as client } from './adminClient';
import type { ApiResponse } from '@hopenvision/shared';
import type { ExamStatistics, QuestionStatistics, AreaStatistics, ExamDashboardItem, DiscriminationDetail } from '../types/statistics';

export const statisticsApi = {
  getExamStatistics: async (examCd: string): Promise<ApiResponse<ExamStatistics>> => {
    const response = await client.get(`/api/statistics/exams/${examCd}`);
    return response.data;
  },

  getQuestionStatistics: async (examCd: string): Promise<ApiResponse<QuestionStatistics[]>> => {
    const response = await client.get(`/api/statistics/exams/${examCd}/questions`);
    return response.data;
  },

  getAreaStatistics: async (examCd: string): Promise<ApiResponse<AreaStatistics[]>> => {
    const response = await client.get(`/api/statistics/exams/${examCd}/area`);
    return response.data;
  },

  getDashboard: async (): Promise<ApiResponse<ExamDashboardItem[]>> => {
    const response = await client.get('/api/statistics/dashboard');
    return response.data;
  },

  getDiscriminationIndex: async (examCd: string, subjectCd: string): Promise<ApiResponse<DiscriminationDetail[]>> => {
    const response = await client.get(`/api/statistics/exams/${examCd}/subjects/${subjectCd}/discrimination`);
    return response.data;
  },

  exportScores: async (examCd: string): Promise<void> => {
    const response = await client.get(`/api/statistics/exams/${examCd}/export`, {
      responseType: 'blob',
    });
    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `성적_${examCd}.xlsx`);
    document.body.appendChild(link);
    link.click();
    link.remove();
    window.URL.revokeObjectURL(url);
  },
};
