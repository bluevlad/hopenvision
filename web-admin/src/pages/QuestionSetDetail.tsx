import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Table,
  Button,
  Card,
  Tag,
  Modal,
  Form,
  Input,
  InputNumber,
  message,
  Row,
  Col,
  Popconfirm,
  Descriptions,
} from 'antd';
import {
  PlusOutlined,
  DeleteOutlined,
  ArrowLeftOutlined,
  RocketOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { questionSetApi } from '../api/questionSetApi';
import type { QuestionSetItemResponse, QuestionSetItemRequest } from '../types/questionSet';
import { EXAM_TYPES, QUESTION_TYPES } from '@hopenvision/shared';

const DIFFICULTY_OPTIONS = [
  { value: '1', label: '매우 쉬움' },
  { value: '2', label: '쉬움' },
  { value: '3', label: '보통' },
  { value: '4', label: '어려움' },
  { value: '5', label: '매우 어려움' },
];

export default function QuestionSetDetail() {
  const { setId } = useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [addForm] = Form.useForm();
  const [deployForm] = Form.useForm();
  const setIdNum = Number(setId);

  const [addModalOpen, setAddModalOpen] = useState(false);
  const [deployModalOpen, setDeployModalOpen] = useState(false);

  // 세트 상세 조회
  const { data: setData, isLoading } = useQuery({
    queryKey: ['questionSet', setIdNum],
    queryFn: () => questionSetApi.getSetDetail(setIdNum),
    enabled: !!setId,
  });

  // 항목 추가
  const addItemMutation = useMutation({
    mutationFn: (data: QuestionSetItemRequest) => questionSetApi.addItem(setIdNum, data),
    onSuccess: () => {
      message.success('항목이 추가되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionSet', setIdNum] });
      setAddModalOpen(false);
      addForm.resetFields();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '추가 중 오류가 발생했습니다.');
    },
  });

  // 항목 제거
  const removeItemMutation = useMutation({
    mutationFn: (setItemId: number) => questionSetApi.removeItem(setIdNum, setItemId),
    onSuccess: () => {
      message.success('항목이 제거되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionSet', setIdNum] });
    },
    onError: () => {
      message.error('제거 중 오류가 발생했습니다.');
    },
  });

  // 시험 배치
  const deployMutation = useMutation({
    mutationFn: (examCd: string) => questionSetApi.deployToExam(setIdNum, examCd),
    onSuccess: (result) => {
      message.success(`${result.data?.deployedCount || 0}문항이 시험에 배치되었습니다.`);
      setDeployModalOpen(false);
      deployForm.resetFields();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '배치 중 오류가 발생했습니다.');
    },
  });

  const handleAddItem = () => {
    addForm.validateFields().then((values: QuestionSetItemRequest) => {
      addItemMutation.mutate(values);
    });
  };

  const handleDeploy = () => {
    deployForm.validateFields().then((values: { examCd: string }) => {
      Modal.confirm({
        title: '시험 배치 확인',
        content: `시험 [${values.examCd}]에 문제세트를 배치합니다. 해당 과목의 기존 문제/정답이 교체됩니다. 계속하시겠습니까?`,
        okText: '배치',
        cancelText: '취소',
        onOk: () => deployMutation.mutate(values.examCd),
      });
    });
  };

  const set = setData?.data;
  const items = set?.items || [];

  const columns: ColumnsType<QuestionSetItemResponse> = [
    {
      title: '순서',
      dataIndex: 'sortOrder',
      key: 'sortOrder',
      width: 60,
      align: 'center',
    },
    {
      title: '문항번호',
      dataIndex: 'questionNo',
      key: 'questionNo',
      width: 80,
      align: 'center',
    },
    {
      title: '문제',
      key: 'question',
      render: (_, record) => {
        const text = record.questionTitle || record.questionText || `(항목 ID: ${record.itemId})`;
        return text.length > 60 ? text.substring(0, 60) + '...' : text;
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
      key: 'score',
      width: 80,
      align: 'center',
      render: (_, record) => {
        if (record.score != null) {
          return <span>{record.score} <Tag color="blue" style={{ fontSize: 10 }}>커스텀</Tag></span>;
        }
        return record.bankScore ?? '-';
      },
    },
    {
      title: '난이도',
      dataIndex: 'difficulty',
      key: 'difficulty',
      width: 80,
      align: 'center',
      render: (value) => DIFFICULTY_OPTIONS.find((d) => d.value === value)?.label || value || '-',
    },
    {
      title: '유형',
      dataIndex: 'questionType',
      key: 'questionType',
      width: 80,
      align: 'center',
      render: (value) => QUESTION_TYPES.find((t) => t.value === value)?.label || value || '-',
    },
    {
      title: '관리',
      key: 'action',
      width: 80,
      align: 'center',
      render: (_, record) => (
        <Popconfirm
          title="항목을 제거하시겠습니까?"
          onConfirm={() => removeItemMutation.mutate(record.setItemId)}
          okText="제거"
          cancelText="취소"
        >
          <Button danger size="small" icon={<DeleteOutlined />}>
            제거
          </Button>
        </Popconfirm>
      ),
    },
  ];

  return (
    <div>
      <Button
        icon={<ArrowLeftOutlined />}
        onClick={() => navigate('/question-sets')}
        style={{ marginBottom: 16 }}
      >
        목록으로
      </Button>

      <Card loading={isLoading} style={{ marginBottom: 16 }}>
        {set && (
          <Descriptions title={set.setNm} bordered size="small" column={3}
            extra={
              <Button
                type="primary"
                icon={<RocketOutlined />}
                onClick={() => setDeployModalOpen(true)}
                disabled={items.length === 0}
              >
                시험에 배치
              </Button>
            }
          >
            <Descriptions.Item label="세트코드">{set.setCd}</Descriptions.Item>
            <Descriptions.Item label="과목">{set.subjectNm || set.subjectCd}</Descriptions.Item>
            <Descriptions.Item label="카테고리">
              {EXAM_TYPES.find((t) => t.value === set.category)?.label || set.category || '-'}
            </Descriptions.Item>
            <Descriptions.Item label="문제수">{set.questionCnt}문항</Descriptions.Item>
            <Descriptions.Item label="총 배점">{set.totalScore}점</Descriptions.Item>
            <Descriptions.Item label="평균 난이도">
              {DIFFICULTY_OPTIONS.find((d) => d.value === set.difficultyLevel)?.label || set.difficultyLevel || '-'}
            </Descriptions.Item>
            <Descriptions.Item label="사용여부">
              <Tag color={set.isUse === 'Y' ? 'green' : 'red'}>
                {set.isUse === 'Y' ? '사용' : '미사용'}
              </Tag>
            </Descriptions.Item>
            {set.description && (
              <Descriptions.Item label="설명" span={2}>{set.description}</Descriptions.Item>
            )}
          </Descriptions>
        )}
      </Card>

      <Card
        title={<span>세트 항목 (총 <strong>{items.length}</strong>문항)</span>}
        extra={
          <Button type="primary" icon={<PlusOutlined />} onClick={() => {
            addForm.resetFields();
            addForm.setFieldsValue({ questionNo: items.length + 1, sortOrder: items.length + 1 });
            setAddModalOpen(true);
          }}>
            항목 추가
          </Button>
        }
      >
        <Table
          columns={columns}
          dataSource={items}
          rowKey="setItemId"
          loading={isLoading}
          pagination={false}
          scroll={{ x: 900 }}
        />
      </Card>

      {/* 항목 추가 모달 */}
      <Modal
        title="문제은행 항목 추가"
        open={addModalOpen}
        onOk={handleAddItem}
        onCancel={() => setAddModalOpen(false)}
        confirmLoading={addItemMutation.isPending}
        okText="추가"
        cancelText="취소"
      >
        <Form form={addForm} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item
            name="itemId"
            label="문제은행 항목 ID"
            rules={[{ required: true, message: '문제은행 항목 ID를 입력하세요' }]}
          >
            <InputNumber min={1} style={{ width: '100%' }} placeholder="문제은행 항목 ID" />
          </Form.Item>
          <Row gutter={16}>
            <Col span={8}>
              <Form.Item name="questionNo" label="문항번호">
                <InputNumber min={1} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="score" label="배점 (오버라이드)">
                <InputNumber min={0} step={0.5} style={{ width: '100%' }} placeholder="미입력 시 기본값" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="sortOrder" label="정렬순서">
                <InputNumber min={0} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
          </Row>
        </Form>
      </Modal>

      {/* 시험 배치 모달 */}
      <Modal
        title="시험에 배치"
        open={deployModalOpen}
        onOk={handleDeploy}
        onCancel={() => setDeployModalOpen(false)}
        confirmLoading={deployMutation.isPending}
        okText="배치"
        cancelText="취소"
      >
        <Form form={deployForm} layout="vertical" style={{ marginTop: 16 }}>
          <Form.Item
            name="examCd"
            label="시험코드"
            rules={[{ required: true, message: '시험코드를 입력하세요' }]}
            extra="해당 과목의 기존 문제와 정답이 이 세트의 내용으로 교체됩니다."
          >
            <Input placeholder="예: 2024_9LEVEL_1" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
