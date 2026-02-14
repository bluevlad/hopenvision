import { useState, useCallback, type ReactNode } from 'react';
import { AuthContext } from './authTypes';

const STORAGE_KEY = 'admin_api_key';

export function AuthProvider({ children }: { children: ReactNode }) {
  const [apiKey, setApiKey] = useState<string | null>(() => {
    return sessionStorage.getItem(STORAGE_KEY);
  });

  const login = useCallback((key: string) => {
    sessionStorage.setItem(STORAGE_KEY, key);
    setApiKey(key);
  }, []);

  const logout = useCallback(() => {
    sessionStorage.removeItem(STORAGE_KEY);
    setApiKey(null);
  }, []);

  return (
    <AuthContext.Provider value={{
      apiKey,
      isAuthenticated: !!apiKey,
      login,
      logout,
    }}>
      {children}
    </AuthContext.Provider>
  );
}
