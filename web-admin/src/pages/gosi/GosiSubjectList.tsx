import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Table, Card, Select, Row, Col, Input, Button, Space, Tag } from 'antd';
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { gosiApi } from '../../api/gosiApi';
import type { GosiSubjectResponse, GosiVodResponse } from '../../types/gosi';

export default function GosiSubjectList() {
  const [selectedType, setSelectedType] = useState<string>('');
  const [vodParams, setVodParams] = useState({
    gosiCd: '',
    keyword: '',
    page: 0,
    size: 20,
  });

  // 유형 목록
  const { data: typeData } = useQuery({
    queryKey: ['gosi-types'],
    queryFn: () => gosiApi.getTypeList(),
  });

  // 시험 목록
  const { data: examData } = useQuery({
    queryKey: ['gosi-exams'],
    queryFn: () => gosiApi.getExamList(),
  });

  // 과목 목록
  const { data: subjectData, isLoading: subjectLoading } = useQuery({
    queryKey: ['gosi-subjects', selectedType],
    queryFn: () => gosiApi.getSubjectList(selectedType || undefined),
  });

  // VOD 목록
  const { data: vodData, isLoading: vodLoading } = useQuery({
    queryKey: ['gosi-vods', vodParams],
    queryFn: () => gosiApi.getVodList(vodParams),
  });

  const subjectColumns: ColumnsType<GosiSubjectResponse> = [
    { title: '유형', dataIndex: 'gosiType', key: 'gosiType', width: 100 },
    { title: '과목코드', dataIndex: 'gosiSubjectCd', key: 'gosiSubjectCd', width: 120 },
    { title: '과목명', dataIndex: 'gosiSubjecNm', key: 'gosiSubjecNm' },
    {
      title: '사용', dataIndex: 'isuse', key: 'isuse', width: 70, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '사용' : '미사용'}</Tag>,
    },
    { title: '순서', dataIndex: 'pos', key: 'pos', width: 70, align: 'center' },
  ];

  const vodColumns: ColumnsType<GosiVodResponse> = [
    { title: '시험코드', dataIndex: 'gosiCd', key: 'gosiCd', width: 100 },
    { title: '과목', dataIndex: 'subjectNm', key: 'subjectNm', width: 120 },
    { title: '강사', dataIndex: 'prfNm', key: 'prfNm', width: 120 },
    { title: 'VOD명', dataIndex: 'vodNm', key: 'vodNm' },
    {
      title: 'URL', dataIndex: 'vodUrl', key: 'vodUrl', width: 200, ellipsis: true,
      render: (v) => v ? <a href={v} target="_blank" rel="noopener noreferrer">{v}</a> : '-',
    },
    {
      title: '사용', dataIndex: 'isuse', key: 'isuse', width: 70, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '사용' : '미사용'}</Tag>,
    },
  ];

  return (
    <div>
      <Card
        title={
          <Space>
            <span>과목 목록 ({subjectData?.data?.length || 0}건)</span>
            <Select
              placeholder="시험유형 필터"
              allowClear
              style={{ width: 160 }}
              value={selectedType || undefined}
              onChange={(v) => setSelectedType(v || '')}
              options={(typeData?.data || []).map((t) => ({
                value: t.gosiType,
                label: t.gosiTypeNm,
              }))}
            />
          </Space>
        }
        style={{ marginBottom: 16 }}
      >
        <Table
          columns={subjectColumns}
          dataSource={subjectData?.data || []}
          rowKey={(r) => `${r.gosiType}-${r.gosiSubjectCd}`}
          loading={subjectLoading}
          pagination={false}
          size="small"
          scroll={{ x: 600 }}
        />
      </Card>

      <Card title={<span>VOD 목록 (총 <strong>{vodData?.data?.totalElements || 0}</strong>건)</span>}>
        <Row gutter={[16, 16]} align="middle" style={{ marginBottom: 16 }}>
          <Col>
            <Select
              placeholder="시험 선택"
              allowClear
              style={{ width: 200 }}
              value={vodParams.gosiCd || undefined}
              onChange={(v) => setVodParams((prev) => ({ ...prev, gosiCd: v || '', page: 0 }))}
              options={(examData?.data || []).map((e) => ({
                value: e.gosiCd,
                label: e.gosiNm || e.gosiCd,
              }))}
            />
          </Col>
          <Col flex="auto">
            <Input
              placeholder="과목명, 강사명, VOD명 검색"
              value={vodParams.keyword}
              onChange={(e) => setVodParams((prev) => ({ ...prev, keyword: e.target.value }))}
              onPressEnter={() => setVodParams((prev) => ({ ...prev, page: 0 }))}
              style={{ width: 250 }}
            />
          </Col>
          <Col>
            <Space>
              <Button icon={<SearchOutlined />} type="primary"
                onClick={() => setVodParams((prev) => ({ ...prev, page: 0 }))}>
                검색
              </Button>
              <Button icon={<ReloadOutlined />}
                onClick={() => setVodParams({ gosiCd: '', keyword: '', page: 0, size: 20 })}>
                초기화
              </Button>
            </Space>
          </Col>
        </Row>
        <Table
          columns={vodColumns}
          dataSource={vodData?.data?.content || []}
          rowKey={(r) => `${r.gosiCd}-${r.prfId}-${r.idx}`}
          loading={vodLoading}
          pagination={{
            current: vodParams.page + 1,
            pageSize: vodParams.size,
            total: vodData?.data?.totalElements || 0,
            showSizeChanger: true,
            showTotal: (total) => `총 ${total}건`,
            onChange: (page, pageSize) => {
              setVodParams((prev) => ({ ...prev, page: page - 1, size: pageSize }));
            },
          }}
          size="small"
          scroll={{ x: 800 }}
        />
      </Card>
    </div>
  );
}
