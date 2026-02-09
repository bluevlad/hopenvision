-- ============================================
-- 공무원 시험 채점 시스템 DB 스키마
-- PostgreSQL Database
-- ============================================

-- 1. 시험 마스터 테이블
CREATE TABLE IF NOT EXISTS exam_mst (
    exam_cd         VARCHAR(50) PRIMARY KEY,
    exam_nm         VARCHAR(200) NOT NULL,
    exam_type       VARCHAR(20),
    exam_year       VARCHAR(4),
    exam_round      INTEGER,
    exam_date       DATE,
    total_score     NUMERIC(5,2) DEFAULT 100,
    pass_score      NUMERIC(5,2),
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);

COMMENT ON TABLE exam_mst IS '시험 마스터';
COMMENT ON COLUMN exam_mst.exam_cd IS '시험코드';
COMMENT ON COLUMN exam_mst.exam_nm IS '시험명';
COMMENT ON COLUMN exam_mst.pass_score IS '합격 기준 총점';

-- 2. 과목 테이블
CREATE TABLE IF NOT EXISTS exam_subject (
    exam_cd         VARCHAR(50) NOT NULL,
    subject_cd      VARCHAR(20) NOT NULL,
    subject_nm      VARCHAR(100) NOT NULL,
    subject_type    CHAR(1) DEFAULT 'M',
    question_cnt    INTEGER DEFAULT 20,
    score_per_q     NUMERIC(5,2) DEFAULT 5,
    question_type   VARCHAR(20) DEFAULT 'CHOICE',
    cut_line        NUMERIC(5,2) DEFAULT 40,
    sort_order      INTEGER DEFAULT 1,
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (exam_cd, subject_cd),
    FOREIGN KEY (exam_cd) REFERENCES exam_mst(exam_cd) ON DELETE CASCADE
);

COMMENT ON TABLE exam_subject IS '과목 정보';
COMMENT ON COLUMN exam_subject.subject_type IS '과목유형 (M:필수, S:선택)';
COMMENT ON COLUMN exam_subject.question_type IS '문제유형 (CHOICE:객관식, ESSAY:주관식)';
COMMENT ON COLUMN exam_subject.cut_line IS '과목별 커트라인 (과락 기준)';

-- 3. 문제 테이블 (문항 정보, 해설 포함)
CREATE TABLE IF NOT EXISTS exam_question (
    exam_cd         VARCHAR(50) NOT NULL,
    subject_cd      VARCHAR(20) NOT NULL,
    question_no     INTEGER NOT NULL,
    question_text   TEXT,
    context_text    TEXT,
    choice_1        VARCHAR(1000),
    choice_2        VARCHAR(1000),
    choice_3        VARCHAR(1000),
    choice_4        VARCHAR(1000),
    choice_5        VARCHAR(1000),
    image_file      VARCHAR(200),
    category        VARCHAR(100),
    difficulty      VARCHAR(10),
    title           VARCHAR(500),
    explanation     TEXT,
    correction_note TEXT,
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    PRIMARY KEY (exam_cd, subject_cd, question_no),
    FOREIGN KEY (exam_cd, subject_cd) REFERENCES exam_subject(exam_cd, subject_cd) ON DELETE CASCADE
);

COMMENT ON TABLE exam_question IS '문제 정보';
COMMENT ON COLUMN exam_question.question_text IS '문제 텍스트';
COMMENT ON COLUMN exam_question.context_text IS '지문/보기';
COMMENT ON COLUMN exam_question.choice_1 IS '선택지 1';
COMMENT ON COLUMN exam_question.choice_2 IS '선택지 2';
COMMENT ON COLUMN exam_question.choice_3 IS '선택지 3';
COMMENT ON COLUMN exam_question.choice_4 IS '선택지 4';
COMMENT ON COLUMN exam_question.choice_5 IS '선택지 5';
COMMENT ON COLUMN exam_question.image_file IS '이미지 파일명';
COMMENT ON COLUMN exam_question.category IS '분류 (고대사-선사시대 등)';
COMMENT ON COLUMN exam_question.difficulty IS '난이도 (상/중/하)';
COMMENT ON COLUMN exam_question.title IS '문제 제목';
COMMENT ON COLUMN exam_question.explanation IS '해설';
COMMENT ON COLUMN exam_question.correction_note IS '오답 분석';

-- 4. 정답 테이블 (문항별 정답)
CREATE TABLE IF NOT EXISTS exam_answer_key (
    exam_cd         VARCHAR(50) NOT NULL,
    subject_cd      VARCHAR(20) NOT NULL,
    question_no     INTEGER NOT NULL,
    correct_ans     VARCHAR(10) NOT NULL,
    score           NUMERIC(5,2) DEFAULT 5,
    is_multi_ans    CHAR(1) DEFAULT 'N',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    PRIMARY KEY (exam_cd, subject_cd, question_no),
    FOREIGN KEY (exam_cd, subject_cd) REFERENCES exam_subject(exam_cd, subject_cd) ON DELETE CASCADE
);

