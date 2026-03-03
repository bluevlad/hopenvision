import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Table, Button, Space, Input, Select, Modal, Form, Tag, message, Popconfirm,
  InputNumber, Typography,
} from 'antd';
import {
  PlusOutlined, SearchOutlined, EditOutlined, DeleteOutlined, ReloadOutlined,
} from '@ant-design/icons';
import { EXAM_TYPES } from '@hopenvision/shared';
import { subjectApi } from '../api/subjectApi';
import type { SubjectMasterResponse, SubjectMasterRequest } from '../types/subject';

const { Title } = Typography;

export default function SubjectMasterList() {
  const queryClient = useQueryClient();
  const [searchParams, setSearchParams] = useState({ keyword: '', category: '', isUse: '', page: 0, size: 20 });
  const [modalOpen, setModalOpen] = useState(false);
  const [editingSubject, setEditingSubject] = useState<SubjectMasterResponse | null>(null);
  const [form] = Form.useForm();

  const { data, isLoading } = useQuery({
    queryKey: ['subjects', searchParams],
    queryFn: () => subjectApi.searchSubjects(searchParams),
  });

  const createMutation = useMutation({
    mutationFn: (data: SubjectMasterRequest) => subjectApi.createSubject(data),
    onSuccess: () => {
      message.success('과목이 등록되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
      closeModal();
    },
    onError: () => message.error('과목 등록에 실패했습니다.'),
  });

  const updateMutation = useMutation({
    mutationFn: ({ subjectCd, data }: { subjectCd: string; data: SubjectMasterRequest }) =>
      subjectApi.updateSubject(subjectCd, data),
    onSuccess: () => {
      message.success('과목이 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
      closeModal();
    },
    onError: () => message.error('과목 수정에 실패했습니다.'),
  });

  const deleteMutation = useMutation({
    mutationFn: (subjectCd: string) => subjectApi.deleteSubject(subjectCd),
    onSuccess: () => {
      message.success('과목이 삭제되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
    },
    onError: () => message.error('과목 삭제에 실패했습니다.'),
  });

  const openCreateModal = () => {
    setEditingSubject(null);
    form.resetFields();
    form.setFieldsValue({ subjectDepth: 1, sortOrder: 1, isUse: 'Y' });
    setModalOpen(true);
  };

  const openEditModal = (record: SubjectMasterResponse) => {
    setEditingSubject(record);
    form.setFieldsValue(record);
    setModalOpen(true);
  };

  const closeModal = () => {
    setModalOpen(false);
    setEditingSubject(null);
    form.resetFields();
  };

  const handleSubmit = async () => {
    const values = await form.validateFields();
    if (editingSubject) {
      updateMutation.mutate({ subjectCd: editingSubject.subjectCd, data: values });
    } else {
      createMutation.mutate(values);
    }
  };

  const columns = [
    {
      title: '과목코드',
      dataIndex: 'subjectCd',
      key: 'subjectCd',
      width: 120,
    },
    {
      title: '과목명',
      dataIndex: 'subjectNm',
      key: 'subjectNm',
    },
    {
      title: '카테고리',
      dataIndex: 'category',
      key: 'category',
      width: 120,
      render: (val: string) => {
        const found = EXAM_TYPES.find((t) => t.value === val);
        return found ? <Tag>{found.label}</Tag> : val || '-';
      },
    },
    {
      title: '깊이',
      dataIndex: 'subjectDepth',
      key: 'subjectDepth',
      width: 60,
      align: 'center' as const,
    },
    {
      title: '정렬',
      dataIndex: 'sortOrder',
      key: 'sortOrder',
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
      width: 120,
      render: (_: unknown, record: SubjectMasterResponse) => (
        <Space size="small">
          <Button size="small" icon={<EditOutlined />} onClick={() => openEditModal(record)} />
          <Popconfirm
            title="이 과목을 삭제하시겠습니까?"
            onConfirm={() => deleteMutation.mutate(record.subjectCd)}
          >
            <Button size="small" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Title level={4}>과목 관리</Title>

      <Space style={{ marginBottom: 16 }} wrap>
        <Input
          placeholder="과목코드/과목명 검색"
          value={searchParams.keyword}
          onChange={(e) => setSearchParams((prev) => ({ ...prev, keyword: e.target.value, page: 0 }))}
          onPressEnter={() => queryClient.invalidateQueries({ queryKey: ['subjects'] })}
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
          placeholder="사용여부"
          allowClear
          style={{ width: 100 }}
          value={searchParams.isUse || undefined}
          onChange={(val) => setSearchParams((prev) => ({ ...prev, isUse: val || '', page: 0 }))}
          options={[
            { value: 'Y', label: '사용' },
            { value: 'N', label: '미사용' },
          ]}
        />
        <Button
          icon={<SearchOutlined />}
          onClick={() => queryClient.invalidateQueries({ queryKey: ['subjects'] })}
        >
          검색
        </Button>
        <Button
          icon={<ReloadOutlined />}
          onClick={() => {
            setSearchParams({ keyword: '', category: '', isUse: '', page: 0, size: 20 });
          }}
        >
          초기화
        </Button>
        <Button type="primary" icon={<PlusOutlined />} onClick={openCreateModal}>
          과목 등록
        </Button>
      </Space>

      <Table
        columns={columns}
        dataSource={data?.data || []}
        rowKey="subjectCd"
        loading={isLoading}
        size="small"
        pagination={{
          current: (data?.page ?? 0) + 1,
          pageSize: data?.size ?? 20,
          total: data?.totalElements ?? 0,
          showSizeChanger: true,
          showTotal: (total) => `총 ${total}건`,
          onChange: (page, pageSize) =>
            setSearchParams((prev) => ({ ...prev, page: page - 1, size: pageSize })),
        }}
      />

      <Modal
        title={editingSubject ? '과목 수정' : '과목 등록'}
        open={modalOpen}
        onOk={handleSubmit}
        onCancel={closeModal}
        confirmLoading={createMutation.isPending || updateMutation.isPending}
        width={600}
      >
        <Form form={form} layout="vertical">
          <Form.Item
            name="subjectCd"
            label="과목코드"
            rules={[{ required: true, message: '과목코드를 입력하세요' }]}
          >
            <Input disabled={!!editingSubject} placeholder="예: KOREAN, ENGLISH" />
          </Form.Item>
          <Form.Item
            name="subjectNm"
            label="과목명"
            rules={[{ required: true, message: '과목명을 입력하세요' }]}
          >
            <Input placeholder="예: 국어, 영어" />
          </Form.Item>
          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item name="category" label="카테고리" style={{ flex: 1 }}>
              <Select allowClear placeholder="선택" options={EXAM_TYPES} />
            </Form.Item>
            <Form.Item name="parentSubjectCd" label="상위과목코드" style={{ flex: 1 }}>
              <Input placeholder="선택사항" />
            </Form.Item>
          </Space>
          <Space style={{ width: '100%' }} styles={{ item: { flex: 1 } }}>
            <Form.Item name="subjectDepth" label="깊이" style={{ flex: 1 }}>
              <InputNumber min={1} max={3} style={{ width: '100%' }} />
            </Form.Item>
            <Form.Item name="sortOrder" label="정렬순서" style={{ flex: 1 }}>
              <InputNumber min={1} style={{ width: '100%' }} />
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
    </div>
  );
}
