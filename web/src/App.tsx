import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ConfigProvider } from 'antd';
import koKR from 'antd/locale/ko_KR';
import Layout from './components/Layout';
import ExamList from './pages/exam/ExamList';
import ExamForm from './pages/exam/ExamForm';
import AnswerKeyForm from './pages/exam/AnswerKeyForm';
import ExcelImport from './pages/exam/ExcelImport';
import JsonImport from './pages/exam/JsonImport';
import UserExamList from './pages/user/UserExamList';
import UserAnswerForm from './pages/user/UserAnswerForm';
import UserScoreResult from './pages/user/UserScoreResult';
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
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<Layout />}>
              <Route index element={<Navigate to="/user" replace />} />
              {/* 관리자 시스템 */}
              <Route path="exam" element={<ExamList />} />
              <Route path="exam/new" element={<ExamForm />} />
              <Route path="exam/:examCd" element={<ExamForm />} />
              <Route path="exam/:examCd/answers" element={<AnswerKeyForm />} />
              <Route path="exam/:examCd/import" element={<ExcelImport />} />
              <Route path="exam/:examCd/json-import" element={<JsonImport />} />
              <Route path="import/preview" element={<ExcelImport />} />
              {/* 사용자 시스템 */}
              <Route path="user" element={<UserExamList />} />
              <Route path="user/exams/:examCd/answer" element={<UserAnswerForm />} />
              <Route path="user/exams/:examCd/result" element={<UserScoreResult />} />
            </Route>
          </Routes>
        </BrowserRouter>
      </ConfigProvider>
    </QueryClientProvider>
  );
}

export default App;
