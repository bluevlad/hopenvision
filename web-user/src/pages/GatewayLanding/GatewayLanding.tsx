import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import './landing.css';

type FeatureLevel = 'public' | 'admin';

type FeatureCard = {
  icon: string;
  name: string;
  desc: string;
  to: string;
  external?: boolean;
  tag: string;
  level: FeatureLevel;
};

const FEATURES: FeatureCard[] = [
  { icon: '📝', name: '시험 채점', desc: 'OMR/약식 답안 입력 후 즉시 채점 — 과목별 점수와 합격 예측을 한 화면에 표시', to: '/exams', tag: 'Public · Exam', level: 'public' },
  { icon: '📋', name: '모의고사', desc: '문제세트 기반 온라인 모의고사 응시 — 시간 제한·자동 채점·해설 제공', to: '/exams', tag: 'Public · Mock', level: 'public' },
  { icon: '📊', name: '응시 이력', desc: '과거 응시 결과·점수 추이·과목별 정답률을 누적 조회', to: '/history', tag: 'Public · History', level: 'public' },
  { icon: '📋', name: '시험 관리', desc: '시험 회차 등록·수정·답안지 매핑·임포트 진입 통합 (관리자 전용)', to: '/admin/exams', external: true, tag: 'Admin · Exam', level: 'admin' },
  { icon: '🔑', name: '답안지 등록', desc: '과목·문항별 정답·배점·문제유형(객관식/주관식) 일괄 입력', to: '/admin/exams', external: true, tag: 'Admin · AnswerKey', level: 'admin' },
  { icon: '📂', name: 'Excel 임포트', desc: '정답표·응시자 명단 Excel 업로드 → 미리보기 → 일괄 저장 (Apache POI)', to: '/admin/import/preview', external: true, tag: 'Admin · Import', level: 'admin' },
  { icon: '👥', name: '응시자 관리', desc: '응시자 명부·CSV 업로드·임시점수 등록·시험별 응시자 매핑 통합 운영', to: '/admin/applicants', external: true, tag: 'Admin · Applicant', level: 'admin' },
  { icon: '📈', name: '통계 대시보드', desc: '과목별 평균·합격률·점수 분포 시각화 (Recharts, exam_applicant 기반)', to: '/admin/statistics', external: true, tag: 'Admin · Statistics', level: 'admin' },
  { icon: '📚', name: '과목 관리', desc: '과목 마스터 코드·명칭·표시 순서 관리 — 시험 등록 시 참조 카탈로그', to: '/admin/subjects', external: true, tag: 'Admin · Master', level: 'admin' },
  { icon: '🏛️', name: '문제은행', desc: '문항 그룹·문항·정답·해설 등록 + CSV/Excel 일괄 임포트·갱신 지원', to: '/admin/question-bank', external: true, tag: 'Admin · QuestionBank', level: 'admin' },
  { icon: '📄', name: '문제세트', desc: '문제은행에서 문항을 골라 모의고사용 시험지 세트를 구성·발행', to: '/admin/question-sets', external: true, tag: 'Admin · QuestionSet', level: 'admin' },
  { icon: '🔍', name: '고시 분석', desc: '공무원 시험 회차·과목별 정답률·난이도·오답 패턴 심층 리포트', to: '/admin/gosi/analytics', external: true, tag: 'Admin · Analytics', level: 'admin' },
];

const TECH_STACK = [
  { name: 'React 19', color: '#61dafb' },
  { name: 'Vite', color: '#646cff' },
  { name: 'Ant Design', color: '#0170fe' },
  { name: 'TypeScript', color: '#3178c6' },
  { name: 'Java 17', color: '#f89820' },
  { name: 'Spring Boot', color: '#6db33f' },
  { name: 'JPA · Hibernate', color: '#59666c' },
  { name: 'Flyway', color: '#cc0000' },
  { name: 'PostgreSQL', color: '#336791' },
  { name: 'Redis', color: '#dc382d' },
  { name: 'Apache POI', color: '#1d6f42' },
  { name: 'Docker', color: '#2496ed' },
  { name: 'Nginx', color: '#f97316' },
];

const CONNECTED_SERVICES = [
  { name: 'InfraWatcher', role: '컨테이너 모니터링', color: '#06b6d4', href: 'https://infrawatcher.unmong.com/intro.html' },
  { name: 'QA-Agent', role: '품질 자동 테스트', color: '#8b5cf6', href: 'https://qadashboard.unmong.com/intro.html' },
  { name: 'StandUp', role: '업무 추적 연동', color: '#14b8a6', href: 'https://standup.unmong.com/intro.html' },
];

