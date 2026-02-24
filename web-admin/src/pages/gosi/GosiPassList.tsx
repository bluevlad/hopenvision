import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Table, Card, Select, Row, Col, Input, Button, Space, Tag } from 'antd';
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { gosiApi } from '../../api/gosiApi';
import type { GosiPassMstResponse, GosiPassStaResponse } from '../../types/gosi';

export default function GosiPassList() {
  const [searchParams, setSearchParams] = useState({
    gosiCd: '',
    subjectCd: '',
    examType: '',
    page: 0,
    size: 20,
  });

  // 시험 목록 (gosiCd 선택용)
  const { data: examData } = useQuery({
    queryKey: ['gosi-exams'],
    queryFn: () => gosiApi.getExamList(),
  });

  // 정답 목록
  const { data, isLoading } = useQuery({
    queryKey: ['gosi-pass', searchParams],
    queryFn: () => gosiApi.getPassList(searchParams),
    enabled: !!searchParams.gosiCd,
  });

  // 합격선
  const { data: staData } = useQuery({
    queryKey: ['gosi-pass-sta', searchParams.gosiCd],
    queryFn: () => gosiApi.getPassStaList(searchParams.gosiCd),
    enabled: !!searchParams.gosiCd,
  });

  const handleReset = () => {
    setSearchParams({ gosiCd: '', subjectCd: '', examType: '', page: 0, size: 20 });
  };

  const passColumns: ColumnsType<GosiPassMstResponse> = [
    { title: '과목코드', dataIndex: 'subjectCd', key: 'subjectCd', width: 100 },
    { title: '과목명', dataIndex: 'subjectNm', key: 'subjectNm', width: 150 },
    { title: '시험유형', dataIndex: 'examType', key: 'examType', width: 100 },
    { title: '문항번호', dataIndex: 'itemNo', key: 'itemNo', width: 90, align: 'center' },
    {
      title: '정답', dataIndex: 'answerData', key: 'answerData', width: 80, align: 'center',
      render: (v) => <Tag color="blue">{v}</Tag>,
    },
  ];

  const staColumns: ColumnsType<GosiPassStaResponse> = [
    { title: '시험유형', dataIndex: 'gosiType', key: 'gosiType', width: 100 },
    { title: '유형명', dataIndex: 'gosiTypeNm', key: 'gosiTypeNm' },
    {
      title: '합격점수', dataIndex: 'passScore', key: 'passScore', width: 100, align: 'center',
      render: (v) => v != null ? `${v}점` : '-',
    },
    {
      title: '사용', dataIndex: 'isuse', key: 'isuse', width: 70, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '사용' : '미사용'}</Tag>,
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
            <Input
              placeholder="과목코드"
              style={{ width: 120 }}
              value={searchParams.subjectCd}
              onChange={(e) => setSearchParams((prev) => ({ ...prev, subjectCd: e.target.value }))}
            />
          </Col>
          <Col>
            <Input
              placeholder="시험유형"
              style={{ width: 120 }}
              value={searchParams.examType}
              onChange={(e) => setSearchParams((prev) => ({ ...prev, examType: e.target.value }))}
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

      {searchParams.gosiCd && staData?.data && staData.data.length > 0 && (
        <Card title="합격선" style={{ marginBottom: 16 }}>
          <Table
            columns={staColumns}
            dataSource={staData.data}
            rowKey={(r) => `${r.gosiCd}-${r.gosiType}`}
            pagination={false}
            size="small"
          />
        </Card>
      )}

      <Card
        title={<span>정답 목록 (총 <strong>{data?.data?.totalElements || 0}</strong>건)</span>}
      >
        <Table
          columns={passColumns}
          dataSource={data?.data?.content || []}
          rowKey={(r) => `${r.gosiCd}-${r.subjectCd}-${r.examType}-${r.itemNo}`}
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
          scroll={{ x: 600 }}
        />
      </Card>
    </div>
  );
}
