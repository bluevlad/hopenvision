import { createContext } from 'react';

export interface AuthContextType {
  apiKey: string | null;
  isAuthenticated: boolean;
  login: (key: string) => void;
  logout: () => void;
}

export const AuthContext = createContext<AuthContextType | null>(null);
