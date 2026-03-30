import { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { Layout as AntLayout, Menu, Button, Space, theme } from 'antd';
import {
  FileTextOutlined,
  UserOutlined,
  BarChartOutlined,
  LogoutOutlined,
  BookOutlined,
} from '@ant-design/icons';
import { useAuth } from '../auth/useAuth';

const { Header, Sider, Content } = AntLayout;

const menuItems = [
  {
    key: '/exams',
    icon: <FileTextOutlined />,
    label: '시험 관리',
  },
  {
    key: '/applicants',
    icon: <UserOutlined />,
    label: '응시자 관리',
  },
  {
    key: 'stats',
    icon: <BarChartOutlined />,
    label: '통계',
    children: [
      { key: '/statistics', label: '시험 통계' },
      { key: '/gosi/analytics', label: '성적 분석' },
    ],
  },
  {
    key: 'content',
    icon: <BookOutlined />,
    label: '콘텐츠 관리',
    children: [
      { key: '/subjects', label: '과목 관리' },
      { key: '/question-bank', label: '문제은행' },
      { key: '/question-bank/bulk-import', label: '문제 일괄등록' },
      { key: '/question-bank/csv-update', label: 'CSV 정답 업데이트' },
      { key: '/question-bank/excel-update', label: 'Excel 정답 업데이트' },
      { key: '/question-sets', label: '문제세트' },
    ],
  },
];

export default function AdminLayout() {
  const [collapsed, setCollapsed] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();
  const { token } = theme.useToken();
  const { logout, user } = useAuth();

  const handleMenuClick = ({ key }: { key: string }) => {
    navigate(key);
  };

  const getSelectedKey = () => {
    const path = location.pathname;
    if (path.startsWith('/subjects')) return '/subjects';
    if (path.startsWith('/question-bank/excel-update')) return '/question-bank/excel-update';
    if (path.startsWith('/question-bank/csv-update')) return '/question-bank/csv-update';
    if (path.startsWith('/question-bank/bulk-import')) return '/question-bank/bulk-import';
    if (path.startsWith('/question-bank')) return '/question-bank';
    if (path.startsWith('/question-sets')) return '/question-sets';
    if (path.startsWith('/gosi/analytics')) return '/gosi/analytics';
    if (path.startsWith('/exams')) return '/exams';
    if (path.startsWith('/applicants')) return '/applicants';
    if (path.startsWith('/statistics')) return '/statistics';
    return '/exams';
  };

  const getOpenKeys = () => {
    const path = location.pathname;
    if (path.startsWith('/question-sets')) return ['content'];
    if (path.startsWith('/question-bank')) return ['content'];
    if (path.startsWith('/subjects')) return ['content'];
    if (path.startsWith('/statistics') || path.startsWith('/gosi/analytics')) return ['stats'];
    return [];
  };

  const handleLogout = () => {
    logout();
    navigate('/login', { replace: true });
  };

  return (
    <AntLayout style={{ minHeight: '100vh' }}>
      <Sider
        collapsible
        collapsed={collapsed}
        onCollapse={setCollapsed}
        style={{ background: token.colorBgContainer }}
      >
        <div
          style={{
            height: 64,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            borderBottom: `1px solid ${token.colorBorderSecondary}`,
          }}
        >
          <h2 style={{ margin: 0, fontSize: collapsed ? 14 : 16, color: token.colorPrimary }}>
            {collapsed ? 'HV' : 'HV Admin'}
          </h2>
        </div>
        <Menu
          mode="inline"
          selectedKeys={[getSelectedKey()]}
          defaultOpenKeys={getOpenKeys()}
          items={menuItems}
          onClick={handleMenuClick}
          style={{ borderRight: 0 }}
        />
      </Sider>
      <AntLayout>
        <Header
          style={{
            padding: '0 24px',
            background: token.colorBgContainer,
            borderBottom: `1px solid ${token.colorBorderSecondary}`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <h3 style={{ margin: 0 }}>시험 관리 시스템</h3>
          <Space>
            {user && (
              <Space size="small">
                {user.picture && (
                  <img
                    src={user.picture}
                    alt={user.name}
                    style={{ width: 28, height: 28, borderRadius: '50%' }}
                    referrerPolicy="no-referrer"
                  />
                )}
                <span style={{ fontSize: 13, color: token.colorTextSecondary }}>
                  {user.name}
                </span>
              </Space>
            )}
            <Button icon={<LogoutOutlined />} onClick={handleLogout}>
              로그아웃
            </Button>
          </Space>
        </Header>
        <Content
          style={{
            margin: 24,
            padding: 24,
            background: token.colorBgContainer,
            borderRadius: token.borderRadiusLG,
            minHeight: 280,
          }}
        >
          <Outlet />
        </Content>
      </AntLayout>
    </AntLayout>
  );
}
