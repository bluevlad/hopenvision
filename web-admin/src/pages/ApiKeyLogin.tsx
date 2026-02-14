import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Card, Form, Input, Button, Typography, message, Space } from 'antd';
import { LockOutlined } from '@ant-design/icons';
import { useAuth } from '../auth/useAuth';
import { adminClient } from '../api/adminClient';

const { Title, Text } = Typography;

export default function ApiKeyLogin() {
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (values: { apiKey: string }) => {
    setLoading(true);
    try {
      // API Key를 임시로 설정하고 verify 엔드포인트 호출
      await adminClient.post('/api/admin/verify', null, {
        headers: { 'X-Api-Key': values.apiKey },
      });
      login(values.apiKey);
      message.success('로그인 성공');
      navigate('/', { replace: true });
    } catch {
      message.error('API Key가 올바르지 않습니다.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      minHeight: '100vh',
      background: '#f0f2f5',
    }}>
      <Card style={{ width: 400, boxShadow: '0 2px 8px rgba(0,0,0,0.1)' }}>
        <Space direction="vertical" size="large" style={{ width: '100%', textAlign: 'center' }}>
          <div>
            <LockOutlined style={{ fontSize: 48, color: '#1890ff' }} />
            <Title level={3} style={{ margin: '16px 0 0' }}>HopenVision Admin</Title>
            <Text type="secondary">관리자 인증이 필요합니다</Text>
          </div>

          <Form onFinish={handleSubmit} layout="vertical" style={{ textAlign: 'left' }}>
            <Form.Item
              name="apiKey"
              label="API Key"
              rules={[{ required: true, message: 'API Key를 입력하세요' }]}
            >
              <Input.Password
                placeholder="API Key를 입력하세요"
                size="large"
                prefix={<LockOutlined />}
              />
            </Form.Item>
            <Form.Item>
              <Button type="primary" htmlType="submit" loading={loading} block size="large">
                로그인
              </Button>
            </Form.Item>
          </Form>
        </Space>
      </Card>
    </div>
  );
}
