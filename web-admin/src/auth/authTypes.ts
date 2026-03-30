import { createContext } from 'react';

export interface AdminUser {
  email: string;
  name: string;
  picture?: string;
}

export type AuthMethod = 'google' | 'apikey';

export interface AuthContextType {
  token: string | null;
  user: AdminUser | null;
  authMethod: AuthMethod | null;
  isAuthenticated: boolean;
  loginWithGoogle: (token: string, user: AdminUser) => void;
  loginWithApiKey: (apiKey: string) => void;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | null>(null);