COMMENT ON TABLE exam_answer_key IS '시험 정답';
COMMENT ON COLUMN exam_answer_key.correct_ans IS '정답 (객관식:1~5, 주관식:텍스트)';
COMMENT ON COLUMN exam_answer_key.is_multi_ans IS '복수정답 여부';

-- 4. 응시자 마스터 테이블
CREATE TABLE IF NOT EXISTS exam_applicant (
    exam_cd         VARCHAR(50) NOT NULL,
    applicant_no    VARCHAR(20) NOT NULL,
    user_id         VARCHAR(50),
    user_nm         VARCHAR(100),
    apply_area      VARCHAR(50),
    apply_type      VARCHAR(20),
    add_score       NUMERIC(5,2) DEFAULT 0,
    total_score     NUMERIC(5,2),
    avg_score       NUMERIC(5,2),
    ranking         INTEGER,
    pass_yn         CHAR(1),
    score_status    CHAR(1) DEFAULT 'N',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    PRIMARY KEY (exam_cd, applicant_no),
    FOREIGN KEY (exam_cd) REFERENCES exam_mst(exam_cd) ON DELETE CASCADE
);

COMMENT ON TABLE exam_applicant IS '응시자 정보';
COMMENT ON COLUMN exam_applicant.add_score IS '가산점';
COMMENT ON COLUMN exam_applicant.pass_yn IS '합격여부 (Y:합격, N:불합격, P:예비합격)';

-- 5. 응시자 답안 테이블
CREATE TABLE IF NOT EXISTS exam_applicant_ans (
    exam_cd         VARCHAR(50) NOT NULL,
    applicant_no    VARCHAR(20) NOT NULL,
    subject_cd      VARCHAR(20) NOT NULL,
    question_no     INTEGER NOT NULL,
    user_ans        VARCHAR(10),
    is_correct      CHAR(1),
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (exam_cd, applicant_no, subject_cd, question_no),
    FOREIGN KEY (exam_cd, applicant_no) REFERENCES exam_applicant(exam_cd, applicant_no) ON DELETE CASCADE
);

COMMENT ON TABLE exam_applicant_ans IS '응시자 답안';
COMMENT ON COLUMN exam_applicant_ans.is_correct IS '정답여부';

-- 6. 응시자 과목별 성적 테이블
CREATE TABLE IF NOT EXISTS exam_applicant_score (
    exam_cd         VARCHAR(50) NOT NULL,
    applicant_no    VARCHAR(20) NOT NULL,
    subject_cd      VARCHAR(20) NOT NULL,
    raw_score       NUMERIC(5,2),
    adj_score       NUMERIC(5,2),
    correct_cnt     INTEGER,
    wrong_cnt       INTEGER,
    subject_rank    INTEGER,
    cut_pass_yn     CHAR(1),
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    PRIMARY KEY (exam_cd, applicant_no, subject_cd),
    FOREIGN KEY (exam_cd, applicant_no) REFERENCES exam_applicant(exam_cd, applicant_no) ON DELETE CASCADE
);

COMMENT ON TABLE exam_applicant_score IS '응시자 과목별 성적';
COMMENT ON COLUMN exam_applicant_score.raw_score IS '원점수';
COMMENT ON COLUMN exam_applicant_score.adj_score IS '조정점수';
COMMENT ON COLUMN exam_applicant_score.cut_pass_yn IS '과락여부 (Y:통과, N:과락)';

-- 7. 합격선 설정 테이블 (지역/유형별)
CREATE TABLE IF NOT EXISTS exam_pass_line (
    exam_cd         VARCHAR(50) NOT NULL,
    apply_area      VARCHAR(50) NOT NULL,
    apply_type      VARCHAR(20) NOT NULL,
    recruit_cnt     INTEGER,
    pass_line       NUMERIC(5,2),
    cut_line_must   NUMERIC(5,2) DEFAULT 40,
    cut_line_sel    NUMERIC(5,2) DEFAULT 40,
    pass_ranking    INTEGER,
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    PRIMARY KEY (exam_cd, apply_area, apply_type),
    FOREIGN KEY (exam_cd) REFERENCES exam_mst(exam_cd) ON DELETE CASCADE
);

COMMENT ON TABLE exam_pass_line IS '합격선 설정';
COMMENT ON COLUMN exam_pass_line.pass_line IS '합격 커트라인';
COMMENT ON COLUMN exam_pass_line.cut_line_must IS '필수과목 과락 기준';
COMMENT ON COLUMN exam_pass_line.cut_line_sel IS '선택과목 과락 기준';

