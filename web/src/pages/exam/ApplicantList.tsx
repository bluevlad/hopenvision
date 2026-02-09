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
  Popconfirm,
  message,
  Row,
  Col,
} from 'antd';
import {
  PlusOutlined,
  SearchOutlined,
  ReloadOutlined,
  EditOutlined,
  DeleteOutlined,
} from '@ant-design/icons';
import type { ColumnsType } from 'antd/es/table';
import { examApi } from '../../api/examApi';
import { applicantApi } from '../../api/applicantApi';
import type { ApplicantResponse, ApplicantRequest } from '../../types/applicant';
import { APPLY_AREAS, APPLY_TYPES } from '../../types/applicant';
import ApplicantModal from './ApplicantModal';

export default function ApplicantList() {
  const queryClient = useQueryClient();
  const [selectedExamCd, setSelectedExamCd] = useState<string | undefined>();
  const [keyword, setKeyword] = useState('');
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(10);
  const [modalOpen, setModalOpen] = useState(false);
  const [editData, setEditData] = useState<ApplicantResponse | null>(null);

  // 시험 목록
  const { data: examListData } = useQuery({
    queryKey: ['exams', { page: 0, size: 100 }],
    queryFn: () => examApi.getExamList({ page: 0, size: 100 }),
  });

  // 응시자 목록
  const { data, isLoading } = useQuery({
    queryKey: ['applicants', selectedExamCd, keyword, page, size],
    queryFn: () => applicantApi.getApplicantList(selectedExamCd!, { keyword, page, size }),
    enabled: !!selectedExamCd,
  });

  // 응시자 등록
  const createMutation = useMutation({
    mutationFn: (req: ApplicantRequest) => applicantApi.createApplicant(selectedExamCd!, req),
    onSuccess: () => {
      message.success('응시자가 등록되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['applicants'] });
      setModalOpen(false);
    },
    onError: () => message.error('등록 중 오류가 발생했습니다.'),
  });

  // 응시자 수정
  const updateMutation = useMutation({
    mutationFn: (req: ApplicantRequest) =>
      applicantApi.updateApplicant(selectedExamCd!, editData!.applicantNo, req),
    onSuccess: () => {
      message.success('응시자가 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['applicants'] });
      setModalOpen(false);
      setEditData(null);
    },
    onError: () => message.error('수정 중 오류가 발생했습니다.'),
  });

  // 응시자 삭제
  const deleteMutation = useMutation({
    mutationFn: (applicantNo: string) => applicantApi.deleteApplicant(selectedExamCd!, applicantNo),
    onSuccess: () => {
      message.success('응시자가 삭제되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['applicants'] });
    },
    onError: () => message.error('삭제 중 오류가 발생했습니다.'),
  });

  const handleModalOk = (values: ApplicantRequest) => {
    if (editData) {
      updateMutation.mutate(values);
    } else {
      createMutation.mutate(values);
    }
  };

  const examList = examListData?.data?.content || [];

  const columns: ColumnsType<ApplicantResponse> = [
    {
      title: '수험번호',
      dataIndex: 'applicantNo',
      key: 'applicantNo',
      width: 120,
    },
    {
      title: '이름',
      dataIndex: 'userNm',
      key: 'userNm',
      width: 100,
    },
    {
      title: '사용자ID',
      dataIndex: 'userId',
      key: 'userId',
      width: 120,
      render: (value: string | null) => value || '-',
    },
    {
      title: '지역',
      dataIndex: 'applyArea',
      key: 'applyArea',
      width: 80,
      render: (value: string | null) => {
        const area = APPLY_AREAS.find((a) => a.value === value);
        return area?.label || value || '-';
      },
    },
    {
      title: '유형',
      dataIndex: 'applyType',
      key: 'applyType',
      width: 80,
      render: (value: string | null) => {
        const type = APPLY_TYPES.find((t) => t.value === value);
        return type?.label || value || '-';
      },
    },
    {
      title: '가산점',
      dataIndex: 'addScore',
      key: 'addScore',
      width: 80,
      align: 'center',
      render: (value: number) => value > 0 ? `${value}점` : '-',
    },
    {
      title: '총점',
      dataIndex: 'totalScore',
      key: 'totalScore',
      width: 80,
      align: 'center',
      render: (value: number | null) => value != null ? `${value}점` : '-',
    },
    {
      title: '평균',
      dataIndex: 'avgScore',
      key: 'avgScore',
      width: 80,
      align: 'center',
      render: (value: number | null) => value != null ? `${value}점` : '-',
    },
    {
      title: '석차',
      dataIndex: 'ranking',
      key: 'ranking',
      width: 60,
      align: 'center',
      render: (value: number | null) => value ?? '-',
    },
    {
      title: '합격여부',
      dataIndex: 'passYn',
      key: 'passYn',
      width: 80,
      align: 'center',
      render: (value: string | null) => {
        if (value === 'Y') return <Tag color="green">합격</Tag>;
        if (value === 'N') return <Tag color="red">불합격</Tag>;
        return <Tag>미정</Tag>;
      },
    },
    {
      title: '채점상태',
      dataIndex: 'scoreStatus',
      key: 'scoreStatus',
      width: 80,
      align: 'center',
      render: (value: string) => (
        <Tag color={value === 'Y' ? 'green' : 'default'}>
          {value === 'Y' ? '완료' : '미완료'}
        </Tag>
      ),
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
            onClick={() => {
              setEditData(record);
              setModalOpen(true);
            }}
          >
            수정
          </Button>
          <Popconfirm
            title="응시자를 삭제하시겠습니까?"
            onConfirm={() => deleteMutation.mutate(record.applicantNo)}
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
              placeholder="시험 선택"
              style={{ width: 300 }}
              value={selectedExamCd}
              onChange={(value) => {
                setSelectedExamCd(value);
                setPage(0);
                setKeyword('');
              }}
              showSearch
              filterOption={(input, option) =>
                (option?.label as string)?.toLowerCase().includes(input.toLowerCase()) ?? false
              }
              options={examList.map((exam) => ({
                value: exam.examCd,
                label: `${exam.examNm} (${exam.examCd})`,
              }))}
            />
          </Col>
          <Col flex="auto">
            <Input
              placeholder="이름 또는 수험번호 검색"
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              onPressEnter={() => setPage(0)}
              style={{ width: 250 }}
              disabled={!selectedExamCd}
            />
          </Col>
          <Col>
            <Space>
              <Button
                icon={<SearchOutlined />}
                type="primary"
                onClick={() => setPage(0)}
                disabled={!selectedExamCd}
              >
                검색
              </Button>
              <Button
                icon={<ReloadOutlined />}
                onClick={() => {
                  setKeyword('');
                  setPage(0);
                }}
              >
                초기화
              </Button>
            </Space>
          </Col>
        </Row>
      </Card>

      <Card
        title={
          <span>
            응시자 목록 (총 <strong>{data?.data?.totalElements || 0}</strong>명)
          </span>
        }
        extra={
          <Button
            type="primary"
            icon={<PlusOutlined />}
            onClick={() => {
              setEditData(null);
              setModalOpen(true);
            }}
            disabled={!selectedExamCd}
          >
            응시자 등록
          </Button>
        }
      >
        <Table
          columns={columns}
          dataSource={data?.data?.content || []}
          rowKey="applicantNo"
          loading={isLoading}
          pagination={{
            current: page + 1,
            pageSize: size,
            total: data?.data?.totalElements || 0,
            showSizeChanger: true,
            showTotal: (total) => `총 ${total}명`,
            onChange: (p, s) => {
              setPage(p - 1);
              setSize(s);
            },
          }}
          scroll={{ x: 1200 }}
        />
      </Card>

      <ApplicantModal
        open={modalOpen}
        editData={editData}
        loading={createMutation.isPending || updateMutation.isPending}
        onOk={handleModalOk}
        onCancel={() => {
          setModalOpen(false);
          setEditData(null);
        }}
      />
    </div>
  );
}
