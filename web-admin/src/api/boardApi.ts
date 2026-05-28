import { adminClient as client } from './adminClient';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type { BoardDetail, BoardListItem } from '../types/board';

const BASE_PATH = '/api/board';

export interface BoardListParams {
  q?: string;
  page?: number;
  size?: number;
}

export const boardApi = {
  list: async (params: BoardListParams): Promise<PageResponse<BoardListItem>> => {
    const res = await client.get<ApiResponse<PageResponse<BoardListItem>>>(BASE_PATH, { params });
    return res.data.data;
  },

  get: async (id: number): Promise<BoardDetail> => {
    const res = await client.get<ApiResponse<BoardDetail>>(`${BASE_PATH}/${id}`);
    return res.data.data;
  },
};
