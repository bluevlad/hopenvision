/**
 * Order 모듈 — 장바구니·주문·결제·환불.
 *
 * <p>테이블 prefix: {@code od_*}
 * <p>주요 엔터티: {@code od_cart}, {@code od_order}, {@code od_order_item}, {@code od_payment}, {@code od_refund}
 *
 * <p>의존: identity, content, book. 결제 완료 시 도메인 이벤트 발행 → enrollment / book 구독.
 */
package com.hopenvision.order;
