-- ============================================
-- MVP Sprint 3 — Enrollment + Order 모듈
-- prefix: en_ (enrollment), od_ (order)
-- ============================================

-- 장바구니 (세션성 상 있기 쉽지만 DB 영속 유지 — Redis 는 임시 lock/count 에만 사용)
CREATE TABLE IF NOT EXISTS od_cart (
    cart_id         BIGSERIAL PRIMARY KEY,
    member_id       BIGINT NOT NULL REFERENCES id_member(member_id) ON DELETE CASCADE,
    item_type       VARCHAR(20) NOT NULL,
    item_ref_id     BIGINT NOT NULL,
    quantity        INTEGER DEFAULT 1,
    added_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (member_id, item_type, item_ref_id)
);
COMMENT ON TABLE  od_cart IS '장바구니 (LECTURE / BOOK 항목 보관)';
COMMENT ON COLUMN od_cart.item_type IS 'LECTURE: ct_lecture.lecture_id, BOOK: bk_catalog.book_id';

-- 주문 마스터
CREATE TABLE IF NOT EXISTS od_order (
    order_id        BIGSERIAL PRIMARY KEY,
    order_no        VARCHAR(30) UNIQUE NOT NULL,
    member_id       BIGINT NOT NULL REFERENCES id_member(member_id),
    order_status    VARCHAR(20) DEFAULT 'PENDING',
    total_amount    BIGINT DEFAULT 0,
    discount_amount BIGINT DEFAULT 0,
    mileage_used    BIGINT DEFAULT 0,
    coupon_discount BIGINT DEFAULT 0,
    pay_amount      BIGINT DEFAULT 0,
    pg_provider     VARCHAR(30),
    pg_tx_id        VARCHAR(100),
    ordered_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    paid_at         TIMESTAMP,
    canceled_at     TIMESTAMP,
    memo            VARCHAR(500),
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
COMMENT ON TABLE  od_order IS '주문 헤더';
COMMENT ON COLUMN od_order.order_status IS 'PENDING → PAID → (PARTIALLY_REFUNDED|REFUNDED|CANCELED)';

CREATE INDEX IF NOT EXISTS ix_od_order_member ON od_order(member_id, ordered_at DESC);
CREATE INDEX IF NOT EXISTS ix_od_order_status ON od_order(order_status);

-- 주문 상세
CREATE TABLE IF NOT EXISTS od_order_item (
    item_id         BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL REFERENCES od_order(order_id) ON DELETE CASCADE,
    item_type       VARCHAR(20) NOT NULL,
    item_ref_id     BIGINT NOT NULL,
    item_name       VARCHAR(300) NOT NULL,
    unit_price      BIGINT DEFAULT 0,
    quantity        INTEGER DEFAULT 1,
    item_amount     BIGINT DEFAULT 0,
    discount_amount BIGINT DEFAULT 0,
    item_status     VARCHAR(20) DEFAULT 'NORMAL',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON COLUMN od_order_item.item_type IS 'LECTURE / BOOK / MOCK_EXAM';
COMMENT ON COLUMN od_order_item.item_status IS 'NORMAL / REFUNDED';

CREATE INDEX IF NOT EXISTS ix_od_order_item_order ON od_order_item(order_id);

-- 결제 이력 (PG 응답 스냅샷)
CREATE TABLE IF NOT EXISTS od_payment (
    payment_id      BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL REFERENCES od_order(order_id) ON DELETE CASCADE,
    pg_provider     VARCHAR(30) NOT NULL,
    pg_tx_id        VARCHAR(100),
    pay_method      VARCHAR(30),
    amount          BIGINT NOT NULL,
    status          VARCHAR(20) NOT NULL,
    raw_response    TEXT,
    requested_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at    TIMESTAMP
);
COMMENT ON TABLE  od_payment IS '결제 트랜잭션 기록';
COMMENT ON COLUMN od_payment.pay_method IS 'CARD / VBANK / POINT / MIXED';

-- 환불
CREATE TABLE IF NOT EXISTS od_refund (
    refund_id       BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL REFERENCES od_order(order_id),
    item_id         BIGINT REFERENCES od_order_item(item_id),
    refund_type     VARCHAR(20) DEFAULT 'FULL',
    refund_amount   BIGINT NOT NULL,
    refund_reason   VARCHAR(500),
    refund_status   VARCHAR(20) DEFAULT 'REQUESTED',
    requested_by    BIGINT REFERENCES id_member(member_id),
    requested_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_by     BIGINT REFERENCES id_member(member_id),
    approved_at     TIMESTAMP,
    completed_at    TIMESTAMP
);
COMMENT ON COLUMN od_refund.refund_type IS 'FULL / PARTIAL / PARTIAL_ITEM';
COMMENT ON COLUMN od_refund.refund_status IS 'REQUESTED → APPROVED → COMPLETED 또는 REJECTED';

-- ============================================
-- Enrollment — 수강권·진도
-- ============================================

-- 수강권 (주문 결제 완료 시 자동 발급)
CREATE TABLE IF NOT EXISTS en_entitlement (
    entitlement_id  BIGSERIAL PRIMARY KEY,
    member_id       BIGINT NOT NULL REFERENCES id_member(member_id),
    lecture_id      BIGINT NOT NULL REFERENCES ct_lecture(lecture_id),
    order_item_id   BIGINT REFERENCES od_order_item(item_id),
    granted_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expire_at       TIMESTAMP,
    status          VARCHAR(20) DEFAULT 'ACTIVE',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
COMMENT ON TABLE  en_entitlement IS '수강권 (주문 → 발급 → 만료/연장)';
COMMENT ON COLUMN en_entitlement.status IS 'ACTIVE / EXPIRED / SUSPENDED / REVOKED';

CREATE INDEX IF NOT EXISTS ix_en_entitlement_member_active
    ON en_entitlement(member_id, status);
CREATE INDEX IF NOT EXISTS ix_en_entitlement_lecture
    ON en_entitlement(lecture_id);

-- 진도 (챕터별 시청 상태 — 동영상 플레이어 연동 전에는 수동/목차 체크 수준)
CREATE TABLE IF NOT EXISTS en_progress (
    progress_id     BIGSERIAL PRIMARY KEY,
    entitlement_id  BIGINT NOT NULL REFERENCES en_entitlement(entitlement_id) ON DELETE CASCADE,
    chapter_id      BIGINT NOT NULL REFERENCES ct_lecture_chapter(chapter_id),
    watched_seconds INTEGER DEFAULT 0,
    completion_rate NUMERIC(5,2) DEFAULT 0,
    last_watched_at TIMESTAMP,
    completed_at    TIMESTAMP,
    UNIQUE (entitlement_id, chapter_id)
);
COMMENT ON TABLE en_progress IS '챕터별 진도 (동영상 연동 전에는 last_watched_at/completed_at 토글만)';

-- 재수강 신청
CREATE TABLE IF NOT EXISTS en_reenroll_request (
    request_id      BIGSERIAL PRIMARY KEY,
    entitlement_id  BIGINT NOT NULL REFERENCES en_entitlement(entitlement_id),
    member_id       BIGINT NOT NULL REFERENCES id_member(member_id),
    reason          VARCHAR(500),
    request_status  VARCHAR(20) DEFAULT 'PENDING',
    extend_days     INTEGER,
    requested_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_by     BIGINT REFERENCES id_member(member_id),
    reviewed_at     TIMESTAMP
);
COMMENT ON TABLE en_reenroll_request IS '수강 연장·재수강 신청 (관리자 승인 흐름)';
