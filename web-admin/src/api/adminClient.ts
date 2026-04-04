import { createApiClient } from '@hopenvision/shared';

const TOKEN_KEY = 'admin_token';
const METHOD_KEY = 'admin_auth_method';

export const adminClient = createApiClient({
  getToken: () => {
    const method = sessionStorage.getItem(METHOD_KEY);
    if (method === 'google') {
      return sessionStorage.getItem(TOKEN_KEY);
    }
    return null;
  },
  getApiKey: () => {
    const method = sessionStorage.getItem(METHOD_KEY);
    if (method === 'apikey') {
      return sessionStorage.getItem(TOKEN_KEY);
    }
    return null;
  },
  onUnauthorized: () => {
    sessionStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem('admin_user');
    sessionStorage.removeItem(METHOD_KEY);
    window.location.href = ((window as any).__BASE_PATH__ || '') + '/login';
  },
});
