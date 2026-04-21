/**
 * Content 모듈 — 강의·과목·교수진·챕터.
 *
 * <p>테이블 prefix: {@code ct_*}
 * <p>주요 엔터티: {@code ct_lecture}, {@code ct_subject}, {@code ct_teacher}, {@code ct_category}, {@code ct_lecture_chapter}
 *
 * <p>의존: identity (강사 계정 연결). exam 모듈은 단방향으로만 참조한다.
 */
package com.hopenvision.content;
