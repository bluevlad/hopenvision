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

  const { data: setData, isLoading } = useQuery({
    queryKey: ['questionSet', setIdNum],
    queryFn: () => questionSetApi.getSetDetail(setIdNum),
    enabled: !!setId,
  });

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

  const deployMutation = useMutation({
    mutationFn: (examCd: string) => questionSetApi.deployToExam(setIdNum, examCd),
    onSuccess: (result) => {
      const data = result.data;
      message.success(`${data?.subjectCount || 0}과목, ${data?.deployedCount || 0}문항이 시험에 배치되었습니다.`);
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
        content: `시험 [${values.examCd}]에 문제세트를 배치합니다. 각 과목의 기존 문제/정답이 교체되고, 시험에 문제세트가 연결됩니다. 계속하시겠습니까?`,
        okText: '배치',
        cancelText: '취소',
        onOk: () => deployMutation.mutate(values.examCd),
      });
    });
  };

  const set = setData?.data;
  const items = set?.items || [];
  const summaries = set?.subjectSummaries || [];

  // 과목별로 그룹핑
  const itemsBySubject: Record<string, QuestionSetItemResponse[]> = {};
  for (const item of items) {
    const key = item.subjectCd;
    if (!itemsBySubject[key]) itemsBySubject[key] = [];
    itemsBySubject[key].push(item);
  }

  const columns: ColumnsType<QuestionSetItemResponse> = [
    { title: '순서', dataIndex: 'sortOrder', key: 'sortOrder', width: 60, align: 'center' },
    { title: '문항', dataIndex: 'questionNo', key: 'questionNo', width: 60, align: 'center' },
    {
      title: '문제',
      key: 'question',
      render: (_, record) => {
        const text = record.questionTitle || record.questionText || `(항목 ID: ${record.itemId})`;
        return text.length > 50 ? text.substring(0, 50) + '...' : text;
      },
    },
    { title: '정답', dataIndex: 'correctAns', key: 'correctAns', width: 50, align: 'center' },
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
      width: 70,
      align: 'center',
      render: (value) => DIFFICULTY_OPTIONS.find((d) => d.value === value)?.label || value || '-',
    },
    {
      title: '유형',
      dataIndex: 'questionType',
      key: 'questionType',
      width: 70,
      align: 'center',
      render: (value) => QUESTION_TYPES.find((t) => t.value === value)?.label || value || '-',
    },
    {
      title: '',
      key: 'action',
      width: 70,
      align: 'center',
      render: (_, record) => (
        <Popconfirm
          title="항목을 제거하시겠습니까?"
          onConfirm={() => removeItemMutation.mutate(record.setItemId)}
          okText="제거"
          cancelText="취소"
        >
          <Button danger size="small" icon={<DeleteOutlined />} />
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
            <Descriptions.Item label="카테고리">
              {EXAM_TYPES.find((t) => t.value === set.category)?.label || set.category || '-'}
            </Descriptions.Item>
            <Descriptions.Item label="사용여부">
              <Tag color={set.isUse === 'Y' ? 'green' : 'red'}>
                {set.isUse === 'Y' ? '사용' : '미사용'}
              </Tag>
            </Descriptions.Item>
            <Descriptions.Item label="과목 구성" span={3}>
              {summaries.length > 0 ? summaries.map((s) => (
                <Tag key={s.subjectCd} color="blue" style={{ marginBottom: 4 }}>
                  {s.subjectNm} ({s.itemCount}문항)
                </Tag>
              )) : <Tag>미설정</Tag>}
            </Descriptions.Item>
            <Descriptions.Item label="총 문제수">{set.questionCnt}문항</Descriptions.Item>
            <Descriptions.Item label="총 배점">{set.totalScore}점</Descriptions.Item>
            <Descriptions.Item label="과목수">{set.subjectCnt}과목</Descriptions.Item>
            {set.description && (
              <Descriptions.Item label="설명" span={3}>{set.description}</Descriptions.Item>
            )}
          </Descriptions>
        )}
      </Card>

      {/* 과목별 문제 테이블 */}
      {Object.entries(itemsBySubject).map(([subjectCd, subjectItems]) => {
        const subjectNm = subjectItems[0]?.subjectNm || subjectCd;
        return (
          <Card
            key={subjectCd}
            title={<span>{subjectNm} <Tag color="blue">{subjectCd}</Tag> ({subjectItems.length}문항)</span>}
            style={{ marginBottom: 16 }}
            size="small"
          >
            <Table
              columns={columns}
              dataSource={subjectItems}
              rowKey="setItemId"
              pagination={false}
              size="small"
              scroll={{ x: 700 }}
            />
          </Card>
        );
      })}

      {items.length === 0 && !isLoading && (
        <Card>
          <div style={{ textAlign: 'center', padding: '40px 0', color: '#999' }}>
            문제가 없습니다. 아래 버튼으로 문제를 추가하세요.
          </div>
        </Card>
      )}

      <div style={{ textAlign: 'center', margin: '16px 0' }}>
        <Button type="primary" icon={<PlusOutlined />} onClick={() => {
          addForm.resetFields();
          addForm.setFieldsValue({ questionNo: items.length + 1, sortOrder: items.length + 1 });
          setAddModalOpen(true);
        }}>
          문제 추가
        </Button>
      </div>

      {/* 항목 추가 모달 */}
      <Modal
        title="문제 추가 (문제은행에서 선택)"
        open={addModalOpen}
        onOk={handleAddItem}
        onCancel={() => setAddModalOpen(false)}
        confirmLoading={addItemMutation.isPending}
        okText="추가"
        cancelText="취소"
      >
        <Form form={addForm} layout="vertical" style={{ marginTop: 16 }}>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="itemId"
                label="문제은행 항목 ID"
                rules={[{ required: true, message: '문제은행 항목 ID를 입력하세요' }]}
              >
                <InputNumber min={1} style={{ width: '100%' }} placeholder="문제은행 항목 ID" />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="subjectCd"
                label="과목코드"
                rules={[{ required: true, message: '과목코드를 입력하세요' }]}
              >
                <Input placeholder="예: KOREAN" />
              </Form.Item>
            </Col>
          </Row>
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
            extra="각 과목의 기존 문제와 정답이 이 세트의 내용으로 교체되고, 시험에 문제세트가 연결됩니다."
          >
            <Input placeholder="예: 2024_9LEVEL_1" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
