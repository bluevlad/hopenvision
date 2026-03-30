import { useState, useCallback, useMemo, type ReactNode } from 'react';
import { AuthContext } from './authTypes';
import type { AdminUser, AuthMethod } from './authTypes';

const TOKEN_KEY = 'admin_token';
const USER_KEY = 'admin_user';
const METHOD_KEY = 'admin_auth_method';

export function AuthProvider({ children }: { children: ReactNode }) {
  const [token, setToken] = useState<string | null>(() =>
    sessionStorage.getItem(TOKEN_KEY),
  );
  const [user, setUser] = useState<AdminUser | null>(() => {
    const stored = sessionStorage.getItem(USER_KEY);
    return stored ? JSON.parse(stored) : null;
  });
  const [authMethod, setAuthMethod] = useState<AuthMethod | null>(() =>
    sessionStorage.getItem(METHOD_KEY) as AuthMethod | null,
  );

  const loginWithGoogle = useCallback((jwt: string, userInfo: AdminUser) => {
    sessionStorage.setItem(TOKEN_KEY, jwt);
    sessionStorage.setItem(USER_KEY, JSON.stringify(userInfo));
    sessionStorage.setItem(METHOD_KEY, 'google');
    setToken(jwt);
    setUser(userInfo);
    setAuthMethod('google');
  }, []);

  const loginWithApiKey = useCallback((apiKey: string) => {
    sessionStorage.setItem(TOKEN_KEY, apiKey);
    sessionStorage.removeItem(USER_KEY);
    sessionStorage.setItem(METHOD_KEY, 'apikey');
    setToken(apiKey);
    setUser(null);
    setAuthMethod('apikey');
  }, []);

  const logout = useCallback(() => {
    sessionStorage.removeItem(TOKEN_KEY);
    sessionStorage.removeItem(USER_KEY);
    sessionStorage.removeItem(METHOD_KEY);
    setToken(null);
    setUser(null);
    setAuthMethod(null);
  }, []);

  const value = useMemo(
    () => ({
      token,
      user,
      authMethod,
      isAuthenticated: !!token,
      loginWithGoogle,
      loginWithApiKey,
      logout,
    }),
    [token, user, authMethod, loginWithGoogle, loginWithApiKey, logout],
  );

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}
