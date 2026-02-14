import { adminClient as client } from './adminClient';
import type { ApiResponse } from '@hopenvision/shared';
import type { ExamStatistics } from '../types/statistics';

export const statisticsApi = {
  getExamStatistics: async (examCd: string): Promise<ApiResponse<ExamStatistics>> => {
    const response = await client.get(`/api/statistics/exams/${examCd}`);
    return response.data;
  },
};
