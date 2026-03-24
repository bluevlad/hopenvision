import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Card,
  Select,
  Row,
  Col,
  Statistic,
  Table,
  Empty,
  Spin,
  Button,
  message,
  Tabs,
  Tag,
  Progress,
} from 'antd';
import {
  UserOutlined,
  TrophyOutlined,
  BarChartOutlined,
  RiseOutlined,
  FallOutlined,
  DownloadOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
} from 'recharts';
import { examApi } from '../api/examApi';
import { statisticsApi } from '../api/statisticsApi';
import type { SubjectStatistics, QuestionDetail, AreaStatistics, ExamDashboardItem } from '../types/statistics';

const CHART_COLORS = ['#1890ff', '#52c41a', '#faad14', '#f5222d', '#722ed1', '#13c2c2', '#eb2f96', '#fa8c16'];

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

export default function Statistics() {
  const [selectedExamCd, setSelectedExamCd] = useState<string | undefined>();
  const [exporting, setExporting] = useState(false);

  const { data: examListData } = useQuery({
    queryKey: ['exams', { page: 0, size: 100 }],
    queryFn: () => examApi.getExamList({ page: 0, size: 100 }),
  });

  const { data: statsData, isLoading } = useQuery({
    queryKey: ['statistics', selectedExamCd],
    queryFn: () => statisticsApi.getExamStatistics(selectedExamCd!),
    enabled: !!selectedExamCd,
  });

  const { data: questionStatsData, isLoading: isLoadingQuestions } = useQuery({
    queryKey: ['questionStatistics', selectedExamCd],
    queryFn: () => statisticsApi.getQuestionStatistics(selectedExamCd!),
    enabled: !!selectedExamCd,
  });

  const { data: areaStatsData } = useQuery({
    queryKey: ['areaStatistics', selectedExamCd],
    queryFn: () => statisticsApi.getAreaStatistics(selectedExamCd!),
    enabled: !!selectedExamCd,
  });

  const { data: dashboardData } = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => statisticsApi.getDashboard(),
  });

  const examList = examListData?.data?.content || [];
  const stats = statsData?.data;
  const questionStats = questionStatsData?.data || [];
  const areaStats = areaStatsData?.data || [];
  const dashboard = dashboardData?.data || [];

  const STATUS_LABELS: Record<string, { label: string; color: string }> = {
    DRAFT: { label: '초안', color: 'default' },
    REGISTRATION: { label: '접수중', color: 'blue' },
    IN_PROGRESS: { label: '시험중', color: 'orange' },
    GRADING: { label: '채점중', color: 'purple' },
    PUBLISHED: { label: '성적공개', color: 'green' },
    CLOSED: { label: '종료', color: 'default' },
  };

  const subjectColumns: ColumnsType<SubjectStatistics> = [
    {
      title: '과목코드',
      dataIndex: 'subjectCd',
      key: 'subjectCd',
      width: 120,
    },
    {
      title: '과목명',
      dataIndex: 'subjectNm',
      key: 'subjectNm',
      width: 150,
    },
    {
      title: '응시자수',
      dataIndex: 'applicantCount',
      key: 'applicantCount',
      width: 100,
      align: 'center',
      render: (value: number) => `${value}명`,
    },
    {
      title: '평균점수',
      dataIndex: 'avgScore',
      key: 'avgScore',
      width: 100,
      align: 'center',
      render: (value: number | null) => value != null ? `${value}점` : '-',
    },
    {
      title: '최고점수',
      dataIndex: 'maxScore',
      key: 'maxScore',
      width: 100,
      align: 'center',
      render: (value: number | null) => value != null ? `${value}점` : '-',
    },
    {
      title: '최저점수',
      dataIndex: 'minScore',
      key: 'minScore',
      width: 100,
      align: 'center',
      render: (value: number | null) => value != null ? `${value}점` : '-',
    },
  ];

  // 점수 분포 차트 데이터
  const distributionChartData = stats?.scoreDistributions.map((dist) => ({
    range: dist.range + '점',
    인원수: dist.count,
    비율: dist.percentage,
    fill: DISTRIBUTION_COLORS[dist.range] || '#1890ff',
  })) || [];

  // 과목별 비교 차트 데이터
  const subjectChartData = stats?.subjectStatistics.map((sub) => ({
    과목: sub.subjectNm,
    평균: sub.avgScore ?? 0,
    최고: sub.maxScore ?? 0,
    최저: sub.minScore ?? 0,
  })) || [];

  // 합격/불합격 파이 차트 데이터
  const passFailData = stats ? [
    { name: '합격', value: stats.passedCount },
    { name: '불합격', value: stats.totalApplicants - stats.passedCount },
  ] : [];
  const PIE_COLORS = ['#52c41a', '#ff4d4f'];

  return (
    <div>
      <Card style={{ marginBottom: 16 }}>
        <Row align="middle" gutter={16}>
          <Col>
            <span style={{ fontWeight: 'bold', marginRight: 8 }}>시험 선택:</span>
          </Col>
          <Col flex="auto">
            <Select
              placeholder="통계를 조회할 시험을 선택하세요"
              style={{ width: 400 }}
              value={selectedExamCd}
              onChange={setSelectedExamCd}
              showSearch
              filterOption={(input, option) =>
                (option?.label as string)?.toLowerCase().includes(input.toLowerCase()) ?? false
              }
              options={examList.map((exam) => ({
                value: exam.examCd,
                label: `${exam.examNm} (${exam.examCd})`,
              }))}
            />
          </Col>
          <Col>
            <Button
              type="primary"
              icon={<DownloadOutlined />}
              disabled={!selectedExamCd || !stats}
              loading={exporting}
              onClick={async () => {
                if (!selectedExamCd) return;
                setExporting(true);
                try {
                  await statisticsApi.exportScores(selectedExamCd);
                  message.success('성적 Excel 파일을 다운로드했습니다.');
                } catch {
                  message.error('Excel 내보내기에 실패했습니다.');
                } finally {
                  setExporting(false);
                }
              }}
            >
              Excel 내보내기
            </Button>
          </Col>
        </Row>
      </Card>

      {isLoading && (
        <Card>
          <div style={{ textAlign: 'center', padding: 60 }}>
            <Spin size="large" />
            <p style={{ marginTop: 16 }}>통계를 불러오는 중...</p>
          </div>
        </Card>
      )}

      {!selectedExamCd && !isLoading && (
        <Card>
          <Empty description="시험을 선택해주세요" />
        </Card>
      )}

      {stats && !isLoading && (
        <Tabs
          defaultActiveKey="overview"
          items={[
            {
              key: 'overview',
              label: '전체 통계',
              children: (
                <>
                  <Row gutter={16} style={{ marginBottom: 16 }}>
                    <Col span={4}>
                      <Card>
                        <Statistic title="응시자수" value={stats.totalApplicants} suffix="명" prefix={<UserOutlined />} />
                      </Card>
                    </Col>
                    <Col span={4}>
                      <Card>
                        <Statistic title="합격자수" value={stats.passedCount} suffix="명" prefix={<TrophyOutlined />} valueStyle={{ color: '#3f8600' }} />
                      </Card>
                    </Col>
                    <Col span={4}>
                      <Card>
                        <Statistic title="합격률" value={stats.passRate} suffix="%" prefix={<BarChartOutlined />} precision={2} />
                      </Card>
                    </Col>
                    <Col span={4}>
                      <Card>
                        <Statistic title="평균점수" value={stats.avgScore ?? 0} suffix="점" precision={2} />
                      </Card>
                    </Col>
                    <Col span={4}>
                      <Card>
                        <Statistic title="최고점수" value={stats.maxScore ?? 0} suffix="점" prefix={<RiseOutlined />} valueStyle={{ color: '#3f8600' }} />
                      </Card>
                    </Col>
                    <Col span={4}>
                      <Card>
                        <Statistic title="최저점수" value={stats.minScore ?? 0} suffix="점" prefix={<FallOutlined />} valueStyle={{ color: '#cf1322' }} />
                      </Card>
                    </Col>
                  </Row>

                  <Row gutter={16} style={{ marginBottom: 16 }}>
                    <Col span={16}>
                      <Card title="점수 분포">
                        <ResponsiveContainer width="100%" height={300}>
                          <BarChart data={distributionChartData}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="range" />
                            <YAxis allowDecimals={false} />
                            <Tooltip
                              formatter={(value, name) => {
                                if (name === '인원수') return [`${value}명`, name];
                                return [`${value}%`, name];
                              }}
                            />
                            <Legend />
                            <Bar dataKey="인원수" fill="#1890ff">
                              {distributionChartData.map((entry, index) => (
                                <Cell key={`cell-${index}`} fill={entry.fill} />
                              ))}
                            </Bar>
                          </BarChart>
                        </ResponsiveContainer>
                      </Card>
                    </Col>
                    <Col span={8}>
                      <Card title="합격/불합격 비율">
                        <ResponsiveContainer width="100%" height={300}>
                          <PieChart>
                            <Pie
                              data={passFailData}
                              cx="50%"
                              cy="50%"
                              innerRadius={60}
                              outerRadius={100}
                              dataKey="value"
                              label={({ name, value }) => `${name} ${value}명`}
                            >
                              {passFailData.map((_entry, index) => (
                                <Cell key={`cell-${index}`} fill={PIE_COLORS[index]} />
                              ))}
                            </Pie>
                            <Tooltip formatter={(value) => [`${value}명`]} />
                          </PieChart>
                        </ResponsiveContainer>
                      </Card>
                    </Col>
                  </Row>

                  <Row gutter={16} style={{ marginBottom: 16 }}>
                    <Col span={24}>
                      <Card title="과목별 통계 비교">
                        <ResponsiveContainer width="100%" height={300}>
                          <BarChart data={subjectChartData}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="과목" />
                            <YAxis />
                            <Tooltip formatter={(value) => [`${value}점`]} />
                            <Legend />
                            <Bar dataKey="평균" fill={CHART_COLORS[0]} />
                            <Bar dataKey="최고" fill={CHART_COLORS[1]} />
                            <Bar dataKey="최저" fill={CHART_COLORS[3]} />
                          </BarChart>
                        </ResponsiveContainer>
                      </Card>
                    </Col>
                  </Row>

                  <Row gutter={16}>
                    <Col span={24}>
                      <Card title="과목별 상세 통계">
                        <Table
                          columns={subjectColumns}
                          dataSource={stats.subjectStatistics}
                          rowKey="subjectCd"
                          size="small"
                          pagination={false}
                        />
                      </Card>
                    </Col>
                  </Row>
                </>
              ),
            },
            {
              key: 'questions',
              label: '문항별 분석',
              children: isLoadingQuestions ? (
                <Card><div style={{ textAlign: 'center', padding: 60 }}><Spin size="large" /></div></Card>
              ) : (
                <>
                  {questionStats.map((subject) => {
                    const questionColumns: ColumnsType<QuestionDetail> = [
                      {
                        title: '문항',
                        dataIndex: 'questionNo',
                        key: 'questionNo',
                        width: 70,
                        align: 'center',
                        render: (v: number) => `Q${v}`,
                      },
                      {
                        title: '정답',
                        dataIndex: 'correctAns',
                        key: 'correctAns',
                        width: 60,
                        align: 'center',
                        render: (v: string) => <Tag color="blue">{v}</Tag>,
                      },
                      {
                        title: '응시자',
                        dataIndex: 'totalAnswered',
                        key: 'totalAnswered',
                        width: 80,
                        align: 'center',
                        render: (v: number) => `${v}명`,
                      },
                      {
                        title: '정답률',
                        dataIndex: 'correctRate',
                        key: 'correctRate',
                        width: 160,
                        render: (rate: number) => (
                          <Progress
                            percent={rate}
                            size="small"
                            strokeColor={rate >= 70 ? '#52c41a' : rate >= 40 ? '#faad14' : '#f5222d'}
                            format={(p) => `${p?.toFixed(1)}%`}
                          />
                        ),
                      },
                      {
                        title: '난이도',
                        dataIndex: 'difficulty',
                        key: 'difficulty',
                        width: 100,
                        align: 'center',
                        render: (v: string) => {
                          const color = v.includes('쉬움') ? 'green' : v.includes('보통') ? 'orange' : 'red';
                          return <Tag color={color}>{v}</Tag>;
                        },
                      },
                      {
                        title: '선택지 분포',
                        key: 'choiceDistributions',
                        render: (_, record) => (
                          <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                            {record.choiceDistributions.map((cd) => (
                              <div key={cd.choice} style={{ textAlign: 'center', minWidth: 40 }}>
                                <div style={{
                                  fontSize: 11,
                                  fontWeight: cd.isCorrect ? 'bold' : 'normal',
                                  color: cd.isCorrect ? '#1890ff' : '#666',
                                }}>
                                  {cd.isCorrect ? `[${cd.choice}]` : cd.choice}
                                </div>
                                <div style={{
                                  background: cd.isCorrect ? '#e6f7ff' : '#f5f5f5',
                                  borderRadius: 4,
                                  padding: '2px 6px',
                                  fontSize: 11,
                                  border: cd.isCorrect ? '1px solid #91d5ff' : '1px solid #d9d9d9',
                                }}>
                                  {cd.percentage.toFixed(0)}%
                                </div>
                              </div>
                            ))}
                          </div>
                        ),
                      },
                    ];

                    return (
                      <Card
                        key={subject.subjectCd}
                        title={`${subject.subjectNm} (${subject.subjectCd})`}
                        style={{ marginBottom: 16 }}
                        extra={
                          <span style={{ color: '#888' }}>
                            {subject.questions.length}문항
                          </span>
                        }
                      >
                        <Table
                          columns={questionColumns}
                          dataSource={subject.questions}
                          rowKey="questionNo"
                          size="small"
                          pagination={false}
                        />
                      </Card>
                    );
                  })}
                  {questionStats.length === 0 && (
                    <Card><Empty description="문항별 통계 데이터가 없습니다." /></Card>
                  )}
                </>
              ),
            },
            {
              key: 'area',
              label: '직렬별 분석',
              children: (
                <>
                  {areaStats.length > 0 ? (
                    <>
                      <Card title="직렬별 비교" style={{ marginBottom: 16 }}>
                        <ResponsiveContainer width="100%" height={300}>
                          <BarChart data={areaStats.map((a) => ({
                            직렬: a.applyArea || '미지정',
                            평균: a.avgScore ?? 0,
                            최고: a.maxScore ?? 0,
                            최저: a.minScore ?? 0,
                          }))}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="직렬" />
                            <YAxis />
                            <Tooltip formatter={(value) => [`${value}점`]} />
                            <Legend />
                            <Bar dataKey="평균" fill={CHART_COLORS[0]} />
                            <Bar dataKey="최고" fill={CHART_COLORS[1]} />
                            <Bar dataKey="최저" fill={CHART_COLORS[3]} />
                          </BarChart>
                        </ResponsiveContainer>
                      </Card>
                      <Card title="직렬별 상세">
                        <Table<AreaStatistics>
                          columns={[
                            { title: '직렬', dataIndex: 'applyArea', key: 'applyArea', width: 120, render: (v: string) => v || '미지정' },
                            { title: '응시자', dataIndex: 'applicantCount', key: 'applicantCount', width: 80, align: 'center', render: (v: number) => `${v}명` },
                            { title: '평균', dataIndex: 'avgScore', key: 'avgScore', width: 80, align: 'center', render: (v: number | null) => v != null ? `${v}점` : '-' },
                            { title: '최고', dataIndex: 'maxScore', key: 'maxScore', width: 80, align: 'center', render: (v: number | null) => v != null ? `${v}점` : '-' },
                            { title: '최저', dataIndex: 'minScore', key: 'minScore', width: 80, align: 'center', render: (v: number | null) => v != null ? `${v}점` : '-' },
                            { title: '합격자', dataIndex: 'passedCount', key: 'passedCount', width: 80, align: 'center', render: (v: number) => `${v}명` },
                            { title: '합격률', dataIndex: 'passRate', key: 'passRate', width: 100, align: 'center', render: (v: number) => <Progress percent={v} size="small" format={(p) => `${p?.toFixed(1)}%`} /> },
                          ]}
                          dataSource={areaStats}
                          rowKey="applyArea"
                          size="small"
                          pagination={false}
                        />
                      </Card>
                    </>
                  ) : (
                    <Card><Empty description="직렬별 통계 데이터가 없습니다. 응시자의 직렬(applyArea) 정보가 필요합니다." /></Card>
                  )}
                </>
              ),
            },
          ]}
        />
      )}

      {!selectedExamCd && !isLoading && dashboard.length > 0 && (
        <Card title="응시 현황 대시보드">
          <Table<ExamDashboardItem>
            columns={[
              { title: '시험코드', dataIndex: 'examCd', key: 'examCd', width: 120 },
              { title: '시험명', dataIndex: 'examNm', key: 'examNm', ellipsis: true },
              { title: '유형', dataIndex: 'examType', key: 'examType', width: 80 },
              {
                title: '상태',
                dataIndex: 'examStatus',
                key: 'examStatus',
                width: 100,
                align: 'center',
                render: (v: string) => {
                  const s = STATUS_LABELS[v] || { label: v || '-', color: 'default' };
                  return <Tag color={s.color}>{s.label}</Tag>;
                },
              },
              { title: '응시자', dataIndex: 'applicantCount', key: 'applicantCount', width: 80, align: 'center', render: (v: number) => `${v}명` },
              { title: '제출 완료', dataIndex: 'submittedCount', key: 'submittedCount', width: 90, align: 'center', render: (v: number) => `${v}명` },
              {
                title: '제출률',
                dataIndex: 'submissionRate',
                key: 'submissionRate',
                width: 140,
                render: (v: number) => <Progress percent={v} size="small" format={(p) => `${p?.toFixed(1)}%`} />,
              },
            ]}
            dataSource={dashboard}
            rowKey="examCd"
            size="small"
            pagination={false}
          />
        </Card>
      )}
    </div>
  );
}
