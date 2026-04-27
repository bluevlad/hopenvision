/**
 * Point 모듈 — 쿠폰·마일리지.
 *
 * <p>테이블 prefix: {@code pt_*}
 * <p>주요 엔터티: {@code pt_coupon}, {@code pt_member_coupon}, {@code pt_mileage_ledger}
 *
 * <p>의존: identity, order. order 모듈이 결제 시점에 쿠폰·마일리지 차감을 요청.
 */
package com.hopenvision.point;
