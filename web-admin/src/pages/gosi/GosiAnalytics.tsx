import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Card, Select, Row, Col, Empty, Spin, Space, Button } from 'antd';
import { ReloadOutlined } from '@ant-design/icons';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { gosiApi } from '../../api/gosiApi';

const CHART_COLORS = ['#1890ff', '#52c41a', '#faad14', '#f5222d', '#722ed1', '#13c2c2', '#eb2f96', '#fa8c16'];

export default function GosiAnalytics() {
  const [selectedGosiCd, setSelectedGosiCd] = useState<string | undefined>();
  const [selectedGosiType, setSelectedGosiType] = useState<string | undefined>();
  const [selectedGosiArea, setSelectedGosiArea] = useState<string | undefined>();

  const { data: examListData } = useQuery({
    queryKey: ['gosi', 'exams'],
    queryFn: () => gosiApi.getExamList(),
  });

  const { data: typeListData } = useQuery({
    queryKey: ['gosi', 'types'],
    queryFn: () => gosiApi.getTypeList(),
  });

  const { data: areaListData } = useQuery({
    queryKey: ['gosi', 'areas', selectedGosiType],
    queryFn: () => gosiApi.getAreaList(selectedGosiType),
  });

  const { data: distributionData, isLoading: isDistLoading } = useQuery({
    queryKey: ['gosi', 'analytics', 'distribution', selectedGosiCd, selectedGosiType, selectedGosiArea],
    queryFn: () => gosiApi.getScoreDistribution({
      gosiCd: selectedGosiCd!,
      gosiType: selectedGosiType,
      gosiArea: selectedGosiArea,
    }),
    enabled: !!selectedGosiCd,
  });

  const { data: trendData, isLoading: isTrendLoading } = useQuery({
    queryKey: ['gosi', 'analytics', 'trend', selectedGosiType],
    queryFn: () => gosiApi.getYearlyTrend(selectedGosiType),
  });

  const { data: subjectData, isLoading: isSubjectLoading } = useQuery({
    queryKey: ['gosi', 'analytics', 'subject', selectedGosiCd],
    queryFn: () => gosiApi.getSubjectComparison(selectedGosiCd!),
    enabled: !!selectedGosiCd,
  });

  const { data: areaData, isLoading: isAreaLoading } = useQuery({
    queryKey: ['gosi', 'analytics', 'area', selectedGosiCd, selectedGosiType],
    queryFn: () => gosiApi.getAreaComparison({
      gosiCd: selectedGosiCd!,
      gosiType: selectedGosiType,
    }),
    enabled: !!selectedGosiCd,
  });

  const examList = examListData?.data || [];
  const typeList = typeListData?.data || [];
  const areaList = areaListData?.data || [];

  const distribution = distributionData?.data || [];
  const trend = trendData?.data || [];
  const subjects = subjectData?.data || [];
  const areas = areaData?.data || [];

  const handleReset = () => {
    setSelectedGosiCd(undefined);
    setSelectedGosiType(undefined);
    setSelectedGosiArea(undefined);
  };

  const distributionChartData = distribution.map((d) => ({
    구간: d.range + '점',
    인원수: d.count,
  }));

  const trendChartData = trend.map((t) => ({
    년도: t.gosiYear + '년',
    평균점수: t.avgScore,
    합격률: t.passRate,
    응시자수: t.totalCnt,
  }));

  const subjectChartData = subjects.map((s) => ({
    과목: s.subjectNm,
    평균: s.avgScore,
    최고: s.maxScore,
    최저: s.minScore,
  }));

  const areaChartData = areas.map((a) => ({
    지역: a.gosiAreaNm || a.gosiArea,
    평균점수: a.avgScore,
    합격률: a.passRate,
    응시자수: a.totalCnt,
  }));

  return (
    <div>
      <Card style={{ marginBottom: 16 }}>
        <Space wrap>
          <span style={{ fontWeight: 'bold' }}>필터:</span>
          <Select
            placeholder="시험 선택"
            style={{ width: 280 }}
            value={selectedGosiCd}
            onChange={setSelectedGosiCd}
            allowClear
            showSearch
            filterOption={(input, option) =>
              (option?.label as string)?.toLowerCase().includes(input.toLowerCase()) ?? false
            }
            options={examList.map((exam) => ({
              value: exam.gosiCd,
              label: `${exam.gosiNm} (${exam.gosiCd})`,
            }))}
          />
          <Select
            placeholder="시험유형"
            style={{ width: 160 }}
            value={selectedGosiType}
            onChange={(value) => {
              setSelectedGosiType(value);
              setSelectedGosiArea(undefined);
            }}
            allowClear
            options={typeList.map((t) => ({
              value: t.gosiType,
              label: t.gosiTypeNm,
            }))}
          />
          <Select
            placeholder="지역"
            style={{ width: 160 }}
            value={selectedGosiArea}
            onChange={setSelectedGosiArea}
            allowClear
            options={areaList.map((a) => ({
              value: a.gosiArea,
              label: a.gosiAreaNm,
            }))}
          />
          <Button icon={<ReloadOutlined />} onClick={handleReset}>
            초기화
          </Button>
        </Space>
      </Card>

      <Row gutter={16} style={{ marginBottom: 16 }}>
        <Col span={12}>
          <Card title="점수 분포도">
            {isDistLoading ? (
              <div style={{ textAlign: 'center', padding: 60 }}><Spin /></div>
            ) : !selectedGosiCd ? (
              <Empty description="시험을 선택해주세요" style={{ padding: 40 }} />
            ) : distributionChartData.length === 0 ? (
              <Empty description="데이터가 없습니다" style={{ padding: 40 }} />
            ) : (
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={distributionChartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="구간" />
                  <YAxis allowDecimals={false} />
                  <Tooltip formatter={(value) => [`${value}명`, '인원수']} />
                  <Legend />
                  <Bar dataKey="인원수" fill={CHART_COLORS[0]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </Card>
        </Col>
        <Col span={12}>
          <Card title="년도별 추이">
            {isTrendLoading ? (
              <div style={{ textAlign: 'center', padding: 60 }}><Spin /></div>
            ) : trendChartData.length === 0 ? (
              <Empty description="데이터가 없습니다" style={{ padding: 40 }} />
            ) : (
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={trendChartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="년도" />
                  <YAxis yAxisId="left" domain={[0, 100]} />
                  <YAxis yAxisId="right" orientation="right" domain={[0, 100]} />
                  <Tooltip
                    formatter={(value, name) => {
                      const v = Number(value ?? 0);
                      if (name === '합격률') return [`${v.toFixed(2)}%`, name];
                      return [`${v.toFixed(2)}점`, name];
                    }}
                  />
                  <Legend />
                  <Line yAxisId="left" type="monotone" dataKey="평균점수" stroke={CHART_COLORS[0]} strokeWidth={2} />
                  <Line yAxisId="right" type="monotone" dataKey="합격률" stroke={CHART_COLORS[1]} strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
            )}
          </Card>
        </Col>
      </Row>

      <Row gutter={16}>
        <Col span={12}>
          <Card title="과목별 성적 비교">
            {isSubjectLoading ? (
              <div style={{ textAlign: 'center', padding: 60 }}><Spin /></div>
            ) : !selectedGosiCd ? (
              <Empty description="시험을 선택해주세요" style={{ padding: 40 }} />
            ) : subjectChartData.length === 0 ? (
              <Empty description="데이터가 없습니다" style={{ padding: 40 }} />
            ) : (
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
            )}
          </Card>
        </Col>
        <Col span={12}>
          <Card title="지역별 성적 비교">
            {isAreaLoading ? (
              <div style={{ textAlign: 'center', padding: 60 }}><Spin /></div>
            ) : !selectedGosiCd ? (
              <Empty description="시험을 선택해주세요" style={{ padding: 40 }} />
            ) : areaChartData.length === 0 ? (
              <Empty description="데이터가 없습니다" style={{ padding: 40 }} />
            ) : (
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={areaChartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="지역" />
                  <YAxis yAxisId="left" />
                  <YAxis yAxisId="right" orientation="right" domain={[0, 100]} />
                  <Tooltip
                    formatter={(value, name) => {
                      const v = Number(value ?? 0);
                      if (name === '합격률') return [`${v.toFixed(2)}%`, name];
                      return [`${v.toFixed(2)}점`, name];
                    }}
                  />
                  <Legend />
                  <Bar yAxisId="left" dataKey="평균점수" fill={CHART_COLORS[0]} />
                  <Bar yAxisId="right" dataKey="합격률" fill={CHART_COLORS[1]} />
                </BarChart>
              </ResponsiveContainer>
            )}
          </Card>
        </Col>
      </Row>
    </div>
  );
}
