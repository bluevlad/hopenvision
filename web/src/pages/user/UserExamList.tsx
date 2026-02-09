import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Card,
  Table,
  Button,
  Space,
  Tag,
  Input,
  Modal,
  Form,
  Typography,
  message,
  Tooltip,
} from 'antd';
import {
  EditOutlined,
  EyeOutlined,
  UserOutlined,
  TrophyOutlined,
} from '@ant-design/icons';
import { getAvailableExams, setUserId } from '../../api/userApi';
import type { UserExam } from '../../types/user';
import { EXAM_TYPES } from '../../types/exam';

const { Title, Text } = Typography;

const UserExamList: React.FC = () => {
  const navigate = useNavigate();
  const [userIdModalVisible, setUserIdModalVisible] = useState(false);
  const [form] = Form.useForm();

  const currentUserId = localStorage.getItem('userId') || 'guest';

  const { data: exams, isLoading, refetch } = useQuery({
    queryKey: ['userExams'],
    queryFn: getAvailableExams,
  });

  const handleUserIdChange = () => {
    form.validateFields().then((values) => {
      setUserId(values.userId);
      message.success(`사용자 ID가 ${values.userId}로 변경되었습니다.`);
      setUserIdModalVisible(false);
      refetch();
    });
  };

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
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 16 }}>
          <Title level={4} style={{ margin: 0 }}>채점 가능한 시험 목록</Title>
          <Space>
            <Text type="secondary">현재 사용자:</Text>
            <Tag color="blue" style={{ cursor: 'pointer' }} onClick={() => {
              form.setFieldsValue({ userId: currentUserId });
              setUserIdModalVisible(true);
            }}>
              {currentUserId}
            </Tag>
            <Button onClick={() => {
              form.setFieldsValue({ userId: currentUserId });
              setUserIdModalVisible(true);
            }}>
              변경
            </Button>
          </Space>
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

      <Modal
        title="사용자 ID 설정"
        open={userIdModalVisible}
        onOk={handleUserIdChange}
        onCancel={() => setUserIdModalVisible(false)}
        okText="변경"
        cancelText="취소"
      >
        <Form form={form} layout="vertical">
          <Form.Item
            name="userId"
            label="사용자 ID"
            rules={[{ required: true, message: '사용자 ID를 입력하세요' }]}
          >
            <Input placeholder="사용자 ID를 입력하세요" />
          </Form.Item>
        </Form>
        <Text type="secondary">
          * 실제 서비스에서는 로그인 기능으로 대체됩니다.
        </Text>
      </Modal>
    </div>
  );
};

export default UserExamList;
