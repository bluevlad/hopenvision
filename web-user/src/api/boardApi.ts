import { apiClient } from '@hopenvision/shared';
import type { ApiResponse, PageResponse } from '@hopenvision/shared';
import type { BoardDetail, BoardListItem } from '../types/board';

export interface BoardListParams {
  q?: string;
  page?: number;
  size?: number;
}

export async function listBoards(params: BoardListParams): Promise<PageResponse<BoardListItem>> {
  const res = await apiClient.get<ApiResponse<PageResponse<BoardListItem>>>('/api/board', { params });
  return res.data.data;
}

export async function getBoard(id: number): Promise<BoardDetail> {
  const res = await apiClient.get<ApiResponse<BoardDetail>>(`/api/board/${id}`);
  return res.data.data;
}
