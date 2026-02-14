import { useEffect } from 'react';
import { Modal, Form, Input, Checkbox, message } from 'antd';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { upsertProfile, setUserId } from '../api/userApi';
import type { UserProfile, UserProfileUpsertRequest } from '../types/user';

interface UserProfileModalProps {
  open: boolean;
  onClose: () => void;
  onSaved?: (userId: string) => void;
  profile: UserProfile | null;
  userId: string;
  isFirstTime: boolean;
}

export default function UserProfileModal({ open, onClose, onSaved, profile, userId, isFirstTime }: UserProfileModalProps) {
  const [form] = Form.useForm();
  const queryClient = useQueryClient();

  useEffect(() => {
    if (open) {
      form.setFieldsValue({
        userId: profile?.userId || userId,
        userNm: profile?.userNm || '',
        email: profile?.email || '',
        newsletterYn: profile?.newsletterYn === 'Y',
      });
    }
  }, [open, profile, userId, form]);

  const mutation = useMutation({
    mutationFn: upsertProfile,
    onSuccess: (_data, variables) => {
      if (isFirstTime) {
        setUserId(variables.userId);
      }
      message.success(isFirstTime ? '프로필이 등록되었습니다.' : '프로필이 수정되었습니다.');
      queryClient.invalidateQueries({ queryKey: ['userProfile'] });
      queryClient.invalidateQueries({ queryKey: ['userProfileExists'] });
      onSaved?.(variables.userId);
      onClose();
    },
    onError: () => {
      message.error('프로필 저장에 실패했습니다.');
    },
  });

  const handleOk = () => {
    form.validateFields().then((values) => {
      const request: UserProfileUpsertRequest = {
        userId: values.userId,
        userNm: values.userNm,
        email: values.email || undefined,
        newsletterYn: values.newsletterYn ? 'Y' : 'N',
      };
      mutation.mutate(request);
    });
  };

  const handleCancel = () => {
    if (isFirstTime) {
      Modal.confirm({
        title: '프로필 등록을 건너뛰시겠습니까?',
        content: '나중에 상단 프로필 버튼에서 등록할 수 있습니다.',
        okText: '건너뛰기',
        cancelText: '계속 작성',
        onOk: onClose,
      });
    } else {
      onClose();
    }
  };

  return (
    <Modal
      title={isFirstTime ? '프로필 등록' : '프로필 수정'}
      open={open}
      onOk={handleOk}
      onCancel={handleCancel}
      okText="저장"
      cancelText={isFirstTime ? '건너뛰기' : '취소'}
      confirmLoading={mutation.isPending}
      maskClosable={!isFirstTime}
    >
      <Form form={form} layout="vertical" style={{ marginTop: 16 }}>
        <Form.Item
          name="userId"
          label="사용자 ID"
          rules={[{ required: true, message: '사용자 ID를 입력하세요' }]}
        >
          <Input disabled={!isFirstTime} />
        </Form.Item>
        <Form.Item
          name="userNm"
          label="이름"
          rules={[{ required: true, message: '이름을 입력하세요' }]}
        >
          <Input placeholder="이름을 입력하세요" />
        </Form.Item>
        <Form.Item
          name="email"
          label="이메일"
          rules={[{ type: 'email', message: '올바른 이메일 형식이 아닙니다' }]}
        >
          <Input placeholder="이메일을 입력하세요 (선택)" />
        </Form.Item>
        <Form.Item name="newsletterYn" valuePropName="checked">
          <Checkbox>뉴스레터 수신 동의</Checkbox>
        </Form.Item>
      </Form>
    </Modal>
  );
}
