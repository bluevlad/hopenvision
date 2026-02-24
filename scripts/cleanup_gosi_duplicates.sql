-- 중복 데이터 정리 스크립트
-- gosi_rst_det: 420건 중복, gosi_vod: 1건 중복 제거

-- 1. gosi_rst_det 중복 제거 (ctid 활용)
DELETE FROM gosi_rst_det a
USING gosi_rst_det b
WHERE a.ctid < b.ctid
  AND a.gosi_cd = b.gosi_cd
  AND a.rst_no = b.rst_no
  AND a.subject_cd = b.subject_cd
  AND a.item_no = b.item_no;

-- 2. gosi_vod 중복 제거
DELETE FROM gosi_vod a
USING gosi_vod b
WHERE a.ctid < b.ctid
  AND a.gosi_cd = b.gosi_cd
  AND a.prf_id = b.prf_id
  AND a.idx = b.idx;

-- 3. PK 제약조건 추가
ALTER TABLE gosi_rst_det ADD PRIMARY KEY (gosi_cd, rst_no, subject_cd, item_no);
ALTER TABLE gosi_vod ADD PRIMARY KEY (gosi_cd, prf_id, idx);

-- 4. 기타 테이블 PK 추가
ALTER TABLE gosi_mst ADD PRIMARY KEY (gosi_cd);
ALTER TABLE gosi_cod ADD PRIMARY KEY (gosi_type);
ALTER TABLE gosi_area_mst ADD PRIMARY KEY (gosi_type, gosi_area);
ALTER TABLE gosi_subject ADD PRIMARY KEY (gosi_type, gosi_subject_cd);
ALTER TABLE gosi_pass_mst ADD PRIMARY KEY (gosi_cd, subject_cd, exam_type, item_no);
ALTER TABLE gosi_pass_sta ADD PRIMARY KEY (gosi_cd, gosi_type);
ALTER TABLE gosi_rst_mst ADD PRIMARY KEY (gosi_cd, rst_no);
ALTER TABLE gosi_rst_sbj ADD PRIMARY KEY (gosi_cd, rst_no, subject_cd);
ALTER TABLE gosi_stat_mst ADD PRIMARY KEY (gosi_cd, gosi_type, gosi_area, gosi_subject_cd);
ALTER TABLE gosi_sbj_mst ADD PRIMARY KEY (gosi_cd, sbj_type, subject_cd);
ALTER TABLE tb_ma_member ADD PRIMARY KEY (user_id);
