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
  SaveOutlined,
  LogoutOutlined,
} from '@ant-design/icons';
import { getExamDetail, getSubjectQuestions, submitAnswers } from '../api/userApi';
import type { SubmitRequest, SubjectAnswer } from '../types/user';
import SubjectSelectModal from '../components/SubjectSelectModal';

const { Title, Text } = Typography;

type AnswersState = Record<string, Record<number, string>>;
type DisplayMode = 'text' | 'image';
type SubjectPhase = 'waiting' | 'active' | 'completed';

interface SubjectTimerState {
  remaining: number;
  phase: SubjectPhase;
}

// --- localStorage 임시저장 ---
const STORAGE_KEY_PREFIX = 'mockExam_';

interface SavedSession {
  examCd: string;
  selectedSubjectCds: string[];
  answers: AnswersState;
  timers: Record<string, SubjectTimerState>;
  currentSubjectIdx: number;
  currentQuestionNo: number;
  allCompleted: boolean;
  reviewMode: boolean;
  savedAt: number;
}

const saveSession = (examCd: string, data: Omit<SavedSession, 'savedAt'>) => {
  try {
    const session: SavedSession = { ...data, savedAt: Date.now() };
    localStorage.setItem(STORAGE_KEY_PREFIX + examCd, JSON.stringify(session));
  } catch { /* storage full 등 무시 */ }
};

const loadSession = (examCd: string): SavedSession | null => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY_PREFIX + examCd);
    if (!raw) return null;
    const session: SavedSession = JSON.parse(raw);
    // 24시간 이상 지난 세션은 무효
    if (Date.now() - session.savedAt > 24 * 60 * 60 * 1000) {
      localStorage.removeItem(STORAGE_KEY_PREFIX + examCd);
      return null;
    }
    return session;
  } catch {
    return null;
  }
};

const clearSession = (examCd: string) => {
  localStorage.removeItem(STORAGE_KEY_PREFIX + examCd);
};

