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
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  Cell,
} from 'recharts';
import { getMyResult, getScoreAnalysis } from '../api/userApi';
import type { SubjectResult } from '../types/user';
import OMRCard from '../components/OMRCard';

const { Title, Text } = Typography;

const DISTRIBUTION_COLORS: Record<string, string> = {
  '90~100': '#52c41a',
  '80~89': '#73d13d',
  '70~79': '#95de64',
  '60~69': '#faad14',
  '50~59': '#fa8c16',
  '40~49': '#fa541c',
  '30~39': '#f5222d',
  '0~29': '#cf1322',
};

const UserScoreResult: React.FC = () => {
  const { examCd } = useParams<{ examCd: string }>();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<string>('summary');

  const { data: result, isLoading, error } = useQuery({
    queryKey: ['userResult', examCd],
    queryFn: () => getMyResult(examCd!),
    enabled: !!examCd,
  });

  const { data: analysis } = useQuery({
    queryKey: ['scoreAnalysis', examCd],
    queryFn: () => getScoreAnalysis(examCd!),
    enabled: !!examCd && !!result,
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
          onClick={() => navigate('/')}
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

  // 분석 탭
  const analysisTab = analysis ? (
    <div>
      <Row gutter={[24, 24]} style={{ marginBottom: 24 }}>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic
              title="내 순위"
              value={analysis.ranking}
              suffix={`/ ${analysis.totalApplicants}명`}
              valueStyle={{ color: '#1890ff' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic
              title="백분위"
              value={analysis.percentile}
              suffix="%"
              precision={1}
              valueStyle={{ color: '#722ed1' }}
            />
          </Card>
        </Col>
        <Col xs={24} sm={8}>
          <Card>
            <Statistic
              title="상위"
              value={analysis.totalApplicants > 0
                ? Math.round((analysis.ranking / analysis.totalApplicants) * 100)
                : 0}
              suffix="%"
              valueStyle={{ color: '#52c41a' }}
            />
          </Card>
        </Col>
      </Row>

      <Card title="점수 분포 (내 위치)" style={{ marginBottom: 24 }}>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={analysis.scoreDistributions.map((d) => ({
            range: d.range + '점',
            인원수: d.count,
            fill: d.isUserInRange ? '#1890ff' : (DISTRIBUTION_COLORS[d.range] || '#d9d9d9'),
            isUserInRange: d.isUserInRange,
          }))}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="range" />
            <YAxis allowDecimals={false} />
            <Tooltip
              formatter={(value) => [`${value}명`, '인원수']}
            />
            <Bar dataKey="인원수">
              {analysis.scoreDistributions.map((d, index) => (
                <Cell
                  key={`cell-${index}`}
                  fill={d.isUserInRange ? '#1890ff' : (DISTRIBUTION_COLORS[d.range] || '#d9d9d9')}
                  stroke={d.isUserInRange ? '#003a8c' : undefined}
                  strokeWidth={d.isUserInRange ? 2 : 0}
                />
              ))}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
        <div style={{ textAlign: 'center', color: '#1890ff', marginTop: 8 }}>
          * 파란색 막대가 내 점수가 속한 구간입니다
        </div>
      </Card>

      <Card title="과목별 비교 (내 점수 vs 전체)">
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={analysis.subjectComparisons.map((s) => ({
            과목: s.subjectNm,
            '내 점수': s.myScore,
            평균: s.avgScore,
            최고: s.maxScore,
            최저: s.minScore,
          }))}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="과목" />
            <YAxis />
            <Tooltip formatter={(value) => [`${value}점`]} />
            <Legend />
            <Bar dataKey="내 점수" fill="#1890ff" />
            <Bar dataKey="평균" fill="#faad14" />
            <Bar dataKey="최고" fill="#52c41a" />
            <Bar dataKey="최저" fill="#f5222d" />
          </BarChart>
        </ResponsiveContainer>

        <Divider />

        <Table
          dataSource={analysis.subjectComparisons}
          rowKey="subjectCd"
          pagination={false}
          size="small"
          columns={[
            { title: '과목', dataIndex: 'subjectNm', key: 'subjectNm' },
            {
              title: '내 점수',
              dataIndex: 'myScore',
              key: 'myScore',
              align: 'center',
              render: (v: number) => <Text strong style={{ color: '#1890ff' }}>{v}점</Text>,
            },
            {
              title: '전체 평균',
              dataIndex: 'avgScore',
              key: 'avgScore',
              align: 'center',
              render: (v: number) => `${v}점`,
            },
            {
              title: '최고점',
              dataIndex: 'maxScore',
              key: 'maxScore',
              align: 'center',
              render: (v: number) => `${v}점`,
            },
            {
              title: '최저점',
              dataIndex: 'minScore',
              key: 'minScore',
              align: 'center',
              render: (v: number) => `${v}점`,
            },
            {
              title: '순위',
              key: 'ranking',
              align: 'center',
              render: (_: unknown, record) => `${record.ranking} / ${record.totalCount}명`,
            },
          ]}
        />
      </Card>
    </div>
  ) : (
    <div style={{ textAlign: 'center', padding: 60 }}>
      <Spin size="large" />
      <p style={{ marginTop: 16 }}>분석 데이터를 불러오는 중...</p>
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
    {
      key: 'analysis',
      label: '성적 분석',
      children: analysisTab,
    },
    ...detailTabs,
  ];

  return (
    <div style={{ padding: 24 }}>
      <Card>
        <div style={{ marginBottom: 24 }}>
          <Button
            icon={<ArrowLeftOutlined />}
            onClick={() => navigate('/')}
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
