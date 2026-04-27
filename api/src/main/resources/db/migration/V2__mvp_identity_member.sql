-- ============================================
-- MVP Sprint 1 — Identity 모듈
-- 회원(수강생·관리자 공통 프로필) 테이블
-- prefix: id_  (identity 모듈)
-- ============================================

CREATE TABLE IF NOT EXISTS id_member (
    member_id        BIGSERIAL PRIMARY KEY,
    email            VARCHAR(200) NOT NULL UNIQUE,
    password_hash    VARCHAR(200),
    name             VARCHAR(100) NOT NULL,
    phone            VARCHAR(30),
    birth_date       DATE,
    gender           CHAR(1),
    member_type      VARCHAR(20) DEFAULT 'USER',
    member_status    VARCHAR(20) DEFAULT 'ACTIVE',
    google_sub       VARCHAR(100),
    newsletter_yn    CHAR(1) DEFAULT 'N',
    terms_agreed_at  TIMESTAMP,
    privacy_agreed_at TIMESTAMP,
    marketing_agreed_at TIMESTAMP,
    last_login_at    TIMESTAMP,
    reg_dt           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt           TIMESTAMP
);

COMMENT ON TABLE  id_member IS '회원 마스터';
COMMENT ON COLUMN id_member.member_type IS '회원구분 (USER:수강생, ADMIN:운영자, TEACHER:강사)';
COMMENT ON COLUMN id_member.member_status IS '상태 (ACTIVE, DORMANT, WITHDRAWN, SUSPENDED)';
COMMENT ON COLUMN id_member.google_sub IS 'Google OAuth sub (NULL 허용, 이메일+비밀번호 로그인 병행 지원)';

CREATE UNIQUE INDEX IF NOT EXISTS ux_id_member_google_sub
    ON id_member (google_sub) WHERE google_sub IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_id_member_status ON id_member (member_status);

-- 회원 등급 (향후 포인트·쿠폰 연동 기준)
CREATE TABLE IF NOT EXISTS id_member_grade (
    grade_cd         VARCHAR(20) PRIMARY KEY,
    grade_nm         VARCHAR(50) NOT NULL,
    grade_order      INTEGER DEFAULT 0,
    min_order_amount BIGINT DEFAULT 0,
    mileage_rate     NUMERIC(5,2) DEFAULT 0,
    is_use           CHAR(1) DEFAULT 'Y',
    reg_dt           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt           TIMESTAMP
);

COMMENT ON TABLE  id_member_grade IS '회원 등급';
COMMENT ON COLUMN id_member_grade.mileage_rate IS '마일리지 적립률(%) — point 모듈에서 참조';

-- 회원-등급 이력
CREATE TABLE IF NOT EXISTS id_member_grade_history (
    history_id   BIGSERIAL PRIMARY KEY,
    member_id    BIGINT NOT NULL REFERENCES id_member(member_id) ON DELETE CASCADE,
    grade_cd     VARCHAR(20) NOT NULL REFERENCES id_member_grade(grade_cd),
    changed_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason       VARCHAR(200)
);

CREATE INDEX IF NOT EXISTS ix_id_member_grade_hist_member
    ON id_member_grade_history (member_id, changed_at DESC);

-- 기본 등급 시드
INSERT INTO id_member_grade (grade_cd, grade_nm, grade_order, min_order_amount, mileage_rate) VALUES
    ('BRONZE', '브론즈', 1, 0,       1.00),
    ('SILVER', '실버',   2, 100000,  2.00),
    ('GOLD',   '골드',   3, 500000,  3.00),
    ('VIP',    'VIP',    4, 2000000, 5.00)
ON CONFLICT (grade_cd) DO NOTHING;