-- 8. 시험 통계 테이블
CREATE TABLE IF NOT EXISTS exam_stat (
    id              SERIAL PRIMARY KEY,
    exam_cd         VARCHAR(50) NOT NULL,
    apply_area      VARCHAR(50) DEFAULT 'ALL',
    subject_cd      VARCHAR(20) DEFAULT 'ALL',
    applicant_cnt   INTEGER,
    avg_score       NUMERIC(5,2),
    max_score       NUMERIC(5,2),
    min_score       NUMERIC(5,2),
    top_3_score     NUMERIC(5,2),
    top_10_score    NUMERIC(5,2),
    score_1_per     NUMERIC(5,2),
    score_2_per     NUMERIC(5,2),
    score_3_per     NUMERIC(5,2),
    score_4_per     NUMERIC(5,2),
    score_5_per     NUMERIC(5,2),
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    UNIQUE (exam_cd, apply_area, subject_cd)
);

COMMENT ON TABLE exam_stat IS '시험 통계';

-- 9. 사용자 답안 테이블
CREATE TABLE IF NOT EXISTS user_answer (
    user_id         VARCHAR(50) NOT NULL,
    exam_cd         VARCHAR(50) NOT NULL,
    subject_cd      VARCHAR(50) NOT NULL,
    question_no     INTEGER NOT NULL,
    user_ans        VARCHAR(100),
    is_correct      CHAR(1),
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, exam_cd, subject_cd, question_no),
    FOREIGN KEY (exam_cd) REFERENCES exam_mst(exam_cd) ON DELETE CASCADE
);

COMMENT ON TABLE user_answer IS '사용자 답안';
COMMENT ON COLUMN user_answer.user_ans IS '사용자 입력 답안';
COMMENT ON COLUMN user_answer.is_correct IS '정답여부 (Y/N)';

-- 10. 사용자 과목별 성적 테이블
CREATE TABLE IF NOT EXISTS user_score (
    user_id         VARCHAR(50) NOT NULL,
    exam_cd         VARCHAR(50) NOT NULL,
    subject_cd      VARCHAR(50) NOT NULL,
    raw_score       NUMERIC(5,2),
    correct_cnt     INTEGER,
    wrong_cnt       INTEGER,
    ranking         INTEGER,
    percentile      NUMERIC(5,2),
    batch_yn        CHAR(1) DEFAULT 'N',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    PRIMARY KEY (user_id, exam_cd, subject_cd),
    FOREIGN KEY (exam_cd) REFERENCES exam_mst(exam_cd) ON DELETE CASCADE
);

COMMENT ON TABLE user_score IS '사용자 과목별 성적';
COMMENT ON COLUMN user_score.raw_score IS '원점수';
COMMENT ON COLUMN user_score.correct_cnt IS '정답 수';
COMMENT ON COLUMN user_score.wrong_cnt IS '오답 수';
COMMENT ON COLUMN user_score.ranking IS '과목별 순위';
COMMENT ON COLUMN user_score.percentile IS '백분위';

-- 11. 사용자 총점 테이블
CREATE TABLE IF NOT EXISTS user_total_score (
    user_id         VARCHAR(50) NOT NULL,
    exam_cd         VARCHAR(50) NOT NULL,
    total_score     NUMERIC(5,2),
    avg_score       NUMERIC(5,2),
    total_ranking   INTEGER,
    area_ranking    INTEGER,
    type_ranking    INTEGER,
    percentile      NUMERIC(5,2),
    pass_yn         CHAR(1),
    cut_fail_yn     CHAR(1) DEFAULT 'N',
    batch_yn        CHAR(1) DEFAULT 'N',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP,
    PRIMARY KEY (user_id, exam_cd),
    FOREIGN KEY (exam_cd) REFERENCES exam_mst(exam_cd) ON DELETE CASCADE
);

COMMENT ON TABLE user_total_score IS '사용자 총점';
COMMENT ON COLUMN user_total_score.total_score IS '총점';
COMMENT ON COLUMN user_total_score.avg_score IS '평균 점수';
COMMENT ON COLUMN user_total_score.total_ranking IS '전체 순위';
COMMENT ON COLUMN user_total_score.pass_yn IS '합격여부 (Y/N)';
COMMENT ON COLUMN user_total_score.cut_fail_yn IS '과락여부 (Y:과락있음, N:없음)';

-- ============================================
-- 인덱스 생성
-- ============================================
CREATE INDEX IF NOT EXISTS idx_exam_applicant_user ON exam_applicant(user_id);
CREATE INDEX IF NOT EXISTS idx_exam_applicant_area ON exam_applicant(exam_cd, apply_area);
CREATE INDEX IF NOT EXISTS idx_exam_app_score_subj ON exam_applicant_score(exam_cd, subject_cd);
CREATE INDEX IF NOT EXISTS idx_user_answer_exam ON user_answer(exam_cd, subject_cd);
CREATE INDEX IF NOT EXISTS idx_user_score_exam ON user_score(exam_cd, subject_cd);
CREATE INDEX IF NOT EXISTS idx_user_total_score_exam ON user_total_score(exam_cd);
