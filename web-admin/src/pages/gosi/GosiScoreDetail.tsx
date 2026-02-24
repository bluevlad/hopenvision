import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Card, Descriptions, Table, Tag, Button, Spin } from 'antd';
import { ArrowLeftOutlined } from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { gosiApi } from '../../api/gosiApi';
import type { GosiRstSbjResponse, GosiRstDetResponse } from '../../types/gosi';

export default function GosiScoreDetail() {
  const { gosiCd, rstNo } = useParams<{ gosiCd: string; rstNo: string }>();
  const navigate = useNavigate();

  const { data, isLoading } = useQuery({
    queryKey: ['gosi-result-detail', gosiCd, rstNo],
    queryFn: () => gosiApi.getResultDetail(gosiCd!, rstNo!),
    enabled: !!gosiCd && !!rstNo,
  });

  if (isLoading) return <Spin size="large" />;

  const detail = data?.data;
  if (!detail) return <div>데이터를 찾을 수 없습니다.</div>;

  const sbjColumns: ColumnsType<GosiRstSbjResponse> = [
    { title: '과목코드', dataIndex: 'subjectCd', key: 'subjectCd', width: 100 },
    { title: '과목명', dataIndex: 'subjectNm', key: 'subjectNm' },
    {
      title: '점수', dataIndex: 'score', key: 'score', width: 80, align: 'center',
      render: (v) => v != null ? `${v}` : '-',
    },
    {
      title: '정답수', dataIndex: 'correctCnt', key: 'correctCnt', width: 80, align: 'center',
      render: (v, r) => v != null ? `${v}/${r.totalCnt || 0}` : '-',
    },
  ];

  const detColumns: ColumnsType<GosiRstDetResponse> = [
    { title: '과목코드', dataIndex: 'subjectCd', key: 'subjectCd', width: 100 },
    { title: '문항번호', dataIndex: 'itemNo', key: 'itemNo', width: 90, align: 'center' },
    { title: '답안', dataIndex: 'answerData', key: 'answerData', width: 80, align: 'center' },
    {
      title: '정답여부', dataIndex: 'isCorrect', key: 'isCorrect', width: 90, align: 'center',
      render: (v) => <Tag color={v === 'Y' ? 'green' : 'red'}>{v === 'Y' ? '정답' : '오답'}</Tag>,
    },
  ];

  return (
    <div>
      <Button
        icon={<ArrowLeftOutlined />}
        onClick={() => navigate('/gosi/results')}
        style={{ marginBottom: 16 }}
      >
        목록으로
      </Button>

      <Card title="성적 기본 정보" style={{ marginBottom: 16 }}>
        <Descriptions column={3} size="small">
          <Descriptions.Item label="시험코드">{detail.master.gosiCd}</Descriptions.Item>
          <Descriptions.Item label="성적번호">{detail.master.rstNo}</Descriptions.Item>
          <Descriptions.Item label="사용자ID">{detail.master.userId}</Descriptions.Item>
          <Descriptions.Item label="시험유형">{detail.master.gosiType}</Descriptions.Item>
          <Descriptions.Item label="지역">{detail.master.gosiArea}</Descriptions.Item>
          <Descriptions.Item label="합격여부">
            <Tag color={detail.master.passYn === 'Y' ? 'green' : 'red'}>
              {detail.master.passYn === 'Y' ? '합격' : '불합격'}
            </Tag>
          </Descriptions.Item>
          <Descriptions.Item label="총점">{detail.master.totalScore}</Descriptions.Item>
          <Descriptions.Item label="평균">{detail.master.avgScore}</Descriptions.Item>
          <Descriptions.Item label="등록일">{detail.master.regDt?.substring(0, 16)}</Descriptions.Item>
        </Descriptions>
      </Card>

      <Card title={`과목별 성적 (${detail.subjects.length}건)`} style={{ marginBottom: 16 }}>
        <Table
          columns={sbjColumns}
          dataSource={detail.subjects}
          rowKey={(r) => `${r.gosiCd}-${r.rstNo}-${r.subjectCd}`}
          pagination={false}
          size="small"
        />
      </Card>

      <Card title={`답안 상세 (${detail.details.length}건)`}>
        <Table
          columns={detColumns}
          dataSource={detail.details}
          rowKey={(r) => `${r.gosiCd}-${r.rstNo}-${r.subjectCd}-${r.itemNo}`}
          pagination={{ pageSize: 50, showSizeChanger: true, showTotal: (t) => `총 ${t}건` }}
          size="small"
          scroll={{ x: 500 }}
        />
      </Card>
    </div>
  );
}
