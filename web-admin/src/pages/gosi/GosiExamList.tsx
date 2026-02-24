import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Table, Card, Tag, Select, Space, Descriptions } from 'antd';
import type { ColumnsType } from 'antd/es/table';
import { gosiApi } from '../../api/gosiApi';
import type { GosiMstResponse, GosiCodResponse, GosiAreaResponse } from '../../types/gosi';

export default function GosiExamList() {
  const [selectedType, setSelectedType] = useState<string>('');

  // 시험 목록
  const { data: examData, isLoading: examLoading } = useQuery({
    queryKey: ['gosi-exams'],
    queryFn: () => gosiApi.getExamList(),
  });

  // 시험 유형 목록
  const { data: typeData } = useQuery({
    queryKey: ['gosi-types'],
    queryFn: () => gosiApi.getTypeList(),
  });

  // 지역 목록
  const { data: areaData, isLoading: areaLoading } = useQuery({
    queryKey: ['gosi-areas', selectedType],
    queryFn: () => gosiApi.getAreaList(selectedType || undefined),
  });

  const examColumns: ColumnsType<GosiMstResponse> = [
    { title: '시험코드', dataIndex: 'gosiCd', key: 'gosiCd', width: 120 },
    { title: '시험명', dataIndex: 'gosiNm', key: 'gosiNm' },
    { title: '시험유형', dataIndex: 'gosiType', key: 'gosiType', width: 100 },
    { title: '년도', dataIndex: 'gosiYear', key: 'gosiYear', width: 80 },
    { title: '회차', dataIndex: 'gosiRound', key: 'gosiRound', width: 80 },
    {
      title: '총점', dataIndex: 'totalScore', key: 'totalScore', width: 80, align: 'center',
      render: (v) => v != null ? `${v}점` : '-',
    },
    {
      title: '합격점', dataIndex: 'passScore', key: 'passScore', width: 80, align: 'center',
      render: (v) => v != null ? `${v}점` : '-',
    },
    {
      title: '사용', dataIndex: 'isuse', key: 'isuse', width: 70, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '사용' : '미사용'}</Tag>,
    },
    {
      title: '시작일', dataIndex: 'startDt', key: 'startDt', width: 150,
      render: (v) => v?.substring(0, 16),
    },
  ];

  const typeColumns: ColumnsType<GosiCodResponse> = [
    { title: '유형코드', dataIndex: 'gosiType', key: 'gosiType', width: 120 },
    { title: '유형명', dataIndex: 'gosiTypeNm', key: 'gosiTypeNm' },
    {
      title: '사용', dataIndex: 'isuse', key: 'isuse', width: 70, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '사용' : '미사용'}</Tag>,
    },
    { title: '순서', dataIndex: 'pos', key: 'pos', width: 70, align: 'center' },
  ];

  const areaColumns: ColumnsType<GosiAreaResponse> = [
    { title: '유형', dataIndex: 'gosiType', key: 'gosiType', width: 100 },
    { title: '지역코드', dataIndex: 'gosiArea', key: 'gosiArea', width: 120 },
    { title: '지역명', dataIndex: 'gosiAreaNm', key: 'gosiAreaNm' },
    {
      title: '사용', dataIndex: 'isuse', key: 'isuse', width: 70, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '사용' : '미사용'}</Tag>,
    },
    { title: '순서', dataIndex: 'pos', key: 'pos', width: 70, align: 'center' },
  ];

  const exams = examData?.data || [];
  const exam = exams.length > 0 ? exams[0] : null;

  return (
    <div>
      {exam && (
        <Card title="시험 정보" style={{ marginBottom: 16 }}>
          <Descriptions column={3} size="small">
            <Descriptions.Item label="시험코드">{exam.gosiCd}</Descriptions.Item>
            <Descriptions.Item label="시험명">{exam.gosiNm}</Descriptions.Item>
            <Descriptions.Item label="시험유형">{exam.gosiType}</Descriptions.Item>
            <Descriptions.Item label="년도/회차">{exam.gosiYear} / {exam.gosiRound}</Descriptions.Item>
            <Descriptions.Item label="총점">{exam.totalScore}점</Descriptions.Item>
            <Descriptions.Item label="합격점">{exam.passScore}점</Descriptions.Item>
          </Descriptions>
        </Card>
      )}

      <Card
        title={`시험 목록 (${exams.length}건)`}
        style={{ marginBottom: 16 }}
      >
        <Table
          columns={examColumns}
          dataSource={exams}
          rowKey="gosiCd"
          loading={examLoading}
          pagination={false}
          size="small"
          scroll={{ x: 1000 }}
        />
      </Card>

      <Card
        title={`시험 유형 (${typeData?.data?.length || 0}건)`}
        style={{ marginBottom: 16 }}
      >
        <Table
          columns={typeColumns}
          dataSource={typeData?.data || []}
          rowKey="gosiType"
          pagination={false}
          size="small"
        />
      </Card>

      <Card
        title={
          <Space>
            <span>지역 목록 ({areaData?.data?.length || 0}건)</span>
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
      >
        <Table
          columns={areaColumns}
          dataSource={areaData?.data || []}
          rowKey={(r) => `${r.gosiType}-${r.gosiArea}`}
          loading={areaLoading}
          pagination={false}
          size="small"
          scroll={{ x: 600 }}
        />
      </Card>
    </div>
  );
}
