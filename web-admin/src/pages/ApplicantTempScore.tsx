import { useState, useEffect, useRef } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Card,
  Upload,
  Button,
  Table,
  Tag,
  Typography,
  Space,
  Alert,
  Progress,
  Row,
  Col,
  Select,
  message,
} from 'antd';
import {
  UploadOutlined,
  CheckCircleOutlined,
  CloseCircleOutlined,
  LoadingOutlined,
  FileTextOutlined,
  ThunderboltOutlined,
  ReloadOutlined,
} from '@ant-design/icons';
import type { UploadFile } from 'antd/es/upload';
import { examApi } from '../api/examApi';
import { applicantApi } from '../api/applicantApi';
import type { ImportJobResponse } from '../types/applicant';

const { Title, Text } = Typography;
const { Dragger } = Upload;

export default function ApplicantTempScore() {
  const [selectedExamCd, setSelectedExamCd] = useState<string | undefined>();
  const [file, setFile] = useState<File | null>(null);
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  const [uploading, setUploading] = useState(false);
  const [currentJob, setCurrentJob] = useState<ImportJobResponse | null>(null);
  const pollingRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const { data: examListData } = useQuery({
    queryKey: ['exams', { page: 0, size: 100 }],
    queryFn: () => examApi.getExamList({ page: 0, size: 100 }),
  });

  const { data: jobListData, refetch: refetchJobs } = useQuery({
    queryKey: ['import-jobs', selectedExamCd],
    queryFn: () => applicantApi.getJobList(selectedExamCd!),
    enabled: !!selectedExamCd,
  });

  const examList = examListData?.data?.content || [];
  const jobList = jobListData?.data || [];

  // 폴링: 처리 중인 Job 상태 추적
  useEffect(() => {
    if (currentJob && (currentJob.status === 'PENDING' || currentJob.status === 'PROCESSING')) {
      pollingRef.current = setInterval(async () => {
        try {
          const res = await applicantApi.getJobStatus(currentJob.jobId);
          if (res.success) {
            setCurrentJob(res.data);
            if (res.data.status === 'COMPLETED' || res.data.status === 'FAILED') {
              if (pollingRef.current) clearInterval(pollingRef.current);
              refetchJobs();
              if (res.data.status === 'COMPLETED') {
                message.success(`${res.data.successRows}건 등록 완료`);
              } else {
                message.error('처리 실패: ' + (res.data.errorMessage || ''));
              }
            }
          }
        } catch {
          // 폴링 에러 무시
        }
      }, 3000);
    }
    return () => {
      if (pollingRef.current) clearInterval(pollingRef.current);
    };
  }, [currentJob?.jobId, currentJob?.status]);

  const handleFileSelect = (info: { fileList: UploadFile[] }) => {
    const latestFile = info.fileList.slice(-1);
    setFileList(latestFile);
    if (latestFile.length > 0 && latestFile[0].originFileObj) {
      setFile(latestFile[0].originFileObj);
    } else {
      setFile(null);
    }
  };

  const handleUpload = async () => {
    if (!selectedExamCd) {
      message.warning('시험을 선택해주세요.');
      return;
    }
    if (!file) {
      message.warning('CSV 파일을 선택해주세요.');
      return;
    }
    setUploading(true);
    try {
      const res = await applicantApi.tempScoreUpload(selectedExamCd, file);
      if (res.success) {
        message.success('파일 업로드 완료. 백그라운드 처리를 시작합니다.');
        setCurrentJob({
          jobId: res.data.jobId,
          status: 'PENDING',
          fileName: res.data.fileName,
          totalRows: 0,
          processedRows: 0,
          successRows: 0,
          errorRows: 0,
        } as ImportJobResponse);
        setFile(null);
        setFileList([]);
        refetchJobs();
      } else {
        message.error(res.message || '업로드 실패');
      }
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : '업로드 중 오류 발생';
      message.error(errorMsg);
    } finally {
      setUploading(false);
    }
  };

  const statusTag = (status: string) => {
    switch (status) {
      case 'PENDING':
        return <Tag icon={<LoadingOutlined />} color="default">대기 중</Tag>;
      case 'PROCESSING':
        return <Tag icon={<LoadingOutlined />} color="processing">처리 중</Tag>;
      case 'COMPLETED':
        return <Tag icon={<CheckCircleOutlined />} color="success">완료</Tag>;
      case 'FAILED':
        return <Tag icon={<CloseCircleOutlined />} color="error">실패</Tag>;
      default:
        return <Tag>{status}</Tag>;
    }
  };

  const jobColumns = [
    {
      title: '상태',
      dataIndex: 'status',
      key: 'status',
      width: 100,
      render: (status: string) => statusTag(status),
    },
    {
      title: '파일명',
      dataIndex: 'fileName',
      key: 'fileName',
      ellipsis: true,
    },
    {
      title: '진행률',
      key: 'progress',
      width: 200,
      render: (_: unknown, record: ImportJobResponse) => {
        if (record.totalRows === 0) return '-';
        const pct = Math.round((record.processedRows / record.totalRows) * 100);
        return (
          <Progress
            percent={pct}
            size="small"
            status={record.status === 'FAILED' ? 'exception' : record.status === 'COMPLETED' ? 'success' : 'active'}
          />
        );
      },
    },
    {
      title: '성공/오류',
      key: 'result',
      width: 120,
      render: (_: unknown, record: ImportJobResponse) => (
        <Space size={4}>
          <Text type="success">{record.successRows}</Text>
          <Text>/</Text>
          <Text type="danger">{record.errorRows}</Text>
        </Space>
      ),
    },
    {
      title: '등록일시',
      dataIndex: 'regDt',
      key: 'regDt',
      width: 160,
      render: (val: string) => val ? new Date(val).toLocaleString('ko-KR') : '-',
    },
    {
      title: '결과',
      dataIndex: 'resultSummary',
      key: 'resultSummary',
      ellipsis: true,
    },
  ];

  const isProcessing = currentJob?.status === 'PENDING' || currentJob?.status === 'PROCESSING';

  return (
    <div>
      <Title level={4}>
        <ThunderboltOutlined style={{ marginRight: 8 }} />
        임시점수결과 등록
      </Title>

      <Card style={{ marginBottom: 16 }}>
        <Alert
          message="CSV 파일 형식 (점수 기반 무작위 답안 생성)"
          description={
            <div>
              <p style={{ margin: '4px 0' }}>
                헤더(첫 행): <strong>시험코드,과목명,이름,사용자ID,점수</strong>
              </p>
              <p style={{ margin: '4px 0' }}>
                예시: <code>2025-9LEVEL-R1,한국사,홍길동,hong123,60</code>
              </p>
              <p style={{ margin: '4px 0', color: '#faad14' }}>
                파일 업로드 후 백그라운드에서 비동기 처리됩니다. 동일 파일 중복 업로드는 자동 차단됩니다.
              </p>
            </div>
          }
          type="warning"
          showIcon
          style={{ marginBottom: 16 }}
        />

        <Row gutter={16} style={{ marginBottom: 16 }}>
          <Col span={12}>
            <Select
              placeholder="시험 선택"
              style={{ width: '100%' }}
              value={selectedExamCd}
              onChange={setSelectedExamCd}
              showSearch
              filterOption={(input, option) =>
                (option?.label as string)?.toLowerCase().includes(input.toLowerCase()) ?? false
              }
              options={examList.map((exam) => ({
                value: exam.examCd,
                label: `${exam.examNm} (${exam.examCd})`,
              }))}
            />
          </Col>
        </Row>

        <Dragger
          accept=".csv"
          fileList={fileList}
          onChange={handleFileSelect}
          beforeUpload={() => false}
          maxCount={1}
          disabled={isProcessing}
        >
          <p className="ant-upload-drag-icon">
            <FileTextOutlined />
          </p>
          <p className="ant-upload-text">CSV 파일을 드래그하거나 클릭하여 선택</p>
          <p className="ant-upload-hint">.csv 파일만 지원 (UTF-8 / EUC-KR)</p>
        </Dragger>
        <div style={{ marginTop: 16, textAlign: 'right' }}>
          <Button
            type="primary"
            icon={<UploadOutlined />}
            onClick={handleUpload}
            loading={uploading}
            disabled={!file || !selectedExamCd || isProcessing}
          >
            업로드 및 처리 시작
          </Button>
        </div>
      </Card>

      {/* 현재 처리 중인 Job */}
      {currentJob && isProcessing && (
        <Card title="처리 진행 중" style={{ marginBottom: 16 }}>
          <Row gutter={16} align="middle">
            <Col span={4}>
              {statusTag(currentJob.status)}
            </Col>
            <Col span={12}>
              <Progress
                percent={currentJob.totalRows > 0
                  ? Math.round((currentJob.processedRows / currentJob.totalRows) * 100)
                  : 0}
                status="active"
              />
            </Col>
            <Col span={8}>
              <Text>
                {currentJob.processedRows} / {currentJob.totalRows}건 처리
                (성공: {currentJob.successRows}, 오류: {currentJob.errorRows})
              </Text>
            </Col>
          </Row>
        </Card>
      )}

      {/* Job 히스토리 */}
      {selectedExamCd && (
        <Card
          title="처리 이력"
          extra={
            <Button icon={<ReloadOutlined />} onClick={() => refetchJobs()}>
              새로고침
            </Button>
          }
        >
          <Table
            columns={jobColumns}
            dataSource={jobList}
            rowKey="jobId"
            size="small"
            pagination={{ pageSize: 10, showTotal: (t) => `총 ${t}건` }}
          />
        </Card>
      )}
    </div>
  );
}
