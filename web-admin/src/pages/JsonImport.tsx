import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Card,
  Upload,
  Button,
  Table,
  Alert,
  Space,
  Typography,
  message,
  Tag,
  Result,
  Spin,
  Select,
  Row,
  Col,
} from 'antd';
import {
  UploadOutlined,
  FileTextOutlined,
  CheckCircleOutlined,
  ArrowLeftOutlined,
} from '@ant-design/icons';
import type { UploadFile, UploadProps } from 'antd';
import { examApi } from '../api/examApi';
import type { JsonImportResult, ExamResponse, SubjectResponse } from '../types/exam';

const { Title, Text } = Typography;
const { Dragger } = Upload;

const JsonImport: React.FC = () => {
  const navigate = useNavigate();
  const [selectedExamCd, setSelectedExamCd] = useState<string | undefined>();
  const [selectedSubjectCd, setSelectedSubjectCd] = useState<string | undefined>();
  const [questionFileList, setQuestionFileList] = useState<UploadFile[]>([]);
  const [answerFileList, setAnswerFileList] = useState<UploadFile[]>([]);
  const [previewResult, setPreviewResult] = useState<JsonImportResult | null>(null);
  const [importResult, setImportResult] = useState<JsonImportResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [importing, setImporting] = useState(false);

  // 시험 목록 조회
  const { data: examListData } = useQuery({
    queryKey: ['exams', { page: 0, size: 100 }],
    queryFn: () => examApi.getExamList({ page: 0, size: 100 }),
  });

  // 선택한 시험의 과목 조회
  const { data: subjectListData } = useQuery({
    queryKey: ['subjects', selectedExamCd],
    queryFn: () => examApi.getSubjectList(selectedExamCd!),
    enabled: !!selectedExamCd,
  });

  const examList: ExamResponse[] = examListData?.data?.content || [];
  const subjectList: SubjectResponse[] = subjectListData?.data || [];

  const columns = [
    {
      title: '문항번호',
      dataIndex: 'questionNo',
      key: 'questionNo',
      width: 80,
      align: 'center' as const,
    },
    {
      title: '제목',
      dataIndex: 'title',
      key: 'title',
      width: 200,
      ellipsis: true,
    },
    {
      title: '문제 내용',
      dataIndex: 'questionText',
      key: 'questionText',
      ellipsis: true,
    },
    {
      title: '카테고리',
      dataIndex: 'category',
      key: 'category',
      width: 120,
    },
    {
      title: '난이도',
      dataIndex: 'difficulty',
      key: 'difficulty',
      width: 80,
      align: 'center' as const,
      render: (value: string) => {
        const colorMap: Record<string, string> = { '상': 'red', '중': 'orange', '하': 'green' };
        return <Tag color={colorMap[value] || 'default'}>{value || '-'}</Tag>;
      },
    },
    {
      title: '정답',
      dataIndex: 'correctAnswer',
      key: 'correctAnswer',
      width: 80,
      align: 'center' as const,
      render: (value: number) => <Tag color="blue">{value}</Tag>,
    },
  ];

  const questionUploadProps: UploadProps = {
    name: 'questionFile',
    multiple: false,
    accept: '.json',
    fileList: questionFileList,
    beforeUpload: (file) => {
      if (!file.name.toLowerCase().endsWith('.json')) {
        message.error('JSON 파일만 업로드 가능합니다 (.json)');
        return Upload.LIST_IGNORE;
      }
      setQuestionFileList([file]);
      return false;
    },
    onRemove: () => {
      setQuestionFileList([]);
      setPreviewResult(null);
      setImportResult(null);
    },
  };

  const answerUploadProps: UploadProps = {
    name: 'answerFile',
    multiple: false,
    accept: '.json',
    fileList: answerFileList,
    beforeUpload: (file) => {
      if (!file.name.toLowerCase().endsWith('.json')) {
        message.error('JSON 파일만 업로드 가능합니다 (.json)');
        return Upload.LIST_IGNORE;
      }
      setAnswerFileList([file]);
      return false;
    },
    onRemove: () => {
      setAnswerFileList([]);
      setPreviewResult(null);
      setImportResult(null);
    },
  };

  const handlePreview = async () => {
    if (questionFileList.length === 0 || answerFileList.length === 0) {
      message.error('문제지 JSON과 답안지 JSON 파일을 모두 업로드해주세요.');
      return;
    }

    setLoading(true);
    setPreviewResult(null);
    setImportResult(null);

    try {
      const questionFile = questionFileList[0] as unknown as File;
      const answerFile = answerFileList[0] as unknown as File;
      const result = await examApi.previewJsonQuestionBank(questionFile, answerFile);
      setPreviewResult(result);

      if (result.failCount > 0) {
        message.warning(`${result.failCount}건의 오류가 발견되었습니다.`);
      } else {
        message.success(`${result.successCount}건의 문제를 미리보기합니다.`);
      }
    } catch (error) {
      message.error('파일 미리보기에 실패했습니다.');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleImport = async () => {
    if (!selectedExamCd || !selectedSubjectCd) {
      message.error('시험과 과목을 선택해주세요.');
      return;
    }
    if (questionFileList.length === 0 || answerFileList.length === 0) {
      message.error('문제지 JSON과 답안지 JSON 파일을 모두 업로드해주세요.');
      return;
    }

    setImporting(true);
    try {
      const questionFile = questionFileList[0] as unknown as File;
      const answerFile = answerFileList[0] as unknown as File;
      const result = await examApi.importJsonQuestionBank(selectedExamCd, selectedSubjectCd, questionFile, answerFile);
      setImportResult(result);

      if (result.failCount > 0) {
        message.warning(`${result.successCount}건 저장 완료, ${result.failCount}건 오류`);
      } else {
        message.success(`${result.successCount}건의 문제가 저장되었습니다.`);
      }
    } catch (error) {
      message.error('문제 저장에 실패했습니다.');
      console.error(error);
    } finally {
      setImporting(false);
    }
  };

  const handleReset = () => {
    setQuestionFileList([]);
    setAnswerFileList([]);
    setPreviewResult(null);
    setImportResult(null);
  };

  return (
    <div style={{ padding: 24 }}>
      <Space direction="vertical" size="large" style={{ width: '100%' }}>
        <Card>
          <Space>
            <Button icon={<ArrowLeftOutlined />} onClick={() => navigate(-1)}>
              뒤로가기
            </Button>
            <Title level={4} style={{ margin: 0 }}>
              <FileTextOutlined /> JSON 문제은행 가져오기
            </Title>
          </Space>
        </Card>

        <Card title="시험 / 과목 선택">
          <Row gutter={16}>
            <Col span={12}>
              <Text strong>시험 선택</Text>
              <Select
                placeholder="시험을 선택하세요"
                style={{ width: '100%', marginTop: 8 }}
                value={selectedExamCd}
                onChange={(value) => {
                  setSelectedExamCd(value);
                  setSelectedSubjectCd(undefined);
                }}
                options={examList.map((exam) => ({
                  value: exam.examCd,
                  label: `${exam.examNm} (${exam.examCd})`,
                }))}
                showSearch
                filterOption={(input, option) =>
                  (option?.label as string)?.toLowerCase().includes(input.toLowerCase()) ?? false
                }
              />
            </Col>
            <Col span={12}>
              <Text strong>과목 선택</Text>
              <Select
                placeholder="과목을 선택하세요"
                style={{ width: '100%', marginTop: 8 }}
                value={selectedSubjectCd}
                onChange={setSelectedSubjectCd}
                disabled={!selectedExamCd}
                options={subjectList.map((subject) => ({
                  value: subject.subjectCd,
                  label: `${subject.subjectNm} (${subject.subjectCd})`,
                }))}
              />
            </Col>
          </Row>
        </Card>

        <Card title="JSON 파일 업로드">
          <Alert
            type="info"
            showIcon
            message="JSON 파일 형식"
            description="문제지 JSON과 답안지 JSON 2개의 파일을 업로드합니다. 미리보기로 데이터를 확인한 후 저장할 수 있습니다."
            style={{ marginBottom: 16 }}
          />
          <Row gutter={16}>
            <Col span={12}>
              <Text strong>문제지 JSON</Text>
              <Dragger {...questionUploadProps} style={{ marginTop: 8 }}>
                <p className="ant-upload-drag-icon">
                  <FileTextOutlined style={{ fontSize: 48, color: '#1890ff' }} />
                </p>
                <p className="ant-upload-text">문제지 JSON 파일</p>
                <p className="ant-upload-hint">클릭하거나 드래그하여 업로드</p>
              </Dragger>
            </Col>
            <Col span={12}>
              <Text strong>답안지 JSON</Text>
              <Dragger {...answerUploadProps} style={{ marginTop: 8 }}>
                <p className="ant-upload-drag-icon">
                  <FileTextOutlined style={{ fontSize: 48, color: '#52c41a' }} />
                </p>
                <p className="ant-upload-text">답안지 JSON 파일</p>
                <p className="ant-upload-hint">클릭하거나 드래그하여 업로드</p>
              </Dragger>
            </Col>
          </Row>
          <div style={{ marginTop: 16, textAlign: 'center' }}>
            <Button
              type="primary"
              onClick={handlePreview}
              loading={loading}
              disabled={questionFileList.length === 0 || answerFileList.length === 0}
            >
              미리보기
            </Button>
          </div>
        </Card>

        {loading && (
          <Card>
            <div style={{ textAlign: 'center', padding: 40 }}>
              <Spin size="large" />
              <p style={{ marginTop: 16 }}>파일을 분석하고 있습니다...</p>
            </div>
          </Card>
        )}

        {previewResult && !loading && (
          <Card
            title={
              <Space>
                미리보기 결과
                <Tag color="blue">{previewResult.totalCount}건</Tag>
                <Tag color="green">성공: {previewResult.successCount}건</Tag>
                {previewResult.failCount > 0 && (
                  <Tag color="red">실패: {previewResult.failCount}건</Tag>
                )}
              </Space>
            }
            extra={
              selectedExamCd && selectedSubjectCd && previewResult.successCount > 0 && !importResult && (
                <Button
                  type="primary"
                  icon={<UploadOutlined />}
                  onClick={handleImport}
                  loading={importing}
                >
                  DB에 저장하기
                </Button>
              )
            }
          >
            {previewResult.errors.length > 0 && (
              <Alert
                type="error"
                showIcon
                message="오류 목록"
                description={
                  <ul style={{ margin: 0, paddingLeft: 20 }}>
                    {previewResult.errors.map((error, index) => (
                      <li key={index}>{error}</li>
                    ))}
                  </ul>
                }
                style={{ marginBottom: 16 }}
              />
            )}

            <Table
              columns={columns}
              dataSource={previewResult.importedQuestions.map((item, index) => ({
                ...item,
                key: index,
              }))}
              size="small"
              pagination={{ pageSize: 20 }}
              scroll={{ y: 400 }}
            />
          </Card>
        )}

        {importResult && (
          <Card>
            <Result
              status={importResult.failCount === 0 ? 'success' : 'warning'}
              icon={importResult.failCount === 0 ? <CheckCircleOutlined /> : undefined}
              title={importResult.failCount === 0 ? '문제 저장 완료' : '일부 데이터 저장 완료'}
              subTitle={
                <Space direction="vertical">
                  <Text>총 {importResult.totalCount}건 중 {importResult.successCount}건 저장 완료</Text>
                  {importResult.failCount > 0 && (
                    <Text type="danger">{importResult.failCount}건 저장 실패</Text>
                  )}
                </Space>
              }
              extra={[
                <Button type="primary" key="list" onClick={() => navigate('/exams')}>
                  시험 목록으로
                </Button>,
                <Button key="another" onClick={handleReset}>
                  다른 파일 업로드
                </Button>,
              ]}
            />
          </Card>
        )}

        {(!selectedExamCd || !selectedSubjectCd) && previewResult && !importResult && (
          <Alert
            type="warning"
            showIcon
            message="시험과 과목을 선택해주세요"
            description="문제를 저장하려면 상단에서 시험과 과목을 선택해야 합니다."
          />
        )}
      </Space>
    </div>
  );
};

export default JsonImport;
