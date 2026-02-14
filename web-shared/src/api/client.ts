import axios from 'axios';
import type { AxiosInstance } from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || '';

export function createApiClient(options?: {
  getApiKey?: () => string | null;
  onUnauthorized?: () => void;
}): AxiosInstance {
  const client = axios.create({
    baseURL: API_BASE_URL,
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
    (error) => {
      if (error.response?.status === 401 || error.response?.status === 403) {
        options?.onUnauthorized?.();
      }
      return Promise.reject(error);
    },
  );

  return client;
}

// 기본 API 클라이언트 (인증 불필요 - 사용자 앱용)
export const apiClient = createApiClient();

export default apiClient;