export default function GatewayLanding() {
  useEffect(() => {
    document.body.classList.add('is-landing');
    return () => document.body.classList.remove('is-landing');
  }, []);

  const renderFeature = (f: FeatureCard) => {
    const tagClass = f.level === 'admin' ? 'sl-feature-tag sl-feature-tag-admin' : 'sl-feature-tag';
    const inner = (
      <>
        <span className="sl-feature-icon">{f.icon}</span>
        <div className="sl-feature-name">{f.name}</div>
        <div className="sl-feature-desc">{f.desc}</div>
        <span className={tagClass}>{f.tag}</span>
      </>
    );
    if (f.external) {
      return <a key={f.name} className="sl-feature" href={f.to} target="_blank" rel="noopener noreferrer">{inner}</a>;
    }
    return <Link key={f.name} className="sl-feature" to={f.to}>{inner}</Link>;
  };

  return (
    <div className="sl-container">
      <nav className="sl-topnav">
        <div className="sl-nav-links">
          <a href="https://www.unmong.com/index.html" className="sl-nav-link"><span className="sl-nav-arrow">↑</span> Portal</a>
          <a href="https://www.unmong.com/architecture.html" className="sl-nav-link"><span className="sl-nav-arrow">→</span> Architecture</a>
        </div>
      </nav>

      <section className="sl-hero">
        <div className="sl-hero-status"><span className="dot"></span> Active</div>
        <h1>HopenVision</h1>
        <p className="tagline">Admission Prediction · 모의고사 · 합격 예측</p>
        <p className="desc">모의고사 성적 데이터를 기반으로 대학별 합격 가능성을 예측하고, 학습 방향을 제시하는 입시 예측 시스템</p>
        <div className="sl-hero-actions">
          <Link to="/exams" className="sl-btn sl-btn-primary">시험 채점</Link>
          <Link to="/exams" className="sl-btn sl-btn-outline">모의고사</Link>
          <Link to="/history" className="sl-btn sl-btn-outline">응시 이력</Link>
          <a href="/admin/statistics" className="sl-btn sl-btn-outline">통계 대시보드</a>
          <a href="/admin/login" className="sl-btn sl-btn-outline">관리자</a>
        </div>
      </section>

      <section className="sl-section">
        <div className="sl-section-title">Features</div>
        <div className="sl-features">
          {FEATURES.map(renderFeature)}
        </div>
      </section>

      <section className="sl-section sl-arch">
        <div className="sl-section-title">Architecture</div>
        <div className="sl-arch-diagram">
          <div className="sl-arch-node"><div className="sl-arch-node-label">Frontend</div><div className="sl-arch-node-tech">React</div></div>
          <div className="sl-arch-arrow">→</div>
          <div className="sl-arch-node highlight"><div className="sl-arch-node-label">Backend</div><div className="sl-arch-node-tech">Spring Boot</div></div>
          <div className="sl-arch-arrow">→</div>
          <div className="sl-arch-node"><div className="sl-arch-node-label">Database</div><div className="sl-arch-node-tech">PostgreSQL</div></div>
        </div>
      </section>

      <section className="sl-section sl-flow">
        <div className="sl-section-title">Service Flow</div>
        <div className="sl-flow-steps">
          <div className="sl-flow-step"><div className="sl-flow-step-num">1</div><div className="sl-flow-step-label">시험 응시</div><div className="sl-flow-step-desc">온라인 모의고사</div></div>
          <div className="sl-flow-arrow">→</div>
          <div className="sl-flow-step"><div className="sl-flow-step-num">2</div><div className="sl-flow-step-label">성적 분석</div><div className="sl-flow-step-desc">과목별 분석</div></div>
          <div className="sl-flow-arrow">→</div>
          <div className="sl-flow-step"><div className="sl-flow-step-num">3</div><div className="sl-flow-step-label">합격 예측</div><div className="sl-flow-step-desc">대학별 가능성</div></div>
          <div className="sl-flow-arrow">→</div>
          <div className="sl-flow-step"><div className="sl-flow-step-num">4</div><div className="sl-flow-step-label">통계 리포트</div><div className="sl-flow-step-desc">추이 시각화</div></div>
        </div>
      </section>

      <section className="sl-section sl-tech">
        <div className="sl-section-title">Tech Stack</div>
        <div className="sl-tech-list">
          {TECH_STACK.map(t => (
            <span key={t.name} className="sl-tech-badge">
              <span className="sl-tech-dot" style={{ background: t.color }}></span> {t.name}
            </span>
          ))}
        </div>
      </section>

      <section className="sl-section sl-connected">
        <div className="sl-section-title">Connected Services</div>
        <div className="sl-connected-grid">
          {CONNECTED_SERVICES.map(svc => (
            <a key={svc.name} href={svc.href} target="_blank" rel="noopener noreferrer" className="sl-connected-card">
              <span className="sl-connected-dot" style={{ background: svc.color }}></span>
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
  );
}
