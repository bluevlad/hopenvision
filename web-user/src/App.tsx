import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ConfigProvider } from 'antd';
import koKR from 'antd/locale/ko_KR';
import UserLayout from './components/UserLayout';
import UserExamList from './pages/UserExamList';
import UserAnswerForm from './pages/UserAnswerForm';
import UserScoreResult from './pages/UserScoreResult';
import UserHistory from './pages/UserHistory';
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
            <Route path="/" element={<UserLayout />}>
              <Route index element={<UserExamList />} />
              <Route path="history" element={<UserHistory />} />
              <Route path="exams/:examCd/answer" element={<UserAnswerForm />} />
              <Route path="exams/:examCd/result" element={<UserScoreResult />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Route>
          </Routes>
        </BrowserRouter>
      </ConfigProvider>
    </QueryClientProvider>
  );
}

export default App;
