import React, { useRef, useCallback } from 'react';
import { Card, Input, Typography, Space, Tag, Tooltip } from 'antd';
import { CheckCircleFilled, CloseCircleFilled } from '@ant-design/icons';
import type { QuestionResult } from '../types/user';

const { Title, Text } = Typography;

interface QuickInputCardProps {
  subjectNm: string;
  subjectCd: string;
  questionCnt: number;
  answers: Record<number, string>;
  onAnswerChange: (subjectCd: string, questionNo: number, answer: string) => void;
  disabled?: boolean;
  results?: QuestionResult[];
  showResults?: boolean;
}

const QUESTIONS_PER_ROW = 5;

const QuickInputCard: React.FC<QuickInputCardProps> = ({
  subjectNm,
  subjectCd,
  questionCnt,
  answers,
  onAnswerChange,
  disabled = false,
  results,
  showResults = false,
}) => {
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);

  const resultMap = React.useMemo(() => {
    if (!results) return new Map<number, QuestionResult>();
    return new Map(results.map(r => [r.questionNo, r]));
  }, [results]);

  const getQuestionStatus = (questionNo: number): 'correct' | 'wrong' | 'unanswered' | null => {
    if (!showResults) return null;
    const result = resultMap.get(questionNo);
    if (!result) return 'unanswered';
    return result.isCorrect === 'Y' ? 'correct' : 'wrong';
  };

  const handleInputChange = useCallback((questionNo: number, value: string) => {
    // 1-5 숫자만 허용
    if (value === '' || /^[1-5]$/.test(value)) {
      onAnswerChange(subjectCd, questionNo, value);

      // 다음 입력칸으로 자동 이동
      if (value && questionNo < questionCnt) {
        const nextInput = inputRefs.current[questionNo];
        if (nextInput) {
          nextInput.focus();
          nextInput.select();
        }
      }
    }
  }, [subjectCd, questionCnt, onAnswerChange]);

  const handleKeyDown = useCallback((questionNo: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !answers[questionNo] && questionNo > 1) {
      // 빈 칸에서 백스페이스 누르면 이전 칸으로 이동
      const prevInput = inputRefs.current[questionNo - 2];
      if (prevInput) {
        prevInput.focus();
        prevInput.select();
      }
    } else if (e.key === 'ArrowLeft' && questionNo > 1) {
      const prevInput = inputRefs.current[questionNo - 2];
      if (prevInput) {
        prevInput.focus();
        prevInput.select();
      }
    } else if (e.key === 'ArrowRight' && questionNo < questionCnt) {
      const nextInput = inputRefs.current[questionNo];
      if (nextInput) {
        nextInput.focus();
        nextInput.select();
      }
    } else if (e.key === 'ArrowUp') {
      const targetNo = questionNo - QUESTIONS_PER_ROW;
      if (targetNo >= 1) {
        const targetInput = inputRefs.current[targetNo - 1];
        if (targetInput) {
          targetInput.focus();
          targetInput.select();
        }
      }
    } else if (e.key === 'ArrowDown') {
      const targetNo = questionNo + QUESTIONS_PER_ROW;
      if (targetNo <= questionCnt) {
        const targetInput = inputRefs.current[targetNo - 1];
        if (targetInput) {
          targetInput.focus();
          targetInput.select();
        }
      }
    }
  }, [answers, questionCnt]);

  const getInputStyle = (questionNo: number): React.CSSProperties => {
    const status = getQuestionStatus(questionNo);
    const baseStyle: React.CSSProperties = {
      width: 44,
      height: 44,
      textAlign: 'center',
      fontSize: 18,
      fontWeight: 'bold',
    };

    if (!status) return baseStyle;

    switch (status) {
      case 'correct':
        return { ...baseStyle, backgroundColor: '#f6ffed', borderColor: '#52c41a', color: '#52c41a' };
      case 'wrong':
        return { ...baseStyle, backgroundColor: '#fff2f0', borderColor: '#ff4d4f', color: '#ff4d4f' };
      default:
        return baseStyle;
    }
  };

  const renderQuestionInput = (questionNo: number) => {
    const status = getQuestionStatus(questionNo);
    const result = resultMap.get(questionNo);
    const currentAnswer = answers[questionNo] || '';

    return (
      <div
        key={questionNo}
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 4,
        }}
      >
        <Text type="secondary" style={{ fontSize: 12 }}>
          {questionNo}
        </Text>
        <Tooltip
          title={
            showResults && result
              ? status === 'correct'
                ? '정답!'
                : `정답: ${result.correctAns}`
              : `${questionNo}번 (1~5 입력)`
          }
        >
          <Input
            ref={(el) => { inputRefs.current[questionNo - 1] = el; }}
            value={currentAnswer}
            onChange={(e) => handleInputChange(questionNo, e.target.value)}
            onKeyDown={(e) => handleKeyDown(questionNo, e)}
            onFocus={(e) => e.target.select()}
            disabled={disabled}
            maxLength={1}
            style={getInputStyle(questionNo)}
          />
        </Tooltip>
        {showResults && (
          <div style={{ height: 20 }}>
            {status === 'correct' ? (
              <CheckCircleFilled style={{ color: '#52c41a', fontSize: 16 }} />
            ) : status === 'wrong' ? (
              <CloseCircleFilled style={{ color: '#ff4d4f', fontSize: 16 }} />
            ) : null}
          </div>
        )}
      </div>
    );
  };

  const renderRow = (startNo: number) => {
    const questions: number[] = [];
    for (let i = 0; i < QUESTIONS_PER_ROW && startNo + i <= questionCnt; i++) {
      questions.push(startNo + i);
    }

    return (
      <div
        key={startNo}
        style={{
          display: 'flex',
          gap: 16,
          padding: '12px 16px',
          borderBottom: '1px solid #f0f0f0',
          alignItems: 'flex-start',
        }}
      >
        <div
          style={{
            width: 60,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontWeight: 'bold',
            color: '#1890ff',
            height: 44,
            marginTop: 20,
          }}
        >
          {startNo}-{Math.min(startNo + QUESTIONS_PER_ROW - 1, questionCnt)}
        </div>
        <div style={{ display: 'flex', gap: 12, flex: 1 }}>
          {questions.map((qNo) => renderQuestionInput(qNo))}
        </div>
      </div>
    );
  };

  const answeredCount = Object.keys(answers).filter(
    (key) => answers[parseInt(key)]
  ).length;

  const rowCount = Math.ceil(questionCnt / QUESTIONS_PER_ROW);

  return (
    <Card
      title={
        <Space>
          <Title level={5} style={{ margin: 0 }}>{subjectNm}</Title>
          <Tag color={answeredCount === questionCnt ? 'green' : 'default'}>
            {answeredCount} / {questionCnt}
          </Tag>
        </Space>
      }
      extra={
        <Text type="secondary" style={{ fontSize: 12 }}>
          1~5 숫자 입력 (자동 이동)
        </Text>
      }
      style={{ marginBottom: 16 }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          padding: '8px 16px',
          backgroundColor: '#fafafa',
          borderBottom: '2px solid #d9d9d9',
          fontWeight: 'bold',
        }}
      >
        <Text style={{ width: 60, textAlign: 'center' }}>문항</Text>
        <Text style={{ flex: 1, textAlign: 'center' }}>답안 (1~5)</Text>
      </div>

      <div style={{ maxHeight: 500, overflowY: 'auto' }}>
        {Array.from({ length: rowCount }, (_, i) => renderRow(i * QUESTIONS_PER_ROW + 1))}
      </div>
    </Card>
  );
};

export default QuickInputCard;
