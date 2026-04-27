-- ============================================
-- MVP Sprint 1 — Platform 모듈 (공통코드·메뉴·권한)
-- prefix: pl_
-- ============================================

-- 공통 코드 그룹
CREATE TABLE IF NOT EXISTS pl_code_group (
    group_cd        VARCHAR(50) PRIMARY KEY,
    group_nm        VARCHAR(200) NOT NULL,
    description     VARCHAR(500),
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 공통 코드 상세
CREATE TABLE IF NOT EXISTS pl_code (
    group_cd        VARCHAR(50) NOT NULL REFERENCES pl_code_group(group_cd) ON DELETE CASCADE,
    code_val        VARCHAR(50) NOT NULL,
    code_nm         VARCHAR(200) NOT NULL,
    sort_order      INTEGER DEFAULT 0,
    extra_value     VARCHAR(500),
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    PRIMARY KEY (group_cd, code_val)
);
COMMENT ON TABLE pl_code IS '공통 코드 (TB_BA_CONFIG_CD 대응)';

-- 메뉴 트리
CREATE TABLE IF NOT EXISTS pl_menu (
    menu_id         BIGSERIAL PRIMARY KEY,
    menu_cd         VARCHAR(50) UNIQUE NOT NULL,
    menu_nm         VARCHAR(100) NOT NULL,
    parent_menu_cd  VARCHAR(50),
    menu_path       VARCHAR(300),
    icon            VARCHAR(100),
    menu_order      INTEGER DEFAULT 0,
    menu_type       VARCHAR(20) DEFAULT 'ADMIN',
    required_role   VARCHAR(30),
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
COMMENT ON COLUMN pl_menu.menu_type IS 'ADMIN / USER';
COMMENT ON COLUMN pl_menu.required_role IS '필요 role (pl_role.role_cd)';

CREATE INDEX IF NOT EXISTS ix_pl_menu_parent ON pl_menu(parent_menu_cd, menu_order);

-- 권한 (Role-based)
CREATE TABLE IF NOT EXISTS pl_role (
    role_cd         VARCHAR(30) PRIMARY KEY,
    role_nm         VARCHAR(100) NOT NULL,
    description     VARCHAR(500),
    is_system       CHAR(1) DEFAULT 'N',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 회원-권한 매핑
CREATE TABLE IF NOT EXISTS pl_member_role (
    member_id       BIGINT NOT NULL REFERENCES id_member(member_id) ON DELETE CASCADE,
    role_cd         VARCHAR(30) NOT NULL REFERENCES pl_role(role_cd),
    granted_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by      BIGINT REFERENCES id_member(member_id),
    PRIMARY KEY (member_id, role_cd)
);

-- 기본 role 시드
INSERT INTO pl_role (role_cd, role_nm, description, is_system) VALUES
    ('ROLE_USER',        '일반 수강생',   '기본 수강 권한',            'Y'),
    ('ROLE_TEACHER',     '강사',          '강의 등록·채점',            'Y'),
    ('ROLE_ADMIN',       '관리자',        '전체 관리',                 'Y'),
    ('ROLE_SUPER_ADMIN', '슈퍼 관리자',   'role 부여 포함 최상위 권한', 'Y')
ON CONFLICT (role_cd) DO NOTHING;
