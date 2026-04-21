-- ============================================
-- MVP Sprint 4 — Point + Coupon 모듈
-- prefix: pt_
-- ============================================

-- 쿠폰 템플릿
CREATE TABLE IF NOT EXISTS pt_coupon (
    coupon_id       BIGSERIAL PRIMARY KEY,
    coupon_cd       VARCHAR(50) UNIQUE NOT NULL,
    coupon_nm       VARCHAR(200) NOT NULL,
    discount_type   VARCHAR(20) NOT NULL,
    discount_value  BIGINT NOT NULL,
    min_order_amt   BIGINT DEFAULT 0,
    max_discount    BIGINT,
    valid_from      TIMESTAMP,
    valid_to        TIMESTAMP,
    issue_limit     INTEGER,
    issued_count    INTEGER DEFAULT 0,
    target_item_type VARCHAR(20),
    target_item_ref_id BIGINT,
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
COMMENT ON COLUMN pt_coupon.discount_type IS 'PERCENT / AMOUNT';
COMMENT ON COLUMN pt_coupon.target_item_type IS 'ALL / LECTURE / BOOK / MOCK_EXAM';

-- 회원 보유 쿠폰
CREATE TABLE IF NOT EXISTS pt_member_coupon (
    member_coupon_id BIGSERIAL PRIMARY KEY,
    member_id        BIGINT NOT NULL REFERENCES id_member(member_id) ON DELETE CASCADE,
    coupon_id        BIGINT NOT NULL REFERENCES pt_coupon(coupon_id),
    issued_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used_at          TIMESTAMP,
    used_order_id    BIGINT REFERENCES od_order(order_id),
    expire_at        TIMESTAMP,
    status           VARCHAR(20) DEFAULT 'ISSUED'
);
COMMENT ON COLUMN pt_member_coupon.status IS 'ISSUED / USED / EXPIRED / REVOKED';

CREATE INDEX IF NOT EXISTS ix_pt_member_coupon_member
    ON pt_member_coupon(member_id, status);

-- 마일리지 이력 (적립·사용 append-only 기록)
CREATE TABLE IF NOT EXISTS pt_mileage_ledger (
    ledger_id       BIGSERIAL PRIMARY KEY,
    member_id       BIGINT NOT NULL REFERENCES id_member(member_id) ON DELETE CASCADE,
    change_type     VARCHAR(20) NOT NULL,
    amount          BIGINT NOT NULL,
    balance_after   BIGINT NOT NULL,
    reason          VARCHAR(200),
    ref_order_id    BIGINT REFERENCES od_order(order_id),
    expire_at       TIMESTAMP,
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE  pt_mileage_ledger IS '마일리지 원장 (append-only, balance_after 로 현재잔액 빠르게 조회)';
COMMENT ON COLUMN pt_mileage_ledger.change_type IS 'EARN / USE / EXPIRE / ADJUST';

CREATE INDEX IF NOT EXISTS ix_pt_mileage_member
    ON pt_mileage_ledger(member_id, reg_dt DESC);
