import { useState, useCallback } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import { Layout as AntLayout, Menu, Button, Dropdown, Space, theme } from 'antd';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import {
  UserOutlined,
  FormOutlined,
  HistoryOutlined,
} from '@ant-design/icons';
import { getUserId, getMyProfile, hasProfile as checkHasProfile } from '../api/userApi';
import type { UserProfile } from '../types/user';
import UserProfileModal from './UserProfileModal';

const { Header, Sider, Content } = AntLayout;

const menuItems = [
  {
    key: '/',
    icon: <FormOutlined />,
    label: '채점하기',
  },
  {
    key: '/history',
    icon: <HistoryOutlined />,
    label: '채점 이력',
  },
];

export default function UserLayout() {
  const [collapsed, setCollapsed] = useState(false);
  const [manualModalOpen, setManualModalOpen] = useState(false);
  const [manualIsFirstTime, setManualIsFirstTime] = useState<boolean | null>(null);
  const [autoDismissed, setAutoDismissed] = useState(false);
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

  // 프로필이 없는 사용자에게 자동으로 모달을 표시 (파생 상태, useEffect 불필요)
  const autoPrompt = profileExists === false && userId !== 'guest' && !autoDismissed;
  const profileModalOpen = manualModalOpen || autoPrompt;
  const isFirstTime = manualIsFirstTime ?? autoPrompt;

  const handleMenuClick = ({ key }: { key: string }) => {
    navigate(key);
  };

  const getSelectedKey = () => {
    const path = location.pathname;
    if (path === '/history') return '/history';
    return '/';
  };

  const queryClient = useQueryClient();

  const openProfileModal = useCallback((firstTime: boolean) => {
    setManualIsFirstTime(firstTime);
    setManualModalOpen(true);
  }, []);

  const closeProfileModal = useCallback(() => {
    setManualModalOpen(false);
    setManualIsFirstTime(null);
    setAutoDismissed(true);
  }, []);

  const handleProfileSaved = useCallback((savedUserId: string) => {
    setCurrentUserId(savedUserId);
    setAutoDismissed(true);
    queryClient.invalidateQueries({ queryKey: ['userExams'] });
  }, [queryClient]);

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
        onClose={closeProfileModal}
        onSaved={handleProfileSaved}
        profile={profile ?? null}
        userId={userId}
        isFirstTime={isFirstTime}
      />
    </AntLayout>
  );
}
