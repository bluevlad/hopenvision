import React, { useState, useMemo } from 'react';
import {
  Modal,
  Card,
  Checkbox,
  Tag,
  Typography,
  Space,
  Alert,
  Divider,
  Row,
  Col,
} from 'antd';
import {
  BookOutlined,
  CheckCircleFilled,
  LockOutlined,
} from '@ant-design/icons';
import type { SubjectInfo } from '../types/user';

const { Title, Text } = Typography;

const MAX_ELECTIVE = 2;

interface SubjectSelectModalProps {
  open: boolean;
  examNm: string;
  subjects: SubjectInfo[];
  onConfirm: (selectedSubjectCds: string[]) => void;
  onCancel: () => void;
}

const SubjectSelectModal: React.FC<SubjectSelectModalProps> = ({
  open,
  examNm,
  subjects,
  onConfirm,
  onCancel,
}) => {
  const [selectedElectives, setSelectedElectives] = useState<string[]>([]);

  const mandatory = useMemo(
    () => subjects.filter((s) => s.subjectType === 'M'),
    [subjects],
  );
  const elective = useMemo(
    () => subjects.filter((s) => s.subjectType === 'S'),
    [subjects],
  );

  const handleElectiveToggle = (subjectCd: string) => {
    setSelectedElectives((prev) => {
      if (prev.includes(subjectCd)) {
        return prev.filter((cd) => cd !== subjectCd);
      }
      if (prev.length >= MAX_ELECTIVE) {
        return prev;
      }
      return [...prev, subjectCd];
    });
  };

  const handleConfirm = () => {
    const allSelected = [
      ...mandatory.map((s) => s.subjectCd),
      ...selectedElectives,
    ];
    onConfirm(allSelected);
  };

  const isReady = elective.length === 0 || selectedElectives.length === MAX_ELECTIVE;

  return (
    <Modal
      open={open}
      title={null}
      width={720}
      centered
      maskClosable={false}
      okText="응시 시작"
      cancelText="취소"
      okButtonProps={{ disabled: !isReady, size: 'large' }}
      cancelButtonProps={{ size: 'large' }}
      onOk={handleConfirm}
      onCancel={onCancel}
    >
      <div style={{ textAlign: 'center', marginBottom: 24 }}>
        <BookOutlined style={{ fontSize: 36, color: '#1677ff', marginBottom: 8 }} />
        <Title level={4} style={{ margin: 0 }}>{examNm}</Title>
        <Text type="secondary">응시 과목을 선택해주세요</Text>
      </div>

      {/* 필수 과목 */}
      <div style={{ marginBottom: 20 }}>
        <Space style={{ marginBottom: 12 }}>
          <Tag color="blue" style={{ fontSize: 14, padding: '2px 12px' }}>필수 과목</Tag>
          <Text type="secondary">{mandatory.length}과목 (자동 선택)</Text>
        </Space>
        <Row gutter={[12, 12]}>
          {mandatory.map((subject) => (
            <Col key={subject.subjectCd} xs={24} sm={8}>
              <Card
                size="small"
                style={{
                  borderColor: '#1677ff',
                  backgroundColor: '#e6f4ff',
                }}
              >
                <Space>
                  <LockOutlined style={{ color: '#1677ff' }} />
                  <Text strong>{subject.subjectNm}</Text>
                  <Text type="secondary" style={{ fontSize: 12 }}>
                    {subject.questionCnt}문항
                  </Text>
                </Space>
              </Card>
            </Col>
          ))}
        </Row>
      </div>

      {/* 선택 과목 */}
      {elective.length > 0 && (
        <>
          <Divider style={{ margin: '16px 0' }} />
          <div>
            <Space style={{ marginBottom: 12 }}>
              <Tag color="orange" style={{ fontSize: 14, padding: '2px 12px' }}>선택 과목</Tag>
              <Text type="secondary">
                {elective.length}과목 중 {MAX_ELECTIVE}과목 선택
              </Text>
              <Tag color={isReady ? 'green' : 'default'}>
                {selectedElectives.length}/{MAX_ELECTIVE} 선택됨
              </Tag>
            </Space>

            {!isReady && (
              <Alert
                message={`선택 과목 ${MAX_ELECTIVE}개를 선택해주세요`}
                type="warning"
                showIcon
                style={{ marginBottom: 12 }}
              />
            )}

            <Row gutter={[12, 12]}>
              {elective.map((subject) => {
                const isSelected = selectedElectives.includes(subject.subjectCd);
                const isDisabled = !isSelected && selectedElectives.length >= MAX_ELECTIVE;

                return (
                  <Col key={subject.subjectCd} xs={24} sm={12} md={8}>
                    <Card
                      size="small"
                      hoverable={!isDisabled}
                      onClick={() => !isDisabled && handleElectiveToggle(subject.subjectCd)}
                      style={{
                        cursor: isDisabled ? 'not-allowed' : 'pointer',
                        borderColor: isSelected ? '#52c41a' : undefined,
                        backgroundColor: isSelected
                          ? '#f6ffed'
                          : isDisabled
                            ? '#fafafa'
                            : undefined,
                        opacity: isDisabled ? 0.5 : 1,
                      }}
                    >
                      <Space>
                        <Checkbox
                          checked={isSelected}
                          disabled={isDisabled}
                          onClick={(e) => e.stopPropagation()}
                          onChange={() => handleElectiveToggle(subject.subjectCd)}
                        />
                        {isSelected && (
                          <CheckCircleFilled style={{ color: '#52c41a', fontSize: 14 }} />
                        )}
                        <Text strong={isSelected}>{subject.subjectNm}</Text>
                        <Text type="secondary" style={{ fontSize: 12 }}>
                          {subject.questionCnt}문항
                        </Text>
                      </Space>
                    </Card>
                  </Col>
                );
              })}
            </Row>
          </div>
        </>
      )}

      {/* 하단 요약 */}
      <Divider style={{ margin: '20px 0 12px' }} />
      <div style={{ textAlign: 'center' }}>
        <Text type="secondary">
          총 응시 과목: {mandatory.length + selectedElectives.length}과목 /
          총 문항: {
            [...mandatory, ...elective.filter((s) => selectedElectives.includes(s.subjectCd))]
              .reduce((sum, s) => sum + s.questionCnt, 0)
          }문항
        </Text>
      </div>
    </Modal>
  );
};

export default SubjectSelectModal;
