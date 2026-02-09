import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Card,
  Select,
  Row,
  Col,
  Statistic,
  Table,
  Progress,
  Empty,
  Spin,
} from 'antd';
import {
  UserOutlined,
  TrophyOutlined,
  BarChartOutlined,
  RiseOutlined,
  FallOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { examApi } from '../../api/examApi';
import { statisticsApi } from '../../api/statisticsApi';
import type { SubjectStatistics } from '../../types/statistics';

export default function Statistics() {
  const [selectedExamCd, setSelectedExamCd] = useState<string | undefined>();

  // 시험 목록
  const { data: examListData } = useQuery({
    queryKey: ['exams', { page: 0, size: 100 }],
    queryFn: () => examApi.getExamList({ page: 0, size: 100 }),
  });

  // 통계 조회
  const { data: statsData, isLoading } = useQuery({
    queryKey: ['statistics', selectedExamCd],
    queryFn: () => statisticsApi.getExamStatistics(selectedExamCd!),
    enabled: !!selectedExamCd,
  });

  const examList = examListData?.data?.content || [];
  const stats = statsData?.data;

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
        <>
          <Row gutter={16} style={{ marginBottom: 16 }}>
            <Col span={4}>
              <Card>
                <Statistic
                  title="응시자수"
                  value={stats.totalApplicants}
                  suffix="명"
                  prefix={<UserOutlined />}
                />
              </Card>
            </Col>
            <Col span={4}>
              <Card>
                <Statistic
                  title="합격자수"
                  value={stats.passedCount}
                  suffix="명"
                  prefix={<TrophyOutlined />}
                  valueStyle={{ color: '#3f8600' }}
                />
              </Card>
            </Col>
            <Col span={4}>
              <Card>
                <Statistic
                  title="합격률"
                  value={stats.passRate}
                  suffix="%"
                  prefix={<BarChartOutlined />}
                  precision={2}
                />
              </Card>
            </Col>
            <Col span={4}>
              <Card>
                <Statistic
                  title="평균점수"
                  value={stats.avgScore ?? 0}
                  suffix="점"
                  precision={2}
                />
              </Card>
            </Col>
            <Col span={4}>
              <Card>
                <Statistic
                  title="최고점수"
                  value={stats.maxScore ?? 0}
                  suffix="점"
                  prefix={<RiseOutlined />}
                  valueStyle={{ color: '#3f8600' }}
                />
              </Card>
            </Col>
            <Col span={4}>
              <Card>
                <Statistic
                  title="최저점수"
                  value={stats.minScore ?? 0}
                  suffix="점"
                  prefix={<FallOutlined />}
                  valueStyle={{ color: '#cf1322' }}
                />
              </Card>
            </Col>
          </Row>

          <Row gutter={16} style={{ marginBottom: 16 }}>
            <Col span={12}>
              <Card title="점수 분포">
                {stats.scoreDistributions.map((dist) => (
                  <div key={dist.range} style={{ marginBottom: 8 }}>
                    <Row align="middle">
                      <Col span={5}>
                        <span style={{ fontWeight: 500 }}>{dist.range}점</span>
                      </Col>
                      <Col span={14}>
                        <Progress
                          percent={dist.percentage}
                          format={() => `${dist.count}명`}
                          strokeColor={getDistributionColor(dist.range)}
                        />
                      </Col>
                      <Col span={5} style={{ textAlign: 'right' }}>
                        <span style={{ color: '#999' }}>{dist.percentage}%</span>
                      </Col>
                    </Row>
                  </div>
                ))}
              </Card>
            </Col>
            <Col span={12}>
              <Card title="과목별 통계">
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
      )}
    </div>
  );
}

function getDistributionColor(range: string): string {
  if (range.startsWith('90') || range.startsWith('100')) return '#52c41a';
  if (range.startsWith('80')) return '#73d13d';
  if (range.startsWith('70')) return '#95de64';
  if (range.startsWith('60')) return '#faad14';
  if (range.startsWith('50')) return '#fa8c16';
  if (range.startsWith('40')) return '#fa541c';
  if (range.startsWith('30')) return '#f5222d';
  return '#cf1322';
}
