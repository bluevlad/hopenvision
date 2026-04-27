import { useState, useEffect, useCallback, useRef } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Card, Form, Input, Button, Typography, message, Space, Divider, Alert, Spin } from 'antd';
import { LockOutlined, GoogleOutlined } from '@ant-design/icons';
import { useAuth } from '../auth/useAuth';
import { adminClient } from '../api/adminClient';

const { Title, Text } = Typography;

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID || '';

const errorMessages: Record<string, string> = {
  oauth_failed: 'Google 인증에 실패했습니다. 다시 시도해주세요.',
  unauthorized: '관리자 권한이 없는 계정입니다.',
  invalid_credential: '유효하지 않은 인증 정보입니다.',
};

export default function ApiKeyLogin() {
  const [loading, setLoading] = useState(false);
  const { loginWithGoogle, loginWithApiKey } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const error = searchParams.get('error');
  const googleButtonRef = useRef<HTMLDivElement>(null);
  const initializedRef = useRef(false);
  const [googleReady, setGoogleReady] = useState(false);

  const handleCredentialResponse = useCallback(
    async (response: { credential: string }) => {
      try {
        const res = await adminClient.post('/api/auth/google/verify', {
          idToken: response.credential,
        });

        const { data } = res.data;
        loginWithGoogle(data.token, {
          email: data.email,
          name: data.name,
          picture: data.picture,
        });
        message.success(`${data.name}님 환영합니다`);
        navigate('/', { replace: true });
      } catch (err: unknown) {
        const status = (err as { response?: { status?: number } })?.response?.status;
        if (status === 403) {
          navigate('/login?error=unauthorized', { replace: true });
        } else {
          navigate('/login?error=oauth_failed', { replace: true });
        }
      }
    },
    [loginWithGoogle, navigate],
  );

  useEffect(() => {
    if (initializedRef.current || !GOOGLE_CLIENT_ID) return;

    const initializeGoogle = () => {
      if (!window.google?.accounts?.id || !googleButtonRef.current) return;
      initializedRef.current = true;

      window.google.accounts.id.initialize({
        client_id: GOOGLE_CLIENT_ID,
        callback: handleCredentialResponse,
      });

      window.google.accounts.id.renderButton(googleButtonRef.current, {
        theme: 'outline',
        size: 'large',
        width: 352,
        text: 'signin_with',
        locale: 'ko',
      });

      setGoogleReady(true);
    };

    if (window.google?.accounts?.id) {
      initializeGoogle();
    } else {
      const script = document.createElement('script');
      script.src = 'https://accounts.google.com/gsi/client';
      script.async = true;
      script.defer = true;
      script.onload = initializeGoogle;
      document.head.appendChild(script);
    }
  }, [handleCredentialResponse]);

  const handleApiKeySubmit = async (values: { apiKey: string }) => {
    setLoading(true);
    try {
      await adminClient.post('/api/admin/verify', null, {
        headers: { 'X-Api-Key': values.apiKey },
      });
      loginWithApiKey(values.apiKey);
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
            <GoogleOutlined style={{ fontSize: 48, color: '#1890ff' }} />
            <Title level={3} style={{ margin: '16px 0 0' }}>HopenVision Admin</Title>
            <Text type="secondary">관리자 인증이 필요합니다</Text>
          </div>

          {error && (
            <Alert
              type="error"
              message={errorMessages[error] || '알 수 없는 오류가 발생했습니다.'}
              showIcon
            />
          )}

          {GOOGLE_CLIENT_ID && (
            <>
              {!googleReady && (
                <div style={{ display: 'flex', justifyContent: 'center', minHeight: 44, alignItems: 'center' }}>
                  <Spin size="small" />
                </div>
              )}
              <div
                ref={googleButtonRef}
                style={{
                  display: googleReady ? 'flex' : 'none',
                  justifyContent: 'center',
                  minHeight: 44,
                  alignItems: 'center',
                }}
              />

              <Divider plain>
                <Text type="secondary" style={{ fontSize: 12 }}>또는 API Key로 로그인</Text>
              </Divider>
            </>
          )}

          <Form onFinish={handleApiKeySubmit} layout="vertical" style={{ textAlign: 'left' }}>
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

declare global {
  interface Window {
    google?: {
      accounts: {
        id: {
          initialize: (config: {
            client_id: string;
            callback: (response: { credential: string }) => void;
          }) => void;
          renderButton: (
            element: HTMLElement,
            config: {
              theme?: string;
              size?: string;
              width?: number;
              text?: string;
              locale?: string;
            },
          ) => void;
        };
      };
    };
  }
}
