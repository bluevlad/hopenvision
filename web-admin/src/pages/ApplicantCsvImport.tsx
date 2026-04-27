import { useState } from 'react';
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
  Statistic,
  Row,
  Col,
  Steps,
  Result,
  Select,
  message,
} from 'antd';
import {
  UploadOutlined,
  CheckCircleOutlined,
  WarningOutlined,
  CloseCircleOutlined,
  FileTextOutlined,
} from '@ant-design/icons';
import type { UploadFile } from 'antd/es/upload';
import { examApi } from '../api/examApi';
import { applicantApi } from '../api/applicantApi';
import type { CsvResultImportResult, CsvResultRow } from '../types/applicant';

const { Title, Text } = Typography;
const { Dragger } = Upload;

export default function ApplicantCsvImport() {
  const [currentStep, setCurrentStep] = useState(0);
  const [selectedExamCd, setSelectedExamCd] = useState<string | undefined>();
  const [file, setFile] = useState<File | null>(null);
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  const [previewResult, setPreviewResult] = useState<CsvResultImportResult | null>(null);
  const [applyResult, setApplyResult] = useState<CsvResultImportResult | null>(null);
  const [loading, setLoading] = useState(false);

  const { data: examListData } = useQuery({
    queryKey: ['exams', { page: 0, size: 100 }],
    queryFn: () => examApi.getExamList({ page: 0, size: 100 }),
  });

  const examList = examListData?.data?.content || [];

  const handleFileSelect = (info: { fileList: UploadFile[] }) => {
    const latestFile = info.fileList.slice(-1);
    setFileList(latestFile);
    if (latestFile.length > 0 && latestFile[0].originFileObj) {
      setFile(latestFile[0].originFileObj);
    } else {
      setFile(null);
    }
  };

  const handlePreview = async () => {
    if (!selectedExamCd) {
      message.warning('시험을 선택해주세요.');
      return;
    }
    if (!file) {
      message.warning('CSV 파일을 선택해주세요.');
      return;
    }
    setLoading(true);
    try {
      const res = await applicantApi.csvResultPreview(selectedExamCd, file);
      if (res.success) {
        setPreviewResult(res.data);
        setCurrentStep(1);
      } else {
        message.error(res.message || '미리보기 실패');
      }
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : '미리보기 중 오류 발생';
      message.error(errorMsg);
    } finally {
      setLoading(false);
    }
  };

  const handleApply = async () => {
    if (!selectedExamCd || !file) return;
    setLoading(true);
    try {
      const res = await applicantApi.csvResultApply(selectedExamCd, file);
      if (res.success) {
        setApplyResult(res.data);
        setCurrentStep(2);
        message.success(`${res.data.importedRows}건 등록 완료`);
      } else {
        message.error(res.message || '등록 실패');
      }
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : '등록 중 오류 발생';
      message.error(errorMsg);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setCurrentStep(0);
    setFile(null);
    setFileList([]);
    setPreviewResult(null);
    setApplyResult(null);
  };

  const statusTag = (status: string) => {
    switch (status) {
      case 'MATCHED':
        return <Tag color="green">매칭</Tag>;
      case 'SKIP':
        return <Tag color="default">건너뜀</Tag>;
      case 'ERROR':
        return <Tag color="red">오류</Tag>;
      case 'DUPLICATE':
        return <Tag color="orange">중복</Tag>;
      default:
        return <Tag>{status}</Tag>;
    }
  };

  const columns = [
    { title: '행', dataIndex: 'rowNum', key: 'rowNum', width: 50 },
    { title: '사용자ID', dataIndex: 'userId', key: 'userId', width: 100 },
    { title: '이름', dataIndex: 'userNm', key: 'userNm', width: 80 },
    { title: '과목', dataIndex: 'subjectNm', key: 'subjectNm', width: 100 },
    {
      title: '답안수',
      dataIndex: 'answerCount',
      key: 'answerCount',
      width: 70,
      align: 'center' as const,
    },
    {
      title: '정답',
      dataIndex: 'correctCnt',
      key: 'correctCnt',
      width: 60,
      align: 'center' as const,
      render: (val: number) => <Text type="success">{val}</Text>,
    },
    {
      title: '오답',
      dataIndex: 'wrongCnt',
      key: 'wrongCnt',
      width: 60,
      align: 'center' as const,
      render: (val: number) => <Text type="danger">{val}</Text>,
    },
    {
      title: '점수',
      dataIndex: 'score',
      key: 'score',
      width: 70,
      align: 'center' as const,
      render: (val: number | null) => (val != null ? `${val}점` : '-'),
    },
    {
      title: '상태',
      key: 'status',
      width: 80,
      render: (_: unknown, row: CsvResultRow) => statusTag(row.status),
    },
    {
      title: '답안',
      dataIndex: 'answers',
      key: 'answers',
      ellipsis: true,
      width: 200,
      render: (val: string | null) => (
        <Text style={{ fontSize: 12 }} type="secondary">{val || '-'}</Text>
      ),
    },
    {
      title: '비고',
      dataIndex: 'message',
      key: 'message',
      ellipsis: true,
    },
  ];

  const result = applyResult || previewResult;

  return (
    <div>
      <Title level={4}>응시결과 CSV 등록</Title>

      <Steps
        current={currentStep}
        style={{ marginBottom: 24 }}
        items={[
          { title: '파일 업로드' },
          { title: '미리보기 확인' },
          { title: '완료' },
        ]}
      />

      {currentStep === 0 && (
        <Card>
          <Alert
            message="CSV 파일 형식"
            description={
              <div>
                <p style={{ margin: '4px 0' }}>
                  헤더(첫 행): <strong>시험코드,과목명,이름,사용자ID,답안지</strong>
                </p>
                <p style={{ margin: '4px 0' }}>
                  답안지: <code>3/2/4/1/N/2/...</code> (20개, <code>/</code>로 구분, <code>N</code>=미체크)
                </p>
                <p style={{ margin: '4px 0' }}>
                  20개 미만 시 나머지는 N(오답)으로 채움 / 20개 초과 시 20개까지만 등록
                </p>
              </div>
            }
            type="info"
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
              onClick={handlePreview}
              loading={loading}
              disabled={!file || !selectedExamCd}
            >
              미리보기
            </Button>
          </div>
        </Card>
      )}

      {currentStep === 1 && previewResult && (
        <>
          <Row gutter={16} style={{ marginBottom: 16 }}>
            <Col span={6}>
              <Card>
                <Statistic title="전체" value={previewResult.totalRows} />
              </Card>
            </Col>
            <Col span={6}>
              <Card>
                <Statistic
                  title="매칭 (등록 대상)"
                  value={previewResult.matchedRows}
                  valueStyle={{ color: '#52c41a' }}
                  prefix={<CheckCircleOutlined />}
                />
              </Card>
            </Col>
            <Col span={6}>
              <Card>
                <Statistic
                  title="건너뜀"
                  value={previewResult.skippedRows}
                  valueStyle={{ color: '#faad14' }}
                  prefix={<WarningOutlined />}
                />
              </Card>
            </Col>
            <Col span={6}>
              <Card>
                <Statistic
                  title="오류"
                  value={previewResult.errorRows}
                  valueStyle={{ color: '#ff4d4f' }}
                  prefix={<CloseCircleOutlined />}
                />
              </Card>
            </Col>
          </Row>

          <Card
            title="미리보기 결과"
            extra={
              <Space>
                <Button onClick={handleReset}>다시 선택</Button>
                <Button
                  type="primary"
                  onClick={handleApply}
                  loading={loading}
                  disabled={previewResult.matchedRows === 0}
                >
                  {previewResult.matchedRows}건 등록 적용
                </Button>
              </Space>
            }
          >
            <Table
              columns={columns}
              dataSource={previewResult.rows}
              rowKey="rowNum"
              size="small"
              scroll={{ x: 1100, y: 500 }}
              pagination={{ pageSize: 50, showSizeChanger: true, showTotal: (t) => `총 ${t}건` }}
              rowClassName={(row) => {
                if (row.status === 'ERROR') return 'ant-table-row-error';
                if (row.status === 'SKIP') return 'ant-table-row-warning';
                return '';
              }}
            />
          </Card>
        </>
      )}

      {currentStep === 2 && result && (
        <Card>
          <Result
            status="success"
            title="등록 완료"
            subTitle={`총 ${result.totalRows}건 중 ${result.importedRows}건 등록, ${result.skippedRows}건 건너뜀, ${result.errorRows}건 오류`}
            extra={[
              <Button key="reset" type="primary" onClick={handleReset}>
                다른 파일 업로드
              </Button>,
            ]}
          />
          <Table
            columns={columns}
            dataSource={result.rows}
            rowKey="rowNum"
            size="small"
            scroll={{ x: 1100, y: 400 }}
            pagination={{ pageSize: 50, showSizeChanger: true, showTotal: (t) => `총 ${t}건` }}
          />
        </Card>
      )}
    </div>
  );
}
