import { createApiClient } from '@hopenvision/shared';

const STORAGE_KEY = 'admin_api_key';

export const adminClient = createApiClient({
  getApiKey: () => sessionStorage.getItem(STORAGE_KEY),
  onUnauthorized: () => {
    sessionStorage.removeItem(STORAGE_KEY);
    window.location.href = '/login';
  },
});
