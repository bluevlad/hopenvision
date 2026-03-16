import React, { useState, useEffect, useMemo, useCallback, useRef } from 'react';
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
  Modal,
  Radio,
  Progress,
  message,
  Tooltip,
  Badge,
} from 'antd';
import {
  ArrowLeftOutlined,
  ArrowRightOutlined,
  SendOutlined,
  ClockCircleOutlined,
  ExclamationCircleOutlined,
  FileTextOutlined,
  PictureOutlined,
} from '@ant-design/icons';
import { getExamDetail, getSubjectQuestions, submitAnswers } from '../api/userApi';
import type {
  SubmitRequest,
  SubjectAnswer,
} from '../types/user';
import SubjectSelectModal from '../components/SubjectSelectModal';

const { Title, Text } = Typography;

type AnswersState = Record<string, Record<number, string>>;
type DisplayMode = 'text' | 'image';

// 과목 진행 상태
type SubjectPhase = 'waiting' | 'active' | 'completed';

interface SubjectTimerState {
  remaining: number; // 초 단위
  phase: SubjectPhase;
}

const MockExamPage: React.FC = () => {
  const { examCd } = useParams<{ examCd: string }>();
  const navigate = useNavigate();

  // 상태
  const [selectedSubjectCds, setSelectedSubjectCds] = useState<string[] | null>(null);
  const [currentSubjectIdx, setCurrentSubjectIdx] = useState(0);
  const [currentQuestionNo, setCurrentQuestionNo] = useState(1);
  const [answers, setAnswers] = useState<AnswersState>({});
  const [timers, setTimers] = useState<Record<string, SubjectTimerState>>({});
  const [allCompleted, setAllCompleted] = useState(false);
  const [reviewMode, setReviewMode] = useState(false);
  const [displayMode, setDisplayMode] = useState<DisplayMode>('text');
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // 시험 정보 조회
  const { data: exam, isLoading: examLoading } = useQuery({
    queryKey: ['userExam', examCd],
    queryFn: () => getExamDetail(examCd!),
    enabled: !!examCd,
  });

  const hasElective = exam?.subjects.some((s) => s.subjectType === 'S') ?? false;
  const showSelectModal = !!exam && !exam.hasSubmitted && hasElective && selectedSubjectCds === null;

  // 선택된 과목 필터링
  const activeSubjects = useMemo(() => {
    if (!exam) return [];
    if (!hasElective) return exam.subjects;
    if (!selectedSubjectCds) return [];
    return exam.subjects.filter((s) => selectedSubjectCds.includes(s.subjectCd));
  }, [exam, hasElective, selectedSubjectCds]);

  const currentSubject = activeSubjects[currentSubjectIdx];

  // 현재 과목 문제 조회
  const { data: questionData, isLoading: questionsLoading } = useQuery({
    queryKey: ['examQuestions', examCd, currentSubject?.subjectCd],
    queryFn: () => getSubjectQuestions(examCd!, currentSubject!.subjectCd),
    enabled: !!examCd && !!currentSubject,
  });

  // 타이머 초기화
  useEffect(() => {
    if (activeSubjects.length > 0 && Object.keys(timers).length === 0) {
      const initial: Record<string, SubjectTimerState> = {};
      activeSubjects.forEach((s, idx) => {
        initial[s.subjectCd] = {
          remaining: (s.timeLimit || 22) * 60,
          phase: idx === 0 ? 'active' : 'waiting',
        };
      });
      setTimers(initial);
    }
  }, [activeSubjects, timers]);

  // 타이머 틱
  useEffect(() => {
    if (!currentSubject || allCompleted) return;

    const subjectCd = currentSubject.subjectCd;
    const timerState = timers[subjectCd];
    if (!timerState || timerState.phase !== 'active') return;

    timerRef.current = setInterval(() => {
      setTimers((prev) => {
        const current = prev[subjectCd];
        if (!current || current.remaining <= 0) {
          return prev;
        }
        const newRemaining = current.remaining - 1;
        if (newRemaining <= 0) {
          // 시간 초과: 자동으로 다음 과목 이동
          return {
            ...prev,
            [subjectCd]: { ...current, remaining: 0, phase: 'completed' },
          };
        }
        return {
          ...prev,
          [subjectCd]: { ...current, remaining: newRemaining },
        };
      });
    }, 1000);

    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [currentSubject, timers, allCompleted]);

  // 시간 초과 시 자동 다음 과목 이동
  useEffect(() => {
    if (!currentSubject || allCompleted) return;
    const timerState = timers[currentSubject.subjectCd];
    if (timerState?.phase === 'completed' && timerState.remaining <= 0) {
      handleCompleteSubject();
    }
  }, [timers, currentSubject, allCompleted]);

  const handleSubjectConfirm = useCallback((subjectCds: string[]) => {
    setSelectedSubjectCds(subjectCds);
  }, []);

  const handleSubjectCancel = useCallback(() => {
    navigate('/');
  }, [navigate]);

  const handleAnswerSelect = (questionNo: number, answer: string) => {
    if (!currentSubject) return;
    const subjectCd = currentSubject.subjectCd;
    const timerState = timers[subjectCd];

    // 복습 모드가 아니고 과목이 완료+시간초과면 변경 불가
    if (!reviewMode && timerState?.phase === 'completed' && timerState.remaining <= 0) return;

    setAnswers((prev) => ({
      ...prev,
      [subjectCd]: {
        ...(prev[subjectCd] || {}),
        [questionNo]: answer,
      },
    }));
  };

  const handleCompleteSubject = () => {
    if (!currentSubject) return;
    const subjectCd = currentSubject.subjectCd;

    setTimers((prev) => ({
      ...prev,
      [subjectCd]: { ...prev[subjectCd], phase: 'completed' },
    }));

    const nextIdx = currentSubjectIdx + 1;
    if (nextIdx < activeSubjects.length) {
      // 다음 과목으로 이동
      const nextSubjectCd = activeSubjects[nextIdx].subjectCd;
      setTimers((prev) => ({
        ...prev,
        [nextSubjectCd]: { ...prev[nextSubjectCd], phase: 'active' },
      }));
      setCurrentSubjectIdx(nextIdx);
      setCurrentQuestionNo(1);
    } else {
      // 전체 완료 → 복습 모드
      setAllCompleted(true);
      setReviewMode(true);
      message.success('모든 과목 응시가 완료되었습니다. 남은 시간 내에 답안을 수정할 수 있습니다.');
    }
  };

  const handleReviewSubjectChange = (idx: number) => {
    if (!reviewMode) return;
    setCurrentSubjectIdx(idx);
    setCurrentQuestionNo(1);
  };

  // 제출
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

  const handleSubmit = () => {
    Modal.confirm({
      title: '답안을 제출하시겠습니까?',
      icon: <ExclamationCircleOutlined />,
      content: '제출 후에는 수정이 불가능합니다.',
      okText: '제출',
      cancelText: '취소',
      onOk: () => {
        const subjects: SubjectAnswer[] = activeSubjects.map((subject) => {
          const subjectAnswers = answers[subject.subjectCd] || {};
          return {
            subjectCd: subject.subjectCd,
            answers: Array.from({ length: subject.questionCnt }, (_, i) => ({
              questionNo: i + 1,
              answer: subjectAnswers[i + 1] || '',
            })),
          };
        });
        submitMutation.mutate({ examCd: examCd!, subjects });
      },
    });
  };

  // 시간 포맷
  const formatTime = (seconds: number) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  };

  // 로딩
  if (examLoading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}>
        <Spin size="large" />
      </div>
    );
  }

  if (!exam) {
    return (
      <div style={{ padding: 24 }}>
        <Alert message="시험 정보를 불러올 수 없습니다" type="error" showIcon />
        <Button style={{ marginTop: 16 }} icon={<ArrowLeftOutlined />} onClick={() => navigate('/')}>목록으로</Button>
      </div>
    );
  }

  if (exam.hasSubmitted) {
    return (
      <div style={{ padding: 24 }}>
        <Alert message="이미 채점이 완료된 시험입니다" type="info" showIcon />
        <Space style={{ marginTop: 16 }}>
          <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/')}>목록으로</Button>
          <Button type="primary" onClick={() => navigate(`/exams/${examCd}/result`)}>결과 보기</Button>
        </Space>
      </div>
    );
  }

  // 과목 선택 모달
  if (hasElective && selectedSubjectCds === null) {
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

  if (!currentSubject) return null;

  const currentTimer = timers[currentSubject.subjectCd];
  const subjectAnswers = answers[currentSubject.subjectCd] || {};
  const answeredCount = Object.values(subjectAnswers).filter((v) => v).length;
  const currentQuestion = questionData?.questions?.find((q) => q.questionNo === currentQuestionNo);
  const isTimerWarning = currentTimer && currentTimer.remaining < 60;

  return (
    <div style={{ padding: '12px', maxWidth: 1200, margin: '0 auto' }}>
      {/* 상단 헤더 */}
      <Card size="small" style={{ marginBottom: 12 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 8 }}>
          <div>
            <Button size="small" icon={<ArrowLeftOutlined />} onClick={() => navigate('/')}>
              목록
            </Button>
            <Text strong style={{ marginLeft: 12, fontSize: 16 }}>{exam.examNm}</Text>
          </div>
          <Space>
            {/* 표시 모드 전환 */}
            <Button.Group>
              <Tooltip title="텍스트 모드">
                <Button
                  type={displayMode === 'text' ? 'primary' : 'default'}
                  icon={<FileTextOutlined />}
                  onClick={() => setDisplayMode('text')}
                  size="small"
                />
              </Tooltip>
              <Tooltip title="이미지 모드">
                <Button
                  type={displayMode === 'image' ? 'primary' : 'default'}
                  icon={<PictureOutlined />}
                  onClick={() => setDisplayMode('image')}
                  size="small"
                />
              </Tooltip>
            </Button.Group>
            {/* 타이머 */}
            <Tag
              color={isTimerWarning ? 'red' : 'blue'}
              icon={<ClockCircleOutlined />}
              style={{ fontSize: 16, padding: '4px 12px' }}
            >
              {currentTimer ? formatTime(currentTimer.remaining) : '--:--'}
            </Tag>
          </Space>
        </div>
      </Card>

      <div style={{ display: 'flex', gap: 12 }}>
        {/* 왼쪽: 문제 영역 */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <Card
            title={
              <Space>
                {currentSubject.subjectType === 'M' ? (
                  <Tag color="blue">필수</Tag>
                ) : (
                  <Tag color="orange">선택</Tag>
                )}
                <span>{currentSubject.subjectNm}</span>
                <Text type="secondary">문제 {currentQuestionNo}/{currentSubject.questionCnt}</Text>
              </Space>
            }
            style={{ minHeight: 500 }}
          >
            {questionsLoading ? (
              <div style={{ textAlign: 'center', padding: 60 }}><Spin size="large" /></div>
            ) : currentQuestion ? (
              <div>
                {/* 문제 텍스트 */}
                {displayMode === 'text' ? (
                  <div style={{ marginBottom: 24 }}>
                    <Title level={5} style={{ marginBottom: 16 }}>
                      {currentQuestionNo}. {currentQuestion.questionText}
                    </Title>
                    {currentQuestion.contextText && (
                      <Card
                        size="small"
                        style={{
                          backgroundColor: '#fafafa',
                          marginBottom: 16,
                          borderLeft: '3px solid #1677ff',
                        }}
                      >
                        <Text style={{ whiteSpace: 'pre-wrap', lineHeight: 1.8 }}>
                          {currentQuestion.contextText}
                        </Text>
                      </Card>
                    )}
                  </div>
                ) : (
                  <div style={{ marginBottom: 24, textAlign: 'center' }}>
                    {currentQuestion.imageUrl ? (
                      <img
                        src={currentQuestion.imageUrl}
                        alt={`문제 ${currentQuestionNo}`}
                        style={{ maxWidth: '100%', maxHeight: 400 }}
                      />
                    ) : (
                      <Alert
                        message="이미지가 등록되지 않은 문제입니다"
                        description="텍스트 모드로 전환하여 문제를 확인하세요."
                        type="info"
                        showIcon
                      />
                    )}
                  </div>
                )}

                {/* 보기 */}
                <Radio.Group
                  value={subjectAnswers[currentQuestionNo] || ''}
                  onChange={(e) => handleAnswerSelect(currentQuestionNo, e.target.value)}
                  style={{ width: '100%' }}
                >
                  <Space direction="vertical" style={{ width: '100%' }} size={12}>
                    {currentQuestion.choices.map((choice, idx) => (
                      <Radio
                        key={idx}
                        value={String(idx + 1)}
                        style={{
                          display: 'flex',
                          padding: '12px 16px',
                          border: '1px solid',
                          borderColor: subjectAnswers[currentQuestionNo] === String(idx + 1)
                            ? '#1677ff' : '#d9d9d9',
                          borderRadius: 8,
                          backgroundColor: subjectAnswers[currentQuestionNo] === String(idx + 1)
                            ? '#e6f4ff' : '#fff',
                          width: '100%',
                          alignItems: 'flex-start',
                        }}
                      >
                        <Text style={{ whiteSpace: 'pre-wrap' }}>
                          <Text strong style={{ marginRight: 8 }}>{idx + 1}.</Text>
                          {choice}
                        </Text>
                      </Radio>
                    ))}
                  </Space>
                </Radio.Group>

                {/* 이전/다음 네비게이션 */}
                <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 24 }}>
                  <Button
                    icon={<ArrowLeftOutlined />}
                    disabled={currentQuestionNo <= 1}
                    onClick={() => setCurrentQuestionNo((p) => p - 1)}
                  >
                    이전
                  </Button>
                  {currentQuestionNo < currentSubject.questionCnt ? (
                    <Button
                      type="primary"
                      onClick={() => setCurrentQuestionNo((p) => p + 1)}
                    >
                      다음 <ArrowRightOutlined />
                    </Button>
                  ) : !allCompleted ? (
                    <Button
                      type="primary"
                      danger
                      onClick={() => {
                        Modal.confirm({
                          title: `${currentSubject.subjectNm} 응시를 완료하시겠습니까?`,
                          content: currentSubjectIdx < activeSubjects.length - 1
                            ? '다음 과목으로 이동합니다.'
                            : '전체 과목 응시가 완료됩니다. 이후 남은 시간 내 답안 수정이 가능합니다.',
                          okText: '완료',
                          cancelText: '취소',
                          onOk: handleCompleteSubject,
                        });
                      }}
                    >
                      과목 응시 완료
                    </Button>
                  ) : null}
                </div>
              </div>
            ) : (
              <Alert message="문제를 불러올 수 없습니다" type="warning" showIcon />
            )}
          </Card>
        </div>

        {/* 오른쪽: 네비게이션 + 과목 패널 */}
        <div style={{ width: 240, flexShrink: 0 }}>
          {/* 문제 번호 네비게이션 */}
          <Card title="문제 번호" size="small" style={{ marginBottom: 12 }}>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5, 1fr)', gap: 4 }}>
              {Array.from({ length: currentSubject.questionCnt }, (_, i) => {
                const qNo = i + 1;
                const isAnswered = !!subjectAnswers[qNo];
                const isCurrent = qNo === currentQuestionNo;
                return (
                  <Button
                    key={qNo}
                    size="small"
                    type={isCurrent ? 'primary' : isAnswered ? 'default' : 'dashed'}
                    style={{
                      backgroundColor: isCurrent ? undefined : isAnswered ? '#e6f4ff' : undefined,
                      fontWeight: isCurrent ? 'bold' : undefined,
                    }}
                    onClick={() => setCurrentQuestionNo(qNo)}
                  >
                    {qNo}
                  </Button>
                );
              })}
            </div>
            <div style={{ marginTop: 8, textAlign: 'center' }}>
              <Text type="secondary" style={{ fontSize: 12 }}>
                {answeredCount}/{currentSubject.questionCnt} 완료
              </Text>
              <Progress
                percent={Math.round((answeredCount / currentSubject.questionCnt) * 100)}
                size="small"
                showInfo={false}
              />
            </div>
          </Card>

          {/* 과목 목록 */}
          <Card title="과목 목록" size="small">
            <Space direction="vertical" style={{ width: '100%' }} size={4}>
              {activeSubjects.map((subject, idx) => {
                const timer = timers[subject.subjectCd];
                const subAnswers = answers[subject.subjectCd] || {};
                const cnt = Object.values(subAnswers).filter((v) => v).length;
                const isCurrent = idx === currentSubjectIdx;
                const isCompleted = timer?.phase === 'completed';
                const canClick = reviewMode || idx === currentSubjectIdx;

                return (
                  <Card
                    key={subject.subjectCd}
                    size="small"
                    hoverable={canClick}
                    onClick={() => canClick && handleReviewSubjectChange(idx)}
                    style={{
                      cursor: canClick ? 'pointer' : 'not-allowed',
                      borderColor: isCurrent ? '#1677ff' : isCompleted ? '#52c41a' : undefined,
                      backgroundColor: isCurrent ? '#e6f4ff' : isCompleted ? '#f6ffed' : undefined,
                      opacity: canClick ? 1 : 0.6,
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <div>
                        <Badge
                          status={
                            isCompleted ? 'success' :
                            isCurrent ? 'processing' : 'default'
                          }
                        />
                        <Text
                          strong={isCurrent}
                          style={{ fontSize: 12, marginLeft: 4 }}
                        >
                          {subject.subjectNm}
                        </Text>
                      </div>
                      <div style={{ textAlign: 'right' }}>
                        <Text style={{ fontSize: 11, display: 'block' }} type="secondary">
                          {cnt}/{subject.questionCnt}
                        </Text>
                        {timer && (
                          <Text
                            style={{ fontSize: 11 }}
                            type={timer.remaining < 60 ? 'danger' : 'secondary'}
                          >
                            {formatTime(timer.remaining)}
                          </Text>
                        )}
                      </div>
                    </div>
                  </Card>
                );
              })}
            </Space>
          </Card>

          {/* 제출 버튼 (복습 모드에서만) */}
          {reviewMode && (
            <Button
              type="primary"
              size="large"
              icon={<SendOutlined />}
              block
              style={{ marginTop: 12 }}
              onClick={handleSubmit}
              loading={submitMutation.isPending}
            >
              답안 제출
            </Button>
          )}
        </div>
      </div>
    </div>
  );
};

export default MockExamPage;
