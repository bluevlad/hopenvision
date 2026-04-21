/**
 * Enrollment 모듈 — 수강권·진도·재수강 신청.
 *
 * <p>테이블 prefix: {@code en_*}
 * <p>주요 엔터티: {@code en_entitlement}, {@code en_progress}, {@code en_reenroll_request}
 *
 * <p>의존: identity, content, order. 결제 완료 이벤트를 구독해 entitlement 발급.
 */
package com.hopenvision.enrollment;
