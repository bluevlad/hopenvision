import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Table,
  Button,
  Space,
  Card,
  Tag,
  Modal,
  Form,
  Input,
  InputNumber,
  Select,
  message,
  Row,
  Col,
  Popconfirm,
  Descriptions,
  Tabs,
} from 'antd';
import {
  PlusOutlined,
  DeleteOutlined,
  EditOutlined,
  ArrowLeftOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { questionBankApi } from '../api/questionBankApi';
import type { QuestionBankItemResponse, QuestionBankItemRequest } from '../types/questionBank';
import { EXAM_TYPES, QUESTION_TYPES } from '@hopenvision/shared';

const DIFFICULTY_OPTIONS = [
  { value: '1', label: '매우 쉬움' },
  { value: '2', label: '쉬움' },
  { value: '3', label: '보통' },
  { value: '4', label: '어려움' },
  { value: '5', label: '매우 어려움' },
];

export default function QuestionBankDetail() {
  const { groupId } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [form] = Form.useForm();
  const groupIdNum = Number(groupId);

  const [modalOpen, setModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<QuestionBankItemResponse | null>(null);
  const [previewItem, setPreviewItem] = useState<QuestionBankItemResponse | null>(null);

  // 그룹 상세 조회
  const { data: groupData, isLoading } = useQuery({
    queryKey: ['questionBankGroup', groupIdNum],
    queryFn: () => questionBankApi.getGroupDetail(groupIdNum),
    enabled: !!groupId,
  });

  // 항목 등록
  const createItemMutation = useMutation({
    mutationFn: (data: QuestionBankItemRequest) => questionBankApi.createItem(groupIdNum, data),
    onSuccess: () => {
      message.success('문제가 등록되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroup', groupIdNum] });
      handleCloseModal();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '등록 중 오류가 발생했습니다.');
    },
  });

  // 항목 수정
  const updateItemMutation = useMutation({
    mutationFn: ({ itemId, data }: { itemId: number; data: QuestionBankItemRequest }) =>
      questionBankApi.updateItem(groupIdNum, itemId, data),
    onSuccess: () => {
      message.success('문제가 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroup', groupIdNum] });
      handleCloseModal();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '수정 중 오류가 발생했습니다.');
    },
  });

  // 항목 삭제
  const deleteItemMutation = useMutation({
    mutationFn: (itemId: number) => questionBankApi.deleteItem(groupIdNum, itemId),
    onSuccess: () => {
      message.success('문제가 삭제되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroup', groupIdNum] });
    },
    onError: () => {
      message.error('삭제 중 오류가 발생했습니다.');
    },
  });

  const handleOpenCreate = () => {
    setEditingItem(null);
    form.resetFields();
    form.setFieldsValue({
      questionType: 'CHOICE',
      isMultiAns: 'N',
      score: 5,
      questionNo: (groupData?.data?.items?.length || 0) + 1,
    });
    setModalOpen(true);
  };

  const handleOpenEdit = (record: QuestionBankItemResponse) => {
    setEditingItem(record);
    form.setFieldsValue({
      subjectCd: record.subjectCd,
      questionNo: record.questionNo,
      questionTitle: record.questionTitle,
      questionText: record.questionText,
      contextText: record.contextText,
      choice1: record.choice1,
      choice2: record.choice2,
      choice3: record.choice3,
      choice4: record.choice4,
      choice5: record.choice5,
      correctAns: record.correctAns,
      isMultiAns: record.isMultiAns,
      score: record.score,
      category: record.category,
      difficulty: record.difficulty,
      questionType: record.questionType,
      tags: record.tags,
      explanation: record.explanation,
      correctionNote: record.correctionNote,
    });
    setModalOpen(true);
  };

  const handleCloseModal = () => {
    setModalOpen(false);
    setEditingItem(null);
    form.resetFields();
  };

  const handleSubmit = () => {
    form.validateFields().then((values: QuestionBankItemRequest) => {
      if (editingItem) {
        updateItemMutation.mutate({ itemId: editingItem.itemId, data: values });
      } else {
        createItemMutation.mutate(values);
      }
    });
  };

  const group = groupData?.data;
  const items = group?.items || [];

  const columns: ColumnsType<QuestionBankItemResponse> = [
    {
      title: '번호',
      dataIndex: 'questionNo',
      key: 'questionNo',
      width: 60,
      align: 'center',
    },
    {
      title: '과목',
      dataIndex: 'subjectNm',
      key: 'subjectNm',
      width: 100,
      render: (value, record) => value || record.subjectCd,
    },
    {
      title: '문제',
      key: 'question',
      render: (_, record) => {
        const text = record.questionTitle || record.questionText || '-';
        return (
          <a onClick={() => setPreviewItem(record)}>
            {text.length > 60 ? text.substring(0, 60) + '...' : text}
          </a>
        );
      },
    },
    {
      title: '정답',
      dataIndex: 'correctAns',
      key: 'correctAns',
      width: 60,
      align: 'center',
    },
    {
      title: '배점',
      dataIndex: 'score',
      key: 'score',
      width: 60,
      align: 'center',
    },
    {
      title: '난이도',
      dataIndex: 'difficulty',
      key: 'difficulty',
      width: 80,
      align: 'center',
      render: (value) => {
        const opt = DIFFICULTY_OPTIONS.find((d) => d.value === value);
        return opt?.label || value || '-';
      },
    },
    {
      title: '유형',
      dataIndex: 'questionType',
      key: 'questionType',
      width: 80,
      align: 'center',
      render: (value) => {
        const opt = QUESTION_TYPES.find((t) => t.value === value);
        return opt?.label || value;
      },
    },
    {
      title: '관리',
      key: 'action',
      width: 140,
      align: 'center',
      render: (_, record) => (
        <Space size="small">
          <Button
            type="primary"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleOpenEdit(record)}
          >
            수정
          </Button>
          <Popconfirm
            title="문제를 삭제하시겠습니까?"
            onConfirm={() => deleteItemMutation.mutate(record.itemId)}
            okText="삭제"
            cancelText="취소"
          >
            <Button danger size="small" icon={<DeleteOutlined />}>
              삭제
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Button
        icon={<ArrowLeftOutlined />}
        onClick={() => navigate('/question-bank')}
        style={{ marginBottom: 16 }}
      >
        목록으로
      </Button>

      <Card loading={isLoading} style={{ marginBottom: 16 }}>
        {group && (
          <Descriptions title={group.groupNm} bordered size="small" column={3}>
            <Descriptions.Item label="그룹코드">{group.groupCd}</Descriptions.Item>
            <Descriptions.Item label="카테고리">
              {EXAM_TYPES.find((t) => t.value === group.category)?.label || group.category || '-'}
            </Descriptions.Item>
            <Descriptions.Item label="출제연도">{group.examYear || '-'}</Descriptions.Item>
            <Descriptions.Item label="회차">{group.examRound ? `${group.examRound}차` : '-'}</Descriptions.Item>
            <Descriptions.Item label="출처">{group.source || '-'}</Descriptions.Item>
            <Descriptions.Item label="사용여부">
              <Tag color={group.isUse === 'Y' ? 'green' : 'red'}>
                {group.isUse === 'Y' ? '사용' : '미사용'}
              </Tag>
            </Descriptions.Item>
            {group.description && (
              <Descriptions.Item label="설명" span={3}>{group.description}</Descriptions.Item>
            )}
          </Descriptions>
        )}
      </Card>

      <Card
        title={<span>문제 항목 (총 <strong>{items.length}</strong>문항)</span>}
        extra={
          <Button type="primary" icon={<PlusOutlined />} onClick={handleOpenCreate}>
            문제 추가
          </Button>
        }
      >
        <Table
          columns={columns}
          dataSource={items}
          rowKey="itemId"
          loading={isLoading}
          pagination={{ pageSize: 20, showSizeChanger: true, showTotal: (total) => `총 ${total}문항` }}
          scroll={{ x: 900 }}
        />
      </Card>

      {/* 문제 등록/수정 모달 */}
      <Modal
        title={editingItem ? '문제 수정' : '문제 추가'}
        open={modalOpen}
        onOk={handleSubmit}
        onCancel={handleCloseModal}
        confirmLoading={createItemMutation.isPending || updateItemMutation.isPending}
        okText={editingItem ? '수정' : '등록'}
        cancelText="취소"
        width={800}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Row gutter={16}>
            <Col span={8}>
              <Form.Item
                name="subjectCd"
                label="과목코드"
                rules={[{ required: true, message: '과목코드를 입력하세요' }]}
              >
                <Input placeholder="과목코드" />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item
                name="questionNo"
                label="문항번호"
                rules={[{ required: true, message: '문항번호 필수' }]}
              >
                <InputNumber min={1} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="questionType" label="유형">
                <Select options={QUESTION_TYPES} />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="difficulty" label="난이도">
                <Select allowClear options={DIFFICULTY_OPTIONS} placeholder="선택" />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="score" label="배점">
                <InputNumber min={0} step={0.5} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item name="questionTitle" label="문제 제목">
            <Input placeholder="문제 제목 (선택사항)" />
          </Form.Item>

          <Form.Item name="questionText" label="문제 본문">
            <Input.TextArea rows={3} placeholder="문제 본문" />
          </Form.Item>

          <Form.Item name="contextText" label="지문">
            <Input.TextArea rows={3} placeholder="지문 (선택사항)" />
          </Form.Item>

          <Tabs
            items={[
              {
                key: 'choices',
                label: '보기',
                children: (
                  <>
                    {[1, 2, 3, 4, 5].map((n) => (
                      <Form.Item key={n} name={`choice${n}`} label={`보기 ${n}`}>
                        <Input placeholder={`${n}번 보기`} />
                      </Form.Item>
                    ))}
                  </>
                ),
              },
              {
                key: 'answer',
                label: '정답/해설',
                children: (
                  <>
                    <Row gutter={16}>
                      <Col span={8}>
                        <Form.Item
                          name="correctAns"
                          label="정답"
                          rules={[{ required: true, message: '정답 필수' }]}
                        >
                          <Input placeholder="정답 (예: 3)" />
                        </Form.Item>
                      </Col>
                      <Col span={8}>
                        <Form.Item name="isMultiAns" label="복수정답">
                          <Select
                            options={[
                              { value: 'N', label: '단일 정답' },
                              { value: 'Y', label: '복수 정답' },
                            ]}
                          />
                        </Form.Item>
                      </Col>
                      <Col span={8}>
                        <Form.Item name="tags" label="태그">
                          <Input placeholder="태그 (쉼표 구분)" />
                        </Form.Item>
                      </Col>
                    </Row>
                    <Form.Item name="explanation" label="해설">
                      <Input.TextArea rows={3} placeholder="해설 (선택사항)" />
                    </Form.Item>
                    <Form.Item name="correctionNote" label="정정 사항">
                      <Input.TextArea rows={2} placeholder="정정 사항 (선택사항)" />
                    </Form.Item>
                  </>
                ),
              },
            ]}
          />
        </Form>
      </Modal>

      {/* 문제 미리보기 모달 */}
      <Modal
        title={`문제 ${previewItem?.questionNo || ''} 미리보기`}
        open={!!previewItem}
        onCancel={() => setPreviewItem(null)}
        footer={<Button onClick={() => setPreviewItem(null)}>닫기</Button>}
        width={700}
      >
        {previewItem && (
          <div>
            {previewItem.questionTitle && (
              <h3>{previewItem.questionTitle}</h3>
            )}
            {previewItem.contextText && (
              <Card size="small" style={{ marginBottom: 16, background: '#f5f5f5' }}>
                <pre style={{ whiteSpace: 'pre-wrap', margin: 0 }}>{previewItem.contextText}</pre>
              </Card>
            )}
            {previewItem.questionText && (
              <p style={{ fontSize: 15, marginBottom: 16 }}>{previewItem.questionText}</p>
            )}
            <div style={{ paddingLeft: 16 }}>
              {[previewItem.choice1, previewItem.choice2, previewItem.choice3, previewItem.choice4, previewItem.choice5]
                .map((choice, idx) =>
                  choice ? (
                    <p
                      key={idx}
                      style={{
                        padding: '4px 8px',
                        background: String(idx + 1) === previewItem.correctAns ? '#e6f4ff' : undefined,
                        borderRadius: 4,
                        fontWeight: String(idx + 1) === previewItem.correctAns ? 'bold' : undefined,
                      }}
                    >
                      {idx + 1}. {choice}
                      {String(idx + 1) === previewItem.correctAns && ' ✓'}
                    </p>
                  ) : null
                )}
            </div>
            {previewItem.explanation && (
              <Card size="small" title="해설" style={{ marginTop: 16 }}>
                <p style={{ margin: 0 }}>{previewItem.explanation}</p>
              </Card>
            )}
            <div style={{ marginTop: 16, color: '#888', fontSize: 12 }}>
              <Space>
                <span>과목: {previewItem.subjectNm || previewItem.subjectCd}</span>
                <span>배점: {previewItem.score}</span>
                <span>난이도: {DIFFICULTY_OPTIONS.find((d) => d.value === previewItem.difficulty)?.label || '-'}</span>
                {previewItem.tags && <span>태그: {previewItem.tags}</span>}
              </Space>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
