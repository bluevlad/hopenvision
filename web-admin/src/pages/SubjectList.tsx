import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Table,
  Button,
  Space,
  Input,
  Select,
  Card,
  Tag,
  Modal,
  Form,
  message,
  Row,
  Col,
  Popconfirm,
  InputNumber,
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  DeleteOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { subjectApi } from '../api/subjectApi';
import type { SubjectMasterResponse, SubjectMasterRequest } from '../types/subject';
import { EXAM_TYPES } from '@hopenvision/shared';

export default function SubjectList() {
  const queryClient = useQueryClient();
  const [form] = Form.useForm();

  const [searchParams, setSearchParams] = useState({
    keyword: '',
    category: '',
    isUse: '',
    page: 0,
    size: 20,
  });

  const [modalOpen, setModalOpen] = useState(false);
  const [editingSubject, setEditingSubject] = useState<SubjectMasterResponse | null>(null);

  // 과목 목록 조회
  const { data, isLoading } = useQuery({
    queryKey: ['subjects', searchParams],
    queryFn: () => subjectApi.getSubjectList(searchParams),
  });

  // 과목 등록
  const createMutation = useMutation({
    mutationFn: subjectApi.createSubject,
    onSuccess: () => {
      message.success('과목이 등록되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
      handleCloseModal();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '등록 중 오류가 발생했습니다.');
    },
  });

  // 과목 수정
  const updateMutation = useMutation({
    mutationFn: ({ subjectCd, data }: { subjectCd: string; data: SubjectMasterRequest }) =>
      subjectApi.updateSubject(subjectCd, data),
    onSuccess: () => {
      message.success('과목이 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
      handleCloseModal();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '수정 중 오류가 발생했습니다.');
    },
  });

  // 과목 삭제
  const deleteMutation = useMutation({
    mutationFn: subjectApi.deleteSubject,
    onSuccess: () => {
      message.success('과목이 삭제되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['subjects'] });
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '삭제 중 오류가 발생했습니다.');
    },
  });

  const handleSearch = () => {
    setSearchParams((prev) => ({ ...prev, page: 0 }));
  };

  const handleReset = () => {
    setSearchParams({
      keyword: '',
      category: '',
      isUse: '',
      page: 0,
      size: 20,
    });
  };

  const handleOpenCreate = () => {
    setEditingSubject(null);
    form.resetFields();
    form.setFieldsValue({ subjectDepth: 1, sortOrder: 1, isUse: 'Y' });
    setModalOpen(true);
  };

  const handleOpenEdit = (record: SubjectMasterResponse) => {
    setEditingSubject(record);
    form.setFieldsValue({
      subjectCd: record.subjectCd,
      subjectNm: record.subjectNm,
      parentSubjectCd: record.parentSubjectCd,
      subjectDepth: record.subjectDepth,
      category: record.category,
      description: record.description,
      sortOrder: record.sortOrder,
      isUse: record.isUse,
    });
    setModalOpen(true);
  };

  const handleCloseModal = () => {
    setModalOpen(false);
    setEditingSubject(null);
    form.resetFields();
  };

  const handleSubmit = () => {
    form.validateFields().then((values: SubjectMasterRequest) => {
      if (editingSubject) {
        updateMutation.mutate({ subjectCd: editingSubject.subjectCd, data: values });
      } else {
        createMutation.mutate(values);
      }
    });
  };

  const columns: ColumnsType<SubjectMasterResponse> = [
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
      render: (value) => {
        const type = EXAM_TYPES.find((t) => t.value === value);
        return type?.label || value || '-';
      },
    },
    {
      title: '계층',
      dataIndex: 'subjectDepth',
      key: 'subjectDepth',
      width: 70,
      align: 'center',
    },
    {
      title: '상위과목',
      dataIndex: 'parentSubjectCd',
      key: 'parentSubjectCd',
      width: 120,
      render: (value) => value || '-',
    },
    {
      title: '정렬',
      dataIndex: 'sortOrder',
      key: 'sortOrder',
      width: 70,
      align: 'center',
    },
    {
      title: '하위과목',
      dataIndex: 'childCount',
      key: 'childCount',
      width: 90,
      align: 'center',
      render: (value) => (value > 0 ? `${value}개` : '-'),
    },
    {
      title: '사용여부',
      dataIndex: 'isUse',
      key: 'isUse',
      width: 80,
      align: 'center',
      render: (value) => (
        <Tag color={value === 'Y' ? 'green' : 'red'}>
          {value === 'Y' ? '사용' : '미사용'}
        </Tag>
      ),
    },
    {
      title: '등록일',
      dataIndex: 'regDt',
      key: 'regDt',
      width: 150,
      render: (value) => value?.substring(0, 16),
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
            title="과목을 삭제하시겠습니까?"
            description="하위 과목이나 시험에서 사용 중이면 삭제할 수 없습니다."
            onConfirm={() => deleteMutation.mutate(record.subjectCd)}
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
      <Card style={{ marginBottom: 16 }}>
        <Row gutter={[16, 16]} align="middle">
          <Col>
            <Select
              placeholder="카테고리"
              allowClear
              style={{ width: 140 }}
              value={searchParams.category || undefined}
              onChange={(value) =>
                setSearchParams((prev) => ({ ...prev, category: value || '' }))
              }
              options={EXAM_TYPES}
            />
          </Col>
          <Col>
            <Select
              placeholder="사용여부"
              allowClear
              style={{ width: 100 }}
              value={searchParams.isUse || undefined}
              onChange={(value) =>
                setSearchParams((prev) => ({ ...prev, isUse: value || '' }))
              }
              options={[
                { value: 'Y', label: '사용' },
                { value: 'N', label: '미사용' },
              ]}
            />
          </Col>
          <Col flex="auto">
            <Input
              placeholder="과목명 또는 과목코드 검색"
              value={searchParams.keyword}
              onChange={(e) =>
                setSearchParams((prev) => ({ ...prev, keyword: e.target.value }))
              }
              onPressEnter={handleSearch}
              style={{ width: 250 }}
            />
          </Col>
          <Col>
            <Space>
              <Button icon={<SearchOutlined />} type="primary" onClick={handleSearch}>
                검색
              </Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>
                초기화
              </Button>
            </Space>
          </Col>
        </Row>
      </Card>

      <Card
        title={
          <span>
            과목 마스터 (총 <strong>{data?.data?.totalElements || 0}</strong>건)
          </span>
        }
        extra={
          <Button type="primary" icon={<PlusOutlined />} onClick={handleOpenCreate}>
            과목 등록
          </Button>
        }
      >
        <Table
          columns={columns}
          dataSource={data?.data?.content || []}
          rowKey="subjectCd"
          loading={isLoading}
          pagination={{
            current: searchParams.page + 1,
            pageSize: searchParams.size,
            total: data?.data?.totalElements || 0,
            showSizeChanger: true,
            showTotal: (total) => `총 ${total}건`,
            onChange: (page, pageSize) => {
              setSearchParams((prev) => ({
                ...prev,
                page: page - 1,
                size: pageSize,
              }));
            },
          }}
          scroll={{ x: 1100 }}
        />
      </Card>

      <Modal
        title={editingSubject ? '과목 수정' : '과목 등록'}
        open={modalOpen}
        onOk={handleSubmit}
        onCancel={handleCloseModal}
        confirmLoading={createMutation.isPending || updateMutation.isPending}
        okText={editingSubject ? '수정' : '등록'}
        cancelText="취소"
        width={600}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="subjectCd"
                label="과목코드"
                rules={[{ required: true, message: '과목코드를 입력하세요' }]}
              >
                <Input
                  placeholder="예: KOREAN"
                  disabled={!!editingSubject}
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="subjectNm"
                label="과목명"
                rules={[{ required: true, message: '과목명을 입력하세요' }]}
              >
                <Input placeholder="예: 국어" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="category" label="카테고리 (시험유형)">
                <Select
                  allowClear
                  options={EXAM_TYPES}
                  placeholder="선택"
                />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="parentSubjectCd" label="상위 과목코드">
                <Input placeholder="상위 과목코드 (없으면 비워두세요)" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={8}>
              <Form.Item name="subjectDepth" label="계층 깊이">
                <InputNumber min={1} max={5} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="sortOrder" label="정렬 순서">
                <InputNumber min={0} max={999} style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="isUse" label="사용여부">
                <Select
                  options={[
                    { value: 'Y', label: '사용' },
                    { value: 'N', label: '미사용' },
                  ]}
                />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item name="description" label="설명">
            <Input.TextArea rows={3} placeholder="과목에 대한 설명 (선택사항)" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
