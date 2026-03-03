# -*- coding: utf-8 -*-
"""
Oracle TB_SUBJECT_INFO → PostgreSQL subject_master 마이그레이션 스크립트

Oracle의 TB_SUBJECT_INFO 과목 데이터를 읽어서
HopenVision의 subject_master 테이블에 INSERT 합니다.

컬럼 매핑:
  SUBJECT_CD   → subject_cd
  SUBJECT_NM   → subject_nm
  ISUSE        → is_use
  SUBJECT_SHORT_NM → description (약칭이 있으면 설명으로 활용)
"""

import oracledb
import psycopg2
import os
import sys
from datetime import datetime

# === 접속 정보 ===
ORACLE_CONFIG = {
    'user': 'WILLBES_GOSI',
    'password': 'WILLBES',
    'dsn': oracledb.makedsn('localhost', 1521, sid='orcl'),
}

PG_CONFIG = {
    'host': '172.30.1.72',
    'port': 5432,
    'dbname': 'hopenvision_dev',
    'user': 'dev_writer',
    'password': '2u3efnwWERTjq4HMZ8LrBknFv7VyQq',
}


def main():
    print("=" * 50)
    print("TB_SUBJECT_INFO → subject_master 마이그레이션")
    print("=" * 50)

    # 1) Oracle 접속 및 데이터 읽기
    print("\n[1/3] Oracle 접속 중...")
    os.environ['NLS_LANG'] = 'KOREAN_KOREA.AL32UTF8'
    oracledb.init_oracle_client()
    ora_conn = oracledb.connect(**ORACLE_CONFIG)
    ora_cur = ora_conn.cursor()
    print("  → Oracle 접속 성공")

    ora_cur.execute("""
        SELECT SUBJECT_CD, SUBJECT_NM, SUBJECT_SHORT_NM, ISUSE
        FROM TB_SUBJECT_INFO
        ORDER BY SUBJECT_CD
    """)
    rows = ora_cur.fetchall()
    print(f"  → {len(rows)}건 조회 완료")

    ora_cur.close()
    ora_conn.close()

    # 2) PostgreSQL 접속
    print("\n[2/3] PostgreSQL 접속 중...")
    pg_conn = psycopg2.connect(**PG_CONFIG)
    pg_cur = pg_conn.cursor()
    print("  → PostgreSQL 접속 성공")

    # 기존 데이터 확인
    pg_cur.execute("SELECT COUNT(*) FROM subject_master")
    existing = pg_cur.fetchone()[0]
    print(f"  → 기존 subject_master 데이터: {existing}건")

    # 3) 데이터 INSERT
    print("\n[3/3] subject_master에 INSERT 중...")
    now = datetime.now()
    inserted = 0
    skipped = 0

    for row in rows:
        subject_cd = str(row[0]).strip()
        subject_nm = row[1].strip() if row[1] else ''
        short_nm = row[2].strip() if row[2] else None
        is_use = row[3].strip() if row[3] else 'Y'

        if not subject_nm:
            print(f"  [SKIP] {subject_cd}: 과목명 없음")
            skipped += 1
            continue

        # UPSERT (ON CONFLICT DO UPDATE)
        pg_cur.execute("""
            INSERT INTO subject_master
                (subject_cd, subject_nm, subject_depth, sort_order, description, is_use, reg_dt, upd_dt)
            VALUES (%s, %s, 1, %s, %s, %s, %s, %s)
            ON CONFLICT (subject_cd) DO UPDATE SET
                subject_nm = EXCLUDED.subject_nm,
                description = EXCLUDED.description,
                is_use = EXCLUDED.is_use,
                upd_dt = EXCLUDED.upd_dt
        """, (
            subject_cd,
            subject_nm,
            int(subject_cd) - 1000,  # sort_order: 1001 → 1, 1002 → 2 ...
            short_nm,
            is_use,
            now,
            now,
        ))
        inserted += 1

    pg_conn.commit()

    # 결과 확인
    pg_cur.execute("SELECT COUNT(*) FROM subject_master")
    total = pg_cur.fetchone()[0]

    print(f"\n  → INSERT/UPDATE: {inserted}건, SKIP: {skipped}건")
    print(f"  → subject_master 총 데이터: {total}건")

    pg_cur.close()
    pg_conn.close()

    print("\n" + "=" * 50)
    print("마이그레이션 완료!")
    print("=" * 50)


if __name__ == '__main__':
    main()
