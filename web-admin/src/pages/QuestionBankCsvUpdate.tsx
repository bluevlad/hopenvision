import { useState } from 'react';
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
import { questionBankApi } from '../api/questionBankApi';
import type { CsvUpdateResult, CsvUpdateRow } from '../types/questionBank';

const { Title, Text } = Typography;
const { Dragger } = Upload;

export default function QuestionBankCsvUpdate() {
  const [currentStep, setCurrentStep] = useState(0);
  const [file, setFile] = useState<File | null>(null);
  const [fileList, setFileList] = useState<UploadFile[]>([]);
  const [previewResult, setPreviewResult] = useState<CsvUpdateResult | null>(null);
  const [applyResult, setApplyResult] = useState<CsvUpdateResult | null>(null);
  const [loading, setLoading] = useState(false);

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
    if (!file) {
      message.warning('CSV 파일을 선택해주세요.');
      return;
    }
    setLoading(true);
    try {
      const res = await questionBankApi.csvUpdatePreview(file);
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
    if (!file) return;
    setLoading(true);
    try {
      const res = await questionBankApi.csvUpdateApply(file);
      if (res.success) {
        setApplyResult(res.data);
        setCurrentStep(2);
        message.success(`${res.data.updatedRows}건 업데이트 완료`);
      } else {
        message.error(res.message || '업데이트 실패');
      }
    } catch (err: unknown) {
      const errorMsg = err instanceof Error ? err.message : '업데이트 중 오류 발생';
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
      case 'NOT_FOUND':
        return <Tag color="orange">문항 없음</Tag>;
      case 'SKIP':
        return <Tag color="default">건너뜀</Tag>;
      case 'ERROR':
        return <Tag color="red">오류</Tag>;
      default:
        return <Tag>{status}</Tag>;
    }
  };

  const columns = [
    { title: '행', dataIndex: 'rowNum', key: 'rowNum', width: 60 },
    { title: '과목', dataIndex: 'subjectNm', key: 'subjectNm', width: 100 },
    { title: '문항', dataIndex: 'questionNo', key: 'questionNo', width: 60, align: 'center' as const },
    {
      title: '정답',
      key: 'correctAns',
      width: 120,
      render: (_: unknown, row: CsvUpdateRow) =>
        row.status === 'MATCHED' ? (
          <Space size={4}>
            <Text delete type="secondary">{row.prevCorrectAns || '-'}</Text>
            <Text>→</Text>
            <Text strong>{row.correctAns}</Text>
          </Space>
        ) : (
          <Text>{row.correctAns}</Text>
        ),
    },
    {
      title: '배점',
      key: 'score',
      width: 120,
      render: (_: unknown, row: CsvUpdateRow) =>
        row.status === 'MATCHED' ? (
          <Space size={4}>
            <Text delete type="secondary">{row.prevScore ?? '-'}</Text>
            <Text>→</Text>
            <Text strong>{row.score}</Text>
          </Space>
        ) : (
          <Text>{row.score}</Text>
        ),
    },
    {
      title: '난이도',
      key: 'difficulty',
      width: 120,
      render: (_: unknown, row: CsvUpdateRow) =>
        row.status === 'MATCHED' ? (
          <Space size={4}>
            <Text delete type="secondary">{row.prevDifficulty || '-'}</Text>
            <Text>→</Text>
            <Text strong>{row.difficulty}</Text>
          </Space>
        ) : (
          <Text>{row.difficulty}</Text>
        ),
    },
    {
      title: '상태',
      key: 'status',
      width: 100,
      render: (_: unknown, row: CsvUpdateRow) => statusTag(row.status),
    },
    {
      title: '그룹코드',
      dataIndex: 'groupCd',
      key: 'groupCd',
      width: 200,
      ellipsis: true,
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
      <Title level={4}>CSV 정답/배점/난이도 업데이트</Title>

      <Steps
        current={currentStep}
        style={{ marginBottom: 24 }}
        items={[
          { title: 'CSV 업로드' },
          { title: '미리보기 확인' },
          { title: '완료' },
        ]}
      />

      {currentStep === 0 && (
        <Card>
          <Alert
            message="CSV 파일 형식"
            description="시험코드,시험명,회차,과목명,문항번호,정답,배점,난이도 (EUC-KR 또는 UTF-8 인코딩)"
            type="info"
            showIcon
            style={{ marginBottom: 16 }}
          />
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
            <p className="ant-upload-hint">.csv 파일만 지원 (EUC-KR / UTF-8)</p>
          </Dragger>
          <div style={{ marginTop: 16, textAlign: 'right' }}>
            <Button
              type="primary"
              icon={<UploadOutlined />}
              onClick={handlePreview}
              loading={loading}
              disabled={!file}
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
                  title="매칭 (업데이트 대상)"
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
                  {previewResult.matchedRows}건 업데이트 적용
                </Button>
              </Space>
            }
          >
            <Table
              columns={columns}
              dataSource={previewResult.rows}
              rowKey="rowNum"
              size="small"
              scroll={{ x: 1000, y: 500 }}
              pagination={{ pageSize: 50, showSizeChanger: true, showTotal: (t) => `총 ${t}건` }}
              rowClassName={(row) => {
                if (row.status === 'ERROR') return 'ant-table-row-error';
                if (row.status === 'SKIP' || row.status === 'NOT_FOUND') return 'ant-table-row-warning';
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
            title="업데이트 완료"
            subTitle={`총 ${result.totalRows}건 중 ${result.updatedRows}건 업데이트, ${result.skippedRows}건 건너뜀, ${result.errorRows}건 오류`}
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
            scroll={{ x: 1000, y: 400 }}
            pagination={{ pageSize: 50, showSizeChanger: true, showTotal: (t) => `총 ${t}건` }}
          />
        </Card>
      )}
    </div>
  );
}
