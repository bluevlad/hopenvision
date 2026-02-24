import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Table, Card, Input, Button, Space, Tag, Modal, Descriptions } from 'antd';
import { SearchOutlined, ReloadOutlined, EyeOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { gosiApi } from '../../api/gosiApi';
import type { GosiMemberResponse } from '../../types/gosi';

export default function GosiMemberList() {
  const [searchParams, setSearchParams] = useState({
    keyword: '',
    page: 0,
    size: 20,
  });
  const [detailModal, setDetailModal] = useState<GosiMemberResponse | null>(null);

  // 회원 목록
  const { data, isLoading } = useQuery({
    queryKey: ['gosi-members', searchParams],
    queryFn: () => gosiApi.getMemberList(searchParams),
  });

  const handleReset = () => {
    setSearchParams({ keyword: '', page: 0, size: 20 });
  };

  const columns: ColumnsType<GosiMemberResponse> = [
    { title: '사용자ID', dataIndex: 'userId', key: 'userId', width: 120 },
    { title: '이름', dataIndex: 'userNm', key: 'userNm', width: 120 },
    { title: '닉네임', dataIndex: 'userNicknm', key: 'userNicknm', width: 120 },
    { title: '직급', dataIndex: 'userPosition', key: 'userPosition', width: 100 },
    {
      title: '성별', dataIndex: 'sex', key: 'sex', width: 70, align: 'center',
      render: (v) => v === 'M' ? '남' : v === 'F' ? '여' : v || '-',
    },
    { title: '역할', dataIndex: 'userRole', key: 'userRole', width: 100 },
    {
      title: '포인트', dataIndex: 'userPoint', key: 'userPoint', width: 80, align: 'right',
      render: (v) => v != null ? v.toLocaleString() : '-',
    },
    {
      title: '사용', dataIndex: 'isuse', key: 'isuse', width: 70, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '사용' : '미사용'}</Tag>,
    },
    {
      title: '관리', key: 'action', width: 80, align: 'center',
      render: (_, record) => (
        <Button
          size="small"
          icon={<EyeOutlined />}
          onClick={() => setDetailModal(record)}
        >
          상세
        </Button>
      ),
    },
  ];

  return (
    <div>
      <Card style={{ marginBottom: 16 }}>
        <Space>
          <Input
            placeholder="사용자ID, 이름, 닉네임 검색"
            value={searchParams.keyword}
            onChange={(e) => setSearchParams((prev) => ({ ...prev, keyword: e.target.value }))}
            onPressEnter={() => setSearchParams((prev) => ({ ...prev, page: 0 }))}
            style={{ width: 300 }}
          />
          <Button icon={<SearchOutlined />} type="primary"
            onClick={() => setSearchParams((prev) => ({ ...prev, page: 0 }))}>
            검색
          </Button>
          <Button icon={<ReloadOutlined />} onClick={handleReset}>초기화</Button>
        </Space>
      </Card>

      <Card title={<span>회원 목록 (총 <strong>{data?.data?.totalElements || 0}</strong>건)</span>}>
        <Table
          columns={columns}
          dataSource={data?.data?.content || []}
          rowKey="userId"
          loading={isLoading}
          pagination={{
            current: searchParams.page + 1,
            pageSize: searchParams.size,
            total: data?.data?.totalElements || 0,
            showSizeChanger: true,
            showTotal: (total) => `총 ${total}건`,
            onChange: (page, pageSize) => {
              setSearchParams((prev) => ({ ...prev, page: page - 1, size: pageSize }));
            },
          }}
          size="small"
          scroll={{ x: 900 }}
        />
      </Card>

      <Modal
        title="회원 상세 정보"
        open={!!detailModal}
        onCancel={() => setDetailModal(null)}
        footer={null}
        width={600}
      >
        {detailModal && (
          <Descriptions column={2} size="small" bordered>
            <Descriptions.Item label="사용자ID">{detailModal.userId}</Descriptions.Item>
            <Descriptions.Item label="이름">{detailModal.userNm}</Descriptions.Item>
            <Descriptions.Item label="닉네임">{detailModal.userNicknm || '-'}</Descriptions.Item>
            <Descriptions.Item label="직급">{detailModal.userPosition || '-'}</Descriptions.Item>
            <Descriptions.Item label="성별">
              {detailModal.sex === 'M' ? '남' : detailModal.sex === 'F' ? '여' : detailModal.sex || '-'}
            </Descriptions.Item>
            <Descriptions.Item label="역할">{detailModal.userRole || '-'}</Descriptions.Item>
            <Descriptions.Item label="관리자역할">{detailModal.adminRole || '-'}</Descriptions.Item>
            <Descriptions.Item label="생년월일">{detailModal.birthDay?.substring(0, 10) || '-'}</Descriptions.Item>
            <Descriptions.Item label="카테고리">{detailModal.categoryCode || '-'}</Descriptions.Item>
            <Descriptions.Item label="포인트">{detailModal.userPoint?.toLocaleString() || '-'}</Descriptions.Item>
            <Descriptions.Item label="결제">{detailModal.payment?.toLocaleString() || '-'}</Descriptions.Item>
            <Descriptions.Item label="사용여부">
              <Tag color={detailModal.isuse === 'Y' ? 'green' : 'red'}>
                {detailModal.isuse === 'Y' ? '사용' : '미사용'}
              </Tag>
            </Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </div>
  );
}
