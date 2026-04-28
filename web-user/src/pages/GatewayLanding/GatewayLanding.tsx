import { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import './GatewayLanding.css';

type FeatureLevel = 'public' | 'member' | 'admin';
type AccessState = 'granted' | 'member-locked' | 'admin-locked';

type FeatureItem = {
  icon: string;
  name: string;
  desc: string;
  tag?: string;
  level: FeatureLevel;
  to: string;
  external?: boolean;
};

const FEATURES: FeatureItem[] = [
  { icon: '📝', name: '시험 채점', desc: 'OMR/약식 답안 입력 후 즉시 채점 — 과목별 점수와 합격 예측을 한 화면에 표시', tag: '🌐 채점', level: 'public', to: '/exams' },
  { icon: '📋', name: '모의고사', desc: '문제세트 기반 온라인 모의고사 응시 — 시간 제한·자동 채점·해설 제공', tag: '🌐 모의고사', level: 'public', to: '/exams' },
  { icon: '📊', name: '응시 이력', desc: '과거 응시 결과·점수 추이·과목별 정답률을 누적 조회', tag: '🌐 이력', level: 'public', to: '/history' },
  { icon: '📋', name: '시험 관리', desc: '시험 회차 등록·수정·답안지 매핑·임포트 진입 통합', level: 'admin', to: '/admin/exams', external: true },
  { icon: '🔑', name: '답안지 등록', desc: '과목·문항별 정답·배점·문제유형(객관식/주관식) 일괄 입력', level: 'admin', to: '/admin/exams', external: true },
  { icon: '📂', name: 'Excel 임포트', desc: '정답표·응시자 명단 Excel 업로드 → 미리보기 → 일괄 저장 (Apache POI)', level: 'admin', to: '/admin/import/preview', external: true },
  { icon: '👥', name: '응시자 관리', desc: '응시자 명부·CSV 업로드·임시점수 등록·시험별 응시자 매핑 통합', level: 'admin', to: '/admin/applicants', external: true },
  { icon: '📈', name: '통계 대시보드', desc: '과목별 평균·합격률·점수 분포 시각화 (Recharts, exam_applicant 기반)', level: 'admin', to: '/admin/statistics', external: true },
  { icon: '📚', name: '과목 관리', desc: '과목 마스터 코드·명칭·표시 순서 관리 — 시험 등록 시 참조 카탈로그', level: 'admin', to: '/admin/subjects', external: true },
  { icon: '🏛️', name: '문제은행', desc: '문항 그룹·문항·정답·해설 등록 + CSV/Excel 일괄 임포트·갱신 지원', level: 'admin', to: '/admin/question-bank', external: true },
  { icon: '📄', name: '문제세트', desc: '문제은행에서 문항을 골라 모의고사용 시험지 세트를 구성·발행', level: 'admin', to: '/admin/question-sets', external: true },
  { icon: '🔍', name: '고시 분석', desc: '공무원 시험 회차·과목별 정답률·난이도·오답 패턴 심층 리포트', level: 'admin', to: '/admin/gosi/analytics', external: true },
];

const TECH_STACK = [
  { name: 'React 19', dot: '#61dafb' },
  { name: 'Vite', dot: '#646cff' },
  { name: 'Ant Design', dot: '#0170fe' },
  { name: 'TypeScript', dot: '#3178c6' },
  { name: 'Java 17', dot: '#f89820' },
  { name: 'Spring Boot', dot: '#6db33f' },
  { name: 'JPA · Hibernate', dot: '#59666c' },
  { name: 'Flyway', dot: '#cc0000' },
  { name: 'PostgreSQL', dot: '#336791' },
  { name: 'Redis', dot: '#dc382d' },
  { name: 'Apache POI', dot: '#1d6f42' },
  { name: 'Docker', dot: '#2496ed' },
  { name: 'Nginx', dot: '#f97316' },
];

const CONNECTED_SERVICES = [
  { name: 'InfraWatcher', role: '컨테이너 모니터링', href: 'https://infrawatcher.unmong.com/', dot: '#06b6d4' },
  { name: 'QA-Agent', role: '품질 자동 테스트', href: 'https://qadashboard.unmong.com/', dot: '#8b5cf6' },
  { name: 'StandUp', role: '업무 추적 연동', href: 'https://standup.unmong.com/', dot: '#14b8a6' },
];

type AuthState = { isAuthenticated: boolean; isAdmin: boolean };

function accessFor(level: FeatureLevel, auth: AuthState): AccessState {
  if (level === 'public') return 'granted';
  if (level === 'member') return auth.isAuthenticated ? 'granted' : 'member-locked';
  if (level === 'admin') return auth.isAdmin ? 'granted' : 'admin-locked';
  return 'granted';
}

function tagInfo(state: AccessState, level: FeatureLevel, customTag?: string) {
  if (state === 'granted' && level === 'public') {
    return { label: customTag || '🌐 공개', variant: 'public' };
  }
  if (state === 'granted') return { label: '✓ 사용 가능', variant: 'granted' };
  if (state === 'member-locked') return { label: '🔒 회원전용', variant: 'member-locked' };
  if (state === 'admin-locked') return { label: '🔐 관리자 전용', variant: 'admin-locked' };
  return { label: '', variant: '' };
}

type ToastInfo = { icon: string; message: string; actionLabel: string; actionHref: string };

function lockedToastFor(state: AccessState): ToastInfo | null {
  if (state === 'admin-locked') {
    return { icon: '🔐', message: '관리자 전용입니다', actionLabel: '관리자 로그인', actionHref: '/admin/login' };
  }
  if (state === 'member-locked') {
    return { icon: '🔒', message: '회원전용 서비스입니다', actionLabel: '로그인', actionHref: '/admin/login' };
  }
  return null;
}

type FeatureCardProps = {
  feature: FeatureItem;
  accessState: AccessState;
  onLocked: (state: AccessState) => void;
};

function FeatureCard({ feature, accessState, onLocked }: FeatureCardProps) {
  const locked = accessState !== 'granted';
  const { label, variant } = tagInfo(accessState, feature.level, feature.tag);

  const handleClick = (e: React.MouseEvent) => {
    if (locked) {
      e.preventDefault();
      onLocked(accessState);
    }
  };

  const inner = (
    <>
      {locked && <span className="sl-feature-lock" aria-hidden="true">🔒</span>}
      <span className="sl-feature-icon" aria-hidden="true">{feature.icon}</span>
      <div className="sl-feature-name">{feature.name}</div>
      <div className="sl-feature-desc">{feature.desc}</div>
      <span className={`sl-feature-tag sl-feature-tag--${variant}`}>{label}</span>
    </>
  );

  const commonProps = {
    className: 'sl-feature',
    'data-locked': locked ? 'true' : 'false',
    onClick: handleClick,
  };

  if (feature.external) {
    return <a {...commonProps} href={feature.to} target={locked ? undefined : '_blank'} rel="noopener noreferrer">{inner}</a>;
  }
  if (locked) return <a {...commonProps} href={feature.to}>{inner}</a>;
  return <Link {...commonProps} to={feature.to}>{inner}</Link>;
}

function Toast({ toast, onClose }: { toast: ToastInfo | null; onClose: () => void }) {
  if (!toast) return null;
  return (
    <div className="sl-toast" role="status" aria-live="polite">
      <span className="sl-toast-icon" aria-hidden="true">{toast.icon}</span>
      <span className="sl-toast-msg">{toast.message}</span>
      <a className="sl-toast-action" href={toast.actionHref} onClick={onClose}>{toast.actionLabel} →</a>
      <button type="button" className="sl-toast-close" onClick={onClose} aria-label="닫기">×</button>
    </div>
  );
}

export default function GatewayLanding() {
  const [toast, setToast] = useState<ToastInfo | null>(null);

  useEffect(() => {
    if (!toast) return;
    const timer = setTimeout(() => setToast(null), 4500);
    return () => clearTimeout(timer);
  }, [toast]);

  const handleLocked = useCallback((accessState: AccessState) => {
    const next = lockedToastFor(accessState);
    if (next) setToast(next);
  }, []);

  // web-user 는 공개/관리자 권한만 다룸. AuthContext 도입 시 isAuthenticated/isAdmin 으로 교체.
  const authState: AuthState = { isAuthenticated: false, isAdmin: false };

  return (
    <div className="gateway-landing-root">
      <div className="sl-container">
        <section className="sl-hero">
          <h1>HopenVision</h1>
          <p className="tagline">Admission Prediction · 모의고사 · 합격 예측</p>
          <p className="desc">
            모의고사 성적 데이터를 기반으로 대학별 합격 가능성을 예측하고, 학습 방향을 제시하는 입시 예측 시스템
          </p>
        </section>

        <section className="sl-section">
          <div className="sl-section-title">Features</div>
          <div className="sl-features">
            {FEATURES.map(feature => (
              <FeatureCard
                key={feature.name}
                feature={feature}
                accessState={accessFor(feature.level, authState)}
                onLocked={handleLocked}
              />
            ))}
          </div>
        </section>

        <section className="sl-section sl-arch">
          <div className="sl-section-title">Architecture</div>
          <div className="sl-arch-diagram">
            <div className="sl-arch-node">
              <div className="sl-arch-node-label">Frontend</div>
              <div className="sl-arch-node-tech">React 19 (Vite)</div>
            </div>
            <div className="sl-arch-arrow">→</div>
            <div className="sl-arch-node highlight">
              <div className="sl-arch-node-label">Backend</div>
              <div className="sl-arch-node-tech">Spring Boot 3</div>
            </div>
            <div className="sl-arch-arrow">→</div>
            <div className="sl-arch-node">
              <div className="sl-arch-node-label">Database</div>
              <div className="sl-arch-node-tech">PostgreSQL 15</div>
            </div>
          </div>
        </section>

        <section className="sl-section sl-flow">
          <div className="sl-section-title">Service Flow</div>
          <div className="sl-flow-steps">
            <div className="sl-flow-step">
              <div className="sl-flow-step-num">1</div>
              <div className="sl-flow-step-label">시험 응시</div>
              <div className="sl-flow-step-desc">온라인 모의고사</div>
            </div>
            <div className="sl-flow-arrow">→</div>
            <div className="sl-flow-step">
              <div className="sl-flow-step-num">2</div>
              <div className="sl-flow-step-label">성적 분석</div>
              <div className="sl-flow-step-desc">과목별 분석</div>
            </div>
            <div className="sl-flow-arrow">→</div>
            <div className="sl-flow-step">
              <div className="sl-flow-step-num">3</div>
              <div className="sl-flow-step-label">합격 예측</div>
              <div className="sl-flow-step-desc">대학별 가능성</div>
            </div>
            <div className="sl-flow-arrow">→</div>
            <div className="sl-flow-step">
              <div className="sl-flow-step-num">4</div>
              <div className="sl-flow-step-label">통계 리포트</div>
              <div className="sl-flow-step-desc">추이 시각화</div>
            </div>
          </div>
        </section>

        <section className="sl-section sl-tech">
          <div className="sl-section-title">Tech Stack</div>
          <div className="sl-tech-list">
            {TECH_STACK.map(t => (
              <span key={t.name} className="sl-tech-badge">
                <span className="sl-tech-dot" style={{ background: t.dot }} />
                {t.name}
              </span>
            ))}
          </div>
        </section>

        <section className="sl-section sl-connected">
          <div className="sl-section-title">Connected Services</div>
          <div className="sl-connected-grid">
            {CONNECTED_SERVICES.map(svc => (
              <a key={svc.name} href={svc.href} target="_blank" rel="noopener noreferrer" className="sl-connected-card">
                <span className="sl-connected-dot" style={{ background: svc.dot }} />
                <div className="sl-connected-info">
                  <div className="sl-connected-name">{svc.name}</div>
                  <div className="sl-connected-role">{svc.role}</div>
                </div>
                <span className="sl-connected-arrow">→</span>
              </a>
            ))}
          </div>
        </section>
      </div>

      <Toast toast={toast} onClose={() => setToast(null)} />
    </div>
  );
}
