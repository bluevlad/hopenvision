import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Table, Card, Select, Row, Col, Input, Button, Space, Tag } from 'antd';
import { SearchOutlined, ReloadOutlined, EyeOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { gosiApi } from '../../api/gosiApi';
import type { GosiRstMstResponse } from '../../types/gosi';

export default function GosiScoreList() {
  const navigate = useNavigate();

  const [searchParams, setSearchParams] = useState({
    gosiCd: '',
    gosiType: '',
    gosiArea: '',
    keyword: '',
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

  // 지역 목록
  const { data: areaData } = useQuery({
    queryKey: ['gosi-areas', searchParams.gosiType],
    queryFn: () => gosiApi.getAreaList(searchParams.gosiType || undefined),
    enabled: !!searchParams.gosiType,
  });

  // 성적 목록
  const { data, isLoading } = useQuery({
    queryKey: ['gosi-results', searchParams],
    queryFn: () => gosiApi.getResultList(searchParams),
    enabled: !!searchParams.gosiCd,
  });

  const handleReset = () => {
    setSearchParams({ gosiCd: '', gosiType: '', gosiArea: '', keyword: '', page: 0, size: 20 });
  };

  const columns: ColumnsType<GosiRstMstResponse> = [
    { title: '성적번호', dataIndex: 'rstNo', key: 'rstNo', width: 100 },
    { title: '사용자ID', dataIndex: 'userId', key: 'userId', width: 120 },
    { title: '시험유형', dataIndex: 'gosiType', key: 'gosiType', width: 100 },
    { title: '지역', dataIndex: 'gosiArea', key: 'gosiArea', width: 100 },
    {
      title: '총점', dataIndex: 'totalScore', key: 'totalScore', width: 80, align: 'center',
      render: (v) => v != null ? `${v}` : '-',
    },
    {
      title: '평균', dataIndex: 'avgScore', key: 'avgScore', width: 80, align: 'center',
      render: (v) => v != null ? `${v}` : '-',
    },
    {
      title: '합격', dataIndex: 'passYn', key: 'passYn', width: 70, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '합격' : '불합격'}</Tag>,
    },
    {
      title: '등록일', dataIndex: 'regDt', key: 'regDt', width: 150,
      render: (v) => v?.substring(0, 16),
    },
    {
      title: '관리', key: 'action', width: 80, align: 'center',
      render: (_, record) => (
        <Button
          size="small"
          icon={<EyeOutlined />}
          onClick={() => navigate(`/gosi/results/${record.gosiCd}/${record.rstNo}`)}
        >
          상세
        </Button>
      ),
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
              onChange={(v) => setSearchParams((prev) => ({ ...prev, gosiType: v || '', gosiArea: '', page: 0 }))}
              options={(typeData?.data || []).map((t) => ({
                value: t.gosiType,
                label: t.gosiTypeNm,
              }))}
            />
          </Col>
          <Col>
            <Select
              placeholder="지역"
              allowClear
              style={{ width: 140 }}
              value={searchParams.gosiArea || undefined}
              onChange={(v) => setSearchParams((prev) => ({ ...prev, gosiArea: v || '', page: 0 }))}
              options={(areaData?.data || []).map((a) => ({
                value: a.gosiArea,
                label: a.gosiAreaNm,
              }))}
              disabled={!searchParams.gosiType}
            />
          </Col>
          <Col flex="auto">
            <Input
              placeholder="사용자ID 또는 성적번호 검색"
              value={searchParams.keyword}
              onChange={(e) => setSearchParams((prev) => ({ ...prev, keyword: e.target.value }))}
              onPressEnter={() => setSearchParams((prev) => ({ ...prev, page: 0 }))}
              style={{ width: 250 }}
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

      <Card title={<span>성적 목록 (총 <strong>{data?.data?.totalElements || 0}</strong>건)</span>}>
        <Table
          columns={columns}
          dataSource={data?.data?.content || []}
          rowKey={(r) => `${r.gosiCd}-${r.rstNo}`}
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
