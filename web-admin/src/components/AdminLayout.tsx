import { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { Layout as AntLayout, Menu, Button, Space, theme } from 'antd';
import {
  FileTextOutlined,
  UserOutlined,
  BarChartOutlined,
  LogoutOutlined,
  TrophyOutlined,
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
    key: '/statistics',
    icon: <BarChartOutlined />,
    label: '통계',
  },
  {
    key: 'gosi',
    icon: <TrophyOutlined />,
    label: '합격예측',
    children: [
      { key: '/gosi/exams', label: '시험/지역 관리' },
      { key: '/gosi/pass', label: '정답 관리' },
      { key: '/gosi/results', label: '성적 관리' },
      { key: '/gosi/statistics', label: '통계' },
      { key: '/gosi/subjects', label: '과목/VOD' },
      { key: '/gosi/members', label: '회원 관리' },
    ],
  },
];

export default function AdminLayout() {
  const [collapsed, setCollapsed] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();
  const { token } = theme.useToken();
  const { logout } = useAuth();

  const handleMenuClick = ({ key }: { key: string }) => {
    navigate(key);
  };

  const getSelectedKey = () => {
    const path = location.pathname;
    if (path.startsWith('/gosi/exams')) return '/gosi/exams';
    if (path.startsWith('/gosi/pass')) return '/gosi/pass';
    if (path.startsWith('/gosi/results')) return '/gosi/results';
    if (path.startsWith('/gosi/statistics')) return '/gosi/statistics';
    if (path.startsWith('/gosi/subjects')) return '/gosi/subjects';
    if (path.startsWith('/gosi/members')) return '/gosi/members';
    if (path.startsWith('/exams')) return '/exams';
    if (path.startsWith('/applicants')) return '/applicants';
    if (path.startsWith('/statistics')) return '/statistics';
    return '/exams';
  };

  const getOpenKeys = () => {
    const path = location.pathname;
    if (path.startsWith('/gosi')) return ['gosi'];
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
