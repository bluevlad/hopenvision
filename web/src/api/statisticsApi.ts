import client from './client';
import type { ApiResponse } from '../types/exam';
import type { ExamStatistics } from '../types/statistics';

export const statisticsApi = {
  getExamStatistics: async (examCd: string): Promise<ApiResponse<ExamStatistics>> => {
    const response = await client.get(`/api/statistics/exams/${examCd}`);
    return response.data;
  },
};
