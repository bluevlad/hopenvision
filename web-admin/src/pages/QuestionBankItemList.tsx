import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Table, Button, Space, Input, Select, Modal, Form, Tag, message, Popconfirm,
  InputNumber, Descriptions, Typography,
} from 'antd';
import {
  PlusOutlined, SearchOutlined, EditOutlined, DeleteOutlined, ReloadOutlined,
  EyeOutlined,
} from '@ant-design/icons';
import { DIFFICULTY_LEVELS } from '@hopenvision/shared';
import { questionBankApi } from '../api/questionBankApi';
import { subjectApi } from '../api/subjectApi';
import type {
  QuestionBankItemResponse,
  QuestionBankItemRequest,
} from '../types/questionBank';

const { Title } = Typography;

export default function QuestionBankItemList() {
  const queryClient = useQueryClient();
  const [searchParams, setSearchParams] = useState({
    groupId: undefined as number | undefined,
    subjectCd: '',
    difficulty: '',
    keyword: '',
    isUse: '',
    page: 0,
    size: 10,
  });
  const [modalOpen, setModalOpen] = useState(false);
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<QuestionBankItemResponse | null>(null);
  const [detailItem, setDetailItem] = useState<QuestionBankItemResponse | null>(null);
  const [form] = Form.useForm();

  const { data, isLoading } = useQuery({
    queryKey: ['questionBankItems', searchParams],
    queryFn: () => questionBankApi.getItemList({
      ...searchParams,
      subjectCd: searchParams.subjectCd || undefined,
      difficulty: searchParams.difficulty || undefined,
      keyword: searchParams.keyword || undefined,
      isUse: searchParams.isUse || undefined,
    }),
  });

  const { data: groupsData } = useQuery({
    queryKey: ['questionBankGroups', 'all'],
    queryFn: () => questionBankApi.getGroupList({ page: 0, size: 100 }),
  });

  const { data: subjectsData } = useQuery({
    queryKey: ['subjects', 'all'],
    queryFn: () => subjectApi.searchSubjects({ page: 0, size: 200 }),
  });

  const createMutation = useMutation({
    mutationFn: (data: QuestionBankItemRequest) => questionBankApi.createItem(data),
    onSuccess: () => {
      message.success('문제가 등록되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankItems'] });
      closeModal();
    },
    onError: () => message.error('문제 등록에 실패했습니다.'),
  });

  const updateMutation = useMutation({
    mutationFn: ({ itemId, data }: { itemId: number; data: QuestionBankItemRequest }) =>
      questionBankApi.updateItem(itemId, data),
    onSuccess: () => {
      message.success('문제가 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankItems'] });
      closeModal();
    },
    onError: () => message.error('문제 수정에 실패했습니다.'),
  });

  const deleteMutation = useMutation({
    mutationFn: (itemId: number) => questionBankApi.deleteItem(itemId),
    onSuccess: () => {
      message.success('문제가 삭제되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankItems'] });
    },
    onError: () => message.error('문제 삭제에 실패했습니다.'),
  });

  const groupOptions = (groupsData?.data || []).map((g) => ({
    value: g.groupId,
    label: `${g.groupNm} (${g.groupCd})`,
  }));

  const subjectOptions = (subjectsData?.data || []).map((s) => ({
    value: s.subjectCd,
    label: `${s.subjectNm} (${s.subjectCd})`,
  }));

  const openCreateModal = () => {
    setEditingItem(null);
    form.resetFields();
    form.setFieldsValue({
      isUse: 'Y',
      isMultiAns: 'N',
      questionType: 'CHOICE',
      score: 5,
    });
    setModalOpen(true);
  };

  const openEditModal = (record: QuestionBankItemResponse) => {
    setEditingItem(record);
    form.setFieldsValue(record);
    setModalOpen(true);
  };

  const openDetailModal = async (itemId: number) => {
    try {
      const result = await questionBankApi.getItemDetail(itemId);
      setDetailItem(result.data);
      setDetailModalOpen(true);
    } catch {
      message.error('상세 조회에 실패했습니다.');
    }
  };

  const closeModal = () => {
    setModalOpen(false);
    setEditingItem(null);
    form.resetFields();
  };

  const handleSubmit = async () => {
    const values = await form.validateFields();
    if (editingItem) {
      updateMutation.mutate({ itemId: editingItem.itemId, data: values });
    } else {
      createMutation.mutate(values);
    }
  };

  const columns = [
    {
      title: '번호',
      dataIndex: 'questionNo',
      key: 'questionNo',
      width: 60,
      align: 'center' as const,
    },
    {
      title: '그룹',
      dataIndex: 'groupNm',
      key: 'groupNm',
      width: 150,
      ellipsis: true,
      render: (val: string) => val || '-',
    },
    {
      title: '과목',
      dataIndex: 'subjectNm',
      key: 'subjectNm',
      width: 100,
      render: (val: string) => val || '-',
    },
    {
      title: '문제',
      dataIndex: 'questionTitle',
      key: 'questionTitle',
      ellipsis: true,
      render: (val: string, record: QuestionBankItemResponse) =>
        val || record.questionText?.substring(0, 80) || '-',
    },
    {
      title: '정답',
      dataIndex: 'correctAns',
      key: 'correctAns',
      width: 60,
      align: 'center' as const,
    },
    {
      title: '난이도',
      dataIndex: 'difficulty',
      key: 'difficulty',
      width: 70,
      align: 'center' as const,
      render: (val: string) => {
        const found = DIFFICULTY_LEVELS.find((d) => d.value === val);
        if (!found) return '-';
        const color = val === 'EASY' ? 'green' : val === 'MEDIUM' ? 'orange' : 'red';
        return <Tag color={color}>{found.label}</Tag>;
      },
    },
    {
      title: '배점',
      dataIndex: 'score',
      key: 'score',
      width: 60,
      align: 'center' as const,
    },
    {
      title: '사용',
      dataIndex: 'isUse',
      key: 'isUse',
      width: 60,
      align: 'center' as const,
      render: (val: string) => (
        <Tag color={val === 'Y' ? 'green' : 'default'}>{val === 'Y' ? '사용' : '미사용'}</Tag>
      ),
    },
    {
      title: '작업',
      key: 'actions',
      width: 140,
      render: (_: unknown, record: QuestionBankItemResponse) => (
        <Space size="small">
          <Button size="small" icon={<EyeOutlined />} onClick={() => openDetailModal(record.itemId)} />
          <Button size="small" icon={<EditOutlined />} onClick={() => openEditModal(record)} />
          <Popconfirm title="이 문제를 삭제하시겠습니까?" onConfirm={() => deleteMutation.mutate(record.itemId)}>
            <Button size="small" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Title level={4}>문제은행 문제</Title>

      <Space style={{ marginBottom: 16 }} wrap>
        <Input
          placeholder="문제 제목/내용/태그 검색"
          value={searchParams.keyword}
          onChange={(e) => setSearchParams((prev) => ({ ...prev, keyword: e.target.value, page: 0 }))}
          onPressEnter={() => queryClient.invalidateQueries({ queryKey: ['questionBankItems'] })}
          style={{ width: 220 }}
          prefix={<SearchOutlined />}
        />
        <Select
          placeholder="그룹"
          allowClear
          showSearch
          optionFilterProp="label"
          style={{ width: 200 }}
          value={searchParams.groupId}
          onChange={(val) => setSearchParams((prev) => ({ ...prev, groupId: val, page: 0 }))}
          options={groupOptions}
        />
        <Select
          placeholder="과목"
          allowClear
          showSearch
          optionFilterProp="label"
          style={{ width: 160 }}
          value={searchParams.subjectCd || undefined}
          onChange={(val) => setSearchParams((prev) => ({ ...prev, subjectCd: val || '', page: 0 }))}
          options={subjectOptions}
        />
        <Select
          placeholder="난이도"
          allowClear
          style={{ width: 100 }}
          value={searchParams.difficulty || undefined}
          onChange={(val) => setSearchParams((prev) => ({ ...prev, difficulty: val || '', page: 0 }))}
          options={DIFFICULTY_LEVELS}
        />
        <Button icon={<SearchOutlined />} onClick={() => queryClient.invalidateQueries({ queryKey: ['questionBankItems'] })}>
          검색
        </Button>
        <Button
          icon={<ReloadOutlined />}
          onClick={() =>
            setSearchParams({ groupId: undefined, subjectCd: '', difficulty: '', keyword: '', isUse: '', page: 0, size: 10 })
          }
        >
          초기화
        </Button>
        <Button type="primary" icon={<PlusOutlined />} onClick={openCreateModal}>
          문제 등록
        </Button>
      </Space>

      <Table
        columns={columns}
        dataSource={data?.data || []}
        rowKey="itemId"
        loading={isLoading}
        size="small"
        pagination={{
          current: (data?.page ?? 0) + 1,
          pageSize: data?.size ?? 10,
          total: data?.totalElements ?? 0,
          showSizeChanger: true,
          showTotal: (total) => `총 ${total}건`,
          onChange: (page, pageSize) =>
            setSearchParams((prev) => ({ ...prev, page: page - 1, size: pageSize })),
        }}
      />

      {/* 등록/수정 모달 */}
      <Modal
        title={editingItem ? '문제 수정' : '문제 등록'}
        open={modalOpen}
        onOk={handleSubmit}
        onCancel={closeModal}
        confirmLoading={createMutation.isPending || updateMutation.isPending}
        width={800}
      >
        <Form form={form} layout="vertical">
          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item
              name="groupId"
              label="그룹"
              rules={[{ required: true, message: '그룹을 선택하세요' }]}
              style={{ flex: 2 }}
            >
              <Select showSearch optionFilterProp="label" placeholder="그룹 선택" options={groupOptions} />
            </Form.Item>
            <Form.Item
              name="subjectCd"
              label="과목"
              rules={[{ required: true, message: '과목을 선택하세요' }]}
              style={{ flex: 1 }}
            >
              <Select showSearch optionFilterProp="label" placeholder="과목 선택" options={subjectOptions} />
            </Form.Item>
            <Form.Item name="questionNo" label="문항번호" style={{ flex: 1 }}>
              <InputNumber min={1} style={{ width: '100%' }} />
            </Form.Item>
          </Space>

          <Form.Item name="questionTitle" label="문제 제목">
            <Input placeholder="문제 제목 (선택)" />
          </Form.Item>
          <Form.Item name="questionText" label="문제 지문">
            <Input.TextArea rows={3} placeholder="문제 지문" />
          </Form.Item>

          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item name="choice1" label="1번" style={{ flex: 1 }}>
              <Input />
            </Form.Item>
            <Form.Item name="choice2" label="2번" style={{ flex: 1 }}>
              <Input />
            </Form.Item>
          </Space>
          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item name="choice3" label="3번" style={{ flex: 1 }}>
              <Input />
            </Form.Item>
            <Form.Item name="choice4" label="4번" style={{ flex: 1 }}>
              <Input />
            </Form.Item>
          </Space>
          <Form.Item name="choice5" label="5번">
            <Input />
          </Form.Item>

          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item
              name="correctAns"
              label="정답"
              rules={[{ required: true, message: '정답을 입력하세요' }]}
              style={{ flex: 1 }}
            >
              <Input placeholder="예: 1, 2, 1,3" />
            </Form.Item>
            <Form.Item name="isMultiAns" label="복수정답" style={{ flex: 1 }}>
              <Select options={[{ value: 'N', label: '아니오' }, { value: 'Y', label: '예' }]} />
            </Form.Item>
            <Form.Item name="score" label="배점" style={{ flex: 1 }}>
              <InputNumber min={0} style={{ width: '100%' }} />
            </Form.Item>
          </Space>

          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item name="difficulty" label="난이도" style={{ flex: 1 }}>
              <Select allowClear placeholder="선택" options={DIFFICULTY_LEVELS} />
            </Form.Item>
            <Form.Item name="questionType" label="문제유형" style={{ flex: 1 }}>
              <Select
                options={[
                  { value: 'CHOICE', label: '객관식' },
                  { value: 'ESSAY', label: '주관식' },
                ]}
              />
            </Form.Item>
            <Form.Item name="category" label="출제영역" style={{ flex: 1 }}>
              <Input placeholder="선택사항" />
            </Form.Item>
          </Space>

          <Form.Item name="tags" label="태그 (쉼표 구분)">
            <Input placeholder="예: 헌법, 기본권, 자유권" />
          </Form.Item>
          <Form.Item name="explanation" label="해설">
            <Input.TextArea rows={3} />
          </Form.Item>
          <Form.Item name="isUse" label="사용여부">
            <Select options={[{ value: 'Y', label: '사용' }, { value: 'N', label: '미사용' }]} />
          </Form.Item>
        </Form>
      </Modal>

      {/* 상세 모달 */}
      <Modal
        title={`문제 상세 - #${detailItem?.questionNo || ''}`}
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={700}
      >
        {detailItem && (
          <Descriptions column={2} bordered size="small">
            <Descriptions.Item label="그룹">{detailItem.groupNm || '-'}</Descriptions.Item>
            <Descriptions.Item label="과목">{detailItem.subjectNm || detailItem.subjectCd}</Descriptions.Item>
            <Descriptions.Item label="문항번호">{detailItem.questionNo}</Descriptions.Item>
            <Descriptions.Item label="정답">{detailItem.correctAns}</Descriptions.Item>
            <Descriptions.Item label="문제 제목" span={2}>{detailItem.questionTitle || '-'}</Descriptions.Item>
            <Descriptions.Item label="문제 지문" span={2}>
              <div style={{ whiteSpace: 'pre-wrap' }}>{detailItem.questionText || '-'}</div>
            </Descriptions.Item>
            <Descriptions.Item label="1번">{detailItem.choice1 || '-'}</Descriptions.Item>
            <Descriptions.Item label="2번">{detailItem.choice2 || '-'}</Descriptions.Item>
            <Descriptions.Item label="3번">{detailItem.choice3 || '-'}</Descriptions.Item>
            <Descriptions.Item label="4번">{detailItem.choice4 || '-'}</Descriptions.Item>
            <Descriptions.Item label="5번" span={2}>{detailItem.choice5 || '-'}</Descriptions.Item>
            <Descriptions.Item label="난이도">
              {DIFFICULTY_LEVELS.find((d) => d.value === detailItem.difficulty)?.label || '-'}
            </Descriptions.Item>
            <Descriptions.Item label="배점">{detailItem.score ?? '-'}</Descriptions.Item>
            <Descriptions.Item label="출제영역">{detailItem.category || '-'}</Descriptions.Item>
            <Descriptions.Item label="태그">{detailItem.tags || '-'}</Descriptions.Item>
            <Descriptions.Item label="해설" span={2}>
              <div style={{ whiteSpace: 'pre-wrap' }}>{detailItem.explanation || '-'}</div>
            </Descriptions.Item>
            {detailItem.correctionNote && (
              <Descriptions.Item label="정오표" span={2}>
                <div style={{ whiteSpace: 'pre-wrap', color: 'red' }}>{detailItem.correctionNote}</div>
              </Descriptions.Item>
            )}
          </Descriptions>
        )}
      </Modal>
    </div>
  );
}
