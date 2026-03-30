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
  FormOutlined,
} from '@ant-design/icons';
import { getAvailableExams } from '../api/userApi';
import type { UserExam } from '../types/user';
import { EXAM_TYPES } from '@hopenvision/shared';

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
      title: '과목 구성',
      key: 'subjects',
      width: 220,
      render: (_: unknown, record: UserExam) => {
        const mandatory = record.subjects.filter((s) => s.subjectType === 'M');
        const elective = record.subjects.filter((s) => s.subjectType === 'S');
        return (
          <Space direction="vertical" size={2}>
            <Text style={{ fontSize: 13 }}>
              <Tag color="blue" style={{ marginRight: 4 }}>필수</Tag>
              {mandatory.map((s) => s.subjectNm).join(', ')}
            </Text>
            {elective.length > 0 && (
              <Text type="secondary" style={{ fontSize: 12 }}>
                <Tag style={{ marginRight: 4 }}>선택</Tag>
                {elective.length}과목 중 2과목 선택
              </Text>
            )}
          </Space>
        );
      },
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
      width: 220,
      align: 'center' as const,
      render: (_: unknown, record: UserExam) => (
        <Space>
          {record.hasSubmitted ? (
            <Tooltip title="결과 보기">
              <Button
                type="primary"
                icon={<EyeOutlined />}
                onClick={() => navigate(`/exams/${record.examCd}/result`)}
              >
                결과
              </Button>
            </Tooltip>
          ) : (
            <>
              <Tooltip title="문제를 보면서 시간 제한 내 응시">
                <Button
                  type="primary"
                  icon={<FormOutlined />}
                  onClick={() => navigate(`/exams/${record.examCd}/mock`)}
                >
                  모의고사
                </Button>
              </Tooltip>
              <Tooltip title="답안 번호만 빠르게 입력하여 채점">
                <Button
                  icon={<EditOutlined />}
                  onClick={() => navigate(`/exams/${record.examCd}/answer`)}
                >
                  답안채점
                </Button>
              </Tooltip>
            </>
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
