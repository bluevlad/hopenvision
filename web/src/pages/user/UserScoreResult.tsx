import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Card,
  Button,
  Space,
  Typography,
  Spin,
  Alert,
  Tabs,
  Statistic,
  Row,
  Col,
  Tag,
  Divider,
  Table,
} from 'antd';
import {
  ArrowLeftOutlined,
  TrophyOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  WarningOutlined,
} from '@ant-design/icons';
import { getMyResult } from '../../api/userApi';
import type { SubjectResult } from '../../types/user';
import OMRCard from '../../components/OMRCard';

const { Title, Text } = Typography;

const UserScoreResult: React.FC = () => {
  const { examCd } = useParams<{ examCd: string }>();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<string>('summary');

  const { data: result, isLoading, error } = useQuery({
    queryKey: ['userResult', examCd],
    queryFn: () => getMyResult(examCd!),
    enabled: !!examCd,
  });

  if (isLoading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}>
        <Spin size="large" />
      </div>
    );
  }

  if (error || !result) {
    return (
      <div style={{ padding: 24 }}>
        <Alert
          message="채점 결과를 불러올 수 없습니다"
          description={(error as Error)?.message || '아직 채점하지 않은 시험입니다.'}
          type="error"
          showIcon
        />
        <Button
          style={{ marginTop: 16 }}
          icon={<ArrowLeftOutlined />}
          onClick={() => navigate('/user')}
        >
          목록으로
        </Button>
      </div>
    );
  }

  const isPassed = result.passYn === 'Y';
  const hasCutFail = result.cutFailYn === 'Y';

  const summaryTab = (
    <div>
      <Row gutter={[24, 24]}>
        <Col span={24}>
          <Card
            style={{
              background: isPassed
                ? 'linear-gradient(135deg, #52c41a22 0%, #95de6422 100%)'
                : 'linear-gradient(135deg, #ff4d4f22 0%, #ff7a4522 100%)',
            }}
          >
            <div style={{ textAlign: 'center' }}>
              {isPassed ? (
                <>
                  <TrophyOutlined style={{ fontSize: 64, color: '#52c41a' }} />
                  <Title level={2} style={{ color: '#52c41a', margin: '16px 0 8px' }}>
                    합격
                  </Title>
                </>
              ) : (
                <>
                  <CloseCircleOutlined style={{ fontSize: 64, color: '#ff4d4f' }} />
                  <Title level={2} style={{ color: '#ff4d4f', margin: '16px 0 8px' }}>
                    불합격
                  </Title>
                </>
              )}
              {hasCutFail && (
                <Tag color="warning" icon={<WarningOutlined />}>
                  과락 과목 있음
                </Tag>
              )}
            </div>
          </Card>
        </Col>

        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="총점"
              value={result.totalScore}
              suffix="점"
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>

        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="평균점수"
              value={result.avgScore}
              suffix="점"
              precision={1}
              valueStyle={{ color: '#722ed1' }}
            />
          </Card>
        </Col>

        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="정답률"
              value={result.correctRate}
              suffix="%"
              precision={1}
              valueStyle={{ color: '#13c2c2' }}
            />
          </Card>
        </Col>

        <Col xs={24} sm={12} md={6}>
          <Card>
            <Statistic
              title="예상 순위"
              value={result.estimatedRanking}
              suffix={`/ ${result.totalApplicants}명`}
              valueStyle={{ color: '#fa8c16' }}
            />
          </Card>
        </Col>
      </Row>

      <Divider />

      <Title level={5}>과목별 성적</Title>
      <Table
        dataSource={result.subjectResults}
        rowKey="subjectCd"
        pagination={false}
        columns={[
          {
            title: '과목',
            dataIndex: 'subjectNm',
            key: 'subjectNm',
          },
          {
            title: '점수',
            dataIndex: 'score',
            key: 'score',
            align: 'center',
            render: (score: number) => <Text strong>{score}점</Text>,
          },
          {
            title: '정답/오답',
            key: 'correctWrong',
            align: 'center',
            render: (_: unknown, record: SubjectResult) => (
              <Space>
                <Tag color="green">{record.correctCnt}개 정답</Tag>
                <Tag color="red">{record.wrongCnt}개 오답</Tag>
              </Space>
            ),
          },
          {
            title: '정답률',
            dataIndex: 'correctRate',
            key: 'correctRate',
            align: 'center',
            render: (rate: number) => `${rate}%`,
          },
          {
            title: '과락',
            key: 'cutFail',
            align: 'center',
            render: (_: unknown, record: SubjectResult) => (
              record.cutFailYn === 'Y' ? (
                <Tag color="error" icon={<WarningOutlined />}>
                  과락 (기준: {record.cutLine}점)
                </Tag>
              ) : (
                <Tag color="success" icon={<CheckCircleOutlined />}>
                  통과
                </Tag>
              )
            ),
          },
        ]}
      />
    </div>
  );

  const detailTabs = result.subjectResults.map((subject) => {
    const answersMap: Record<number, string> = {};
    subject.questionResults.forEach((q) => {
      answersMap[q.questionNo] = q.userAns;
    });

    return {
      key: `detail-${subject.subjectCd}`,
      label: subject.subjectNm,
      children: (
        <OMRCard
          subjectNm={subject.subjectNm}
          subjectCd={subject.subjectCd}
          questionCnt={subject.totalQuestions}
          answers={answersMap}
          onAnswerChange={() => {}}
          disabled={true}
          results={subject.questionResults}
          showResults={true}
        />
      ),
    };
  });

  const tabItems = [
    {
      key: 'summary',
      label: '성적 요약',
      children: summaryTab,
    },
    ...detailTabs,
  ];

  return (
    <div style={{ padding: 24 }}>
      <Card>
        <div style={{ marginBottom: 24 }}>
          <Button
            icon={<ArrowLeftOutlined />}
            onClick={() => navigate('/user')}
            style={{ marginBottom: 16 }}
          >
            목록으로
          </Button>
          <Title level={4} style={{ margin: 0 }}>{result.examNm}</Title>
          <Text type="secondary">채점 결과</Text>
        </div>

        <Tabs
          activeKey={activeTab}
          onChange={setActiveTab}
          items={tabItems}
          type="card"
        />
      </Card>
    </div>
  );
};

export default UserScoreResult;
