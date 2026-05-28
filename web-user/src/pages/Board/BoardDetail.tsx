import { useMemo } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Card, Descriptions, Button, Space, Tag, Typography, Divider, Spin, Result, List } from 'antd';
import { ArrowLeftOutlined, PushpinFilled, EyeInvisibleOutlined } from '@ant-design/icons';
import DOMPurify from 'dompurify';
import dayjs from 'dayjs';
import { getBoard } from '../../api/boardApi';
import type { BoardReply } from '../../types/board';

const { Title, Text } = Typography;

function formatDate(iso: string | null): string {
  if (!iso) return '-';
  return dayjs(iso).format('YYYY-MM-DD HH:mm');
}

function SafeHtml({ html }: { html: string | null }) {
  const sanitized = useMemo(() => {
    if (!html) return '';
    return DOMPurify.sanitize(html, {
      USE_PROFILES: { html: true },
      FORBID_TAGS: ['script', 'style', 'iframe', 'object', 'embed', 'form'],
      FORBID_ATTR: ['onerror', 'onclick', 'onload', 'onmouseover'],
    });
  }, [html]);
  if (!sanitized) return <Text type="secondary">(내용 없음)</Text>;
  return <div className="board-content" dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

function ReplyCard({ reply }: { reply: BoardReply }) {
  return (
    <Card size="small" style={{ marginBottom: 8 }}>
      <Space direction="vertical" size={4} style={{ width: '100%' }}>
        <Space size={8} wrap>
          <Text strong>{reply.subject || '(답글)'}</Text>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {reply.author || '-'} · {formatDate(reply.regDt)}
          </Text>
        </Space>
        <SafeHtml html={reply.content} />
      </Space>
    </Card>
  );
}

export default function BoardDetail() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const boardId = Number(id);

  const { data, isLoading, isError } = useQuery({
    queryKey: ['board', boardId],
    queryFn: () => getBoard(boardId),
    enabled: Number.isFinite(boardId) && boardId > 0,
  });

  if (isLoading) {
    return (
      <Card>
        <div style={{ textAlign: 'center', padding: '60px 0' }}>
          <Spin size="large" />
        </div>
      </Card>
    );
  }

  if (isError || !data) {
    return (
      <Result
        status="404"
        title="게시글을 불러올 수 없습니다"
        subTitle="삭제되었거나 잘못된 주소일 수 있습니다."
        extra={
          <Button type="primary" onClick={() => navigate('/board')}>
            목록으로
          </Button>
        }
      />
    );
  }

  return (
    <Card>
      <Space direction="vertical" style={{ width: '100%' }} size="middle">
        <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/board')}>
          목록으로
        </Button>

        <div>
          <Space size={8} wrap style={{ marginBottom: 8 }}>
            {data.noticeTop && <Tag icon={<PushpinFilled />} color="red">공지</Tag>}
            {data.hidden && <Tag icon={<EyeInvisibleOutlined />}>비공개</Tag>}
            {data.legacySource && <Tag>{data.legacySource}</Tag>}
          </Space>
          <Title level={3} style={{ marginTop: 0, marginBottom: 12 }}>
            {data.subject || '(제목 없음)'}
          </Title>
          <Descriptions size="small" column={{ xs: 1, sm: 2, md: 4 }}>
            <Descriptions.Item label="작성자">{data.author || '-'}</Descriptions.Item>
            <Descriptions.Item label="등록일">{formatDate(data.regDt)}</Descriptions.Item>
            <Descriptions.Item label="수정일">{formatDate(data.updDt)}</Descriptions.Item>
            <Descriptions.Item label="조회">{(data.hits ?? 0).toLocaleString()}</Descriptions.Item>
          </Descriptions>
        </div>

        <Divider style={{ margin: '8px 0' }} />

        <SafeHtml html={data.content} />

        {data.answer && (
          <>
            <Divider titlePlacement="start">답변</Divider>
            <SafeHtml html={data.answer} />
          </>
        )}

        {data.replies.length > 0 && (
          <>
            <Divider titlePlacement="start">답글 ({data.replies.length})</Divider>
            <List
              dataSource={data.replies}
              renderItem={(reply) => <ReplyCard reply={reply} />}
              split={false}
            />
          </>
        )}
      </Space>
    </Card>
  );
}
