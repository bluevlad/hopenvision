import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Card,
  Table,
  Button,
  Space,
  Tag,
  Typography,
  Tooltip,
} from 'antd';
import {
  EditOutlined,
  EyeOutlined,
  UserOutlined,
  TrophyOutlined,
} from '@ant-design/icons';
import { getAvailableExams } from '../../api/userApi';
import type { UserExam } from '../../types/user';
import { EXAM_TYPES } from '../../types/exam';

const { Title, Text } = Typography;

const UserExamList: React.FC = () => {
  const navigate = useNavigate();

  const { data: exams, isLoading } = useQuery({
    queryKey: ['userExams'],
    queryFn: getAvailableExams,
  });

  const getExamTypeLabel = (type: string) => {
    return EXAM_TYPES.find((t) => t.value === type)?.label || type;
  };

  const columns = [
    {
      title: '시험명',
      dataIndex: 'examNm',
      key: 'examNm',
      render: (text: string, record: UserExam) => (
        <Space direction="vertical" size={0}>
          <Text strong>{text}</Text>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {record.examCd}
          </Text>
        </Space>
      ),
    },
    {
      title: '시험유형',
      dataIndex: 'examType',
      key: 'examType',
      width: 120,
      render: (type: string) => (
        <Tag color="blue">{getExamTypeLabel(type)}</Tag>
      ),
    },
    {
      title: '시험일',
      key: 'examInfo',
      width: 150,
      render: (_: unknown, record: UserExam) => (
        <Space direction="vertical" size={0}>
          <Text>{record.examYear}년 {record.examRound}회</Text>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {record.examDate}
          </Text>
        </Space>
      ),
    },
    {
      title: '과목수',
      key: 'subjects',
      width: 80,
      align: 'center' as const,
      render: (_: unknown, record: UserExam) => (
        <Text>{record.subjects.length}과목</Text>
      ),
    },
    {
      title: '응시자수',
      dataIndex: 'applicantCount',
      key: 'applicantCount',
      width: 100,
      align: 'center' as const,
      render: (count: number) => (
        <Space>
          <UserOutlined />
          <Text>{count}명</Text>
        </Space>
      ),
    },
    {
      title: '상태',
      key: 'status',
      width: 100,
      align: 'center' as const,
      render: (_: unknown, record: UserExam) => (
        record.hasSubmitted ? (
          <Tag color="green" icon={<TrophyOutlined />}>채점완료</Tag>
        ) : (
          <Tag color="default">미응시</Tag>
        )
      ),
    },
    {
      title: '작업',
      key: 'action',
      width: 150,
      align: 'center' as const,
      render: (_: unknown, record: UserExam) => (
        <Space>
          {record.hasSubmitted ? (
            <Tooltip title="결과 보기">
              <Button
                type="primary"
                icon={<EyeOutlined />}
                onClick={() => navigate(`/user/exams/${record.examCd}/result`)}
              >
                결과
              </Button>
            </Tooltip>
          ) : (
            <Tooltip title="답안 입력">
              <Button
                type="primary"
                icon={<EditOutlined />}
                onClick={() => navigate(`/user/exams/${record.examCd}/answer`)}
              >
                응시
              </Button>
            </Tooltip>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div style={{ padding: 24 }}>
      <Card>
        <div style={{ marginBottom: 16 }}>
          <Title level={4} style={{ margin: 0 }}>채점 가능한 시험 목록</Title>
        </div>

        <Table
          columns={columns}
          dataSource={exams}
          rowKey="examCd"
          loading={isLoading}
          pagination={{
            showSizeChanger: true,
            showQuickJumper: true,
            showTotal: (total) => `총 ${total}개`,
          }}
        />
      </Card>
    </div>
  );
};

export default UserExamList;