// --- 컴포넌트 ---
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
  const [examStarted, setExamStarted] = useState(false);
  const [sessionRecovered, setSessionRecovered] = useState(false);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const autoSaveRef = useRef<ReturnType<typeof setInterval> | null>(null);

  // 시험 정보 조회
  const { data: exam, isLoading: examLoading } = useQuery({
    queryKey: ['userExam', examCd],
    queryFn: () => getExamDetail(examCd!),
    enabled: !!examCd,
  });

  const hasElective = exam?.subjects.some((s) => s.subjectType === 'S') ?? false;
  const showSelectModal = !!exam && !exam.hasSubmitted && hasElective && selectedSubjectCds === null && !sessionRecovered;

  // 선택된 과목
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
    enabled: !!examCd && !!currentSubject && examStarted,
  });

  // --- 세션 복구 ---
  useEffect(() => {
    if (!examCd || !exam || exam.hasSubmitted) return;
    const saved = loadSession(examCd);
    if (!saved) return;

    Modal.confirm({
      title: '이전 응시 기록이 있습니다',
      icon: <ExclamationCircleOutlined />,
      content: (
        <div>
          <p>이전에 응시하던 기록을 복원하시겠습니까?</p>
          <Text type="secondary" style={{ fontSize: 12 }}>
            저장 시각: {new Date(saved.savedAt).toLocaleString()}
          </Text>
        </div>
      ),
      okText: '복원',
      cancelText: '새로 시작',
      onOk: () => {
        setSelectedSubjectCds(saved.selectedSubjectCds);
        setAnswers(saved.answers);
        setTimers(saved.timers);
        setCurrentSubjectIdx(saved.currentSubjectIdx);
        setCurrentQuestionNo(saved.currentQuestionNo);
        setAllCompleted(saved.allCompleted);
        setReviewMode(saved.reviewMode);
        setSessionRecovered(true);
        setExamStarted(true);
      },
      onCancel: () => {
        clearSession(examCd);
      },
    });
  }, [examCd, exam]);

  // --- 자동 임시저장 (5초마다) ---
  useEffect(() => {
    if (!examCd || !examStarted || !selectedSubjectCds) return;

    autoSaveRef.current = setInterval(() => {
      saveSession(examCd, {
        examCd,
        selectedSubjectCds,
        answers,
        timers,
        currentSubjectIdx,
        currentQuestionNo,
        allCompleted,
        reviewMode,
      });
    }, 5000);

    return () => {
      if (autoSaveRef.current) clearInterval(autoSaveRef.current);
    };
  }, [examCd, examStarted, selectedSubjectCds, answers, timers, currentSubjectIdx, currentQuestionNo, allCompleted, reviewMode]);

  // --- 페이지 이탈 방지 ---
  useEffect(() => {
    if (!examStarted) return;

    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      e.preventDefault();
      // 즉시 저장
      if (examCd && selectedSubjectCds) {
        saveSession(examCd, {
          examCd,
          selectedSubjectCds,
          answers,
          timers,
          currentSubjectIdx,
          currentQuestionNo,
          allCompleted,
          reviewMode,
        });
      }
    };

    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [examStarted, examCd, selectedSubjectCds, answers, timers, currentSubjectIdx, currentQuestionNo, allCompleted, reviewMode]);

  // --- 뒤로가기 차단 ---
  useEffect(() => {
    if (!examStarted) return;

    const handlePopState = (e: PopStateEvent) => {
      e.preventDefault();
      window.history.pushState(null, '', window.location.href);
      Modal.warning({
        title: '시험 진행 중입니다',
        content: '시험 중에는 뒤로 가기를 사용할 수 없습니다. 시험을 중단하려면 "시험 중단" 버튼을 사용하세요.',
      });
    };

    window.history.pushState(null, '', window.location.href);
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, [examStarted]);

  // --- 타이머 초기화 ---
  useEffect(() => {
    if (activeSubjects.length > 0 && Object.keys(timers).length === 0 && !sessionRecovered) {
      const initial: Record<string, SubjectTimerState> = {};
      activeSubjects.forEach((s, idx) => {
        initial[s.subjectCd] = {
          remaining: (s.timeLimit || 22) * 60,
          phase: idx === 0 ? 'active' : 'waiting',
        };
      });
      setTimers(initial);
    }
  }, [activeSubjects, timers, sessionRecovered]);

  // --- 타이머 틱 ---
  useEffect(() => {
    if (!currentSubject || !examStarted) return;

    const subjectCd = currentSubject.subjectCd;
    const timerState = timers[subjectCd];
    if (!timerState || timerState.phase !== 'active') return;

    timerRef.current = setInterval(() => {
      setTimers((prev) => {
        const current = prev[subjectCd];
        if (!current || current.remaining <= 0) return prev;
        const newRemaining = current.remaining - 1;
        if (newRemaining <= 0) {
          return { ...prev, [subjectCd]: { ...current, remaining: 0, phase: 'completed' } };
        }
        return { ...prev, [subjectCd]: { ...current, remaining: newRemaining } };
      });
    }, 1000);

    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [currentSubject, timers, examStarted]);

  // 시간 초과 시 자동 다음 과목
  useEffect(() => {
    if (!currentSubject || allCompleted || !examStarted) return;
    const timerState = timers[currentSubject.subjectCd];
    if (timerState?.phase === 'completed' && timerState.remaining <= 0) {
      handleCompleteSubject();
    }
  }, [timers, currentSubject, allCompleted, examStarted]);

  // --- 핸들러 ---
  const handleSubjectConfirm = useCallback((subjectCds: string[]) => {
    setSelectedSubjectCds(subjectCds);
    setExamStarted(true);
  }, []);

  const handleSubjectCancel = useCallback(() => {
    navigate('/');
  }, [navigate]);

  const handleAnswerSelect = (questionNo: number, answer: string) => {
    if (!currentSubject) return;
    const subjectCd = currentSubject.subjectCd;
    const timerState = timers[subjectCd];
    if (!reviewMode && timerState?.phase === 'completed' && timerState.remaining <= 0) return;

    setAnswers((prev) => ({
      ...prev,
      [subjectCd]: { ...(prev[subjectCd] || {}), [questionNo]: answer },
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
      const nextSubjectCd = activeSubjects[nextIdx].subjectCd;
      setTimers((prev) => ({
        ...prev,
        [nextSubjectCd]: { ...prev[nextSubjectCd], phase: 'active' },
      }));
      setCurrentSubjectIdx(nextIdx);
      setCurrentQuestionNo(1);
    } else {
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

  const handleExitExam = () => {
    Modal.confirm({
      title: '시험을 중단하시겠습니까?',
      icon: <ExclamationCircleOutlined />,
      content: '현재까지의 답안은 자동 저장되어 있으며, 다시 접속하면 복원할 수 있습니다.',
      okText: '중단',
      okButtonProps: { danger: true },
      cancelText: '계속 응시',
      onOk: () => {
        // 즉시 저장 후 나가기
        if (examCd && selectedSubjectCds) {
          saveSession(examCd, {
            examCd,
            selectedSubjectCds,
            answers,
            timers,
            currentSubjectIdx,
            currentQuestionNo,
            allCompleted,
            reviewMode,
          });
        }
        navigate('/');
      },
    });
  };

  // 제출
  const submitMutation = useMutation({
    mutationFn: (request: SubmitRequest) => submitAnswers(examCd!, request),
    onSuccess: () => {
      if (examCd) clearSession(examCd);
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
          const sa = answers[subject.subjectCd] || {};
          return {
            subjectCd: subject.subjectCd,
            answers: Array.from({ length: subject.questionCnt }, (_, i) => ({
              questionNo: i + 1,
              answer: sa[i + 1] || '',
            })),
          };
        });
        submitMutation.mutate({ examCd: examCd!, subjects });
      },
    });
  };

  const formatTime = (seconds: number) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  };

  // --- 렌더링: 로딩/에러/이미 제출 ---
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
  if (hasElective && selectedSubjectCds === null && !sessionRecovered) {
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

  // 선택 과목 없는 시험: 바로 시작
  if (!hasElective && !examStarted) {
    setExamStarted(true);
    return null;
  }

  if (!currentSubject) return null;

  const currentTimer = timers[currentSubject.subjectCd];
  const subjectAnswers = answers[currentSubject.subjectCd] || {};
  const answeredCount = Object.values(subjectAnswers).filter((v) => v).length;
  const currentQuestion = questionData?.questions?.find((q) => q.questionNo === currentQuestionNo);
  const isTimerWarning = currentTimer && currentTimer.remaining < 60;

  // --- 풀스크린 모달 ---
  return (
    <Modal
      open={examStarted}
      footer={null}
      closable={false}
      keyboard={false}
      maskClosable={false}
      width="100vw"
      styles={{
        body: { padding: 0, height: 'calc(100vh - 55px)', overflow: 'auto' },
      }}
      style={{ top: 0, maxWidth: '100vw', paddingBottom: 0 }}
    >
      {/* 상단 헤더 바 */}
      <div style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: '8px 16px',
        backgroundColor: '#001529',
        color: '#fff',
      }}>
        <Space>
          <Text strong style={{ color: '#fff', fontSize: 16 }}>{exam.examNm}</Text>
          <Tag color="blue">{currentSubject.subjectNm}</Tag>
          <Text style={{ color: 'rgba(255,255,255,0.65)', fontSize: 13 }}>
            문제 {currentQuestionNo}/{currentSubject.questionCnt}
          </Text>
        </Space>
        <Space size="middle">
          {/* 표시 모드 전환 */}
          <Button.Group>
            <Tooltip title="텍스트 모드">
              <Button
                type={displayMode === 'text' ? 'primary' : 'default'}
                icon={<FileTextOutlined />}
                onClick={() => setDisplayMode('text')}
                size="small"
                ghost={displayMode !== 'text'}
              />
            </Tooltip>
            <Tooltip title="이미지 모드">
              <Button
                type={displayMode === 'image' ? 'primary' : 'default'}
                icon={<PictureOutlined />}
                onClick={() => setDisplayMode('image')}
                size="small"
                ghost={displayMode !== 'image'}
              />
            </Tooltip>
          </Button.Group>
          {/* 자동저장 표시 */}
          <Tooltip title="5초마다 자동 저장">
            <Tag icon={<SaveOutlined />} color="green">자동저장</Tag>
          </Tooltip>
          {/* 타이머 */}
          <Tag
            color={isTimerWarning ? 'red' : 'blue'}
            icon={<ClockCircleOutlined />}
            style={{ fontSize: 18, padding: '4px 16px', fontFamily: 'monospace' }}
          >
            {currentTimer ? formatTime(currentTimer.remaining) : '--:--'}
          </Tag>
          {/* 시험 중단 */}
          <Tooltip title="시험 중단 (답안 자동 저장)">
            <Button
              danger
              ghost
              size="small"
              icon={<LogoutOutlined />}
              onClick={handleExitExam}
            >
              중단
            </Button>
          </Tooltip>
        </Space>
      </div>

      {/* 본문 */}
      <div style={{ display: 'flex', height: 'calc(100vh - 100px)' }}>
        {/* 왼쪽: 문제 영역 */}
        <div style={{ flex: 1, overflow: 'auto', padding: 16 }}>
          {questionsLoading ? (
            <div style={{ textAlign: 'center', padding: 60 }}><Spin size="large" /></div>
          ) : currentQuestion ? (
            <div style={{ maxWidth: 800, margin: '0 auto' }}>
              {/* 문제 텍스트 */}
              {displayMode === 'text' ? (
                <div style={{ marginBottom: 24 }}>
                  <Title level={5} style={{ marginBottom: 16, lineHeight: 1.8 }}>
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
                <Space direction="vertical" style={{ width: '100%' }} size={10}>
                  {currentQuestion.choices.map((choice, idx) => (
                    <Radio
                      key={idx}
                      value={String(idx + 1)}
                      style={{
                        display: 'flex',
                        padding: '12px 16px',
                        border: '1px solid',
                        borderColor: subjectAnswers[currentQuestionNo] === String(idx + 1) ? '#1677ff' : '#d9d9d9',
                        borderRadius: 8,
                        backgroundColor: subjectAnswers[currentQuestionNo] === String(idx + 1) ? '#e6f4ff' : '#fff',
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

              {/* 이전/다음 */}
              <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 24, paddingBottom: 24 }}>
                <Button
                  icon={<ArrowLeftOutlined />}
                  disabled={currentQuestionNo <= 1}
                  onClick={() => setCurrentQuestionNo((p) => p - 1)}
                  size="large"
                >
                  이전
                </Button>
                {currentQuestionNo < currentSubject.questionCnt ? (
                  <Button
                    type="primary"
                    size="large"
                    onClick={() => setCurrentQuestionNo((p) => p + 1)}
                  >
                    다음 <ArrowRightOutlined />
                  </Button>
                ) : !allCompleted ? (
                  <Button
                    type="primary"
                    danger
                    size="large"
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
        </div>

        {/* 오른쪽: 사이드 패널 */}
        <div style={{
          width: 250,
          borderLeft: '1px solid #f0f0f0',
          overflow: 'auto',
          padding: 12,
          backgroundColor: '#fafafa',
        }}>
          {/* 문제 번호 */}
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
                const sa = answers[subject.subjectCd] || {};
                const cnt = Object.values(sa).filter((v) => v).length;
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
                        <Badge status={isCompleted ? 'success' : isCurrent ? 'processing' : 'default'} />
                        <Text strong={isCurrent} style={{ fontSize: 12, marginLeft: 4 }}>
                          {subject.subjectNm}
                        </Text>
                      </div>
                      <div style={{ textAlign: 'right' }}>
                        <Text style={{ fontSize: 11, display: 'block' }} type="secondary">
                          {cnt}/{subject.questionCnt}
                        </Text>
                        {timer && (
                          <Text style={{ fontSize: 11, fontFamily: 'monospace' }} type={timer.remaining < 60 ? 'danger' : 'secondary'}>
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

          {/* 제출 버튼 */}
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
    </Modal>
  );
};

export default MockExamPage;
