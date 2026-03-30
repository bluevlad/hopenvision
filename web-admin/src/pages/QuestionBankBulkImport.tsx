import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useQuery, useQueryClient } from '@tanstack/react-query';
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
  Select,
  Row,
  Col,
  Form,
  Input,
  InputNumber,
  Statistic,
  Steps,
} from 'antd';
import {
  UploadOutlined,
  FileTextOutlined,
  CheckCircleOutlined,
  ArrowLeftOutlined,
  InboxOutlined,
  WarningOutlined,
} from '@ant-design/icons';
import type { UploadProps, UploadFile } from 'antd';
import { questionBankApi } from '../api/questionBankApi';
import { subjectApi } from '../api/subjectApi';
import type {
  QuestionBankGroupResponse,
  QuestionBankItemRequest,
} from '../types/questionBank';

const { Title, Text } = Typography;
const { Dragger } = Upload;

interface ParsedItem {
  key: number;
  questionNo: number;
  subjectCd: string;
  questionText: string;
  choice1: string;
  choice2: string;
  choice3: string;
  choice4: string;
  choice5: string;
  correctAns: string;
  questionType: string;
  isUse: string;
  hasError: boolean;
  errorMsg: string;
}

export default function QuestionBankBulkImport() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  // Steps
  const [currentStep, setCurrentStep] = useState(0);

  // Step 1: 그룹 선택
  const [selectedGroupId, setSelectedGroupId] = useState<number | undefined>();
  const [createNewGroup, setCreateNewGroup] = useState(false);
  const [newGroupForm] = Form.useForm();

  // Step 2: 파일 업로드
  const [fileList, setFileList] = useState<UploadFile[]>([]);

  // Step 3: 미리보기
  const [parsedItems, setParsedItems] = useState<ParsedItem[]>([]);
  const [validationErrors, setValidationErrors] = useState<string[]>([]);

  // Step 4: 임포트 결과
  const [importResult, setImportResult] = useState<{
    success: number;
    fail: number;
    total: number;
  } | null>(null);
  const [importing, setImporting] = useState(false);

  // 그룹 목록
  const { data: groupsData } = useQuery({
    queryKey: ['questionBankGroups', 'all'],
    queryFn: () => questionBankApi.getGroupList({ page: 0, size: 200 }),
  });

  // 과목 목록
  const { data: subjectsData } = useQuery({
    queryKey: ['subjects', 'all'],
    queryFn: () => subjectApi.searchSubjects({ page: 0, size: 200 }),
  });

  const groupsList = groupsData?.data;
  const groupsContent = groupsList && 'content' in groupsList ? groupsList.content : (groupsList || []);
  const groupOptions = groupsContent.map((g: QuestionBankGroupResponse) => ({
    value: g.groupId,
    label: `${g.groupNm} (${g.groupCd})`,
  }));

  const subjectsList = subjectsData?.data;
  const subjectsContent = subjectsList && 'content' in subjectsList ? subjectsList.content : (subjectsList || []);
  const subjectMap = new Map(
    subjectsContent.map((s: { subjectCd: string; subjectNm: string }) => [s.subjectCd, s.subjectNm])
  );

  // 파일 업로드 설정
  const uploadProps: UploadProps = {
    name: 'file',
    multiple: false,
    accept: '.json',
    fileList,
    beforeUpload: (file) => {
      if (!file.name.toLowerCase().endsWith('.json')) {
        message.error('JSON 파일만 업로드 가능합니다 (.json)');
        return Upload.LIST_IGNORE;
      }
      setFileList([file]);
      setParsedItems([]);
      setValidationErrors([]);
      setImportResult(null);
      return false;
    },
    onRemove: () => {
      setFileList([]);
      setParsedItems([]);
      setValidationErrors([]);
      setImportResult(null);
    },
  };

  // Step 1 → Step 2: 그룹 확인
  const handleGroupConfirm = async () => {
    if (createNewGroup) {
      try {
        const values = await newGroupForm.validateFields();
        const result = await questionBankApi.createGroup(values);
        setSelectedGroupId(result.data.groupId);
        queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] });
        message.success(`그룹 '${values.groupNm}' 생성 완료`);
        setCurrentStep(1);
      } catch {
        message.error('그룹 생성에 실패했습니다.');
      }
    } else {
      if (!selectedGroupId) {
        message.error('그룹을 선택하세요.');
        return;
      }
      setCurrentStep(1);
    }
  };

  // Step 2 → Step 3: 파일 파싱 + 검증
  const handleParseFile = async () => {
    if (fileList.length === 0) {
      message.error('JSON 파일을 업로드하세요.');
      return;
    }

    try {
      const file = fileList[0] as unknown as File;
      const text = await file.text();
      const data = JSON.parse(text);

      // items 배열 추출 (최상위 items 또는 배열 자체)
      const rawItems: unknown[] = Array.isArray(data) ? data : (data.items || []);

      if (rawItems.length === 0) {
        message.error('문항 데이터가 없습니다. items 배열을 확인하세요.');
        return;
      }

      const errors: string[] = [];
      const items: ParsedItem[] = rawItems.map((raw: unknown, index: number) => {
        const item = raw as Record<string, unknown>;
        let errorMsg = '';
        const errs: string[] = [];

        // 과목코드 검증
        const subjectCd = String(item.subjectCd || '');
        if (!subjectCd) {
          errs.push('과목코드 없음');
        } else if (!subjectMap.has(subjectCd)) {
          errs.push(`과목코드 '${subjectCd}' 미등록`);
        }

        // 정답 검증
        const correctAns = String(item.correctAns || '');
        if (!correctAns) {
          errs.push('정답 없음');
        }

        if (errs.length > 0) {
          errorMsg = errs.join(', ');
          errors.push(`${index + 1}번째 항목: ${errorMsg}`);
        }

        return {
          key: index,
          questionNo: Number(item.questionNo) || index + 1,
          subjectCd,
          questionText: String(item.questionText || ''),
          choice1: String(item.choice1 || ''),
          choice2: String(item.choice2 || ''),
          choice3: String(item.choice3 || ''),
          choice4: String(item.choice4 || ''),
          choice5: String(item.choice5 || ''),
          correctAns,
          questionType: String(item.questionType || 'CHOICE'),
          isUse: String(item.isUse || 'Y'),
          hasError: errs.length > 0,
          errorMsg,
        };
      });

      setParsedItems(items);
      setValidationErrors(errors);
      setCurrentStep(2);

      const errorCount = items.filter((i) => i.hasError).length;
      if (errorCount > 0) {
        message.warning(`${errorCount}건의 검증 오류가 있습니다.`);
      } else {
        message.success(`${items.length}건 파싱 완료`);
      }
    } catch (e) {
      message.error(`JSON 파싱 실패: ${e instanceof Error ? e.message : String(e)}`);
    }
  };

  // Step 3 → Step 4: 일괄 등록
  const handleImport = async () => {
    if (!selectedGroupId) {
      message.error('그룹이 선택되지 않았습니다.');
      return;
    }

    const validItems = parsedItems.filter((i) => !i.hasError);
    if (validItems.length === 0) {
      message.error('등록 가능한 문항이 없습니다.');
      return;
    }

    setImporting(true);
    let totalSuccess = 0;
    let totalFail = 0;

    try {
      // 50건 단위 배치 처리
      for (let i = 0; i < validItems.length; i += 50) {
        const batch = validItems.slice(i, i + 50);
        const apiItems: QuestionBankItemRequest[] = batch.map((item) => ({
          groupId: selectedGroupId,
          subjectCd: item.subjectCd,
          questionNo: item.questionNo,
          questionText: item.questionText,
          choice1: item.choice1,
          choice2: item.choice2,
          choice3: item.choice3,
          choice4: item.choice4,
          choice5: item.choice5 || undefined,
          correctAns: item.correctAns,
          questionType: item.questionType,
          isUse: item.isUse,
        }));

        try {
          const result = await questionBankApi.bulkImportItems(
            selectedGroupId,
            apiItems
          );
          totalSuccess += result.data?.length ?? batch.length;
        } catch {
          totalFail += batch.length;
        }
      }

      setImportResult({
        success: totalSuccess,
        fail: totalFail,
        total: validItems.length,
      });
      setCurrentStep(3);

      queryClient.invalidateQueries({ queryKey: ['questionBankItems'] });

      if (totalFail === 0) {
        message.success(`${totalSuccess}건 등록 완료`);
      } else {
        message.warning(`${totalSuccess}건 성공, ${totalFail}건 실패`);
      }
    } catch (e) {
      message.error(`임포트 실패: ${e instanceof Error ? e.message : String(e)}`);
    } finally {
      setImporting(false);
    }
  };

  // 초기화
  const handleReset = () => {
    setCurrentStep(0);
    setSelectedGroupId(undefined);
    setCreateNewGroup(false);
    newGroupForm.resetFields();
    setFileList([]);
    setParsedItems([]);
    setValidationErrors([]);
    setImportResult(null);
  };

  // 미리보기 컬럼
  const previewColumns = [
    {
      title: '번호',
      dataIndex: 'questionNo',
      key: 'questionNo',
      width: 60,
      align: 'center' as const,
    },
    {
      title: '과목',
      dataIndex: 'subjectCd',
      key: 'subjectCd',
      width: 100,
      render: (cd: string) => subjectMap.get(cd) || cd,
    },
    {
      title: '문제',
      dataIndex: 'questionText',
      key: 'questionText',
      ellipsis: true,
      render: (text: string) => text?.substring(0, 100) || '-',
    },
    {
      title: '선택지',
      key: 'choices',
      width: 200,
      render: (_: unknown, record: ParsedItem) => (
        <Space direction="vertical" size={0} style={{ fontSize: 12 }}>
          {record.choice1 && <div>1. {record.choice1.substring(0, 30)}</div>}
          {record.choice2 && <div>2. {record.choice2.substring(0, 30)}</div>}
          {record.choice3 && <div>3. {record.choice3.substring(0, 30)}</div>}
          {record.choice4 && <div>4. {record.choice4.substring(0, 30)}</div>}
        </Space>
      ),
    },
    {
      title: '정답',
      dataIndex: 'correctAns',
      key: 'correctAns',
      width: 60,
      align: 'center' as const,
      render: (val: string) => val ? <Tag color="blue">{val}</Tag> : <Tag color="red">-</Tag>,
    },
    {
      title: '상태',
      key: 'status',
      width: 100,
      render: (_: unknown, record: ParsedItem) =>
        record.hasError ? (
          <Tag icon={<WarningOutlined />} color="error">
            {record.errorMsg}
          </Tag>
        ) : (
          <Tag color="success">OK</Tag>
        ),
    },
  ];

  const validCount = parsedItems.filter((i) => !i.hasError).length;
  const errorCount = parsedItems.filter((i) => i.hasError).length;

  return (
    <div>
      <Space style={{ marginBottom: 16 }}>
        <Button icon={<ArrowLeftOutlined />} onClick={() => navigate('/question-bank/items')}>
          문제 목록
        </Button>
        <Title level={4} style={{ margin: 0 }}>
          <FileTextOutlined /> 문제은행 일괄 등록
        </Title>
      </Space>

      <Steps
        current={currentStep}
        style={{ marginBottom: 24 }}
        items={[
          { title: '그룹 선택' },
          { title: 'JSON 업로드' },
          { title: '미리보기' },
          { title: '등록 완료' },
        ]}
      />

      {/* Step 1: 그룹 선택 */}
      {currentStep === 0 && (
        <Card title="Step 1. 문제은행 그룹 선택">
          <Space direction="vertical" size="middle" style={{ width: '100%' }}>
            <div>
              <Button
                type={!createNewGroup ? 'primary' : 'default'}
                onClick={() => setCreateNewGroup(false)}
                style={{ marginRight: 8 }}
              >
                기존 그룹 선택
              </Button>
              <Button
                type={createNewGroup ? 'primary' : 'default'}
                onClick={() => setCreateNewGroup(true)}
              >
                새 그룹 생성
              </Button>
            </div>

            {!createNewGroup ? (
              <Select
                placeholder="그룹을 선택하세요"
                style={{ width: '100%', maxWidth: 500 }}
                showSearch
                optionFilterProp="label"
                value={selectedGroupId}
                onChange={setSelectedGroupId}
                options={groupOptions}
              />
            ) : (
              <Form form={newGroupForm} layout="vertical" style={{ maxWidth: 500 }}>
                <Row gutter={16}>
                  <Col span={12}>
                    <Form.Item
                      name="groupCd"
                      label="그룹코드"
                      rules={[{ required: true, message: '그룹코드를 입력하세요' }]}
                    >
                      <Input placeholder="예: 2024-9LEVEL-R1-국어" />
                    </Form.Item>
                  </Col>
                  <Col span={12}>
                    <Form.Item
                      name="groupNm"
                      label="그룹명"
                      rules={[{ required: true, message: '그룹명을 입력하세요' }]}
                    >
                      <Input placeholder="예: 2024년 9급 1회 국어" />
                    </Form.Item>
                  </Col>
                </Row>
                <Row gutter={16}>
                  <Col span={8}>
                    <Form.Item name="examYear" label="출제연도">
                      <Input placeholder="2024" />
                    </Form.Item>
                  </Col>
                  <Col span={8}>
                    <Form.Item name="examRound" label="회차">
                      <InputNumber min={1} style={{ width: '100%' }} placeholder="1" />
                    </Form.Item>
                  </Col>
                  <Col span={8}>
                    <Form.Item name="category" label="시험유형">
                      <Select
                        placeholder="선택"
                        options={[
                          { value: '5LEVEL', label: '5급' },
                          { value: '7LEVEL', label: '7급' },
                          { value: '9LEVEL', label: '9급' },
                          { value: 'POLICE', label: '경찰' },
                          { value: 'FIRE', label: '소방' },
                        ]}
                      />
                    </Form.Item>
                  </Col>
                </Row>
                <Form.Item name="source" label="출처">
                  <Select
                    placeholder="선택"
                    options={[
                      { value: 'ACTUAL', label: '기출문제' },
                      { value: 'MOCK', label: '모의고사' },
                      { value: 'CUSTOM', label: '자체 제작' },
                    ]}
                  />
                </Form.Item>
              </Form>
            )}

            <Button type="primary" onClick={handleGroupConfirm}>
              다음
            </Button>
          </Space>
        </Card>
      )}

      {/* Step 2: JSON 파일 업로드 */}
      {currentStep === 1 && (
        <Card title="Step 2. JSON 파일 업로드">
          <Alert
            type="info"
            showIcon
            message="JSON 파일 형식"
            description={
              <div>
                <code>{`{ "items": [ { "subjectCd": "1001", "questionNo": 1, "questionText": "...", "choice1": "...", ..., "correctAns": "1" } ] }`}</code>
                <br />
                <Text type="secondary">
                  parse_hwpx.py + merge_answers.py로 생성한 JSON 또는 동일 형식의 JSON을 업로드하세요.
                </Text>
              </div>
            }
            style={{ marginBottom: 16 }}
          />

          <Dragger {...uploadProps} style={{ maxWidth: 600 }}>
            <p className="ant-upload-drag-icon">
              <InboxOutlined style={{ fontSize: 48, color: '#1890ff' }} />
            </p>
            <p className="ant-upload-text">JSON 파일을 드래그하거나 클릭하여 업로드</p>
            <p className="ant-upload-hint">.json 파일만 지원</p>
          </Dragger>

          <Space style={{ marginTop: 16 }}>
            <Button onClick={() => setCurrentStep(0)}>이전</Button>
            <Button
              type="primary"
              onClick={handleParseFile}
              disabled={fileList.length === 0}
            >
              파싱 및 검증
            </Button>
          </Space>
        </Card>
      )}

      {/* Step 3: 미리보기 */}
      {currentStep === 2 && (
        <Space direction="vertical" size="middle" style={{ width: '100%' }}>
          <Card>
            <Row gutter={24}>
              <Col span={6}>
                <Statistic title="전체 문항" value={parsedItems.length} />
              </Col>
              <Col span={6}>
                <Statistic
                  title="등록 가능"
                  value={validCount}
                  valueStyle={{ color: '#3f8600' }}
                />
              </Col>
              <Col span={6}>
                <Statistic
                  title="오류"
                  value={errorCount}
                  valueStyle={errorCount > 0 ? { color: '#cf1322' } : undefined}
                />
              </Col>
              <Col span={6}>
                <Statistic
                  title="정답 없음"
                  value={parsedItems.filter((i) => !i.correctAns).length}
                  valueStyle={{ color: '#faad14' }}
                />
              </Col>
            </Row>
          </Card>

          {validationErrors.length > 0 && (
            <Alert
              type="warning"
              showIcon
              message={`${validationErrors.length}건의 검증 경고`}
              description={
                <ul style={{ margin: 0, paddingLeft: 20, maxHeight: 150, overflow: 'auto' }}>
                  {validationErrors.map((err, idx) => (
                    <li key={idx}>{err}</li>
                  ))}
                </ul>
              }
            />
          )}

          <Card
            title="문항 미리보기"
            extra={
              <Space>
                <Button onClick={() => setCurrentStep(1)}>이전</Button>
                <Button
                  type="primary"
                  icon={<UploadOutlined />}
                  onClick={handleImport}
                  loading={importing}
                  disabled={validCount === 0}
                >
                  {validCount}건 일괄 등록
                </Button>
              </Space>
            }
          >
            <Table
              columns={previewColumns}
              dataSource={parsedItems}
              size="small"
              pagination={{ pageSize: 20 }}
              scroll={{ y: 500 }}
              rowClassName={(record) => (record.hasError ? 'ant-table-row-error' : '')}
            />
          </Card>
        </Space>
      )}

      {/* Step 4: 결과 */}
      {currentStep === 3 && importResult && (
        <Card>
          <Result
            status={importResult.fail === 0 ? 'success' : 'warning'}
            icon={importResult.fail === 0 ? <CheckCircleOutlined /> : undefined}
            title={importResult.fail === 0 ? '일괄 등록 완료' : '일부 등록 완료'}
            subTitle={
              <Space direction="vertical">
                <Text>총 {importResult.total}건 중 {importResult.success}건 등록 완료</Text>
                {importResult.fail > 0 && (
                  <Text type="danger">{importResult.fail}건 등록 실패</Text>
                )}
              </Space>
            }
            extra={[
              <Button
                type="primary"
                key="list"
                onClick={() => navigate('/question-bank/items')}
              >
                문제 목록으로
              </Button>,
              <Button key="another" onClick={handleReset}>
                다른 파일 업로드
              </Button>,
            ]}
          />
        </Card>
      )}
    </div>
  );
}
