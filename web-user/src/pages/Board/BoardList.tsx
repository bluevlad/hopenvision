import { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Card, Table, Input, Space, Tag, Typography, Empty } from 'antd';
import type { ColumnsType } from 'antd/es/table';
import { PushpinFilled, EyeInvisibleOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';
import { listBoards } from '../../api/boardApi';
import type { BoardListItem } from '../../types/board';

const { Title, Text } = Typography;
const PAGE_SIZE = 20;

function formatDate(iso: string | null): string {
  if (!iso) return '-';
  return dayjs(iso).format('YYYY-MM-DD HH:mm');
}

export default function BoardList() {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();

  const initialQ = searchParams.get('q') ?? '';
  const initialPage = Number(searchParams.get('page') ?? '1');

  const [q, setQ] = useState(initialQ);
  const [queryQ, setQueryQ] = useState(initialQ);
  const [page, setPage] = useState(Number.isFinite(initialPage) && initialPage > 0 ? initialPage : 1);

  const { data, isLoading } = useQuery({
    queryKey: ['boardList', queryQ, page],
    queryFn: () => listBoards({ q: queryQ || undefined, page: page - 1, size: PAGE_SIZE }),
  });

  const handleSearch = (value: string) => {
    setQueryQ(value);
    setPage(1);
    setSearchParams(value ? { q: value } : {});
  };

  const handlePageChange = (next: number) => {
    setPage(next);
    const params: Record<string, string> = {};
    if (queryQ) params.q = queryQ;
    params.page = String(next);
    setSearchParams(params);
  };

  const columns: ColumnsType<BoardListItem> = [
    {
      title: '번호',
      dataIndex: 'boardId',
      width: 90,
      align: 'center',
      render: (id: number, row) =>
        row.noticeTop ? <Tag icon={<PushpinFilled />} color="red">공지</Tag> : id,
    },
    {
      title: '제목',
      dataIndex: 'subject',
      ellipsis: true,
      render: (subject: string | null, row) => (
        <Space size={4}>
          {row.hidden && (
            <Tag icon={<EyeInvisibleOutlined />} color="default" style={{ marginRight: 0 }}>
              비공개
            </Tag>
          )}
          <Text strong={row.noticeTop}>{subject || '(제목 없음)'}</Text>
        </Space>
      ),
    },
    {
      title: '작성자',
      dataIndex: 'author',
      width: 140,
      ellipsis: true,
      render: (author: string | null) => author || '-',
    },
    {
      title: '등록일',
      dataIndex: 'regDt',
      width: 160,
      render: formatDate,
    },
    {
      title: '조회',
      dataIndex: 'hits',
      width: 90,
      align: 'right',
      render: (hits: number | null) => (hits ?? 0).toLocaleString(),
    },
    {
      title: '구분',
      dataIndex: 'legacySource',
      width: 130,
      render: (src: string | null) => (src ? <Tag>{src}</Tag> : '-'),
    },
  ];

  return (
    <Card>
      <Space direction="vertical" style={{ width: '100%' }} size="middle">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 12 }}>
          <Title level={3} style={{ margin: 0 }}>게시판</Title>
          <Input.Search
            placeholder="제목 검색"
            defaultValue={initialQ}
            onChange={(e) => setQ(e.target.value)}
            onSearch={handleSearch}
            value={q}
            allowClear
            style={{ maxWidth: 320 }}
          />
        </div>
        <Table<BoardListItem>
          rowKey="boardId"
          columns={columns}
          dataSource={data?.content ?? []}
          loading={isLoading}
          pagination={{
            current: page,
            pageSize: PAGE_SIZE,
            total: data?.totalElements ?? 0,
            showSizeChanger: false,
            showTotal: (total) => `총 ${total.toLocaleString()}건`,
            onChange: handlePageChange,
          }}
          locale={{ emptyText: <Empty description="검색 결과가 없습니다" /> }}
          onRow={(row) => ({
            onClick: () => navigate(`/board/${row.boardId}`),
            style: { cursor: 'pointer' },
          })}
        />
      </Space>
    </Card>
  );
}
