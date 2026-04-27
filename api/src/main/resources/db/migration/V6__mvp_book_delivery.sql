-- ============================================
-- MVP Sprint 4 — Book + Delivery 모듈
-- prefix: bk_
-- ============================================

-- 교재 카탈로그
CREATE TABLE IF NOT EXISTS bk_catalog (
    book_id         BIGSERIAL PRIMARY KEY,
    book_cd         VARCHAR(50) UNIQUE NOT NULL,
    book_nm         VARCHAR(300) NOT NULL,
    subject_cd      VARCHAR(30) REFERENCES ct_subject(subject_cd),
    teacher_id      BIGINT REFERENCES ct_teacher(teacher_id),
    publisher       VARCHAR(100),
    author          VARCHAR(200),
    isbn            VARCHAR(30),
    price           BIGINT DEFAULT 0,
    discount_rate   NUMERIC(5,2) DEFAULT 0,
    sale_price      BIGINT DEFAULT 0,
    publish_date    DATE,
    thumbnail_url   VARCHAR(500),
    description     TEXT,
    linked_lecture_id BIGINT REFERENCES ct_lecture(lecture_id),
    stock_status    VARCHAR(20) DEFAULT 'AVAILABLE',
    is_use          CHAR(1) DEFAULT 'Y',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
COMMENT ON COLUMN bk_catalog.linked_lecture_id IS '강의와 연계된 교재인 경우 (수강신청 시 함께 결제 옵션)';
COMMENT ON COLUMN bk_catalog.stock_status IS 'AVAILABLE / LOW / OUT_OF_STOCK / DISCONTINUED';

CREATE INDEX IF NOT EXISTS ix_bk_catalog_subject ON bk_catalog(subject_cd);

-- 재고
CREATE TABLE IF NOT EXISTS bk_inventory (
    book_id         BIGINT PRIMARY KEY REFERENCES bk_catalog(book_id) ON DELETE CASCADE,
    on_hand         INTEGER DEFAULT 0,
    reserved        INTEGER DEFAULT 0,
    safety_stock    INTEGER DEFAULT 10,
    last_restock_at TIMESTAMP,
    upd_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 배송지
CREATE TABLE IF NOT EXISTS bk_shipping_address (
    address_id      BIGSERIAL PRIMARY KEY,
    member_id       BIGINT NOT NULL REFERENCES id_member(member_id) ON DELETE CASCADE,
    receiver_nm     VARCHAR(100) NOT NULL,
    receiver_phone  VARCHAR(30) NOT NULL,
    postal_code     VARCHAR(10),
    address1        VARCHAR(300) NOT NULL,
    address2        VARCHAR(200),
    is_default      CHAR(1) DEFAULT 'N',
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
CREATE INDEX IF NOT EXISTS ix_bk_shipping_member
    ON bk_shipping_address(member_id, is_default);

-- 배송
CREATE TABLE IF NOT EXISTS bk_delivery (
    delivery_id     BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL REFERENCES od_order(order_id) ON DELETE CASCADE,
    address_id      BIGINT REFERENCES bk_shipping_address(address_id),
    receiver_nm     VARCHAR(100) NOT NULL,
    receiver_phone  VARCHAR(30) NOT NULL,
    postal_code     VARCHAR(10),
    address1        VARCHAR(300) NOT NULL,
    address2        VARCHAR(200),
    courier         VARCHAR(30),
    tracking_no     VARCHAR(50),
    delivery_status VARCHAR(20) DEFAULT 'PREPARING',
    shipped_at      TIMESTAMP,
    delivered_at    TIMESTAMP,
    memo            VARCHAR(300),
    reg_dt          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    upd_dt          TIMESTAMP
);
COMMENT ON COLUMN bk_delivery.delivery_status IS 'PREPARING → READY → SHIPPED → DELIVERED / HOLD / RETURNED';

CREATE INDEX IF NOT EXISTS ix_bk_delivery_order ON bk_delivery(order_id);
CREATE INDEX IF NOT EXISTS ix_bk_delivery_status ON bk_delivery(delivery_status);

-- 배송 상세 항목 (1 배송 = N 교재)
CREATE TABLE IF NOT EXISTS bk_delivery_item (
    delivery_item_id BIGSERIAL PRIMARY KEY,
    delivery_id      BIGINT NOT NULL REFERENCES bk_delivery(delivery_id) ON DELETE CASCADE,
    book_id          BIGINT NOT NULL REFERENCES bk_catalog(book_id),
    order_item_id    BIGINT REFERENCES od_order_item(item_id),
    quantity         INTEGER DEFAULT 1
);
