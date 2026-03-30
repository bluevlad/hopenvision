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
import ApplicantCsvImport from './pages/ApplicantCsvImport';
import ApplicantTempScore from './pages/ApplicantTempScore';
import Statistics from './pages/Statistics';
import SubjectList from './pages/SubjectList';
import QuestionBankList from './pages/QuestionBankList';
import QuestionBankDetail from './pages/QuestionBankDetail';
import QuestionSetList from './pages/QuestionSetList';
import QuestionSetDetail from './pages/QuestionSetDetail';
import GosiAnalytics from './pages/gosi/GosiAnalytics';
import SubjectMasterList from './pages/SubjectMasterList';
import QuestionBankGroupList from './pages/QuestionBankGroupList';
import QuestionBankItemList from './pages/QuestionBankItemList';
import QuestionBankBulkImport from './pages/QuestionBankBulkImport';
import QuestionBankCsvUpdate from './pages/QuestionBankCsvUpdate';
import QuestionBankExcelUpdate from './pages/QuestionBankExcelUpdate';
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
                <Route path="applicants/csv-import" element={<ApplicantCsvImport />} />
                <Route path="applicants/temp-score" element={<ApplicantTempScore />} />
                <Route path="statistics" element={<Statistics />} />
                <Route path="subjects" element={<SubjectList />} />
                <Route path="question-bank" element={<QuestionBankList />} />
                <Route path="question-bank/:groupId" element={<QuestionBankDetail />} />
                <Route path="question-sets" element={<QuestionSetList />} />
                <Route path="question-sets/:setId" element={<QuestionSetDetail />} />
                <Route path="import/preview" element={<ExcelImport />} />
                <Route path="subjects" element={<SubjectMasterList />} />
                <Route path="question-bank/groups" element={<QuestionBankGroupList />} />
                <Route path="question-bank/items" element={<QuestionBankItemList />} />
                <Route path="question-bank/bulk-import" element={<QuestionBankBulkImport />} />
                <Route path="question-bank/csv-update" element={<QuestionBankCsvUpdate />} />
                <Route path="question-bank/excel-update" element={<QuestionBankExcelUpdate />} />
                <Route path="gosi/analytics" element={<GosiAnalytics />} />
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
