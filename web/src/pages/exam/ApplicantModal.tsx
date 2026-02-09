import React, { useEffect } from 'react';
import { Modal, Form, Input, Select, InputNumber } from 'antd';
import type { ApplicantRequest, ApplicantResponse } from '../../types/applicant';
import { APPLY_AREAS, APPLY_TYPES } from '../../types/applicant';

interface ApplicantModalProps {
  open: boolean;
  editData: ApplicantResponse | null;
  loading: boolean;
  onOk: (values: ApplicantRequest) => void;
  onCancel: () => void;
}

const ApplicantModal: React.FC<ApplicantModalProps> = ({
  open,
  editData,
  loading,
  onOk,
  onCancel,
}) => {
  const [form] = Form.useForm<ApplicantRequest>();
  const isEdit = !!editData;

  useEffect(() => {
    if (open) {
      if (editData) {
        form.setFieldsValue({
          applicantNo: editData.applicantNo,
          userNm: editData.userNm,
          userId: editData.userId || undefined,
          applyArea: editData.applyArea || undefined,
          applyType: editData.applyType || undefined,
          addScore: editData.addScore,
        });
      } else {
        form.resetFields();
      }
    }
  }, [open, editData, form]);

  const handleOk = async () => {
    try {
      const values = await form.validateFields();
      onOk(values);
    } catch {
      // validation error
    }
  };

  return (
    <Modal
      title={isEdit ? '응시자 수정' : '응시자 등록'}
      open={open}
      onOk={handleOk}
      onCancel={onCancel}
      confirmLoading={loading}
      destroyOnClose
    >
      <Form form={form} layout="vertical">
        <Form.Item
          name="applicantNo"
          label="수험번호"
          rules={[{ required: true, message: '수험번호를 입력해주세요' }]}
        >
          <Input placeholder="수험번호" disabled={isEdit} />
        </Form.Item>
        <Form.Item
          name="userNm"
          label="이름"
          rules={[{ required: true, message: '이름을 입력해주세요' }]}
        >
          <Input placeholder="이름" />
        </Form.Item>
        <Form.Item name="userId" label="사용자 ID">
          <Input placeholder="사용자 ID (선택)" />
        </Form.Item>
        <Form.Item name="applyArea" label="지역">
          <Select placeholder="지역 선택" allowClear options={APPLY_AREAS} />
        </Form.Item>
        <Form.Item name="applyType" label="유형">
          <Select placeholder="유형 선택" allowClear options={APPLY_TYPES} />
        </Form.Item>
        <Form.Item name="addScore" label="가산점">
          <InputNumber
            placeholder="가산점"
            min={0}
            max={100}
            step={0.5}
            style={{ width: '100%' }}
          />
        </Form.Item>
      </Form>
    </Modal>
  );
};

export default ApplicantModal;
