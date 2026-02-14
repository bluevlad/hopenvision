import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Card, Table, Tag, Button, Spin, Empty, Typography } from 'antd';
import {
  TrophyOutlined,
  CloseCircleOutlined,
  EyeOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { getUserHistory } from '../api/userApi';
import type { HistoryItem } from '../types/user';
import dayjs from 'dayjs';

const { Title } = Typography;

const UserHistory: React.FC = () => {
  const navigate = useNavigate();

  const { data: history, isLoading } = useQuery({
    queryKey: ['userHistory'],
    queryFn: getUserHistory,
  });

  const columns: ColumnsType<HistoryItem> = [
    {
      title: '시험명',
      dataIndex: 'examNm',
      key: 'examNm',
      ellipsis: true,
    },
    {
      title: '시험코드',
      dataIndex: 'examCd',
      key: 'examCd',
      width: 150,
    },
    {
      title: '총점',
      dataIndex: 'totalScore',
      key: 'totalScore',
      width: 100,
      align: 'center',
      render: (value: number) => `${value}점`,
    },
    {
      title: '평균점수',
      dataIndex: 'avgScore',
      key: 'avgScore',
      width: 100,
      align: 'center',
      render: (value: number) => `${value}점`,
    },
    {
      title: '합격 여부',
      dataIndex: 'passYn',
      key: 'passYn',
      width: 120,
      align: 'center',
      render: (value: string) =>
        value === 'Y' ? (
          <Tag color="success" icon={<TrophyOutlined />}>합격</Tag>
        ) : (
          <Tag color="error" icon={<CloseCircleOutlined />}>불합격</Tag>
        ),
    },
    {
      title: '응시일',
      dataIndex: 'regDt',
      key: 'regDt',
      width: 160,
      render: (value: string) => value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '-',
    },
    {
      title: '',
      key: 'action',
      width: 120,
      align: 'center',
      render: (_: unknown, record: HistoryItem) => (
        <Button
          type="primary"
          size="small"
          icon={<EyeOutlined />}
          onClick={() => navigate(`/exams/${record.examCd}/result`)}
        >
          결과보기
        </Button>
      ),
    },
  ];

  if (isLoading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: 100 }}>
        <Spin size="large" />
      </div>
    );
  }

  return (
    <div>
      <Title level={4} style={{ marginBottom: 24 }}>채점 이력</Title>
      <Card>
        {history && history.length > 0 ? (
          <Table
            columns={columns}
            dataSource={history}
            rowKey="examCd"
            pagination={{ pageSize: 10 }}
          />
        ) : (
          <Empty description="채점 이력이 없습니다" />
        )}
      </Card>
    </div>
  );
};

export default UserHistory;
