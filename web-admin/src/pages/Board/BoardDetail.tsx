import { useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Card, Descriptions, Button, Space, Tag, Typography, Divider, Spin, Result, List, Switch } from 'antd';
import { ArrowLeftOutlined, PushpinFilled, EyeInvisibleOutlined } from '@ant-design/icons';
import DOMPurify from 'dompurify';
import dayjs from 'dayjs';
import { boardApi } from '../../api/boardApi';
import type { BoardReply } from '../../types/board';

const { Title, Text, Paragraph } = Typography;

function formatDate(iso: string | null): string {
  if (!iso) return '-';
  return dayjs(iso).format('YYYY-MM-DD HH:mm:ss');
}

function sanitize(html: string | null): string {
  if (!html) return '';
  return DOMPurify.sanitize(html, {
    USE_PROFILES: { html: true },
    FORBID_TAGS: ['script', 'style', 'iframe', 'object', 'embed', 'form'],
    FORBID_ATTR: ['onerror', 'onclick', 'onload', 'onmouseover'],
  });
}

function HtmlBody({ html }: { html: string | null }) {
  const sanitized = useMemo(() => sanitize(html), [html]);
  if (!sanitized) return <Text type="secondary">(내용 없음)</Text>;
  return <div className="board-content" dangerouslySetInnerHTML={{ __html: sanitized }} />;
}

function RawBody({ html }: { html: string | null }) {
  if (!html) return <Text type="secondary">(내용 없음)</Text>;
  return (
    <Paragraph>
      <pre style={{ whiteSpace: 'pre-wrap', wordBreak: 'break-word', background: '#fafafa', padding: 12, borderRadius: 4, fontSize: 12, margin: 0 }}>
        {html}
      </pre>
    </Paragraph>
  );
}

function ReplyCard({ reply, showRaw }: { reply: BoardReply; showRaw: boolean }) {
  return (
    <Card size="small" style={{ marginBottom: 8 }}>
      <Space direction="vertical" size={4} style={{ width: '100%' }}>
        <Space size={8} wrap>
          <Tag>#{reply.boardId}</Tag>
          <Text strong>{reply.subject || '(답글)'}</Text>
          <Text type="secondary" style={{ fontSize: 12 }}>
            {reply.author || '-'} · {formatDate(reply.regDt)}
          </Text>
        </Space>
        {showRaw ? <RawBody html={reply.content} /> : <HtmlBody html={reply.content} />}
      </Space>
    </Card>
  );
}

export default function BoardDetail() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const boardId = Number(id);
  const [showRaw, setShowRaw] = useState(false);

  const { data, isLoading, isError } = useQuery({
    queryKey: ['adminBoard', boardId],
    queryFn: () => boardApi.get(boardId),
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

  const subjectByteLength = data.subject ? new Blob([data.subject]).size : 0;
  const contentByteLength = data.content ? new Blob([data.content]).size : 0;

  return (
    <Card>
      <Space direction="vertical" style={{ width: '100%' }} size="middle">
        <div style={{ display: 'flex', justifyContent: 'space-between', flexWrap: 'wrap', gap: 8 }}>
          <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/board')}>
            목록으로
          </Button>
          <Space>
            <Text type="secondary">원본(raw) 보기</Text>
            <Switch checked={showRaw} onChange={setShowRaw} />
          </Space>
        </div>

        <div>
          <Space size={8} wrap style={{ marginBottom: 8 }}>
            <Tag>ID #{data.boardId}</Tag>
            {data.noticeTop && <Tag icon={<PushpinFilled />} color="red">공지</Tag>}
            {data.hidden && <Tag icon={<EyeInvisibleOutlined />}>비공개</Tag>}
            {data.legacySource && (
              <Tag color={data.legacySource === 'WILLBES_GOSI' ? 'blue' : 'green'}>
                {data.legacySource}
              </Tag>
            )}
          </Space>
          <Title level={3} style={{ marginTop: 0, marginBottom: 12 }}>
            {data.subject || '(제목 없음)'}
          </Title>
          <Descriptions size="small" column={{ xs: 1, sm: 2, md: 4 }}>
            <Descriptions.Item label="작성자">{data.author || '-'}</Descriptions.Item>
            <Descriptions.Item label="등록일">{formatDate(data.regDt)}</Descriptions.Item>
            <Descriptions.Item label="수정일">{formatDate(data.updDt)}</Descriptions.Item>
            <Descriptions.Item label="조회">{(data.hits ?? 0).toLocaleString()}</Descriptions.Item>
            <Descriptions.Item label="제목 바이트">{subjectByteLength.toLocaleString()} B</Descriptions.Item>
            <Descriptions.Item label="본문 바이트">{contentByteLength.toLocaleString()} B</Descriptions.Item>
            <Descriptions.Item label="답글 수">{data.replies.length}</Descriptions.Item>
            <Descriptions.Item label="답변 유무">{data.answer ? '있음' : '없음'}</Descriptions.Item>
          </Descriptions>
        </div>

        <Divider style={{ margin: '8px 0' }} />

        <div>
          <Text type="secondary" style={{ fontSize: 12 }}>본문</Text>
          {showRaw ? <RawBody html={data.content} /> : <HtmlBody html={data.content} />}
        </div>

        {data.answer && (
          <>
            <Divider titlePlacement="start">답변</Divider>
            {showRaw ? <RawBody html={data.answer} /> : <HtmlBody html={data.answer} />}
          </>
        )}

        {data.replies.length > 0 && (
          <>
            <Divider titlePlacement="start">답글 ({data.replies.length})</Divider>
            <List
              dataSource={data.replies}
              renderItem={(reply) => <ReplyCard reply={reply} showRaw={showRaw} />}
              split={false}
            />
          </>
        )}
      </Space>
    </Card>
  );
}
