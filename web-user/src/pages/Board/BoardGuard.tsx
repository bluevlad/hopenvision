import { Navigate } from 'react-router-dom';
import type { ReactNode } from 'react';

function isAdmin(): boolean {
  return typeof window !== 'undefined' && !!window.sessionStorage.getItem('admin_token');
}

export default function BoardGuard({ children }: { children: ReactNode }) {
  if (!isAdmin()) {
    return <Navigate to="/" replace />;
  }
  return <>{children}</>;
}
