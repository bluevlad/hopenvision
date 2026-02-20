import axios from 'axios';
import type { AxiosInstance, AxiosError } from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || '';

export interface ApiErrorDetail {
  status: number | null;
  message: string;
  code: string;
}

function extractErrorDetail(error: AxiosError): ApiErrorDetail {
  if (error.code === 'ECONNABORTED') {
    return { status: null, message: '서버 응답 시간이 초과되었습니다.', code: 'TIMEOUT' };
  }
  if (!error.response) {
    return { status: null, message: '네트워크 연결을 확인해주세요.', code: 'NETWORK_ERROR' };
  }
  const status = error.response.status;
  const serverMessage = (error.response.data as Record<string, unknown>)?.message;
  if (status >= 500) {
    return { status, message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.', code: 'SERVER_ERROR' };
  }
  if (status === 404) {
    return { status, message: '요청한 데이터를 찾을 수 없습니다.', code: 'NOT_FOUND' };
  }
  if (status === 400) {
    return { status, message: (serverMessage as string) || '잘못된 요청입니다.', code: 'BAD_REQUEST' };
  }
  return { status, message: (serverMessage as string) || error.message, code: 'UNKNOWN' };
}

export function createApiClient(options?: {
  getApiKey?: () => string | null;
  onUnauthorized?: () => void;
}): AxiosInstance {
  const client = axios.create({
    baseURL: API_BASE_URL,
    timeout: 30000,
    headers: {
      'Content-Type': 'application/json',
    },
  });

  client.interceptors.request.use(
    (config) => {
      if (options?.getApiKey) {
        const apiKey = options.getApiKey();
        if (apiKey) {
          config.headers['X-Api-Key'] = apiKey;
        }
      }
      return config;
    },
    (error) => Promise.reject(error),
  );

  client.interceptors.response.use(
    (response) => response,
    (error: AxiosError) => {
      if (error.response?.status === 401 || error.response?.status === 403) {
        options?.onUnauthorized?.();
      }
      const detail = extractErrorDetail(error);
      const enriched = Object.assign(error, { apiError: detail });
      return Promise.reject(enriched);
    },
  );

  return client;
}

// 기본 API 클라이언트 (인증 불필요 - 사용자 앱용)
export const apiClient = createApiClient();

export default apiClient;
