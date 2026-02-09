import React from 'react';
import { Radio, Card, Typography, Space, Tag, Tooltip } from 'antd';
import { CheckCircleFilled, CloseCircleFilled } from '@ant-design/icons';
import type { QuestionResult } from '../types/user';

const { Title, Text } = Typography;

interface OMRCardProps {
  subjectNm: string;
  subjectCd: string;
  questionCnt: number;
  answers: Record<number, string>;
  onAnswerChange: (subjectCd: string, questionNo: number, answer: string) => void;
  disabled?: boolean;
  results?: QuestionResult[];
  showResults?: boolean;
}

const ANSWER_OPTIONS = ['1', '2', '3', '4', '5'];

const OMRCard: React.FC<OMRCardProps> = ({
  subjectNm,
  subjectCd,
  questionCnt,
  answers,
  onAnswerChange,
  disabled = false,
  results,
  showResults = false,
}) => {
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

  const getRowStyle = (questionNo: number): React.CSSProperties => {
    const status = getQuestionStatus(questionNo);
    if (!status) return {};

    switch (status) {
      case 'correct':
        return { backgroundColor: '#f6ffed' };
      case 'wrong':
        return { backgroundColor: '#fff2f0' };
      default:
        return {};
    }
  };

  const renderQuestionRow = (questionNo: number) => {
    const status = getQuestionStatus(questionNo);
    const result = resultMap.get(questionNo);
    const currentAnswer = answers[questionNo] || '';

    return (
      <div
        key={questionNo}
        style={{
          display: 'flex',
          alignItems: 'center',
          padding: '8px 12px',
          borderBottom: '1px solid #f0f0f0',
          ...getRowStyle(questionNo),
        }}
      >
        <Text strong style={{ width: 40, textAlign: 'center' }}>
          {questionNo}
        </Text>

        <Radio.Group
          value={currentAnswer}
          onChange={(e) => onAnswerChange(subjectCd, questionNo, e.target.value)}
          disabled={disabled}
          style={{ flex: 1 }}
        >
          <Space>
            {ANSWER_OPTIONS.map((option) => {
              const isCorrectAnswer = showResults && result?.correctAns === option;
              const isUserWrongAnswer = showResults && status === 'wrong' && currentAnswer === option;

              return (
                <Tooltip
                  key={option}
                  title={isCorrectAnswer ? '정답' : isUserWrongAnswer ? '오답' : ''}
                >
                  <Radio.Button
                    value={option}
                    style={{
                      width: 40,
                      height: 40,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      borderRadius: '50%',
                      ...(isCorrectAnswer && {
                        borderColor: '#52c41a',
                        color: '#52c41a',
                        fontWeight: 'bold',
                      }),
                      ...(isUserWrongAnswer && {
                        borderColor: '#ff4d4f',
                        color: '#ff4d4f',
                        textDecoration: 'line-through',
                      }),
                    }}
                  >
                    {option}
                  </Radio.Button>
                </Tooltip>
              );
            })}
          </Space>
        </Radio.Group>

        {showResults && (
          <div style={{ width: 60, textAlign: 'center' }}>
            {status === 'correct' ? (
              <CheckCircleFilled style={{ color: '#52c41a', fontSize: 20 }} />
            ) : status === 'wrong' ? (
              <CloseCircleFilled style={{ color: '#ff4d4f', fontSize: 20 }} />
            ) : (
              <Text type="secondary">-</Text>
            )}
          </div>
        )}
      </div>
    );
  };

  const answeredCount = Object.keys(answers).filter(
    (key) => answers[parseInt(key)]
  ).length;

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
      style={{ marginBottom: 16 }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          padding: '8px 12px',
          backgroundColor: '#fafafa',
          borderBottom: '2px solid #d9d9d9',
          fontWeight: 'bold',
        }}
      >
        <Text style={{ width: 40, textAlign: 'center' }}>번호</Text>
        <Text style={{ flex: 1, textAlign: 'center' }}>답안</Text>
        {showResults && <Text style={{ width: 60, textAlign: 'center' }}>결과</Text>}
      </div>

      <div style={{ maxHeight: 500, overflowY: 'auto' }}>
        {Array.from({ length: questionCnt }, (_, i) => renderQuestionRow(i + 1))}
      </div>
    </Card>
  );
};

export default OMRCard;
