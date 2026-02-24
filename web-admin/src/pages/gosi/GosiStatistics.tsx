import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Table, Card, Select, Row, Col, Button, Space, Statistic } from 'antd';
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { gosiApi } from '../../api/gosiApi';
import type { GosiStatMstResponse } from '../../types/gosi';

export default function GosiStatistics() {
  const [searchParams, setSearchParams] = useState({
    gosiCd: '',
    gosiType: '',
    page: 0,
    size: 20,
  });

  // 시험 목록
  const { data: examData } = useQuery({
    queryKey: ['gosi-exams'],
    queryFn: () => gosiApi.getExamList(),
  });

  // 유형 목록
  const { data: typeData } = useQuery({
    queryKey: ['gosi-types'],
    queryFn: () => gosiApi.getTypeList(),
  });

  // 통계 목록 (페이징)
  const { data, isLoading } = useQuery({
    queryKey: ['gosi-stat', searchParams],
    queryFn: () => gosiApi.getStatList(searchParams),
    enabled: !!searchParams.gosiCd,
  });

  // 대시보드 (전체)
  const { data: dashData } = useQuery({
    queryKey: ['gosi-dashboard', searchParams.gosiCd],
    queryFn: () => gosiApi.getDashboard(searchParams.gosiCd),
    enabled: !!searchParams.gosiCd,
  });

  const handleReset = () => {
    setSearchParams({ gosiCd: '', gosiType: '', page: 0, size: 20 });
  };

  // 대시보드 요약
  const dashboardStats = dashData?.data || [];
  const totalParticipants = dashboardStats.reduce((sum, s) => sum + (s.totalCnt || 0), 0);
  const totalPassCnt = dashboardStats.reduce((sum, s) => sum + (s.passCnt || 0), 0);
  const avgPassRate = dashboardStats.length > 0
    ? (dashboardStats.reduce((sum, s) => sum + (s.passRate || 0), 0) / dashboardStats.length).toFixed(1)
    : '0';

  const columns: ColumnsType<GosiStatMstResponse> = [
    { title: '시험유형', dataIndex: 'gosiTypeNm', key: 'gosiTypeNm', width: 120 },
    { title: '지역', dataIndex: 'gosiAreaNm', key: 'gosiAreaNm', width: 120 },
    { title: '과목', dataIndex: 'gosiSubjectNm', key: 'gosiSubjectNm', width: 150 },
    {
      title: '응시자수', dataIndex: 'totalCnt', key: 'totalCnt', width: 90, align: 'center',
      render: (v) => v != null ? `${v}명` : '-',
    },
    {
      title: '평균점수', dataIndex: 'avgScore', key: 'avgScore', width: 90, align: 'center',
      render: (v) => v != null ? `${v}` : '-',
    },
    {
      title: '최고점', dataIndex: 'maxScore', key: 'maxScore', width: 80, align: 'center',
      render: (v) => v != null ? `${v}` : '-',
    },
    {
      title: '최저점', dataIndex: 'minScore', key: 'minScore', width: 80, align: 'center',
      render: (v) => v != null ? `${v}` : '-',
    },
    {
      title: '합격자수', dataIndex: 'passCnt', key: 'passCnt', width: 90, align: 'center',
      render: (v) => v != null ? `${v}명` : '-',
    },
    {
      title: '합격률', dataIndex: 'passRate', key: 'passRate', width: 80, align: 'center',
      render: (v) => v != null ? `${v}%` : '-',
    },
  ];

  return (
    <div>
      <Card style={{ marginBottom: 16 }}>
        <Row gutter={[16, 16]} align="middle">
          <Col>
            <Select
              placeholder="시험 선택"
              style={{ width: 200 }}
              value={searchParams.gosiCd || undefined}
              onChange={(v) => setSearchParams((prev) => ({ ...prev, gosiCd: v || '', page: 0 }))}
              options={(examData?.data || []).map((e) => ({
                value: e.gosiCd,
                label: e.gosiNm || e.gosiCd,
              }))}
            />
          </Col>
          <Col>
            <Select
              placeholder="시험유형"
              allowClear
              style={{ width: 140 }}
              value={searchParams.gosiType || undefined}
              onChange={(v) => setSearchParams((prev) => ({ ...prev, gosiType: v || '', page: 0 }))}
              options={(typeData?.data || []).map((t) => ({
                value: t.gosiType,
                label: t.gosiTypeNm,
              }))}
            />
          </Col>
          <Col>
            <Space>
              <Button icon={<SearchOutlined />} type="primary"
                onClick={() => setSearchParams((prev) => ({ ...prev, page: 0 }))}>
                검색
              </Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>초기화</Button>
            </Space>
          </Col>
        </Row>
      </Card>

      {searchParams.gosiCd && dashboardStats.length > 0 && (
        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={8}>
            <Card>
              <Statistic title="총 응시자" value={totalParticipants} suffix="명" />
            </Card>
          </Col>
          <Col span={8}>
            <Card>
              <Statistic title="총 합격자" value={totalPassCnt} suffix="명" />
            </Card>
          </Col>
          <Col span={8}>
            <Card>
              <Statistic title="평균 합격률" value={avgPassRate} suffix="%" />
            </Card>
          </Col>
        </Row>
      )}

      <Card title={<span>통계 목록 (총 <strong>{data?.data?.totalElements || 0}</strong>건)</span>}>
        <Table
          columns={columns}
          dataSource={data?.data?.content || []}
          rowKey={(r) => `${r.gosiCd}-${r.gosiType}-${r.gosiArea}-${r.gosiSubjectCd}`}
          loading={isLoading}
          pagination={{
            current: searchParams.page + 1,
            pageSize: searchParams.size,
            total: data?.data?.totalElements || 0,
            showSizeChanger: true,
            showTotal: (total) => `총 ${total}건`,
            onChange: (page, pageSize) => {
              setSearchParams((prev) => ({ ...prev, page: page - 1, size: pageSize }));
            },
          }}
          size="small"
          scroll={{ x: 1000 }}
        />
      </Card>
    </div>
  );
}
