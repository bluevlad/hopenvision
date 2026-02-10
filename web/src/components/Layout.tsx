import { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { Layout as AntLayout, Menu, theme } from 'antd';
import {
  FileTextOutlined,
  UserOutlined,
  BarChartOutlined,
  SettingOutlined,
  FormOutlined,
  HistoryOutlined,
} from '@ant-design/icons';

const { Header, Sider, Content } = AntLayout;

const menuItems = [
  {
    key: '/user',
    icon: <FormOutlined />,
    label: '채점하기',
  },
  {
    key: '/user/history',
    icon: <HistoryOutlined />,
    label: '채점 이력',
  },
  {
    key: 'admin',
    icon: <SettingOutlined />,
    label: '관리자',
    children: [
      {
        key: '/exam',
        icon: <FileTextOutlined />,
        label: '시험 관리',
      },
      {
        key: '/applicant',
        icon: <UserOutlined />,
        label: '응시자 관리',
      },
      {
        key: '/statistics',
        icon: <BarChartOutlined />,
        label: '통계',
      },
    ],
  },
];

export default function Layout() {
  const [collapsed, setCollapsed] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();
  const { token } = theme.useToken();

  const handleMenuClick = ({ key }: { key: string }) => {
    navigate(key);
  };

  const getSelectedKey = () => {
    const path = location.pathname;
    if (path === '/user/history') return '/user/history';
    if (path.startsWith('/user')) return '/user';
    if (path.startsWith('/exam')) return '/exam';
    if (path.startsWith('/applicant')) return '/applicant';
    if (path.startsWith('/statistics')) return '/statistics';
    return '/user';
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
          <h2 style={{ margin: 0, fontSize: collapsed ? 14 : 18, color: token.colorPrimary }}>
            {collapsed ? 'HV' : 'Hopenvision'}
          </h2>
        </div>
        <Menu
          mode="inline"
          selectedKeys={[getSelectedKey()]}
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
          }}
        >
          <h3 style={{ margin: 0 }}>공무원 시험 채점 시스템</h3>
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
