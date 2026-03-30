import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Table, Button, Space, Input, Select, Modal, Form, Tag, message, Popconfirm,
  InputNumber, Typography,
} from 'antd';
import {
  PlusOutlined, SearchOutlined, EditOutlined, DeleteOutlined, ReloadOutlined,
  EyeOutlined,
} from '@ant-design/icons';
import { EXAM_TYPES, QUESTION_SOURCES } from '@hopenvision/shared';
import type { PageResponse } from '@hopenvision/shared';
import { questionBankApi } from '../api/questionBankApi';
import type {
  QuestionBankGroupResponse,
  QuestionBankGroupDetailResponse,
  QuestionBankGroupRequest,
} from '../types/questionBank';

const { Title } = Typography;

export default function QuestionBankGroupList() {
  const queryClient = useQueryClient();
  const [searchParams, setSearchParams] = useState({ keyword: '', category: '', examYear: '', isUse: '', page: 0, size: 10 });
  const [modalOpen, setModalOpen] = useState(false);
  const [detailModalOpen, setDetailModalOpen] = useState(false);
  const [editingGroup, setEditingGroup] = useState<QuestionBankGroupResponse | null>(null);
  const [detailGroup, setDetailGroup] = useState<QuestionBankGroupDetailResponse | null>(null);
  const [form] = Form.useForm();

  const { data, isLoading } = useQuery({
    queryKey: ['questionBankGroups', searchParams],
    queryFn: () => questionBankApi.getGroupList(searchParams),
  });

  const createMutation = useMutation({
    mutationFn: (data: QuestionBankGroupRequest) => questionBankApi.createGroup(data),
    onSuccess: () => {
      message.success('그룹이 등록되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] });
      closeModal();
    },
    onError: () => message.error('그룹 등록에 실패했습니다.'),
  });

  const updateMutation = useMutation({
    mutationFn: ({ groupId, data }: { groupId: number; data: QuestionBankGroupRequest }) =>
      questionBankApi.updateGroup(groupId, data),
    onSuccess: () => {
      message.success('그룹이 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] });
      closeModal();
    },
    onError: () => message.error('그룹 수정에 실패했습니다.'),
  });

  const deleteMutation = useMutation({
    mutationFn: (groupId: number) => questionBankApi.deleteGroup(groupId),
    onSuccess: () => {
      message.success('그룹이 삭제되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] });
    },
    onError: () => message.error('그룹 삭제에 실패했습니다.'),
  });

  const openCreateModal = () => {
    setEditingGroup(null);
    form.resetFields();
    form.setFieldsValue({ isUse: 'Y' });
    setModalOpen(true);
  };

  const openEditModal = (record: QuestionBankGroupResponse) => {
    setEditingGroup(record);
    form.setFieldsValue(record);
    setModalOpen(true);
  };

  const openDetailModal = async (groupId: number) => {
    try {
      const result = await questionBankApi.getGroupDetail(groupId);
      setDetailGroup(result.data);
      setDetailModalOpen(true);
    } catch {
      message.error('상세 조회에 실패했습니다.');
    }
  };

  const closeModal = () => {
    setModalOpen(false);
    setEditingGroup(null);
    form.resetFields();
  };

  const handleSubmit = async () => {
    const values = await form.validateFields();
    if (editingGroup) {
      updateMutation.mutate({ groupId: editingGroup.groupId, data: values });
    } else {
      createMutation.mutate(values);
    }
  };

  const yearOptions = Array.from({ length: 10 }, (_, i) => {
    const year = String(new Date().getFullYear() - i);
    return { value: year, label: year };
  });

  const columns = [
    {
      title: '그룹코드',
      dataIndex: 'groupCd',
      key: 'groupCd',
      width: 150,
    },
    {
      title: '그룹명',
      dataIndex: 'groupNm',
      key: 'groupNm',
      ellipsis: true,
    },
    {
      title: '연도',
      dataIndex: 'examYear',
      key: 'examYear',
      width: 70,
      align: 'center' as const,
    },
    {
      title: '회차',
      dataIndex: 'examRound',
      key: 'examRound',
      width: 60,
      align: 'center' as const,
    },
    {
      title: '카테고리',
      dataIndex: 'category',
      key: 'category',
      width: 110,
      render: (val: string) => {
        const found = EXAM_TYPES.find((t) => t.value === val);
        return found ? <Tag>{found.label}</Tag> : val || '-';
      },
    },
    {
      title: '출처',
      dataIndex: 'source',
      key: 'source',
      width: 90,
      render: (val: string) => {
        const found = QUESTION_SOURCES.find((s) => s.value === val);
        return found ? found.label : val || '-';
      },
    },
    {
      title: '문제수',
      dataIndex: 'itemCount',
      key: 'itemCount',
      width: 70,
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
      render: (_: unknown, record: QuestionBankGroupResponse) => (
        <Space size="small">
          <Button size="small" icon={<EyeOutlined />} onClick={() => openDetailModal(record.groupId)} />
          <Button size="small" icon={<EditOutlined />} onClick={() => openEditModal(record)} />
          <Popconfirm
            title="이 그룹을 삭제하시겠습니까?"
            description="그룹에 포함된 문제도 함께 삭제됩니다."
            onConfirm={() => deleteMutation.mutate(record.groupId)}
          >
            <Button size="small" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Title level={4}>문제은행 그룹</Title>

      <Space style={{ marginBottom: 16 }} wrap>
        <Input
          placeholder="그룹코드/그룹명 검색"
          value={searchParams.keyword}
          onChange={(e) => setSearchParams((prev) => ({ ...prev, keyword: e.target.value, page: 0 }))}
          onPressEnter={() => queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] })}
          style={{ width: 200 }}
          prefix={<SearchOutlined />}
        />
        <Select
          placeholder="카테고리"
          allowClear
          style={{ width: 140 }}
          value={searchParams.category || undefined}
          onChange={(val) => setSearchParams((prev) => ({ ...prev, category: val || '', page: 0 }))}
          options={EXAM_TYPES}
        />
        <Select
          placeholder="시험연도"
          allowClear
          style={{ width: 100 }}
          value={searchParams.examYear || undefined}
          onChange={(val) => setSearchParams((prev) => ({ ...prev, examYear: val || '', page: 0 }))}
          options={yearOptions}
        />
        <Button icon={<SearchOutlined />} onClick={() => queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] })}>
          검색
        </Button>
        <Button
          icon={<ReloadOutlined />}
          onClick={() => setSearchParams({ keyword: '', category: '', examYear: '', isUse: '', page: 0, size: 10 })}
        >
          초기화
        </Button>
        <Button type="primary" icon={<PlusOutlined />} onClick={openCreateModal}>
          그룹 등록
        </Button>
      </Space>

      <Table
        columns={columns}
        dataSource={(data?.data as PageResponse<QuestionBankGroupResponse> | undefined)?.content || []}
        rowKey="groupId"
        loading={isLoading}
        size="small"
        pagination={{
          current: ((data?.data as PageResponse<QuestionBankGroupResponse> | undefined)?.number ?? 0) + 1,
          pageSize: (data?.data as PageResponse<QuestionBankGroupResponse> | undefined)?.size ?? 10,
          total: (data?.data as PageResponse<QuestionBankGroupResponse> | undefined)?.totalElements ?? 0,
          showSizeChanger: true,
          showTotal: (total) => `총 ${total}건`,
          onChange: (page, pageSize) =>
            setSearchParams((prev) => ({ ...prev, page: page - 1, size: pageSize })),
        }}
      />

      {/* 등록/수정 모달 */}
      <Modal
        title={editingGroup ? '그룹 수정' : '그룹 등록'}
        open={modalOpen}
        onOk={handleSubmit}
        onCancel={closeModal}
        confirmLoading={createMutation.isPending || updateMutation.isPending}
        width={600}
      >
        <Form form={form} layout="vertical">
          <Form.Item
            name="groupCd"
            label="그룹코드"
            rules={[{ required: true, message: '그룹코드를 입력하세요' }]}
          >
            <Input disabled={!!editingGroup} placeholder="예: 2026-9LEVEL-R1" />
          </Form.Item>
          <Form.Item
            name="groupNm"
            label="그룹명"
            rules={[{ required: true, message: '그룹명을 입력하세요' }]}
          >
            <Input placeholder="예: 2026년 9급 공무원 1회차" />
          </Form.Item>
          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item name="examYear" label="시험연도" style={{ flex: 1 }}>
              <Select allowClear placeholder="선택" options={yearOptions} />
            </Form.Item>
            <Form.Item name="examRound" label="회차" style={{ flex: 1 }}>
              <InputNumber min={1} max={99} style={{ width: '100%' }} />
            </Form.Item>
          </Space>
          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item name="category" label="카테고리" style={{ flex: 1 }}>
              <Select allowClear placeholder="선택" options={EXAM_TYPES} />
            </Form.Item>
            <Form.Item name="source" label="출처" style={{ flex: 1 }}>
              <Select allowClear placeholder="선택" options={QUESTION_SOURCES} />
            </Form.Item>
            <Form.Item name="isUse" label="사용여부" style={{ flex: 1 }}>
              <Select
                options={[
                  { value: 'Y', label: '사용' },
                  { value: 'N', label: '미사용' },
                ]}
              />
            </Form.Item>
          </Space>
          <Form.Item name="description" label="설명">
            <Input.TextArea rows={3} />
          </Form.Item>
        </Form>
      </Modal>

      {/* 상세 모달 */}
      <Modal
        title={`그룹 상세 - ${detailGroup?.groupNm || ''}`}
        open={detailModalOpen}
        onCancel={() => setDetailModalOpen(false)}
        footer={null}
        width={800}
      >
        {detailGroup && (
          <div>
            <Space direction="vertical" style={{ width: '100%', marginBottom: 16 }}>
              <div><strong>그룹코드:</strong> {detailGroup.groupCd}</div>
              <div><strong>카테고리:</strong> {EXAM_TYPES.find((t) => t.value === detailGroup.category)?.label || detailGroup.category || '-'}</div>
              <div><strong>출처:</strong> {QUESTION_SOURCES.find((s) => s.value === detailGroup.source)?.label || detailGroup.source || '-'}</div>
              <div><strong>문제 수:</strong> {detailGroup.items?.length || 0}개</div>
            </Space>
            <Table
              dataSource={detailGroup.items || []}
              rowKey="itemId"
              size="small"
              pagination={false}
              scroll={{ y: 400 }}
              columns={[
                { title: '번호', dataIndex: 'questionNo', width: 60, align: 'center' as const },
                { title: '과목', dataIndex: 'subjectNm', width: 100, render: (v: string) => v || '-' },
                { title: '문제', dataIndex: 'questionTitle', ellipsis: true, render: (v: string, r: { questionText?: string | null }) => v || r.questionText?.substring(0, 50) || '-' },
                { title: '정답', dataIndex: 'correctAns', width: 60, align: 'center' as const },
                { title: '난이도', dataIndex: 'difficulty', width: 70, align: 'center' as const, render: (v: string) => v || '-' },
              ]}
            />
          </div>
        )}
      </Modal>
    </div>
  );
}
