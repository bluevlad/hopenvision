import { useState, useEffect } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { Layout as AntLayout, Menu, Button, Dropdown, Space, theme } from 'antd';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import {
  FileTextOutlined,
  UserOutlined,
  BarChartOutlined,
  SettingOutlined,
  FormOutlined,
  HistoryOutlined,
} from '@ant-design/icons';
import { getUserId, getMyProfile, hasProfile as checkHasProfile } from '../api/userApi';
import type { UserProfile } from '../types/user';
import UserProfileModal from './UserProfileModal';

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
  const [profileModalOpen, setProfileModalOpen] = useState(false);
  const [isFirstTime, setIsFirstTime] = useState(false);
  const [userId, setCurrentUserId] = useState(getUserId);
  const navigate = useNavigate();
  const location = useLocation();
  const { token } = theme.useToken();

  const { data: profileExists } = useQuery({
    queryKey: ['userProfileExists', userId],
    queryFn: checkHasProfile,
    enabled: userId !== 'guest',
  });

  const { data: profile } = useQuery<UserProfile | null>({
    queryKey: ['userProfile', userId],
    queryFn: getMyProfile,
    enabled: userId !== 'guest' && profileExists === true,
  });

  useEffect(() => {
    if (profileExists === false && userId !== 'guest') {
      setIsFirstTime(true);
      setProfileModalOpen(true);
    }
  }, [profileExists, userId]);

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

  const queryClient = useQueryClient();

  const openProfileModal = (firstTime: boolean) => {
    setIsFirstTime(firstTime);
    setProfileModalOpen(true);
  };

  const handleProfileSaved = (savedUserId: string) => {
    setCurrentUserId(savedUserId);
    queryClient.invalidateQueries({ queryKey: ['userExams'] });
  };

  const displayName = profile?.userNm || userId;

  const dropdownItems = {
    items: [
      {
        key: 'edit-profile',
        label: '프로필 수정',
        onClick: () => openProfileModal(false),
      },
    ],
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
            justifyContent: 'space-between',
          }}
        >
          <h3 style={{ margin: 0 }}>공무원 시험 채점 시스템</h3>
          <Space>
            {profile ? (
              <Dropdown menu={dropdownItems} placement="bottomRight">
                <Button icon={<UserOutlined />}>{displayName}</Button>
              </Dropdown>
            ) : (
              <Button
                icon={<UserOutlined />}
                onClick={() => openProfileModal(!profileExists)}
              >
                {userId}
              </Button>
            )}
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

      <UserProfileModal
        open={profileModalOpen}
        onClose={() => setProfileModalOpen(false)}
        onSaved={handleProfileSaved}
        profile={profile ?? null}
        userId={userId}
        isFirstTime={isFirstTime}
      />
    </AntLayout>
  );
}
