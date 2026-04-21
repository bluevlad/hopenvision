-- ============================================
-- MVP Sprint 2 — Content 모듈 (강의·과목·교수진)
-- prefix: ct_
-- ============================================

-- 교수진
CREATE TABLE IF NOT EXISTS ct_teacher (
    teacher_id      BIGSERIAL PRIMARY KEY,
    member_id       BIGINT REFERENCES id_member(member_id),
    teacher_nm      VARCHAR(100) NOT NULL,
    profile_image   VARCHAR(500),
    bio             TEXT,
    intro_video_url VARCHAR(500),
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);

COMMENT ON TABLE  ct_teacher IS '강사 프로필';
COMMENT ON COLUMN ct_teacher.member_id IS '강사 계정(id_member) 연결. NULL 허용 (외부 강사 초빙 케이스)';

-- 과목 카테고리 (공무원/법학/자격증 등 대분류)
CREATE TABLE IF NOT EXISTS ct_category (
    category_cd     VARCHAR(30) PRIMARY KEY,
    category_nm     VARCHAR(100) NOT NULL,
    parent_cd       VARCHAR(30) REFERENCES ct_category(category_cd),
    depth           INTEGER DEFAULT 1,
    sort_order      INTEGER DEFAULT 0,
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE ct_category IS '강의 카테고리 (계층)';

-- 강의 과목 (예: 형법, 행정법)
CREATE TABLE IF NOT EXISTS ct_subject (
    subject_cd      VARCHAR(30) PRIMARY KEY,
    subject_nm      VARCHAR(200) NOT NULL,
    category_cd     VARCHAR(30) REFERENCES ct_category(category_cd),
    description     TEXT,
    sort_order      INTEGER DEFAULT 0,
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
COMMENT ON TABLE ct_subject IS '강의 과목 마스터 (exam_subject 와 구분: ct_subject 는 강의 과목, exam_subject 는 시험 과목)';

-- 강의 마스터
CREATE TABLE IF NOT EXISTS ct_lecture (
    lecture_id      BIGSERIAL PRIMARY KEY,
    lecture_cd      VARCHAR(50) UNIQUE NOT NULL,
    lecture_nm      VARCHAR(300) NOT NULL,
    subject_cd      VARCHAR(30) REFERENCES ct_subject(subject_cd),
    teacher_id      BIGINT REFERENCES ct_teacher(teacher_id),
    lecture_type    VARCHAR(20) DEFAULT 'ONLINE',
    price           BIGINT DEFAULT 0,
    discount_rate   NUMERIC(5,2) DEFAULT 0,
    sale_price      BIGINT DEFAULT 0,
    duration_days   INTEGER DEFAULT 90,
    total_minutes   INTEGER DEFAULT 0,
    chapter_cnt     INTEGER DEFAULT 0,
    thumbnail_url   VARCHAR(500),
    description     TEXT,
    target_exam_cd  VARCHAR(50),
    sale_start_dt   TIMESTAMP,
    sale_end_dt     TIMESTAMP,
    lecture_status  VARCHAR(20) DEFAULT 'DRAFT',
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
COMMENT ON TABLE  ct_lecture IS '강의 마스터';
COMMENT ON COLUMN ct_lecture.lecture_type IS 'ONLINE(동영상), OFFLINE(학원), PACKAGE(패키지)';
COMMENT ON COLUMN ct_lecture.duration_days IS '수강 기간 (수강권 발급 시 적용)';
COMMENT ON COLUMN ct_lecture.target_exam_cd IS '연계 시험코드 (exam_mst.exam_cd). 필수 아님';
COMMENT ON COLUMN ct_lecture.lecture_status IS 'DRAFT, ON_SALE, PAUSED, ENDED';

CREATE INDEX IF NOT EXISTS ix_ct_lecture_subject ON ct_lecture(subject_cd);
CREATE INDEX IF NOT EXISTS ix_ct_lecture_status  ON ct_lecture(lecture_status, is_use);

-- 강의 챕터 (동영상 메타 — 실제 재생은 별도 Sprint)
CREATE TABLE IF NOT EXISTS ct_lecture_chapter (
    chapter_id      BIGSERIAL PRIMARY KEY,
    lecture_id      BIGINT NOT NULL REFERENCES ct_lecture(lecture_id) ON DELETE CASCADE,
    chapter_no      INTEGER NOT NULL,
    chapter_nm      VARCHAR(300) NOT NULL,
    duration_sec    INTEGER DEFAULT 0,
    video_url       VARCHAR(500),
    is_free_preview CHAR(1) DEFAULT 'N',
    sort_order      INTEGER DEFAULT 0,
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (lecture_id, chapter_no)
);
COMMENT ON TABLE  ct_lecture_chapter IS '강의 챕터 (목차 + 영상 URL 메타)';
COMMENT ON COLUMN ct_lecture_chapter.is_free_preview IS 'Y: 비로그인 미리보기 허용';
