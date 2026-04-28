import React, { useState, useMemo, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation } from '@tanstack/react-query';
import {
  Card,
  Button,
  Space,
  Tag,
  Typography,
  Spin,
  Alert,
  Tabs,
  Modal,
  Progress,
  Descriptions,
  Segmented,
  message,
} from 'antd';
import {
  ArrowLeftOutlined,
  SendOutlined,
  ExclamationCircleOutlined,
  TableOutlined,
  EditOutlined,
} from '@ant-design/icons';
import { getExamDetail, submitAnswers } from '../api/userApi';
import type { SubmitRequest, SubjectAnswer, SubjectInfo } from '../types/user';
import OMRCard from '../components/OMRCard';
import QuickInputCard from '../components/QuickInputCard';
import SubjectSelectModal from '../components/SubjectSelectModal';

const { Title, Text } = Typography;

type AnswersState = Record<string, Record<number, string>>;
type InputMode = 'omr' | 'quick';

const UserAnswerForm: React.FC = () => {
  const { examCd } = useParams<{ examCd: string }>();
  const navigate = useNavigate();

  const [answers, setAnswers] = useState<AnswersState>({});
  const [activeTab, setActiveTab] = useState<string>('');
  const [inputMode, setInputMode] = useState<InputMode>('omr');
  const [selectedSubjectCds, setSelectedSubjectCds] = useState<string[] | null>(null);

  const { data: exam, isLoading, error } = useQuery({
    queryKey: ['userExam', examCd],
    queryFn: () => getExamDetail(examCd!),
    enabled: !!examCd,
  });

  // 선택 과목이 있는지 확인
  const hasElective = exam?.subjects.some((s) => s.subjectType === 'S') ?? false;
  // 모달 표시 조건: 선택 과목이 있고 아직 과목 선택을 하지 않은 경우
  const showSelectModal = !!exam && !exam.hasSubmitted && hasElective && selectedSubjectCds === null;
  // 과목 선택이 완료되었는지 (선택 과목이 없으면 바로 완료)
  const subjectSelectionDone = !hasElective || selectedSubjectCds !== null;

  // 선택된 과목만 필터링
  const activeSubjects = useMemo(() => {
    if (!exam) return [];
    if (!hasElective) return exam.subjects;
    if (!selectedSubjectCds) return [];
    return exam.subjects.filter((s) => selectedSubjectCds.includes(s.subjectCd));
  }, [exam, hasElective, selectedSubjectCds]);

  const handleSubjectConfirm = useCallback((subjectCds: string[]) => {
    setSelectedSubjectCds(subjectCds);
    // 첫 번째 과목을 활성 탭으로 설정
    if (subjectCds.length > 0) {
      setActiveTab(subjectCds[0]);
    }
  }, []);

  const handleSubjectCancel = useCallback(() => {
    navigate('/exams');
  }, [navigate]);

  const effectiveActiveTab = activeTab || (activeSubjects[0]?.subjectCd ?? '');

  const submitMutation = useMutation({
    mutationFn: (request: SubmitRequest) => submitAnswers(examCd!, request),
    onSuccess: () => {
      message.success('채점이 완료되었습니다!');
      navigate(`/exams/${examCd}/result`);
    },
    onError: (error: Error) => {
      message.error(`채점 실패: ${error.message}`);
    },
  });

  const handleAnswerChange = (subjectCd: string, questionNo: number, answer: string) => {
    setAnswers((prev) => ({
      ...prev,
      [subjectCd]: {
        ...(prev[subjectCd] || {}),
        [questionNo]: answer,
      },
    }));
  };

  const progressInfo = useMemo(() => {
    if (!exam || activeSubjects.length === 0) return { total: 0, answered: 0, percentage: 0 };

    let total = 0;
    let answered = 0;

    activeSubjects.forEach((subject: SubjectInfo) => {
      total += subject.questionCnt;
      const subjectAnswers = answers[subject.subjectCd] || {};
      answered += Object.values(subjectAnswers).filter((v) => v).length;
    });

    return {
      total,
      answered,
      percentage: total > 0 ? Math.round((answered / total) * 100) : 0,
    };
  }, [exam, activeSubjects, answers]);

  const handleSubmit = () => {
    if (!exam) return;

    const unansweredSubjects = activeSubjects.filter((subject: SubjectInfo) => {
      const subjectAnswers = answers[subject.subjectCd] || {};
      const answeredCount = Object.values(subjectAnswers).filter((v) => v).length;
      return answeredCount < subject.questionCnt;
    });

    if (unansweredSubjects.length > 0) {
      Modal.confirm({
        title: '답안이 완전하지 않습니다',
        icon: <ExclamationCircleOutlined />,
        content: (
          <div>
            <p>다음 과목의 답안이 완전하지 않습니다:</p>
            <ul>
              {unansweredSubjects.map((s: SubjectInfo) => {
                const subjectAnswers = answers[s.subjectCd] || {};
                const answeredCount = Object.values(subjectAnswers).filter((v) => v).length;
                return (
                  <li key={s.subjectCd}>
                    {s.subjectNm}: {answeredCount}/{s.questionCnt}
                  </li>
                );
              })}
            </ul>
            <p>그래도 제출하시겠습니까?</p>
          </div>
        ),
        okText: '제출',
        cancelText: '취소',
        onOk: () => doSubmit(),
      });
    } else {
      Modal.confirm({
        title: '답안을 제출하시겠습니까?',
        icon: <ExclamationCircleOutlined />,
        content: '제출 후에는 수정이 불가능합니다.',
        okText: '제출',
        cancelText: '취소',
        onOk: () => doSubmit(),
      });
    }
  };

  const doSubmit = () => {
    if (!exam) return;

    const subjects: SubjectAnswer[] = activeSubjects.map((subject: SubjectInfo) => {
      const subjectAnswers = answers[subject.subjectCd] || {};
      return {
        subjectCd: subject.subjectCd,
        answers: Array.from({ length: subject.questionCnt }, (_, i) => ({
          questionNo: i + 1,
          answer: subjectAnswers[i + 1] || '',
        })),
      };
    });

    const request: SubmitRequest = {
      examCd: examCd!,
      subjects,
    };

    submitMutation.mutate(request);
  };

  if (isLoading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}>
        <Spin size="large" />
      </div>
    );
  }

  if (error || !exam) {
    return (
      <div style={{ padding: 24 }}>
        <Alert
          message="시험 정보를 불러올 수 없습니다"
          description={(error as Error)?.message}
          type="error"
          showIcon
        />
        <Button
          style={{ marginTop: 16 }}
          icon={<ArrowLeftOutlined />}
          onClick={() => navigate('/exams')}
        >
          목록으로
        </Button>
      </div>
    );
  }

  if (exam.hasSubmitted) {
    return (
      <div style={{ padding: 24 }}>
        <Alert
          message="이미 채점이 완료된 시험입니다"
          description="결과 페이지에서 채점 결과를 확인하세요."
          type="info"
          showIcon
        />
        <Space style={{ marginTop: 16 }}>
          <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/exams')}>
            목록으로
          </Button>
          <Button type="primary" onClick={() => navigate(`/exams/${examCd}/result`)}>
            결과 보기
          </Button>
        </Space>
      </div>
    );
  }

  // 과목 선택 모달 (선택 과목이 있을 때만)
  if (!subjectSelectionDone) {
    return (
      <SubjectSelectModal
        open={showSelectModal}
        examNm={exam.examNm}
        subjects={exam.subjects}
        onConfirm={handleSubjectConfirm}
        onCancel={handleSubjectCancel}
      />
    );
  }

  const InputComponent = inputMode === 'omr' ? OMRCard : QuickInputCard;

  const tabItems = activeSubjects.map((subject: SubjectInfo) => {
    const subjectAnswers = answers[subject.subjectCd] || {};
    const answeredCount = Object.values(subjectAnswers).filter((v) => v).length;

    return {
      key: subject.subjectCd,
      label: (
        <span>
          {subject.subjectType === 'M' ? (
            <Tag color="blue" style={{ marginRight: 4, fontSize: 11 }}>필수</Tag>
          ) : (
            <Tag color="orange" style={{ marginRight: 4, fontSize: 11 }}>선택</Tag>
          )}
          {subject.subjectNm}
          <Text
            type={answeredCount === subject.questionCnt ? 'success' : 'secondary'}
            style={{ marginLeft: 8, fontSize: 12 }}
          >
            ({answeredCount}/{subject.questionCnt})
          </Text>
        </span>
      ),
      children: (
        <InputComponent
          subjectNm={subject.subjectNm}
          subjectCd={subject.subjectCd}
          questionCnt={subject.questionCnt}
          answers={subjectAnswers}
          onAnswerChange={handleAnswerChange}
        />
      ),
    };
  });

  return (
    <div style={{ padding: 24 }}>
      <Card>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 24 }}>
          <div>
            <Button
              icon={<ArrowLeftOutlined />}
              onClick={() => navigate('/exams')}
              style={{ marginBottom: 16 }}
            >
              목록으로
            </Button>
            <Title level={4} style={{ margin: 0 }}>{exam.examNm}</Title>
            <Text type="secondary">
              {exam.examYear}년 {exam.examRound}회 | {exam.examDate}
            </Text>
          </div>

          <Card size="small" style={{ width: 300 }}>
            <Descriptions column={1} size="small">
              <Descriptions.Item label="총 문항수">{progressInfo.total}문제</Descriptions.Item>
              <Descriptions.Item label="입력 완료">{progressInfo.answered}문제</Descriptions.Item>
              <Descriptions.Item label="진행률">
                <Progress
                  percent={progressInfo.percentage}
                  size="small"
                  status={progressInfo.percentage === 100 ? 'success' : 'active'}
                />
              </Descriptions.Item>
            </Descriptions>
          </Card>
        </div>

        {/* 입력 방식 선택 */}
        <div style={{ marginBottom: 20, padding: '16px', backgroundColor: '#f5f5f5', borderRadius: 8 }}>
          <Space size="middle" align="center">
            <Text strong>입력 방식:</Text>
            <Segmented
              value={inputMode}
              onChange={(value) => setInputMode(value as InputMode)}
              options={[
                {
                  label: (
                    <Space>
                      <TableOutlined />
                      <span>OMR 카드</span>
                    </Space>
                  ),
                  value: 'omr',
                },
                {
                  label: (
                    <Space>
                      <EditOutlined />
                      <span>빠른 입력</span>
                    </Space>
                  ),
                  value: 'quick',
                },
              ]}
              size="large"
            />
            <Text type="secondary" style={{ fontSize: 12 }}>
              {inputMode === 'omr'
                ? '버튼을 클릭하여 답안 선택'
                : '숫자(1~5)를 직접 입력 (5문항씩 표시)'}
            </Text>
          </Space>
        </div>

        <Tabs
          activeKey={effectiveActiveTab}
          onChange={setActiveTab}
          items={tabItems}
          type="card"
        />

        <div style={{ marginTop: 24, textAlign: 'center' }}>
          <Button
            type="primary"
            size="large"
            icon={<SendOutlined />}
            onClick={handleSubmit}
            loading={submitMutation.isPending}
          >
            답안 제출 및 채점
          </Button>
        </div>
      </Card>
    </div>
  );
};

export default UserAnswerForm;
