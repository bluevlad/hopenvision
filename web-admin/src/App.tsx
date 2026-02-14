import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ConfigProvider } from 'antd';
import koKR from 'antd/locale/ko_KR';
import { AuthProvider } from './auth/AuthContext';
import AuthGuard from './auth/AuthGuard';
import AdminLayout from './components/AdminLayout';
import ApiKeyLogin from './pages/ApiKeyLogin';
import ExamList from './pages/ExamList';
import ExamForm from './pages/ExamForm';
import AnswerKeyForm from './pages/AnswerKeyForm';
import ExcelImport from './pages/ExcelImport';
import JsonImport from './pages/JsonImport';
import ApplicantList from './pages/ApplicantList';
import Statistics from './pages/Statistics';
import './App.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ConfigProvider locale={koKR}>
        <AuthProvider>
          <BrowserRouter>
            <Routes>
              <Route path="/login" element={<ApiKeyLogin />} />
              <Route path="/" element={
                <AuthGuard>
                  <AdminLayout />
                </AuthGuard>
              }>
                <Route index element={<Navigate to="/exams" replace />} />
                <Route path="exams" element={<ExamList />} />
                <Route path="exams/new" element={<ExamForm />} />
                <Route path="exams/:examCd" element={<ExamForm />} />
                <Route path="exams/:examCd/answers" element={<AnswerKeyForm />} />
                <Route path="exams/:examCd/import" element={<ExcelImport />} />
                <Route path="exams/:examCd/json-import" element={<JsonImport />} />
                <Route path="applicants" element={<ApplicantList />} />
                <Route path="statistics" element={<Statistics />} />
                <Route path="import/preview" element={<ExcelImport />} />
                <Route path="*" element={<Navigate to="/exams" replace />} />
              </Route>
            </Routes>
          </BrowserRouter>
        </AuthProvider>
      </ConfigProvider>
    </QueryClientProvider>
  );
}

export default App;
