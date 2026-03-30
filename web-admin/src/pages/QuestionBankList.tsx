import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
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
  EyeOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { questionBankApi } from '../api/questionBankApi';
import type { QuestionBankGroupResponse, QuestionBankGroupRequest } from '../types/questionBank';
import { EXAM_TYPES } from '@hopenvision/shared';

const currentYear = new Date().getFullYear();
const YEARS = Array.from({ length: 6 }, (_, i) => currentYear - i);

const SOURCE_OPTIONS = [
  { value: '기출', label: '기출' },
  { value: '모의', label: '모의' },
  { value: '자체', label: '자체 제작' },
  { value: '기타', label: '기타' },
];

export default function QuestionBankList() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [form] = Form.useForm();

  const [searchParams, setSearchParams] = useState({
    keyword: '',
    category: '',
    examYear: '',
    source: '',
    isUse: '',
    page: 0,
    size: 10,
  });

  const [modalOpen, setModalOpen] = useState(false);
  const [editingGroup, setEditingGroup] = useState<QuestionBankGroupResponse | null>(null);

  // 그룹 목록 조회
  const { data, isLoading } = useQuery({
    queryKey: ['questionBankGroups', searchParams],
    queryFn: () => questionBankApi.getGroupList(searchParams),
  });

  // 그룹 등록
  const createMutation = useMutation({
    mutationFn: questionBankApi.createGroup,
    onSuccess: () => {
      message.success('문제은행 그룹이 등록되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] });
      handleCloseModal();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '등록 중 오류가 발생했습니다.');
    },
  });

  // 그룹 수정
  const updateMutation = useMutation({
    mutationFn: ({ groupId, data }: { groupId: number; data: QuestionBankGroupRequest }) =>
      questionBankApi.updateGroup(groupId, data),
    onSuccess: () => {
      message.success('문제은행 그룹이 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] });
      handleCloseModal();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '수정 중 오류가 발생했습니다.');
    },
  });

  // 그룹 삭제
  const deleteMutation = useMutation({
    mutationFn: questionBankApi.deleteGroup,
    onSuccess: () => {
      message.success('문제은행 그룹이 삭제되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionBankGroups'] });
    },
    onError: () => {
      message.error('삭제 중 오류가 발생했습니다.');
    },
  });

  const handleSearch = () => {
    setSearchParams((prev) => ({ ...prev, page: 0 }));
  };

  const handleReset = () => {
    setSearchParams({
      keyword: '',
      category: '',
      examYear: '',
      source: '',
      isUse: '',
      page: 0,
      size: 10,
    });
  };

  const handleOpenCreate = () => {
    setEditingGroup(null);
    form.resetFields();
    form.setFieldsValue({ isUse: 'Y' });
    setModalOpen(true);
  };

  const handleOpenEdit = (record: QuestionBankGroupResponse) => {
    setEditingGroup(record);
    form.setFieldsValue({
      groupCd: record.groupCd,
      groupNm: record.groupNm,
      examYear: record.examYear,
      examRound: record.examRound,
      category: record.category,
      source: record.source,
      description: record.description,
      isUse: record.isUse,
    });
    setModalOpen(true);
  };

  const handleCloseModal = () => {
    setModalOpen(false);
    setEditingGroup(null);
    form.resetFields();
  };

  const handleSubmit = () => {
    form.validateFields().then((values: QuestionBankGroupRequest) => {
      if (editingGroup) {
        updateMutation.mutate({ groupId: editingGroup.groupId, data: values });
      } else {
        createMutation.mutate(values);
      }
    });
  };

  const columns: ColumnsType<QuestionBankGroupResponse> = [
    {
      title: '그룹코드',
      dataIndex: 'groupCd',
      key: 'groupCd',
      width: 140,
    },
    {
      title: '그룹명',
      dataIndex: 'groupNm',
      key: 'groupNm',
      render: (text, record) => (
        <a onClick={() => navigate(`/question-bank/${record.groupId}`)}>{text}</a>
      ),
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
      title: '출제연도',
      dataIndex: 'examYear',
      key: 'examYear',
      width: 90,
      align: 'center',
      render: (value) => value || '-',
    },
    {
      title: '회차',
      dataIndex: 'examRound',
      key: 'examRound',
      width: 60,
      align: 'center',
      render: (value) => value ? `${value}차` : '-',
    },
    {
      title: '출처',
      dataIndex: 'source',
      key: 'source',
      width: 80,
      align: 'center',
      render: (value) => value || '-',
    },
    {
      title: '문제수',
      dataIndex: 'itemCount',
      key: 'itemCount',
      width: 80,
      align: 'center',
      render: (value) => `${value}문항`,
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
      width: 200,
      align: 'center',
      render: (_, record) => (
        <Space size="small">
          <Button
            size="small"
            icon={<EyeOutlined />}
            onClick={() => navigate(`/question-bank/${record.groupId}`)}
          >
            상세
          </Button>
          <Button
            type="primary"
            size="small"
            icon={<EditOutlined />}
            onClick={() => handleOpenEdit(record)}
          >
            수정
          </Button>
          <Popconfirm
            title="그룹을 삭제하시겠습니까?"
            description="하위 문제 항목도 함께 삭제됩니다."
            onConfirm={() => deleteMutation.mutate(record.groupId)}
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
              placeholder="출제연도"
              allowClear
              style={{ width: 120 }}
              value={searchParams.examYear || undefined}
              onChange={(value) =>
                setSearchParams((prev) => ({ ...prev, examYear: value || '' }))
              }
              options={YEARS.map((y) => ({ value: String(y), label: `${y}년` }))}
            />
          </Col>
          <Col>
            <Select
              placeholder="출처"
              allowClear
              style={{ width: 100 }}
              value={searchParams.source || undefined}
              onChange={(value) =>
                setSearchParams((prev) => ({ ...prev, source: value || '' }))
              }
              options={SOURCE_OPTIONS}
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
              placeholder="그룹명 또는 그룹코드 검색"
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
            문제은행 (총 <strong>{data?.data?.totalElements || 0}</strong>건)
          </span>
        }
        extra={
          <Button type="primary" icon={<PlusOutlined />} onClick={handleOpenCreate}>
            그룹 등록
          </Button>
        }
      >
        <Table
          columns={columns}
          dataSource={data?.data?.content || []}
          rowKey="groupId"
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
          scroll={{ x: 1200 }}
        />
      </Card>

      <Modal
        title={editingGroup ? '그룹 수정' : '그룹 등록'}
        open={modalOpen}
        onOk={handleSubmit}
        onCancel={handleCloseModal}
        confirmLoading={createMutation.isPending || updateMutation.isPending}
        okText={editingGroup ? '수정' : '등록'}
        cancelText="취소"
        width={600}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item
                name="groupCd"
                label="그룹코드"
                rules={[{ required: true, message: '그룹코드를 입력하세요' }]}
              >
                <Input placeholder="예: 2024_9LEVEL_1" disabled={!!editingGroup} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item
                name="groupNm"
                label="그룹명"
                rules={[{ required: true, message: '그룹명을 입력하세요' }]}
              >
                <Input placeholder="예: 2024년 9급 1차 문제" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={8}>
              <Form.Item name="category" label="카테고리">
                <Select allowClear options={EXAM_TYPES} placeholder="선택" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="examYear" label="출제연도">
                <Select
                  allowClear
                  options={YEARS.map((y) => ({ value: String(y), label: `${y}년` }))}
                  placeholder="선택"
                />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="examRound" label="회차">
                <InputNumber min={1} max={10} style={{ width: '100%' }} placeholder="회차" />
              </Form.Item>
            </Col>
          </Row>

          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="source" label="출처">
                <Select allowClear options={SOURCE_OPTIONS} placeholder="선택" />
              </Form.Item>
            </Col>
            <Col span={12}>
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
            <Input.TextArea rows={3} placeholder="그룹에 대한 설명 (선택사항)" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
