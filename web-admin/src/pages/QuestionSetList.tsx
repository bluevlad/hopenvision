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
import { questionSetApi } from '../api/questionSetApi';
import type { QuestionSetResponse, QuestionSetRequest } from '../types/questionSet';
import { EXAM_TYPES } from '@hopenvision/shared';

const DIFFICULTY_OPTIONS = [
  { value: '1', label: '매우 쉬움' },
  { value: '2', label: '쉬움' },
  { value: '3', label: '보통' },
  { value: '4', label: '어려움' },
  { value: '5', label: '매우 어려움' },
];

export default function QuestionSetList() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [form] = Form.useForm();

  const [searchParams, setSearchParams] = useState({
    keyword: '',
    category: '',
    isUse: '',
    page: 0,
    size: 10,
  });

  const [modalOpen, setModalOpen] = useState(false);
  const [editingSet, setEditingSet] = useState<QuestionSetResponse | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['questionSets', searchParams],
    queryFn: () => questionSetApi.getSetList(searchParams),
  });

  const createMutation = useMutation({
    mutationFn: questionSetApi.createSet,
    onSuccess: () => {
      message.success('문제세트가 등록되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionSets'] });
      handleCloseModal();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '등록 중 오류가 발생했습니다.');
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ setId, data }: { setId: number; data: QuestionSetRequest }) =>
      questionSetApi.updateSet(setId, data),
    onSuccess: () => {
      message.success('문제세트가 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionSets'] });
      handleCloseModal();
    },
    onError: (error: Error & { response?: { data?: { message?: string } } }) => {
      message.error(error.response?.data?.message || '수정 중 오류가 발생했습니다.');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: questionSetApi.deleteSet,
    onSuccess: () => {
      message.success('문제세트가 삭제되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['questionSets'] });
    },
    onError: () => {
      message.error('삭제 중 오류가 발생했습니다.');
    },
  });

  const handleSearch = () => {
    setSearchParams((prev) => ({ ...prev, page: 0 }));
  };

  const handleReset = () => {
    setSearchParams({ keyword: '', category: '', isUse: '', page: 0, size: 10 });
  };

  const handleOpenCreate = () => {
    setEditingSet(null);
    form.resetFields();
    form.setFieldsValue({ isUse: 'Y' });
    setModalOpen(true);
  };

  const handleOpenEdit = (record: QuestionSetResponse) => {
    setEditingSet(record);
    form.setFieldsValue({
      setCd: record.setCd,
      setNm: record.setNm,
      category: record.category,
      difficultyLevel: record.difficultyLevel,
      description: record.description,
      isUse: record.isUse,
    });
    setModalOpen(true);
  };

  const handleCloseModal = () => {
    setModalOpen(false);
    setEditingSet(null);
    form.resetFields();
  };

  const handleSubmit = () => {
    form.validateFields().then((values: QuestionSetRequest) => {
      if (editingSet) {
        updateMutation.mutate({ setId: editingSet.setId, data: values });
      } else {
        createMutation.mutate(values);
      }
    });
  };

  const columns: ColumnsType<QuestionSetResponse> = [
    { title: '세트코드', dataIndex: 'setCd', key: 'setCd', width: 140 },
    {
      title: '세트명',
      dataIndex: 'setNm',
      key: 'setNm',
      render: (text, record) => (
        <a onClick={() => navigate(`/question-sets/${record.setId}`)}>{text}</a>
      ),
    },
    {
      title: '과목',
      key: 'subjects',
      width: 180,
      render: (_, record) => {
        if (!record.subjectSummaries || record.subjectSummaries.length === 0) {
          return <Tag>미설정</Tag>;
        }
        return (
          <Space size={[0, 4]} wrap>
            {record.subjectSummaries.map((s) => (
              <Tag key={s.subjectCd} color="blue">
                {s.subjectNm} ({s.itemCount})
              </Tag>
            ))}
          </Space>
        );
      },
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
      title: '문제수',
      dataIndex: 'questionCnt',
      key: 'questionCnt',
      width: 80,
      align: 'center',
      render: (value) => `${value}문항`,
    },
    {
      title: '총 배점',
      dataIndex: 'totalScore',
      key: 'totalScore',
      width: 80,
      align: 'center',
      render: (value) => `${value}점`,
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
      title: '관리',
      key: 'action',
      width: 200,
      align: 'center',
      render: (_, record) => (
        <Space size="small">
          <Button size="small" icon={<EyeOutlined />} onClick={() => navigate(`/question-sets/${record.setId}`)}>
            상세
          </Button>
          <Button type="primary" size="small" icon={<EditOutlined />} onClick={() => handleOpenEdit(record)}>
            수정
          </Button>
          <Popconfirm
            title="문제세트를 삭제하시겠습니까?"
            onConfirm={() => deleteMutation.mutate(record.setId)}
            okText="삭제"
            cancelText="취소"
          >
            <Button danger size="small" icon={<DeleteOutlined />}>삭제</Button>
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
              onChange={(value) => setSearchParams((prev) => ({ ...prev, category: value || '' }))}
              options={EXAM_TYPES}
            />
          </Col>
          <Col>
            <Select
              placeholder="사용여부"
              allowClear
              style={{ width: 100 }}
              value={searchParams.isUse || undefined}
              onChange={(value) => setSearchParams((prev) => ({ ...prev, isUse: value || '' }))}
              options={[
                { value: 'Y', label: '사용' },
                { value: 'N', label: '미사용' },
              ]}
            />
          </Col>
          <Col flex="auto">
            <Input
              placeholder="세트명 또는 세트코드 검색"
              value={searchParams.keyword}
              onChange={(e) => setSearchParams((prev) => ({ ...prev, keyword: e.target.value }))}
              onPressEnter={handleSearch}
              style={{ width: 250 }}
            />
          </Col>
          <Col>
            <Space>
              <Button icon={<SearchOutlined />} type="primary" onClick={handleSearch}>검색</Button>
              <Button icon={<ReloadOutlined />} onClick={handleReset}>초기화</Button>
            </Space>
          </Col>
        </Row>
      </Card>

      <Card
        title={<span>문제세트 (총 <strong>{data?.data?.totalElements || 0}</strong>건)</span>}
        extra={<Button type="primary" icon={<PlusOutlined />} onClick={handleOpenCreate}>세트 등록</Button>}
      >
        <Table
          columns={columns}
          dataSource={data?.data?.content || []}
          rowKey="setId"
          loading={isLoading}
          pagination={{
            current: searchParams.page + 1,
            pageSize: searchParams.size,
            total: data?.data?.totalElements || 0,
            showSizeChanger: true,
            showTotal: (total) => `총 ${total}건`,
            onChange: (page, pageSize) => {
              setSearchParams((prev) => ({ ...prev, page: page - 1, size: pageSize }));
            },
          }}
          scroll={{ x: 1200 }}
        />
      </Card>

      <Modal
        title={editingSet ? '세트 수정' : '세트 등록'}
        open={modalOpen}
        onOk={handleSubmit}
        onCancel={handleCloseModal}
        confirmLoading={createMutation.isPending || updateMutation.isPending}
        okText={editingSet ? '수정' : '등록'}
        cancelText="취소"
        width={600}
      >
        <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
          <Row gutter={16}>
            <Col span={12}>
              <Form.Item name="setCd" label="세트코드" rules={[{ required: true, message: '세트코드를 입력하세요' }]}>
                <Input placeholder="예: SET_2024_9LEVEL_1" disabled={!!editingSet} />
              </Form.Item>
            </Col>
            <Col span={12}>
              <Form.Item name="setNm" label="세트명" rules={[{ required: true, message: '세트명을 입력하세요' }]}>
                <Input placeholder="예: 2024 9급 1차 문제세트" />
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
              <Form.Item name="difficultyLevel" label="평균 난이도">
                <Select allowClear options={DIFFICULTY_OPTIONS} placeholder="선택" />
              </Form.Item>
            </Col>
            <Col span={8}>
              <Form.Item name="isUse" label="사용여부">
                <Select options={[{ value: 'Y', label: '사용' }, { value: 'N', label: '미사용' }]} />
              </Form.Item>
            </Col>
          </Row>

          <Form.Item name="description" label="설명">
            <Input.TextArea rows={3} placeholder="세트에 대한 설명 (선택사항)" />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
