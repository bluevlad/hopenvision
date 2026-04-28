/*M!999999\- enable the sandbox mode */ 

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
DROP TABLE IF EXISTS `acm_board`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_board` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `PARENT_BOARD_SEQ` varchar(20) DEFAULT NULL,
  `SUBJECT` varchar(200) DEFAULT NULL,
  `CONTENT` longblob DEFAULT NULL,
  `FILE_PATH` varchar(100) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `REAL_FILE_NAME` varchar(100) DEFAULT NULL,
  `NOTICE_TOP_YN` varchar(1) DEFAULT NULL,
  `OPEN_YN` varchar(1) DEFAULT NULL,
  `IS_USE` varchar(1) DEFAULT NULL,
  `HITS` bigint(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `CREATENAME` varchar(30) DEFAULT NULL,
  `ANSWER` longblob DEFAULT NULL,
  `THUMBNAIL_FILE_PATH` varchar(100) DEFAULT NULL,
  `THUMBNAIL_FILE_NAME` varchar(100) DEFAULT NULL,
  `THUMBNAIL_FILE_REAL_NAME` varchar(100) DEFAULT NULL,
  `RECOMMEND` varchar(1) DEFAULT NULL,
  `BOARD_SEQ3` bigint(20) DEFAULT NULL,
  `EXAM_TYPE` varchar(1) DEFAULT NULL,
  `EXAM_AREA` varchar(50) DEFAULT NULL,
  `EXAM_CATE` varchar(1) DEFAULT NULL,
  `EXAM_SUB` varchar(50) DEFAULT NULL,
  `CATEGORY_CODE` varchar(100) DEFAULT NULL,
  `PROF_ID` varchar(30) DEFAULT NULL,
  `BOARD_TYPE` varchar(2) DEFAULT NULL,
  `MOCKCODE` varchar(20) DEFAULT NULL,
  `DIVICE_TYPE` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_board_category_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_board_category_info` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `CATEGORY_CODE` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_board_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_board_comment` (
  `SEQ` bigint(20) NOT NULL,
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NAME` varchar(50) DEFAULT NULL,
  `TITLE` varchar(200) DEFAULT NULL,
  `CONTENT` varchar(4000) DEFAULT NULL,
  `CHOICE_POINT` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_board_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_board_file` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `FILE_NO` varchar(20) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `FILE_PATH` varchar(100) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `PARENT_BOARD_SEQ` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_board_mng`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_board_mng` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_MNG_NAME` varchar(200) DEFAULT NULL,
  `BOARD_MNG_TYPE` varchar(20) DEFAULT NULL,
  `ATTACH_FILE_YN` varchar(1) DEFAULT NULL,
  `OPEN_YN` varchar(1) DEFAULT NULL,
  `REPLY_YN` varchar(1) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_board_voting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_board_voting` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `IS_TYPE` varchar(1) DEFAULT NULL,
  `VOTING` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_book` (
  `BOOK_CD` varchar(100) NOT NULL COMMENT '교재코드(L + 현재날짜 + 시퀀스5자리, 시퀀스가 20일경우 앞의 3자리는 0으로 채운다)',
  `SUBJECT_CD` varchar(1000) DEFAULT NULL COMMENT '과목(과목코드#강사아이디로 입력)(과목을 두개 이상 추가할 경우,로 구분) 1005#wgt202,1003#wgt53',
  `CATEGORY_CD` varchar(20) DEFAULT NULL COMMENT '직종코드',
  `FORM_CODE` varchar(20) DEFAULT NULL COMMENT '학습형태 코드',
  `BOOK_NM` varchar(400) DEFAULT NULL COMMENT '도서명',
  `BOOK_INFO` varchar(2000) DEFAULT NULL COMMENT '도서상세설명',
  `BOOK_MEMO` varchar(2000) DEFAULT NULL COMMENT '메모',
  `BOOK_KEYWORD` varchar(2000) DEFAULT NULL COMMENT '키워드',
  `ISSUE_DATE` varchar(8) DEFAULT NULL COMMENT '이벤트 기간',
  `COVER_TYPE` varchar(1) DEFAULT NULL COMMENT '상품상태(A 주문가능, S 품절, O 절판, N 신규)',
  `BOOK_CONTENTS` varchar(2000) DEFAULT NULL COMMENT '목차',
  `PRICE` int(11) DEFAULT NULL COMMENT '도서가격',
  `DISCOUNT` int(11) DEFAULT NULL COMMENT '할인율',
  `DISCOUNT_PRICE` int(11) DEFAULT NULL COMMENT '할인가',
  `POINT` int(11) DEFAULT NULL COMMENT '포인트',
  `BOOK_PUBLISHERS` varchar(100) DEFAULT NULL COMMENT '출판사',
  `BOOK_AUTHOR` varchar(50) DEFAULT NULL COMMENT '저자',
  `BOOK_SUPPLEMENTDATA` varchar(1) DEFAULT NULL COMMENT '보충자료',
  `BOOK_PRINTINGDATE` varchar(1) DEFAULT NULL COMMENT '프린트자료',
  `BOOK_MAIN` varchar(1) DEFAULT NULL COMMENT '주교재',
  `BOOK_SUB` varchar(1) DEFAULT NULL COMMENT '부교재',
  `BOOK_STUDENTBOOK` varchar(1) DEFAULT NULL COMMENT '수강생교재',
  `ATTACH_FILE` varchar(100) DEFAULT NULL COMMENT '첨부파일',
  `ATTACH_IMG_L` varchar(100) DEFAULT NULL COMMENT '도서이미지(L)',
  `ATTACH_IMG_M` varchar(100) DEFAULT NULL COMMENT '도서이미지(M)',
  `ATTACH_IMG_S` varchar(100) DEFAULT NULL COMMENT '도서이미지(S)',
  `ATTACH_DETAIL_INFO` varchar(100) DEFAULT NULL COMMENT '도서이미지(D)',
  `BOOK_STOCK` int(11) DEFAULT NULL COMMENT '도서재고',
  `FREE_POST` varchar(1) DEFAULT NULL COMMENT '무료배송(Y N)',
  `BOOK_DATE` varchar(8) DEFAULT NULL COMMENT '도서 발행일',
  `NEW_BOOK` varchar(1) DEFAULT NULL COMMENT '신간반영(반영, 미반영)',
  `MAIN_VIEW` varchar(1) DEFAULT NULL COMMENT '메인반영(반영, 미반영)',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '상태(활성, 비활성)',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자 아이디',
  `BOOK_PAGE` int(11) DEFAULT NULL COMMENT '페이지수',
  `BOOK_FORMAT` varchar(50) DEFAULT NULL COMMENT '교재판형(크기)',
  PRIMARY KEY (`BOOK_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_book_plus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_book_plus` (
  `IDX` int(11) DEFAULT NULL COMMENT '순번',
  `LEC_CD` varchar(30) DEFAULT NULL COMMENT '강의코드',
  `BOOK_CD` varchar(20) DEFAULT NULL COMMENT '교재 과목코드',
  `BOOK_FLAG` varchar(1) DEFAULT NULL COMMENT '구분(주교재 J, 부교재 B, 수강생교재 S)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_box`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_box` (
  `BOX_CD` varchar(10) DEFAULT NULL COMMENT '사물함코드',
  `BOX_NM` varchar(200) DEFAULT NULL COMMENT '사물함이름',
  `BOX_COUNT` int(11) DEFAULT NULL COMMENT '사물함갯수',
  `DEPOSIT` int(11) DEFAULT 0 COMMENT '예치금',
  `ROW_COUNT` int(11) DEFAULT NULL COMMENT '층수',
  `ROW_NUM` int(11) DEFAULT NULL COMMENT '가로갯수',
  `UPD_DT` datetime DEFAULT current_timestamp() COMMENT '등록/수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '등록/수정자',
  `START_NUM` int(11) DEFAULT NULL COMMENT '사물함 시작번호',
  `END_NUM` int(11) DEFAULT NULL COMMENT '사물함 종료번호',
  `BOX_PRICE` int(11) DEFAULT NULL COMMENT '사물함사용료'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_box_num`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_box_num` (
  `BOX_CD` varchar(10) NOT NULL COMMENT '사물함코드',
  `BOX_NUM` int(11) NOT NULL COMMENT '사물함번호',
  `USER_ID` varchar(30) DEFAULT NULL COMMENT '사용자ID',
  `BOX_FLAG` varchar(1) DEFAULT 'N' COMMENT '사물함상태',
  `UPD_DT` datetime DEFAULT current_timestamp() COMMENT '등록/수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '등록/수정자',
  `RENT_SEQ` int(11) DEFAULT NULL COMMENT '사물함대여번호',
  `RENT_MEMO` varchar(500) DEFAULT NULL COMMENT '사물함대여시메모',
  PRIMARY KEY (`BOX_CD`,`BOX_NUM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_box_rent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_box_rent` (
  `BOX_CD` varchar(10) NOT NULL COMMENT '사물함코드',
  `BOX_NUM` int(11) NOT NULL COMMENT '사물함번호',
  `RENT_SEQ` int(11) NOT NULL COMMENT '사물함신청번호',
  `USER_ID` varchar(30) DEFAULT NULL COMMENT '사용자ID',
  `RENT_START` datetime DEFAULT NULL COMMENT '대여시작일',
  `RENT_END` datetime DEFAULT NULL COMMENT '대여종료일',
  `DEPOSIT` int(11) DEFAULT NULL COMMENT '예치금',
  `DEPOSIT_YN` varchar(20) DEFAULT NULL COMMENT '예치금반환여부(Y:반환,N:미반환)',
  `EXTEND_YN` varchar(20) DEFAULT NULL COMMENT '연장여부(Y:Yes, N:No)',
  `KEY_YN` varchar(20) DEFAULT NULL COMMENT '키반납여부(R:대여,Y:반납,N:미반납)',
  `UPD_DT` datetime DEFAULT NULL COMMENT '등록/수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '등록/수정자',
  `RENT_TYPE` varchar(10) DEFAULT NULL COMMENT '신청구분(ON:온라인,OFF:오프라인)',
  `ORDER_NO` varchar(20) DEFAULT NULL COMMENT '주문번호(ACM_OFF_ORDER)',
  `RENT_MEMO` varchar(500) DEFAULT NULL COMMENT '대여시 메모',
  PRIMARY KEY (`BOX_CD`,`BOX_NUM`,`RENT_SEQ`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_category_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_category_info` (
  `CATEGORY_CD` varchar(20) NOT NULL COMMENT '직종관리 코드',
  `CATEGORY_NM` varchar(50) DEFAULT NULL COMMENT '직종관리 명',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '상태(Y:활성, N:비활성)',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자 아이디',
  `USE_ON` varchar(1) DEFAULT NULL COMMENT '온라인직렬사용여부(Y: 사용, N: 미사용)',
  `USE_OFF` varchar(1) DEFAULT NULL COMMENT '오프라인직렬사용여부(Y: 사용, N: 미사용)',
  `P_CODE` varchar(20) DEFAULT NULL COMMENT '상위코드',
  `ORDR` int(11) DEFAULT NULL COMMENT '정렬순서',
  PRIMARY KEY (`CATEGORY_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_answer` (
  `ANS_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EXAM_ID` int(11) NOT NULL COMMENT '모의고사코드',
  `IDENTY_ID` varchar(20) NOT NULL COMMENT '응시번호',
  `USER_ID` varchar(20) NOT NULL COMMENT '응시번호',
  `QUE_ID` int(11) NOT NULL COMMENT '문제번호',
  `ANSWER` varchar(200) DEFAULT NULL COMMENT '답변번호',
  `REG_ID` varchar(30) NOT NULL COMMENT '등록자',
  `REG_DT` datetime NOT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `CORRECT_YN` varchar(2) DEFAULT NULL COMMENT '정답여부(정답=Y,오답=N)',
  PRIMARY KEY (`ANS_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_bank`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_bank` (
  `BANK_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '문제은행번호',
  `EXAM_YEAR` int(11) DEFAULT NULL COMMENT '년도',
  `EXAM_ROUND` int(11) DEFAULT NULL COMMENT '회차',
  `SBJ_CD` int(11) DEFAULT NULL COMMENT '과목코드',
  `QUE_ID` int(11) DEFAULT NULL COMMENT '문제번호',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '삭제여부, Y:사용, N:미사용',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`BANK_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=293 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='문제은행';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_bank_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_bank_item` (
  `QUE_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '문제일련번호',
  `QUE_TITLE` varchar(200) DEFAULT NULL COMMENT '문제제목',
  `QUE_DESC` varchar(1000) DEFAULT NULL COMMENT '문제지문',
  `QUE_RANGE` int(11) DEFAULT NULL COMMENT '출제영역',
  `QUE_LEVEL` int(11) DEFAULT NULL COMMENT '난이도',
  `QUE_COUNT` int(11) DEFAULT NULL COMMENT '지문수',
  `QUE_TYPE` varchar(20) DEFAULT NULL COMMENT '문제유형(S:단일선택형, M:다지선택형, T:단답형, D:서술형)',
  `PASS_ANS` varchar(200) DEFAULT NULL COMMENT '정답(번호)',
  `ANS_DESC` varchar(1000) DEFAULT NULL COMMENT '답안해설',
  `QUE_FILE_ID` int(11) DEFAULT NULL COMMENT '문제 파일ID',
  `ANS_FILE_ID` int(11) DEFAULT NULL COMMENT '답안 파일ID',
  `ANS_VIEW1` varchar(200) DEFAULT NULL COMMENT '지문1',
  `ANS_VIEW2` varchar(200) DEFAULT NULL COMMENT '지문2',
  `ANS_VIEW3` varchar(200) DEFAULT NULL COMMENT '지문3',
  `ANS_VIEW4` varchar(200) DEFAULT NULL COMMENT '지문4',
  `ANS_VIEW5` varchar(200) DEFAULT NULL COMMENT '지문5',
  `IS_USE` char(1) DEFAULT NULL COMMENT '사용여부',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`QUE_ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=441 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='문제은행문항';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_mst` (
  `EXAM_ID` int(11) NOT NULL AUTO_INCREMENT,
  `EXAM_NM` varchar(100) NOT NULL,
  `EXAM_YEAR` int(11) DEFAULT NULL COMMENT '응시년도',
  `EXAM_ROUND` int(11) DEFAULT NULL COMMENT '응시회차',
  `EXAM_OPEN` varchar(20) DEFAULT NULL COMMENT '응시시작일시',
  `EXAM_END` varchar(20) DEFAULT NULL COMMENT '응시종료일시',
  `EXAM_PERIOD` int(11) DEFAULT NULL COMMENT '시험기간',
  `EXAM_TIME` int(11) DEFAULT NULL COMMENT '시험시간',
  `IS_USE` char(1) NOT NULL,
  `USE_FLAG` char(1) NOT NULL COMMENT '개설상태(F:비활성, T:활성, E:마감, U:상시)',
  `SET_ID` int(11) DEFAULT NULL COMMENT '시험세트번호',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자',
  PRIMARY KEY (`EXAM_ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시험기본정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_ord`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_ord` (
  `ORD_NO` int(11) NOT NULL AUTO_INCREMENT COMMENT '주문번호',
  `REQ_ID` varchar(20) DEFAULT NULL COMMENT '응시번호',
  `EXAM_ID` int(11) DEFAULT NULL COMMENT '시험코드',
  `USER_ID` varchar(30) DEFAULT NULL COMMENT '응시자ID',
  `USER_NM` varchar(50) DEFAULT NULL COMMENT '응시자명',
  `ORD_NOTE` varchar(500) DEFAULT NULL COMMENT '비고',
  `EXAM_FLAG` varchar(1) DEFAULT NULL COMMENT '응시상태(N:응시전,I:응시중,T:임시저장,E:제출완료)',
  `EXAM_STARTTIME` datetime DEFAULT NULL COMMENT '응시시작일시',
  `EXAM_ENDTIME` datetime DEFAULT NULL COMMENT '응시종료일시',
  `EXAM_SPARETIME` int(11) DEFAULT NULL COMMENT '남은응시시간(초)',
  `EXAM_IP` varchar(20) DEFAULT NULL COMMENT '응시자IP',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`ORD_NO`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_req`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_req` (
  `ORDER_NO` int(11) NOT NULL AUTO_INCREMENT COMMENT '주문번호',
  `IDENTY_ID` varchar(20) DEFAULT NULL COMMENT '응시번호',
  `EXAM_ID` int(11) DEFAULT NULL COMMENT '모의고사코드',
  `USER_ID` varchar(30) DEFAULT NULL COMMENT '사용자ID',
  `USER_NM` varchar(50) DEFAULT NULL COMMENT '사용자명',
  `REQ_TYPE` varchar(1) DEFAULT NULL COMMENT '신청접수구분, O:온라인접수, F:방문접수, D:데스크접수',
  `EXAM_TYPE` varchar(1) NOT NULL COMMENT '응시형태, O:온라인,F:오프라인',
  `REQ_DESC` varchar(500) DEFAULT NULL COMMENT '비고',
  `PAY_AMOUNT` int(11) DEFAULT NULL COMMENT '결제대상금액',
  `DISCOUNT_RATIO` int(11) DEFAULT NULL COMMENT '추가할인비율',
  `DISCOUNT_AMOUNT` int(11) DEFAULT NULL COMMENT '추가할인정액',
  `DISCOUNT_REASON` varchar(100) DEFAULT NULL COMMENT '할인사유',
  `EXAM_STATUS` varchar(1) DEFAULT NULL COMMENT '응시상태(R:응시전,P:응시중,S:임시저장,F:제출완료)',
  `EXAM_START` datetime DEFAULT NULL COMMENT '응시시작일시',
  `EXAM_END` datetime DEFAULT NULL COMMENT '응시종료일시',
  `EXAM_REST` int(11) DEFAULT NULL COMMENT '남은응시시간(초)',
  `EXAM_INFO` varchar(100) DEFAULT NULL COMMENT '응시자IP',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`ORDER_NO`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시험응시정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_set` (
  `SET_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '세트아이디 SQ_SURVEY',
  `SET_TITLE` varchar(200) DEFAULT NULL COMMENT '시험세트명',
  `SET_DESC` varchar(500) DEFAULT NULL COMMENT '시험세트설명',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '사용여부',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '변경일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '변경자',
  PRIMARY KEY (`SET_ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_set_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_set_item` (
  `SET_ID` int(11) NOT NULL COMMENT '세트아이디',
  `QUE_ID` int(11) NOT NULL COMMENT '문제번호',
  `QUE_SEQ` int(11) DEFAULT NULL COMMENT '시험문항순서',
  KEY `SETID_QUEID` (`SET_ID`,`QUE_ID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_exam_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_exam_subject` (
  `EXAM_CD` int(11) NOT NULL,
  `SBJ_CD` int(11) NOT NULL,
  `IS_USE` char(1) DEFAULT NULL,
  PRIMARY KEY (`EXAM_CD`,`SBJ_CD`),
  UNIQUE KEY `ACM_EXAM_SUBJECT_PK` (`EXAM_CD`,`SBJ_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시험과목정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_learning_form_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_learning_form_info` (
  `FORM_CODE` varchar(20) NOT NULL COMMENT '학습형태코드',
  `FORM_NAME` varchar(50) NOT NULL COMMENT '학습형태명',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '상태(Y:활성 N:비활성)',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  PRIMARY KEY (`FORM_CODE`,`FORM_NAME`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_lecture_choice_jong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_lecture_choice_jong` (
  `SEQ` int(11) DEFAULT NULL COMMENT 'TB_LEC_MST 테이블의 SEQ 값 (선택종합반 SEQ 값과 매칭)',
  `LECCODE` varchar(30) DEFAULT NULL COMMENT '선택종합반 과목 코드값',
  `NO` int(11) DEFAULT NULL COMMENT '부과목 선택할수 있는 갯수',
  `CATEGORY_CD` varchar(100) DEFAULT NULL COMMENT '카테고리 코드'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_lecture_jong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_lecture_jong` (
  `SEQ` int(11) DEFAULT NULL COMMENT '순번',
  `LECCODE` varchar(30) DEFAULT NULL COMMENT '종합반 강의코드',
  `MST_LECCODE` varchar(30) DEFAULT NULL COMMENT '단과반 강의코드',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자 아이디',
  `SORT` int(11) DEFAULT NULL COMMENT '단과반 강의코드 순서',
  `GUBUN` varchar(1) DEFAULT NULL COMMENT '필수, 선택 구분(필수 1, 선택 2)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_lecture_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_lecture_mst` (
  `LEC_CD` varchar(30) NOT NULL COMMENT '강의코드 (D-단과, J-종합반, N-선택형종합반,P-패키지)',
  `CATEGORY_CD` varchar(20) DEFAULT NULL COMMENT '직종코드',
  `FORM_CODE` varchar(20) DEFAULT NULL COMMENT '학습형태코드 단과반 (이론단과[M0101],문풀단과[M0102],유료특강[M0103],무료특강[M0104])',
  `SUBJECT_CD` varchar(20) DEFAULT NULL COMMENT '과목코드',
  `LEC_TEACHER` varchar(30) DEFAULT NULL COMMENT '담당교수아이디',
  `LEC_TEACHER_PAYMENT` varchar(50) DEFAULT NULL COMMENT '담당교수 강사료 지급률',
  `LEC_TITLE` varchar(200) DEFAULT NULL COMMENT '단과명',
  `LEC_DESC` varchar(2000) DEFAULT NULL COMMENT '단과 상세설명',
  `LEC_KEYWORD` varchar(600) DEFAULT NULL COMMENT '키워드',
  `LEC_SCHEDULE` varchar(50) DEFAULT NULL COMMENT '강의예정회차',
  `LEC_COUNT` varchar(50) DEFAULT NULL COMMENT '강의수',
  `LEC_PERIOD` int(11) DEFAULT NULL COMMENT '기간 - 일수',
  `LEC_PRICE` int(11) DEFAULT NULL COMMENT '원가',
  `LEC_DISCOUNT` int(11) DEFAULT NULL COMMENT '할인율',
  `LEC_POINT` int(11) DEFAULT NULL COMMENT '포인트',
  `LEC_MOVIE` int(11) DEFAULT NULL COMMENT '동영상 수강료',
  `LEC_VOD_DEFAULT_PATH` varchar(800) DEFAULT NULL COMMENT '동영상 기본경로(500K)',
  `LEC_PASS` varchar(50) DEFAULT NULL COMMENT '보강 비밀번호',
  `LEC_TYPE_CHOICE` varchar(1) DEFAULT NULL COMMENT '강의종류 (D-단과, J-종합반, N-선택형종합반,P-패키지)',
  `LEC_FLAG` varchar(1) DEFAULT 'C' COMMENT '강의등록상태 (C:업데이트 예정, I: 업데이트 중, E:업데이트 완료)',
  `ORG_LEC_CD` varchar(30) DEFAULT NULL COMMENT '복사원본 강의코드',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '개설여부(활성 Y, 비활성 N)',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자 아이디',
  PRIMARY KEY (`LEC_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_member` (
  `USER_ID` varchar(30) NOT NULL COMMENT '회원 ID',
  `USER_NM` varchar(50) DEFAULT NULL COMMENT '성명',
  `user_pwd` varchar(100) DEFAULT NULL COMMENT 'BCrypt hash (Sprint 1-2 이후)',
  `SEX` varchar(1) DEFAULT NULL COMMENT '성별',
  `USER_ROLE` varchar(20) DEFAULT NULL COMMENT '사용자 권한(사용자, 관리자, 강사)',
  `ADMIN_ROLE` varchar(20) DEFAULT NULL COMMENT '관리자 권한(관리자에 사용)',
  `BIRTH_DAY` varchar(8) DEFAULT NULL COMMENT '생일(생년월일)',
  `EMAIL` varchar(100) DEFAULT NULL COMMENT '이메일',
  `ZIP_CODE` varchar(10) DEFAULT NULL COMMENT '우편번호',
  `ADDRESS1` varchar(200) DEFAULT NULL COMMENT '자택주소',
  `ADDRESS2` varchar(200) DEFAULT NULL COMMENT '자택주소 상세',
  `USER_POINT` varchar(50) DEFAULT NULL COMMENT '포인트',
  `MEMO` varchar(2000) DEFAULT NULL COMMENT '메모(관리자에 사용)',
  `PIC` varchar(100) DEFAULT NULL COMMENT '사진(소)(강사에 사용)',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '상태',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자 아이디',
  `ISOK_SMS` varchar(1) DEFAULT NULL COMMENT '문자수신여부',
  `ISOK_EMAIL` varchar(1) DEFAULT NULL COMMENT '이메일수신여부',
  `TOKEN` varchar(256) DEFAULT NULL COMMENT '로그인 token',
  PRIMARY KEY (`USER_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_member_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_member_category` (
  `USER_ID` varchar(30) NOT NULL COMMENT '강사 아이디',
  `CATEGORY_CD` varchar(20) NOT NULL COMMENT '직종 코드',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자 아이디',
  PRIMARY KEY (`USER_ID`,`CATEGORY_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_member_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_member_subject` (
  `USER_ID` varchar(30) NOT NULL COMMENT '강사 아이디',
  `SUBJECT_CD` varchar(50) NOT NULL COMMENT '과목 코드',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자 아이디',
  PRIMARY KEY (`USER_ID`,`SUBJECT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_menu_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_menu_mst` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `MENU_ID` varchar(20) DEFAULT NULL,
  `MENU_NM` varchar(50) DEFAULT NULL,
  `MENU_SEQ` varchar(100) DEFAULT NULL,
  `MENU_URL` varchar(150) DEFAULT NULL,
  `P_MENUID` varchar(20) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `TARGET` varchar(20) DEFAULT NULL,
  `MENU_INFO` varchar(255) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_menu_mst2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_menu_mst2` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `MENU_ID` varchar(20) DEFAULT NULL,
  `MENU_NM` varchar(50) DEFAULT NULL,
  `MENU_SEQ` varchar(100) DEFAULT NULL,
  `MENU_URL` varchar(250) DEFAULT NULL,
  `P_MENUID` varchar(20) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `TARGET` varchar(20) DEFAULT NULL,
  `MENU_INFO` varchar(255) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `CODE` varchar(3) DEFAULT NULL,
  `TOP_IMG_URL` varchar(200) DEFAULT NULL,
  `LEFT_IMG_URL` varchar(200) DEFAULT NULL,
  `TITL_IMG_URL` varchar(200) DEFAULT NULL,
  `SUBTITL_IMG_URL` varchar(200) DEFAULT NULL,
  `PBLC_YN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_movie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_movie` (
  `MOVIE_NO` int(11) DEFAULT NULL COMMENT '순번',
  `LEC_CD` varchar(30) DEFAULT NULL COMMENT '강의코드',
  `MOVIE_NAME` varchar(300) DEFAULT NULL COMMENT '동영상 명',
  `MOVIE_DESC` varchar(300) DEFAULT NULL COMMENT '동영상 설명',
  `MOVIE_URL` varchar(800) DEFAULT NULL COMMENT '동영상 파일 URL',
  `MOVIE_FILENAME1` varchar(500) DEFAULT NULL COMMENT '동영상 파일명',
  `MP4_URL` varchar(800) DEFAULT NULL COMMENT 'MP4 파일 URL',
  `MOVIE_FILENAME2` varchar(500) DEFAULT NULL COMMENT 'MP4 파일명',
  `MOVIE_FILENAME3` varchar(500) DEFAULT NULL COMMENT 'MP4 고화질',
  `MOVIE_DATA_FILE_YN` varchar(1) DEFAULT NULL COMMENT '자료 체크',
  `MOVIE_DATA_FILENAME` varchar(500) DEFAULT NULL COMMENT '자료가 있는 경우 파일정보',
  `MOVIE_TIME` int(11) DEFAULT NULL COMMENT '동영상 재생시간(HH24MISS)',
  `MOVIE_ORDER1` int(11) DEFAULT NULL COMMENT '회차 회',
  `MOVIE_ORDER2` int(11) DEFAULT NULL COMMENT '회차 강',
  `MOVIE_FREE_FLAG` varchar(1) DEFAULT NULL COMMENT '무료여부',
  `PMP_URL` varchar(800) DEFAULT NULL COMMENT 'PMP 파일 URL',
  `PMP_FILENAME` varchar(500) DEFAULT NULL COMMENT 'PMP 파일명',
  `STOP` varchar(1) DEFAULT NULL COMMENT '활성,비활성 구분',
  `WIDE_URL` varchar(800) DEFAULT NULL COMMENT '와이드 화면 URL',
  `MOVIE_FILENAME4` varchar(500) DEFAULT NULL COMMENT '와이드 화면 파일명'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_mylecture`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_mylecture` (
  `USER_ID` varchar(30) NOT NULL COMMENT '사용자 ID',
  `ORDERNO` varchar(20) NOT NULL COMMENT '상품주문번호',
  `PACKAGE_NO` varchar(30) NOT NULL COMMENT '강의코드',
  `LEC_CD` varchar(30) NOT NULL COMMENT '단과 강의코드',
  `START_DT` datetime DEFAULT NULL COMMENT '수강시작예정일시',
  `END_DT` datetime DEFAULT NULL COMMENT '수강종료예정일시',
  `PERIOD` int(11) DEFAULT NULL COMMENT '수강기간(일)',
  `STUDY_PERCENT` int(11) DEFAULT NULL COMMENT '수강진도율',
  `STOP_LECTURE` varchar(1) DEFAULT NULL COMMENT '강좌중지여부',
  `FREE_ID` varchar(30) DEFAULT NULL COMMENT '등록자',
  `PLUS_BUY` int(11) DEFAULT NULL COMMENT '연장횟수',
  `PLAYYN` varchar(1) DEFAULT 'Y' COMMENT '강좌중지:N',
  `REG_DT` datetime DEFAULT current_timestamp() COMMENT '등록일시',
  `ADD_LENGTH` int(11) DEFAULT NULL COMMENT '강의수강신청일 변경횟수(최대3회)',
  `FIRSTSTART_DATE` datetime DEFAULT NULL COMMENT '강의 최초 시작일 값(강의시작일 수정시 값이 들어 가고 수정을 한번도 안했을경우 null 값이 들간다)',
  `PARENT_ORDERNO` varchar(20) DEFAULT NULL COMMENT '재수강 원 주문번호',
  `GIFT_YN` varchar(1) DEFAULT NULL COMMENT '사은품강좌여부 (강의별 수강신청 필드로 같이 사용 : 강의별 제공시에는 A로 입력)',
  `JONG_REAL_PRICE` int(11) DEFAULT NULL COMMENT '종합반에 소속된 각각의 단과 가격',
  `UPD_DT` datetime DEFAULT NULL COMMENT '최종수강일시',
  `LEC_STATUS` varchar(1) DEFAULT NULL COMMENT '강의관리(null:진행중, D:삭제, E:종료)',
  PRIMARY KEY (`USER_ID`,`ORDERNO`,`PACKAGE_NO`,`LEC_CD`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_mymovie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_mymovie` (
  `USER_ID` varchar(30) NOT NULL COMMENT '사용자아이디',
  `ORDERNO` varchar(20) NOT NULL COMMENT '주문번호',
  `PACKAGE_NO` varchar(30) NOT NULL COMMENT '패키지코드',
  `LEC_CD` varchar(30) NOT NULL COMMENT '강의코드',
  `MOVIE_NO` int(11) NOT NULL COMMENT '동영상번호',
  `CURR_TIME` int(11) DEFAULT NULL COMMENT '최근수강시간',
  `TOTAL_TIME` int(11) DEFAULT NULL COMMENT '총수강시간(배수시간 비적용/원수강시간)',
  `STUDY_PERCENT` int(11) DEFAULT NULL COMMENT '수강율',
  `STUDY_TIME` int(11) DEFAULT NULL COMMENT '수강시간',
  `TOTAL_BAESU` int(11) DEFAULT NULL COMMENT '총배수시간(강의에 설정된 배수값*수강시간)',
  `BAESU_TIME` int(11) DEFAULT NULL COMMENT '배수수강시간(현재는 비교사용 안함.)',
  `LAST_POSITION_TIME` int(11) DEFAULT NULL COMMENT '마지막수강시간',
  `UPD_DT` datetime DEFAULT NULL COMMENT '최근수강종료일시',
  `STUDY_DT` datetime DEFAULT NULL COMMENT '최근수강시작일시',
  `GIFT_IS_FIRST` varchar(1) DEFAULT NULL COMMENT '사은품강좌를 처음 수강하였는지 여부',
  PRIMARY KEY (`USER_ID`,`ORDERNO`,`PACKAGE_NO`,`LEC_CD`,`MOVIE_NO`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_notification` (
  `BOARD_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '게시물번호',
  `BOARD_TITLE` varchar(200) DEFAULT NULL COMMENT '제목',
  `BOARD_MEMO` varchar(2000) DEFAULT NULL COMMENT '메모',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '상태(활성, 비활성)',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자 아이디',
  PRIMARY KEY (`BOARD_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_order_item` (
  `ORDER_NO` varchar(20) NOT NULL COMMENT '상품 주문번호',
  `ITEM_NO` varchar(20) NOT NULL COMMENT '개별상품번호',
  `STATUS_CD` varchar(6) NOT NULL COMMENT '주문처리상태 100 = 입금확인중, 105 = 입금완료, 110 = 배송준비중, 120 = 배송중, 130 = 배송완료, 140 = 취소요청, 150 = 취소완료, 160 = 교환요청, 170 = 교환배송중, 180 = 교환완료, 220 = 환불요청, 230 = 환불완료, 240 = 단과수강취소, 000 = 환불완료',
  `ORDER_CNT` int(11) DEFAULT NULL COMMENT '상품수량',
  `PRICE` decimal(10,0) DEFAULT NULL COMMENT '실제 상품가격',
  `IS_CANCEL` varchar(1) DEFAULT NULL COMMENT '취소여부',
  `CANCEL_DT` datetime DEFAULT NULL COMMENT '취소일시',
  `CONFIRM_DT` datetime DEFAULT NULL COMMENT '확인일시',
  `REPAYMENT_DT` datetime DEFAULT NULL COMMENT '재결제일시',
  `REPAYMENT_PRICE` decimal(10,0) DEFAULT NULL COMMENT '재결제금액',
  `MEMO` varchar(4000) DEFAULT NULL COMMENT '비고',
  `CONFIRM_ID` varchar(20) DEFAULT NULL COMMENT '확인자 아이디',
  `USER_PACKAGE_FLAG` varchar(1) DEFAULT NULL COMMENT '회원 패키지 플래그',
  `ORDER_URL` varchar(30) DEFAULT NULL COMMENT '주문URL(등록자IP)',
  `DISCOUNTPER` int(11) DEFAULT NULL COMMENT '장바구니할인 퍼센터',
  `PRD_TYPE` varchar(2) DEFAULT NULL COMMENT '상품구분(D:단과,J:종합,L;도서,T:독서실,B:사물함)',
  `USER_CANCEL` varchar(1) DEFAULT NULL COMMENT '사용자 취소여부',
  `GIFT_YN` varchar(1) DEFAULT NULL COMMENT '사은품 여부',
  `COUPON_NO` varchar(20) DEFAULT NULL COMMENT '사용쿠폰코드',
  `C_IDX` int(11) DEFAULT NULL COMMENT '쿠폰발행일련번호',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자',
  PRIMARY KEY (`ORDER_NO`,`ITEM_NO`,`STATUS_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_order_pay`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_order_pay` (
  `ORDER_NO` varchar(20) NOT NULL COMMENT '상품주문번호',
  `PRICE` decimal(10,0) NOT NULL DEFAULT 0 COMMENT '주문결제금액',
  `ADD_PRICE` decimal(10,0) DEFAULT NULL COMMENT '추가비용(교재구매시 배송료)',
  `PAY_CD` varchar(6) DEFAULT NULL COMMENT '결제방법코드 - PAY110:카드결제, PAY120:가상계좌,PAT130:계좌이체,PAY140:현금,PAY100:무통장입금',
  `PAY_NM` varchar(50) DEFAULT NULL COMMENT '결제자 이름',
  `USE_POINT` decimal(10,0) DEFAULT NULL COMMENT '사용 포인트',
  `RETURN_VALUE` varchar(2000) DEFAULT NULL COMMENT '응답내용',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일',
  `BANNER_NAME` varchar(40) DEFAULT NULL COMMENT '배너 이름 (사용안함)',
  `REFUND_PAY` decimal(10,0) DEFAULT NULL COMMENT '환불비',
  `REFUND_DT` datetime DEFAULT NULL COMMENT '환불 등록일',
  `ORDER_URL` varchar(10) DEFAULT NULL COMMENT '주문자URL',
  `VCD_BANK` varchar(2) DEFAULT NULL COMMENT '결제기관코드',
  `VACCT` varchar(30) DEFAULT NULL COMMENT '가상계좌번호',
  `VACCT_NAME` varchar(30) DEFAULT NULL COMMENT '결제기관 이름',
  `REFUND_POINT` decimal(10,0) DEFAULT NULL COMMENT '환불가능포인트',
  `INPUT_DT` varchar(10) DEFAULT NULL COMMENT '입금예정일',
  `PG_PRICE` decimal(10,0) DEFAULT NULL COMMENT '실제PG사 결제금액',
  `PRICE_CARD` decimal(10,0) DEFAULT NULL COMMENT '카드금액',
  `PRICE_CASH` decimal(10,0) DEFAULT NULL COMMENT '현금금액',
  `PRICE_BANK` decimal(10,0) DEFAULT NULL COMMENT '예금',
  `PRICE_DISCOUNT` decimal(10,0) DEFAULT NULL COMMENT '할인 비율 또는 금액',
  `PRICE_DISCOUNT_REASON` varchar(500) DEFAULT NULL COMMENT '할인내역(이유)',
  `CARD_NAME` varchar(40) DEFAULT NULL COMMENT '카드이름(종류)',
  `TID` varchar(50) DEFAULT NULL COMMENT '온라인결제시PG사ID',
  `MEMO` varchar(2000) DEFAULT NULL COMMENT '메모',
  PRIMARY KEY (`ORDER_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_order_refund`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_order_refund` (
  `IDX` int(11) NOT NULL AUTO_INCREMENT,
  `ORDER_NO` varchar(20) DEFAULT NULL COMMENT '주문번호',
  `REFUND_PAY` decimal(10,0) DEFAULT NULL COMMENT '환불총금액',
  `REFUND_DT` datetime DEFAULT NULL COMMENT '환불일시',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `ACC_BANK_NAME` varchar(30) DEFAULT NULL COMMENT '환불은행 이름',
  `ACC_BANK_NUM` varchar(30) DEFAULT NULL COMMENT '환불은행 계좌번호',
  `REFUND_CARD` decimal(10,0) DEFAULT 0 COMMENT '환불카드금액',
  `REFUND_CASH` decimal(10,0) DEFAULT 0 COMMENT '환불현금총액',
  `REFUND_MEMO` varchar(300) DEFAULT NULL COMMENT '환불메모',
  PRIMARY KEY (`IDX`)
) ENGINE=InnoDB AUTO_INCREMENT=2343 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_order_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_order_seq` (
  `ORDER_TYPE` varchar(1) NOT NULL COMMENT 'O:온라인 / F:학원 / E:모의고사 / B:사물함 / R:자습실',
  `ORDER_YEAR` varchar(4) NOT NULL DEFAULT '' COMMENT '년도',
  `MAX_ID` int(11) NOT NULL COMMENT '최종발급번호'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='주문번호 생성 정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_order_yearpackage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_order_yearpackage` (
  `ORDERNO` varchar(20) DEFAULT NULL COMMENT '주문번호',
  `PACKAGE_NO` varchar(30) DEFAULT NULL COMMENT '프리패스코드',
  `SUBJECT_TEACHER` varchar(50) DEFAULT NULL COMMENT '강사 ID',
  `LEARNING_CD` varchar(20) DEFAULT NULL COMMENT '학습형태 코드(이론, 문제풀이 등)',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `START_DT` datetime DEFAULT NULL COMMENT '프리패스 시작일',
  `END_DT` datetime DEFAULT NULL COMMENT '프리패스 종료일'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_orders` (
  `ORDER_NO` varchar(20) NOT NULL COMMENT '주문번호',
  `USER_ID` varchar(30) DEFAULT NULL COMMENT '회원 ID',
  `USER_NM` varchar(50) DEFAULT NULL COMMENT '성명',
  `ZIP_CODE` varchar(7) DEFAULT NULL COMMENT '우편번호',
  `ADDRESS1` varchar(200) DEFAULT NULL COMMENT '자택주소',
  `ADDRESS2` varchar(200) DEFAULT NULL COMMENT '자택주소 상세',
  `EMAIL` varchar(100) DEFAULT NULL COMMENT '이메일',
  `IP_DT` datetime DEFAULT NULL COMMENT '결제금액 실제 입금일',
  `FREE_MOVIE` varchar(10) DEFAULT NULL,
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자 아이디',
  `ORDER_TYPE` varchar(5) DEFAULT NULL COMMENT '수강신청방법 구분(ON:온라인,OFF:학원방문신청, DESK: 데스크 접수)',
  `TICKET_PRINT_DT` datetime DEFAULT NULL COMMENT '수강증 출력일시',
  PRIMARY KEY (`ORDER_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_room` (
  `ROOM_CD` int(11) NOT NULL AUTO_INCREMENT COMMENT '독서실코드',
  `ROOM_NM` varchar(200) NOT NULL COMMENT '독서실이름',
  `ROOM_COUNT` int(11) NOT NULL COMMENT '독서실개수',
  `START_NUM` int(11) DEFAULT NULL COMMENT '독서실시작번호',
  `END_NUM` int(11) DEFAULT NULL COMMENT '독서실종료번호',
  `ROOM_PRICE` int(11) DEFAULT NULL COMMENT '대여비용',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '사용여부',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자',
  PRIMARY KEY (`ROOM_CD`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='독서실';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_room_num`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_room_num` (
  `ROOM_CD` int(11) NOT NULL COMMENT '독서실코드',
  `ROOM_NUM` int(11) NOT NULL COMMENT '독서실자리번호',
  `USER_ID` varchar(30) DEFAULT NULL COMMENT '사용자ID',
  `ROOM_FLAG` varchar(1) DEFAULT NULL COMMENT '독서실상태Y:사용,N:미사용,D:대기,H:홀드,X:고장)',
  `RENT_SEQ` int(11) DEFAULT NULL COMMENT '독서실현재신청번호',
  `ROOM_MEMO` varchar(500) DEFAULT NULL COMMENT '독서실자리 메모',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자',
  PRIMARY KEY (`ROOM_CD`,`ROOM_NUM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='독서실현황';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_room_rent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_room_rent` (
  `ROOM_CD` int(11) NOT NULL COMMENT '독서실코드',
  `ROOM_NUM` int(11) NOT NULL COMMENT '독서실자리번호',
  `RENT_SEQ` int(11) NOT NULL COMMENT '대여순서',
  `USER_ID` varchar(30) NOT NULL COMMENT '대여자ID',
  `RENT_START` datetime DEFAULT NULL COMMENT '사용시작일',
  `RENT_END` datetime DEFAULT NULL COMMENT '사용종료일',
  `EXTEND_YN` varchar(20) DEFAULT NULL COMMENT '연장여부',
  `RENT_TYPE` varchar(10) DEFAULT NULL COMMENT '대여방법',
  `ORD_ID` varchar(20) DEFAULT NULL COMMENT '결재코드',
  `RENT_MEMO` varchar(500) DEFAULT NULL COMMENT '대여메모',
  `PAY_TYPE` varchar(20) DEFAULT NULL COMMENT '결재구분',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자ID',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자ID',
  PRIMARY KEY (`ROOM_CD`,`ROOM_NUM`,`RENT_SEQ`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='독서실대여현황';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_site` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `SITE_ID` varchar(20) DEFAULT NULL,
  `SITE_NM` varchar(50) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_site_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_site_menu` (
  `SITE_ID` varchar(20) DEFAULT NULL,
  `MENU_ID` varchar(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_subject_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_subject_info` (
  `SUBJECT_CD` varchar(20) NOT NULL COMMENT '과목코드',
  `SUBJECT_NM` varchar(200) NOT NULL COMMENT '과목명',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '상태(Y:활성N:비활성)',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자 아이디',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자 아이디',
  `USE_ON` varchar(1) DEFAULT NULL COMMENT '온라인사용',
  `USE_OFF` varchar(1) DEFAULT NULL COMMENT '학원사용',
  PRIMARY KEY (`SUBJECT_CD`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_survey_bnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_survey_bnk` (
  `QUE_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '설문번호',
  `QUE_TITLE` varchar(200) DEFAULT NULL COMMENT '설문제목',
  `QUE_OWNER` varchar(20) DEFAULT NULL COMMENT '설문분류',
  `QUE_COUNT` int(11) DEFAULT NULL COMMENT '설문문항수',
  `QUE_TYPE` varchar(1) DEFAULT NULL COMMENT '설문타입- S:선택형, M:선다형, T:복수답변형, D:답변형',
  `QUE_VIW1` varchar(100) DEFAULT NULL COMMENT '문항1',
  `QUE_VIW2` varchar(100) DEFAULT NULL COMMENT '문항2',
  `QUE_VIW3` varchar(100) DEFAULT NULL COMMENT '문항3',
  `QUE_VIW4` varchar(100) DEFAULT NULL COMMENT '문항4',
  `QUE_VIW5` varchar(100) DEFAULT NULL COMMENT '문항5',
  `QUE_VIW6` varchar(100) DEFAULT NULL COMMENT '문항6',
  `QUE_VIW7` varchar(100) DEFAULT NULL COMMENT '문항7',
  `QUE_VIW8` varchar(100) DEFAULT NULL COMMENT '문항8',
  `QUE_VIW9` varchar(100) DEFAULT NULL COMMENT '문항9',
  `QUE_VIW10` varchar(100) DEFAULT NULL COMMENT '문항10',
  `QUE_DESC` varchar(1000) DEFAULT NULL COMMENT '설문문항설명',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '사용여부',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '수정자',
  PRIMARY KEY (`QUE_ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_survey_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_survey_mst` (
  `SURVEY_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '설문번호',
  `SURVEY_TITLE` varchar(200) DEFAULT NULL COMMENT '설문제목',
  `SURVEY_DESC` varchar(500) DEFAULT NULL COMMENT '설문설명',
  `SURVEY_SDAT` varchar(10) DEFAULT NULL COMMENT '시작일자',
  `SURVEY_EDAT` varchar(10) DEFAULT NULL COMMENT '종료일자',
  `SET_ID` int(11) DEFAULT NULL COMMENT '세트명',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '사용여부',
  `SURVEY_TARGET` varchar(20) DEFAULT NULL COMMENT '대상',
  PRIMARY KEY (`SURVEY_ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_survey_rst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_survey_rst` (
  `SURVEY_ID` int(11) NOT NULL COMMENT '설문ID',
  `USER_ID` varchar(50) NOT NULL COMMENT '사용자아이디',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  KEY `SURVEYID_USER_ID` (`SURVEY_ID`,`USER_ID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_survey_rst_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_survey_rst_item` (
  `SURVEY_ID` int(11) DEFAULT NULL COMMENT '설문ID',
  `USER_ID` varchar(50) DEFAULT NULL COMMENT '사용자아이디',
  `QUE_SEQ` int(11) DEFAULT NULL COMMENT '설문문항번호',
  `QUE_ID` int(11) DEFAULT NULL COMMENT '설문번호',
  `USER_ANSW` varchar(200) DEFAULT NULL COMMENT '사용자답변',
  KEY `SURVEYID_USER_ID_QSEQ_QUEID` (`SURVEY_ID`,`USER_ID`,`QUE_SEQ`,`QUE_ID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_survey_set`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_survey_set` (
  `SET_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '세트아이디 SQ_SURVEY',
  `SET_TITLE` varchar(200) DEFAULT NULL COMMENT '설문세트명',
  `SET_DESC` varchar(500) DEFAULT NULL COMMENT '설문세트설명',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '사용여부',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(20) DEFAULT NULL COMMENT '등록자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '변경일시',
  `UPD_ID` varchar(20) DEFAULT NULL COMMENT '변경자',
  PRIMARY KEY (`SET_ID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_survey_set_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_survey_set_item` (
  `SET_ID` int(11) NOT NULL COMMENT '세트아이디',
  `QUE_ID` int(11) NOT NULL COMMENT '설문번호',
  `QUE_SEQ` int(11) DEFAULT NULL COMMENT '설문문항순서',
  KEY `SETID_QUEID` (`SET_ID`,`QUE_ID`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_texamineeanswer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_texamineeanswer` (
  `ID` int(11) NOT NULL COMMENT 'ID',
  `IDENTYID` varchar(20) NOT NULL COMMENT '응시번호',
  `ITEMID` int(11) NOT NULL COMMENT '문제은행구분번호',
  `QUESTIONNUMBER` int(11) NOT NULL COMMENT '문제번호',
  `MOCKCODE` varchar(20) NOT NULL COMMENT '모의고사코드',
  `ANSWERNUMBER` varchar(200) DEFAULT NULL COMMENT '답변번호',
  `REG_ID` varchar(30) NOT NULL COMMENT '등록자',
  `REG_DT` datetime NOT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `CORRECTYN` varchar(2) DEFAULT NULL COMMENT '정답여부(정답=Y,오답=N)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='응시자답안정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_tmock_rst_sbj`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_tmock_rst_sbj` (
  `MOCKCODE` varchar(20) DEFAULT NULL COMMENT '모의고사코드',
  `IDENTYID` varchar(20) DEFAULT NULL COMMENT '수험번호',
  `CLASSCODE` varchar(20) DEFAULT NULL COMMENT '직급코드',
  `CLASSSERIESCODE` varchar(20) DEFAULT NULL COMMENT '직렬코드',
  `SUBJECT_CD` varchar(20) DEFAULT NULL COMMENT '선택과목코드',
  `ORG_POINT` float DEFAULT NULL COMMENT '과목원점수',
  `ADJ_POINT` float DEFAULT NULL COMMENT '과목별 조정점수'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='사용자과목점수정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_tmock_sbj_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_tmock_sbj_mst` (
  `MOCKCODE` varchar(20) DEFAULT NULL COMMENT '모의고사코드',
  `CLASSSERIESCODE` varchar(20) DEFAULT NULL COMMENT '직렬구분',
  `SUBJECT_CD` varchar(20) DEFAULT NULL COMMENT '과목코드',
  `REQ_USR_NUM` int(11) DEFAULT NULL COMMENT '시험선택인원',
  `SUM_POINT` int(11) DEFAULT NULL COMMENT '과목총점',
  `AVR_POINT` int(11) DEFAULT NULL COMMENT '과목평균점',
  `SDV` int(11) DEFAULT NULL COMMENT '과목표준편차',
  `AVR_3_POINT` int(11) DEFAULT NULL COMMENT '전체3%평균',
  `AVR_10_POINT` int(11) DEFAULT NULL COMMENT '전체10%평균'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시험과목정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_tmockgrade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_tmockgrade` (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `IDENTYID` varchar(20) NOT NULL COMMENT '응시번호',
  `MOCKCODE` varchar(20) NOT NULL COMMENT '모의고사코드',
  `SUBJECT_CD` varchar(20) NOT NULL COMMENT '과목코드',
  `CLASSCODE` varchar(20) DEFAULT NULL COMMENT '직급코드',
  `CLASSSERIESCODE` varchar(20) DEFAULT NULL COMMENT '직렬코드',
  `ORIGINGRADE` int(11) DEFAULT 0 COMMENT '원점수',
  `ADJUSTGRADE` int(11) DEFAULT 0 COMMENT '조정점수',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `ITEMID` int(11) DEFAULT NULL COMMENT '과목ID',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시험결과정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_tmockregistration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_tmockregistration` (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `MOCKCODE` varchar(20) NOT NULL COMMENT '모의고사코드',
  `MOCKNAME` varchar(100) NOT NULL COMMENT '모의고사명',
  `EXAMYEAR` int(11) NOT NULL COMMENT '시험년도',
  `EXAMROUND` int(11) NOT NULL COMMENT '시험회차',
  `OFFCLOSEPERSONNUMBER` int(11) DEFAULT NULL COMMENT 'OFF응시마감인원',
  `CLASSCODE` varchar(20) DEFAULT NULL COMMENT '직급코드',
  `EXAMSTARTTIME` varchar(20) DEFAULT NULL COMMENT '시험시작일시',
  `EXAMENDTIME` varchar(20) DEFAULT NULL COMMENT '시험종료일시',
  `EXAMPERIOD` int(11) DEFAULT NULL COMMENT '시험기간',
  `EXAMTIME` int(11) DEFAULT NULL COMMENT '시험시간',
  `RECEIPTSTARTTIME` varchar(20) DEFAULT NULL COMMENT '접수시작일시',
  `RECEIPTENDTIME` varchar(20) DEFAULT NULL COMMENT '접수종료일시',
  `EXAMCOST` int(11) DEFAULT NULL COMMENT '응시료',
  `DISCOUNTRATIO` int(11) DEFAULT NULL COMMENT '할인율',
  `SALEAMOUNTS` int(11) DEFAULT NULL COMMENT '판매가',
  `USEFLAG` varchar(1) DEFAULT NULL COMMENT '개설여부, 0:비활성, 1:활성, 2:마감, 3:상시',
  `REG_ID` varchar(30) NOT NULL COMMENT '등록자',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `ISEXAMTYPEON` int(11) DEFAULT NULL COMMENT '온라인응시가능여부',
  `ISEXAMTYPEOFF` int(11) DEFAULT NULL COMMENT '오프라인응시가능여부',
  `EXAMPERIODTYPE` int(11) DEFAULT NULL COMMENT '시험일자선택구분',
  `LECCODE` varchar(20) DEFAULT NULL COMMENT '형성평가강의코드',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시험상세정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_tmocksubject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_tmocksubject` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `MOCKCODE` varchar(20) NOT NULL,
  `SUBJECT_CD` varchar(20) NOT NULL,
  `ITEMID` int(11) DEFAULT NULL,
  `SUBJECTORDER` int(11) DEFAULT NULL,
  `SUBJECTTYPEDIVISION` int(11) DEFAULT NULL,
  `SUBJECTPERIOD` int(11) DEFAULT NULL,
  `USEFLAG` int(11) DEFAULT NULL,
  `REG_ID` varchar(30) NOT NULL,
  `REG_DT` datetime DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시험과목정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_tsubjectarea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_tsubjectarea` (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '시퀀스ID',
  `SUBJECT_CD` varchar(20) NOT NULL COMMENT '과목코드',
  `SUBJECTAREA` varchar(80) NOT NULL COMMENT '과목영역',
  `AREAORDER` int(11) NOT NULL COMMENT '영역순번',
  `USEFLAG` int(11) NOT NULL COMMENT '활성여부,0:활성,1:비활성',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=243 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시험과목영역정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_tuserchoicesubject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_tuserchoicesubject` (
  `ID` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `ITEMID` int(11) NOT NULL COMMENT '선택과목문제은행ID',
  `ORDERNO` varchar(20) NOT NULL COMMENT '주문번호',
  `IDENTYID` varchar(20) NOT NULL COMMENT '응시번호',
  `REG_ID` varchar(30) NOT NULL COMMENT '등록자',
  `REG_DT` datetime NOT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `EXAMSTATUS` int(11) DEFAULT NULL COMMENT '과목응시상태(0:응시전,1:응시중,2:임시저장,3:응시완료)',
  `SUBJECTORDER` int(11) DEFAULT NULL COMMENT '과목 순번',
  `SUBJECTTYPEDIVISION` int(11) DEFAULT NULL COMMENT '필수/선택구분',
  `EXAMSSTARTTIME` datetime DEFAULT NULL COMMENT '과목응시시작일',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='응시자과목선택지원정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `acm_twronganswernote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `acm_twronganswernote` (
  `ID` int(11) NOT NULL COMMENT 'ID',
  `IDENTYID` varchar(20) NOT NULL COMMENT '응시번호',
  `ITEMID` int(11) NOT NULL COMMENT '문제은행구분번호',
  `QUESTIONint` int(11) NOT NULL COMMENT '문제번호',
  `NOTE` varchar(500) DEFAULT NULL COMMENT '내용',
  `REG_ID` varchar(30) NOT NULL COMMENT '등록자',
  `REG_DT` datetime NOT NULL COMMENT '등록일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `MOCKCODE` varchar(20) NOT NULL COMMENT '모의고사코드'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='오답노트정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `author_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `author_info` (
  `AUTHOR_CODE` varchar(30) NOT NULL DEFAULT '' COMMENT '권한코드',
  `AUTHOR_NM` varchar(60) NOT NULL COMMENT '권한명',
  `AUTHOR_DC` varchar(200) DEFAULT NULL COMMENT '권한설명',
  `AUTHOR_CREAT_DE` char(20) NOT NULL COMMENT '권한생성일',
  PRIMARY KEY (`AUTHOR_CODE`),
  UNIQUE KEY `AUTHOR_INFO_PK` (`AUTHOR_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='권한정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `author_role_relate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `author_role_relate` (
  `AUTHOR_CODE` varchar(30) NOT NULL COMMENT '권한코드',
  `ROLE_CODE` varchar(50) NOT NULL COMMENT '롤코드',
  `CREAT_DT` datetime DEFAULT NULL COMMENT '생성일시',
  PRIMARY KEY (`AUTHOR_CODE`,`ROLE_CODE`),
  UNIQUE KEY `AUTHOR_ROLE_RELATE_PK` (`AUTHOR_CODE`,`ROLE_CODE`),
  KEY `AUTHOR_ROLE_RELATE_i01` (`AUTHOR_CODE`),
  KEY `AUTHOR_ROLE_RELATE_i02` (`ROLE_CODE`),
  CONSTRAINT `AUTHOR_ROLE_RELATE_FK1` FOREIGN KEY (`AUTHOR_CODE`) REFERENCES `author_info` (`AUTHOR_CODE`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `AUTHOR_ROLE_RELATE_FK2` FOREIGN KEY (`ROLE_CODE`) REFERENCES `role_info` (`ROLE_CODE`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='권한롤관계';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ba_config_cd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ba_config_cd` (
  `CODE_NO` int(11) DEFAULT NULL COMMENT '설정코드값',
  `SYS_CD` varchar(20) DEFAULT NULL COMMENT '공통코드',
  `CODE_VAL` varchar(20) DEFAULT NULL COMMENT '설정값',
  `CODE_NM` varchar(100) DEFAULT NULL COMMENT '설정코드명',
  `CODE_SEQ` int(11) DEFAULT NULL COMMENT '코드순서',
  `IS_USE` varchar(1) DEFAULT NULL COMMENT '상태(Y:활성 , N:비활성)',
  `REG_DT` datetime DEFAULT NULL COMMENT '등록일시',
  `REG_ID` varchar(30) DEFAULT NULL COMMENT '등록자',
  `UPD_DT` datetime DEFAULT NULL COMMENT '수정일시',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정자',
  `CODE_INFO` varchar(1000) DEFAULT NULL COMMENT '코드설명',
  `SYS_NM` varchar(100) DEFAULT NULL COMMENT '공통코드명',
  `CODE_CD` varchar(20) DEFAULT NULL,
  `CODE_ID` varchar(20) DEFAULT NULL,
  `P_CODEID` varchar(20) DEFAULT NULL,
  `NO` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `backup_opert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `backup_opert` (
  `BACKUP_OPERT_ID` varchar(20) NOT NULL COMMENT '백업작업ID',
  `BACKUP_OPERT_NM` varchar(60) DEFAULT NULL COMMENT '백업작업명',
  `BACKUP_ORGINL_DRCTRY` varchar(255) DEFAULT NULL COMMENT '백업원본디렉토리',
  `BACKUP_STRE_DRCTRY` varchar(255) DEFAULT NULL COMMENT '백업저장디렉토리',
  `CMPRS_SE` varchar(2) DEFAULT NULL COMMENT '압축구분',
  `EXECUT_CYCLE` varchar(2) DEFAULT NULL COMMENT '실행주기',
  `EXECUT_SCHDUL_DE` char(20) DEFAULT NULL COMMENT '실행일정일',
  `EXECUT_SCHDUL_HOUR` char(2) DEFAULT NULL COMMENT '실행일정시',
  `EXECUT_SCHDUL_MNT` char(2) DEFAULT NULL COMMENT '실행일정분',
  `EXECUT_SCHDUL_SECND` char(2) DEFAULT NULL COMMENT '실행일정초',
  `USE_AT` char(1) DEFAULT NULL COMMENT '사용여부',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  `LAST_UPDT_PNTTM` datetime NOT NULL COMMENT '최종수정시점',
  PRIMARY KEY (`BACKUP_OPERT_ID`),
  UNIQUE KEY `BACKUP_OPERT_PK` (`BACKUP_OPERT_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='백업작업';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `batch_opert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `batch_opert` (
  `BATCH_OPERT_ID` varchar(20) NOT NULL COMMENT '배치작업ID',
  `BATCH_OPERT_NM` varchar(60) DEFAULT NULL COMMENT '배치작업명',
  `BATCH_PROGRM` varchar(255) DEFAULT NULL COMMENT '배치프로그램',
  `PARAMTR` varchar(250) DEFAULT NULL COMMENT '파라미터',
  `USE_AT` char(1) DEFAULT NULL COMMENT '사용여부',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  `LAST_UPDT_PNTTM` datetime NOT NULL COMMENT '최종수정시점',
  PRIMARY KEY (`BATCH_OPERT_ID`),
  UNIQUE KEY `BATCH_OPERT_PK` (`BATCH_OPERT_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='배치작업';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `batch_schdul`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `batch_schdul` (
  `BATCH_SCHDUL_ID` varchar(20) NOT NULL COMMENT '배치일정ID',
  `BATCH_OPERT_ID` varchar(20) NOT NULL COMMENT '배치작업ID',
  `EXECUT_CYCLE` varchar(2) DEFAULT NULL COMMENT '실행주기',
  `EXECUT_SCHDUL_DE` char(20) DEFAULT NULL COMMENT '실행일정일',
  `EXECUT_SCHDUL_HOUR` char(2) DEFAULT NULL COMMENT '실행일정시',
  `EXECUT_SCHDUL_MNT` char(2) DEFAULT NULL COMMENT '실행일정분',
  `EXECUT_SCHDUL_SECND` char(2) DEFAULT NULL COMMENT '실행일정초',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  `LAST_UPDT_PNTTM` datetime NOT NULL COMMENT '최종수정시점',
  PRIMARY KEY (`BATCH_SCHDUL_ID`),
  UNIQUE KEY `BATCH_SCHDUL_PK` (`BATCH_SCHDUL_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='배치스케줄';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `batch_schdul_dfk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `batch_schdul_dfk` (
  `BATCH_SCHDUL_ID` varchar(20) NOT NULL COMMENT '배치일정ID',
  `EXECUT_SCHDUL_DFK_SE` char(1) NOT NULL COMMENT '실행일정요일구분',
  PRIMARY KEY (`BATCH_SCHDUL_ID`,`EXECUT_SCHDUL_DFK_SE`),
  UNIQUE KEY `BATCH_SCHDUL_DFK_PK` (`BATCH_SCHDUL_ID`,`EXECUT_SCHDUL_DFK_SE`),
  CONSTRAINT `BATCH_SCHDUL_DFK_FK1` FOREIGN KEY (`BATCH_SCHDUL_ID`) REFERENCES `batch_schdul` (`BATCH_SCHDUL_ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='배치스케줄요일';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `bk_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bk_book` (
  `book_id` char(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `author` varchar(128) DEFAULT NULL,
  `price` decimal(12,0) NOT NULL DEFAULT 0,
  `stock` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='교재 카탈로그';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `bk_delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bk_delivery` (
  `delivery_id` char(36) NOT NULL,
  `order_id` char(36) NOT NULL,
  `address_id` char(36) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'READY',
  `tracking_no` varchar(64) DEFAULT NULL,
  `carrier` varchar(32) DEFAULT NULL,
  `shipped_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`delivery_id`),
  KEY `idx_bk_delivery_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='배송 상태';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `bk_delivery_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bk_delivery_address` (
  `address_id` char(36) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `recipient` varchar(64) NOT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `zip_code` varchar(16) DEFAULT NULL,
  `address1` varchar(255) NOT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`address_id`),
  KEY `idx_bk_addr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='배송지';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cmmn_cl_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cmmn_cl_code` (
  `CL_CODE` char(3) NOT NULL COMMENT '분류코드',
  `CL_CODE_NM` varchar(60) DEFAULT NULL COMMENT '분류코드명',
  `CL_CODE_DC` varchar(200) DEFAULT NULL COMMENT '분류코드설명',
  `USE_AT` char(1) DEFAULT NULL COMMENT '사용여부',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  PRIMARY KEY (`CL_CODE`),
  UNIQUE KEY `CMMN_CL_CODE_PK` (`CL_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='공통분류코드';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cmmn_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cmmn_code` (
  `CODE_ID` varchar(6) NOT NULL COMMENT '코드ID',
  `CODE_ID_NM` varchar(60) DEFAULT NULL COMMENT '코드ID명',
  `CODE_ID_DC` varchar(200) DEFAULT NULL COMMENT '코드ID설명',
  `USE_AT` char(1) DEFAULT NULL COMMENT '사용여부',
  `CL_CODE` char(3) DEFAULT NULL COMMENT '분류코드',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  PRIMARY KEY (`CODE_ID`),
  UNIQUE KEY `CMMN_CODE_PK` (`CODE_ID`),
  KEY `CMMN_CODE_i01` (`CL_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='공통코드';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cmmn_detail_code`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cmmn_detail_code` (
  `CODE_ID` varchar(6) NOT NULL COMMENT '코드ID',
  `CODE` varchar(15) NOT NULL COMMENT '코드',
  `CODE_NM` varchar(60) DEFAULT NULL COMMENT '코드명',
  `CODE_DC` varchar(200) DEFAULT NULL COMMENT '코드설명',
  `USE_AT` char(1) DEFAULT NULL COMMENT '사용여부',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  PRIMARY KEY (`CODE_ID`,`CODE`),
  UNIQUE KEY `CCMMN_DETAIL_CODE_PK` (`CODE_ID`,`CODE`),
  KEY `CCMMN_DETAIL_CODE_i01` (`CODE_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='공통상세코드';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnbbs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnbbs` (
  `NTT_ID` decimal(20,0) NOT NULL COMMENT '게시물ID',
  `BBS_ID` char(20) NOT NULL COMMENT '게시판ID',
  `NTT_NO` decimal(20,0) DEFAULT NULL COMMENT '게시물번호',
  `NTT_SJ` varchar(2000) DEFAULT NULL COMMENT '게시물제목',
  `NTT_CN` mediumtext DEFAULT NULL COMMENT '게시물내용',
  `ANSWER_AT` char(1) DEFAULT NULL COMMENT '댓글여부',
  `PARNTSCTT_NO` decimal(10,0) DEFAULT NULL COMMENT '부모글번호',
  `ANSWER_LC` decimal(8,0) DEFAULT NULL COMMENT '댓글위치',
  `SORT_ORDR` decimal(8,0) DEFAULT NULL COMMENT '정렬순서',
  `RDCNT` decimal(10,0) DEFAULT NULL COMMENT '조회수',
  `USE_AT` char(1) NOT NULL COMMENT '사용여부',
  `NTCE_BGNDE` char(20) DEFAULT NULL COMMENT '게시시작일',
  `NTCE_ENDDE` char(20) DEFAULT NULL COMMENT '게시종료일',
  `NTCR_ID` varchar(20) DEFAULT NULL COMMENT '게시자ID',
  `NTCR_NM` varchar(20) DEFAULT NULL COMMENT '게시자명',
  `PASSWORD` varchar(200) DEFAULT NULL COMMENT '비밀번호',
  `ATCH_FILE_ID` char(20) DEFAULT NULL COMMENT '첨부파일ID',
  `NOTICE_AT` char(1) DEFAULT NULL COMMENT '공지사항여부',
  `SJ_BOLD_AT` char(1) DEFAULT NULL COMMENT '제목볼드여부',
  `SECRET_AT` char(1) DEFAULT NULL COMMENT '비밀글여부',
  `FRST_REGIST_PNTTM` datetime NOT NULL COMMENT '최초등록시점',
  `FRST_REGISTER_ID` varchar(20) NOT NULL COMMENT '최초등록자ID',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  `BLOG_ID` char(20) DEFAULT NULL COMMENT '블로그 ID',
  PRIMARY KEY (`NTT_ID`,`BBS_ID`),
  UNIQUE KEY `COMTNBBS_PK` (`NTT_ID`,`BBS_ID`),
  KEY `COMTNBBS_i01` (`BBS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='게시판';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnbbsmaster`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnbbsmaster` (
  `BBS_ID` char(20) NOT NULL COMMENT '게시판ID',
  `BBS_NM` varchar(255) NOT NULL COMMENT '게시판명',
  `BBS_INTRCN` varchar(2400) DEFAULT NULL COMMENT '게시판소개',
  `BBS_TY_CODE` char(6) NOT NULL COMMENT '게시판유형코드',
  `REPLY_POSBL_AT` char(1) DEFAULT NULL COMMENT '답장가능여부',
  `FILE_ATCH_POSBL_AT` char(1) NOT NULL COMMENT '파일첨부가능여부',
  `ATCH_POSBL_FILE_NUMBER` decimal(2,0) NOT NULL COMMENT '첨부가능파일숫자',
  `ATCH_POSBL_FILE_SIZE` decimal(8,0) DEFAULT NULL COMMENT '첨부가능파일사이즈',
  `USE_AT` char(1) NOT NULL COMMENT '사용여부',
  `TMPLAT_ID` char(20) DEFAULT NULL COMMENT '템플릿ID',
  `CMMNTY_ID` char(20) DEFAULT NULL COMMENT '커뮤니티ID',
  `FRST_REGISTER_ID` varchar(20) NOT NULL COMMENT '최초등록자ID',
  `FRST_REGIST_PNTTM` datetime NOT NULL COMMENT '최초등록시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  `BLOG_ID` char(20) DEFAULT NULL COMMENT '블로그 ID',
  `BLOG_AT` char(2) DEFAULT NULL COMMENT '블로그 여부',
  PRIMARY KEY (`BBS_ID`),
  UNIQUE KEY `COMTNBBSMASTER_PK` (`BBS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='게시판마스터';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnbbsmasteroptn`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnbbsmasteroptn` (
  `BBS_ID` char(20) NOT NULL COMMENT '게시판ID',
  `ANSWER_AT` char(1) NOT NULL COMMENT '댓글여부',
  `STSFDG_AT` char(1) NOT NULL COMMENT '만족도여부',
  `FRST_REGIST_PNTTM` datetime NOT NULL COMMENT '최초등록시점',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  `FRST_REGISTER_ID` varchar(20) NOT NULL COMMENT '최초등록자ID',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  PRIMARY KEY (`BBS_ID`),
  UNIQUE KEY `COMTNBBSMASTEROPTN_PK` (`BBS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='게시판마스터옵션';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnbbsuse`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnbbsuse` (
  `BBS_ID` char(20) NOT NULL COMMENT '게시판ID',
  `TRGET_ID` char(20) NOT NULL DEFAULT '' COMMENT '대상ID',
  `USE_AT` char(1) NOT NULL COMMENT '사용여부',
  `REGIST_SE_CODE` char(6) DEFAULT NULL COMMENT '등록구분코드',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `FRST_REGISTER_ID` varchar(20) NOT NULL COMMENT '최초등록자ID',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  PRIMARY KEY (`BBS_ID`,`TRGET_ID`),
  UNIQUE KEY `COMTNBBSUSE_PK` (`BBS_ID`,`TRGET_ID`),
  KEY `COMTNBBSUSE_i01` (`BBS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='게시판활용';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnloginlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnloginlog` (
  `LOG_ID` char(20) NOT NULL COMMENT '로그ID',
  `CONECT_ID` varchar(20) DEFAULT NULL COMMENT '접속ID',
  `CONECT_IP` varchar(23) DEFAULT NULL COMMENT '접속IP',
  `CONECT_MTHD` char(4) DEFAULT NULL COMMENT '접속방식',
  `ERROR_OCCRRNC_AT` char(1) DEFAULT NULL COMMENT '오류발생여부',
  `ERROR_CODE` char(3) DEFAULT NULL COMMENT '오류코드',
  `CREAT_DT` datetime DEFAULT NULL COMMENT '생성일시',
  PRIMARY KEY (`LOG_ID`),
  UNIQUE KEY `COMTNLOGINLOG_PK` (`LOG_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='접속로그';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnloginpolicy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnloginpolicy` (
  `EMPLYR_ID` varchar(20) NOT NULL DEFAULT '' COMMENT '업무사용자ID',
  `IP_INFO` varchar(23) NOT NULL COMMENT 'IP정보',
  `DPLCT_PERM_AT` char(1) NOT NULL COMMENT '중복허용여부',
  `LMTT_AT` char(1) NOT NULL COMMENT '제한여부',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  PRIMARY KEY (`EMPLYR_ID`),
  UNIQUE KEY `COMTNLOGINPOLICY_PK` (`EMPLYR_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='로그인정책';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnmenuinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnmenuinfo` (
  `MENU_NM` varchar(60) NOT NULL COMMENT '메뉴명',
  `PROGRM_FILE_NM` varchar(60) NOT NULL COMMENT '프로그램파일명',
  `MENU_NO` decimal(20,0) NOT NULL COMMENT '메뉴번호',
  `UPPER_MENU_NO` decimal(20,0) DEFAULT NULL COMMENT '상위메뉴번호',
  `MENU_ORDR` decimal(5,0) NOT NULL COMMENT '메뉴순서',
  `MENU_DC` varchar(250) DEFAULT NULL COMMENT '메뉴설명',
  `RELATE_IMAGE_PATH` varchar(100) DEFAULT NULL COMMENT '관계이미지경로',
  `RELATE_IMAGE_NM` varchar(60) DEFAULT NULL COMMENT '관계이미지명',
  `CNTNTSUSEAT` char(1) DEFAULT NULL COMMENT '메뉴사용여부',
  PRIMARY KEY (`MENU_NO`),
  UNIQUE KEY `COMTNMENUINFO_PK` (`MENU_NO`),
  KEY `COMTNMENUINFO_FK2` (`PROGRM_FILE_NM`),
  KEY `COMTNMENUINFO_i02` (`UPPER_MENU_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='메뉴정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnntwrksvcmntrng`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnntwrksvcmntrng` (
  `SYS_IP` varchar(23) NOT NULL COMMENT '시스템IP',
  `SYS_PORT` decimal(5,0) NOT NULL COMMENT '시스템포트',
  `SYS_NM` varchar(255) NOT NULL COMMENT '시스템명',
  `MNGR_NM` varchar(60) DEFAULT NULL COMMENT '관리자명',
  `MNGR_EMAIL_ADRES` varchar(50) DEFAULT NULL COMMENT '관리자이메일주소',
  `MNTRNG_STTUS` char(2) DEFAULT NULL COMMENT '모니터링상태',
  `CREAT_DT` datetime DEFAULT NULL COMMENT '생성일시',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `LAST_UPDUSR_ID` varchar(20) NOT NULL COMMENT '최종수정자ID',
  `LAST_UPDT_PNTTM` datetime NOT NULL COMMENT '최종수정시점',
  PRIMARY KEY (`SYS_IP`,`SYS_PORT`),
  UNIQUE KEY `COMTNNTWRKSVCMNTRNG_PK` (`SYS_IP`,`SYS_PORT`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='네트워크서비스모니터링';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnntwrksvcmntrngloginfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnntwrksvcmntrngloginfo` (
  `SYS_IP` varchar(23) NOT NULL COMMENT '시스템IP',
  `SYS_PORT` decimal(5,0) NOT NULL COMMENT '시스템포트',
  `SYS_NM` varchar(255) NOT NULL COMMENT '시스템명',
  `MNTRNG_STTUS` char(2) DEFAULT NULL COMMENT '모니터링상태',
  `LOG_INFO` varchar(2000) DEFAULT NULL COMMENT '로그정보',
  `CREAT_DT` datetime DEFAULT NULL COMMENT '생성일시',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `LAST_UPDUSR_ID` varchar(20) NOT NULL COMMENT '최종수정자ID',
  `LAST_UPDT_PNTTM` datetime NOT NULL COMMENT '최종수정시점',
  `LOG_ID` char(20) NOT NULL DEFAULT '' COMMENT '로그ID',
  PRIMARY KEY (`SYS_IP`,`SYS_PORT`,`LOG_ID`),
  UNIQUE KEY `COMTNNTWRKSVCMNTRNGLOGINFO_PK` (`SYS_IP`,`SYS_PORT`,`LOG_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='네트워크서비스모니터링로그정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnprivacylog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnprivacylog` (
  `REQUST_ID` varchar(20) NOT NULL COMMENT '요청 ID',
  `INQIRE_DT` datetime NOT NULL COMMENT '조회일시',
  `SRVC_NM` varchar(500) DEFAULT NULL COMMENT '서비스 명',
  `INQIRE_INFO` varchar(100) DEFAULT NULL COMMENT '조회 정보 명',
  `RQESTER_ID` varchar(20) DEFAULT NULL COMMENT '요청자아이디',
  `RQESTER_IP` varchar(23) DEFAULT NULL COMMENT '요청아이피',
  PRIMARY KEY (`REQUST_ID`),
  UNIQUE KEY `COMTNPRIVACYLOG_PK` (`REQUST_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='개인정보조회 로그';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnprogrmlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnprogrmlist` (
  `PROGRM_FILE_NM` varchar(60) NOT NULL DEFAULT '' COMMENT '프로그램파일명',
  `PROGRM_STRE_PATH` varchar(100) NOT NULL COMMENT '프로그램저장경로',
  `PROGRM_KOREAN_NM` varchar(60) DEFAULT NULL COMMENT '프로그램한글명',
  `PROGRM_DC` varchar(200) DEFAULT NULL COMMENT '프로그램설명',
  `URL` varchar(100) NOT NULL COMMENT 'URL',
  PRIMARY KEY (`PROGRM_FILE_NM`),
  UNIQUE KEY `COMTNPROGRMLIST_PK` (`PROGRM_FILE_NM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='프로그램목록';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtntmplatinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtntmplatinfo` (
  `TMPLAT_ID` char(20) NOT NULL DEFAULT '' COMMENT '템플릿ID',
  `TMPLAT_NM` varchar(255) DEFAULT NULL COMMENT '템플릿명',
  `TMPLAT_COURS` varchar(2000) DEFAULT NULL COMMENT '템플릿경로',
  `USE_AT` char(1) DEFAULT NULL COMMENT '사용여부',
  `TMPLAT_SE_CODE` char(6) DEFAULT NULL COMMENT '템플릿구분코드',
  `FRST_REGISTER_ID` varchar(20) DEFAULT NULL COMMENT '최초등록자ID',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `LAST_UPDUSR_ID` varchar(20) DEFAULT NULL COMMENT '최종수정자ID',
  `LAST_UPDT_PNTTM` datetime DEFAULT NULL COMMENT '최종수정시점',
  PRIMARY KEY (`TMPLAT_ID`),
  UNIQUE KEY `COMTNTMPLATINFO_PK` (`TMPLAT_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='템플릿';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtntrsmrcvlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtntrsmrcvlog` (
  `REQUST_ID` varchar(20) NOT NULL COMMENT '요청ID',
  `OCCRRNC_DE` char(20) DEFAULT NULL COMMENT '발생일',
  `TRSMRCV_SE_CODE` char(3) DEFAULT NULL COMMENT '송수신구분코드',
  `CNTC_ID` char(8) DEFAULT NULL COMMENT '연계ID',
  `PROVD_INSTT_ID` char(8) DEFAULT NULL COMMENT '제공기관ID',
  `PROVD_SYS_ID` char(8) DEFAULT NULL COMMENT '제공시스템ID',
  `PROVD_SVC_ID` char(8) DEFAULT NULL COMMENT '제공서비스ID',
  `REQUST_INSTT_ID` char(8) DEFAULT NULL COMMENT '요청기관ID',
  `REQUST_SYS_ID` char(8) DEFAULT NULL COMMENT '요청시스템ID',
  `REQUST_TRNSMIT_TM` varchar(14) DEFAULT NULL COMMENT '요청송신시각',
  `REQUST_RECPTN_TM` varchar(14) DEFAULT NULL COMMENT '요청수신시각',
  `RSPNS_TRNSMIT_TM` varchar(14) DEFAULT NULL COMMENT '응답송신시각',
  `RSPNS_RECPTN_TM` varchar(14) DEFAULT NULL COMMENT '응답수신시각',
  `RESULT_CODE` varchar(4) DEFAULT NULL COMMENT '결과코드',
  `RESULT_MSSAGE` varchar(4000) DEFAULT NULL COMMENT '결과메시지',
  `FRST_REGIST_PNTTM` datetime DEFAULT NULL COMMENT '최초등록시점',
  `RQESTER_ID` varchar(20) DEFAULT NULL COMMENT '요청자ID',
  PRIMARY KEY (`REQUST_ID`),
  UNIQUE KEY `COMTNTRSMRCVLOG_PK` (`REQUST_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='송수신로그';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtnuserlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtnuserlog` (
  `OCCRRNC_DE` char(8) NOT NULL DEFAULT '' COMMENT '발생일',
  `RQESTER_ID` varchar(20) NOT NULL DEFAULT '' COMMENT '요청자ID',
  `SVC_NM` varchar(255) NOT NULL DEFAULT '' COMMENT '서비스명',
  `METHOD_NM` varchar(60) NOT NULL DEFAULT '' COMMENT '메서드명',
  `CREAT_CO` decimal(10,0) DEFAULT NULL COMMENT '생성수',
  `UPDT_CO` decimal(10,0) DEFAULT NULL COMMENT '수정수',
  `RDCNT` decimal(10,0) DEFAULT NULL COMMENT '조회수',
  `DELETE_CO` decimal(10,0) DEFAULT NULL COMMENT '삭제수',
  `OUTPT_CO` decimal(10,0) DEFAULT NULL COMMENT '출력수',
  `ERROR_CO` decimal(10,0) DEFAULT NULL COMMENT '오류수',
  PRIMARY KEY (`OCCRRNC_DE`,`RQESTER_ID`,`SVC_NM`,`METHOD_NM`),
  UNIQUE KEY `COMTNUSERLOG_PK` (`OCCRRNC_DE`,`RQESTER_ID`,`SVC_NM`,`METHOD_NM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='사용자로그';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtsbbssummary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtsbbssummary` (
  `OCCRRNC_DE` char(20) NOT NULL DEFAULT '' COMMENT '발생일',
  `STATS_SE` varchar(10) NOT NULL DEFAULT '' COMMENT '통계구분',
  `DETAIL_STATS_SE` varchar(10) NOT NULL DEFAULT '' COMMENT '세부통계구분',
  `CREAT_CO` decimal(10,0) DEFAULT NULL COMMENT '생성수',
  `TOT_RDCNT` decimal(10,0) DEFAULT NULL COMMENT '총조회수',
  `AVRG_RDCNT` decimal(10,0) DEFAULT NULL COMMENT '평균조회수',
  `TOP_INQIRE_BBSCTT_ID` varchar(20) DEFAULT NULL COMMENT '최고조회게시글ID',
  `MUMM_INQIRE_BBSCTT_ID` varchar(20) DEFAULT NULL COMMENT '최소조회게시글ID',
  `TOP_NTCR_ID` varchar(20) DEFAULT NULL COMMENT '최고게시자ID',
  PRIMARY KEY (`OCCRRNC_DE`,`STATS_SE`,`DETAIL_STATS_SE`),
  UNIQUE KEY `COMTSBBSSUMMARY_PK` (`OCCRRNC_DE`,`STATS_SE`,`DETAIL_STATS_SE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='게시물통계요약';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtssyslogsummary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtssyslogsummary` (
  `OCCRRNC_DE` char(8) NOT NULL COMMENT '발생일',
  `SVC_NM` varchar(255) NOT NULL COMMENT '서비스명',
  `METHOD_NM` varchar(60) NOT NULL COMMENT '메서드명',
  `CREAT_CO` decimal(10,0) DEFAULT NULL COMMENT '생성수',
  `UPDT_CO` decimal(10,0) DEFAULT NULL COMMENT '수정수',
  `RDCNT` decimal(10,0) DEFAULT NULL COMMENT '조회수',
  `DELETE_CO` decimal(10,0) DEFAULT NULL COMMENT '삭제수',
  `OUTPT_CO` decimal(10,0) DEFAULT NULL COMMENT '출력수',
  `ERROR_CO` decimal(10,0) DEFAULT NULL COMMENT '오류수',
  PRIMARY KEY (`OCCRRNC_DE`,`SVC_NM`,`METHOD_NM`),
  UNIQUE KEY `COMTSSYSLOGSUMMARY_PK` (`OCCRRNC_DE`,`SVC_NM`,`METHOD_NM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시스템로그요약';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtstrsmrcvlogsummary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtstrsmrcvlogsummary` (
  `OCCRRNC_DE` char(20) NOT NULL DEFAULT '' COMMENT '발생일',
  `TRSMRCV_SE_CODE` char(3) NOT NULL DEFAULT '' COMMENT '송수신구분코드',
  `PROVD_INSTT_ID` char(8) NOT NULL DEFAULT '' COMMENT '제공기관ID',
  `PROVD_SYS_ID` char(8) NOT NULL DEFAULT '' COMMENT '제공시스템ID',
  `PROVD_SVC_ID` char(8) NOT NULL DEFAULT '' COMMENT '제공서비스ID',
  `REQUST_INSTT_ID` char(8) NOT NULL DEFAULT '' COMMENT '요청기관ID',
  `REQUST_SYS_ID` char(8) NOT NULL DEFAULT '' COMMENT '요청시스템ID',
  `RDCNT` decimal(10,0) DEFAULT NULL COMMENT '조회수',
  `ERROR_CO` decimal(10,0) DEFAULT NULL COMMENT '오류수',
  PRIMARY KEY (`OCCRRNC_DE`,`TRSMRCV_SE_CODE`,`PROVD_INSTT_ID`,`PROVD_SYS_ID`,`PROVD_SVC_ID`,`REQUST_INSTT_ID`,`REQUST_SYS_ID`),
  UNIQUE KEY `COMTSTRSMRCVLOGSUMMARY_PK` (`OCCRRNC_DE`,`TRSMRCV_SE_CODE`,`PROVD_INSTT_ID`,`PROVD_SYS_ID`,`PROVD_SVC_ID`,`REQUST_INSTT_ID`,`REQUST_SYS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='송수신로그요약';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comtsweblogsummary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `comtsweblogsummary` (
  `OCCRRNC_DE` char(8) NOT NULL DEFAULT '' COMMENT '발생일',
  `URL` varchar(200) NOT NULL DEFAULT '' COMMENT 'URL',
  `RDCNT` decimal(10,0) DEFAULT NULL COMMENT '조회수',
  PRIMARY KEY (`OCCRRNC_DE`,`URL`),
  UNIQUE KEY `COMTSWEBLOGSUMMARY_PK` (`OCCRRNC_DE`,`URL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='웹로그 요약';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comvnusermaster`;
/*!50001 DROP VIEW IF EXISTS `comvnusermaster`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `comvnusermaster` AS SELECT
 1 AS `ESNTL_ID`,
  1 AS `USER_ID`,
  1 AS `PASSWORD`,
  1 AS `USER_NM`,
  1 AS `ZIP`,
  1 AS `ADRES`,
  1 AS `MBER_EMAIL_ADRES`,
  1 AS `Name_exp_8`,
  1 AS `USER_SE`,
  1 AS `ORGNZT_ID` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `coop_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coop_coupon` (
  `C_CD` varchar(16) DEFAULT NULL,
  `COOP_CD` varchar(10) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `USER_ID` varchar(20) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `coop_coupon_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coop_coupon_mst` (
  `COOP_CD` varchar(20) DEFAULT NULL,
  `COUPON_NM` varchar(100) DEFAULT NULL,
  `LECCODE` varchar(20) DEFAULT NULL,
  `ST_DT` varchar(10) DEFAULT NULL,
  `ED_DT` varchar(10) DEFAULT NULL,
  `COUPON_CNT` bigint(20) DEFAULT NULL,
  `COUPON_USE` bigint(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `coop_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coop_mst` (
  `COOP_CD` varchar(20) DEFAULT NULL,
  `COOP_NM` varchar(50) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `DISCOUNT_PER` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cop_seq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cop_seq` (
  `TABLE_NAME` varchar(20) NOT NULL DEFAULT '' COMMENT '테이블명',
  `NEXT_ID` decimal(30,0) DEFAULT NULL COMMENT '다음아이디',
  PRIMARY KEY (`TABLE_NAME`),
  UNIQUE KEY `COP_SEQ_PK` (`TABLE_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='COMTECOPSEQ';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `counsel_rst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `counsel_rst` (
  `SCH_DAY` varchar(10) DEFAULT NULL,
  `TS_IDX` bigint(20) DEFAULT NULL,
  `USER_ID` varchar(20) DEFAULT NULL,
  `RESERVE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `USER_BIRTHDAY` varchar(10) DEFAULT NULL,
  `USER_NM` varchar(20) DEFAULT NULL,
  `USER_PHONE` varchar(20) DEFAULT NULL,
  `USER_EMAIL` varchar(100) DEFAULT NULL,
  `USER_CATEGORY` varchar(50) DEFAULT NULL,
  `USER_CODE1` varchar(100) DEFAULT NULL,
  `USER_CODE2` varchar(100) DEFAULT NULL,
  `USER_PERIOD` varchar(1) DEFAULT NULL,
  `USER_SUBJECT` varchar(100) DEFAULT NULL,
  `USER_LEC` varchar(200) DEFAULT NULL,
  `USER_COMMENTS` varchar(2000) DEFAULT NULL,
  `CANCEL_DATE` date DEFAULT NULL,
  `USER_AREA` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `counsel_sch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `counsel_sch` (
  `SCH_DAY` varchar(10) DEFAULT NULL,
  `TS_IDX` bigint(20) DEFAULT NULL,
  `MAX_USR` bigint(20) DEFAULT NULL,
  `REQ_CNT` bigint(20) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REQ_TYPE` varchar(1) DEFAULT NULL,
  `CAT_CD` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `counsel_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `counsel_time` (
  `IDX` bigint(20) DEFAULT NULL,
  `TIME_SET` varchar(100) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `emplyr_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `emplyr_info` (
  `EMPLYR_ID` varchar(20) NOT NULL COMMENT '업무사용자ID',
  `ORGNZT_ID` char(20) DEFAULT NULL COMMENT '조직ID',
  `USER_NM` varchar(60) NOT NULL COMMENT '사용자명',
  `PASSWORD` varchar(200) NOT NULL COMMENT '비밀번호',
  `EMPL_NO` varchar(20) DEFAULT NULL COMMENT '사원번호',
  `IHIDNUM` varchar(200) DEFAULT NULL COMMENT '주민등록번호',
  `SEXDSTN_CODE` char(1) DEFAULT NULL COMMENT '성별코드',
  `BRTHDY` char(20) DEFAULT NULL COMMENT '생일',
  `FXNUM` varchar(20) DEFAULT NULL COMMENT '팩스번호',
  `HOUSE_ADRES` varchar(100) DEFAULT NULL COMMENT '주택주소',
  `PASSWORD_HINT` varchar(100) DEFAULT NULL COMMENT '비밀번호힌트',
  `PASSWORD_CNSR` varchar(100) DEFAULT NULL COMMENT '비밀번호정답',
  `HOUSE_END_TELNO` varchar(4) DEFAULT NULL COMMENT '주택끝전화번호',
  `AREA_NO` varchar(4) DEFAULT NULL COMMENT '지역번호',
  `DETAIL_ADRES` varchar(100) DEFAULT NULL COMMENT '상세주소',
  `ZIP` varchar(6) DEFAULT NULL COMMENT '우편번호',
  `OFFM_TELNO` varchar(20) DEFAULT NULL COMMENT '사무실전화번호',
  `MBTLNUM` varchar(20) DEFAULT NULL COMMENT '이동전화번호',
  `EMAIL_ADRES` varchar(50) DEFAULT NULL COMMENT '이메일주소',
  `OFCPS_NM` varchar(60) DEFAULT NULL COMMENT '직위명',
  `HOUSE_MIDDLE_TELNO` varchar(4) DEFAULT NULL COMMENT '주택중간전화번호',
  `GROUP_ID` char(20) DEFAULT NULL COMMENT '그룹ID',
  `PSTINST_CODE` char(8) DEFAULT NULL COMMENT '소속기관코드',
  `EMPLYR_STTUS_CODE` char(1) DEFAULT NULL COMMENT '사용자상태코드',
  `ESNTL_ID` char(20) DEFAULT NULL COMMENT '고유ID',
  `CRTFC_DN_VALUE` varchar(100) DEFAULT NULL COMMENT '인증DN값',
  `SBSCRB_DE` datetime DEFAULT NULL COMMENT '가입일자',
  `LOCK_AT` char(1) DEFAULT NULL COMMENT '잠금여부',
  `LOCK_CNT` decimal(3,0) DEFAULT NULL COMMENT '잠금회수',
  `LOCK_LAST_PNTTM` datetime DEFAULT NULL COMMENT '잠금최종시점',
  `CHG_PWD_LAST_PNTTM` datetime DEFAULT NULL COMMENT '비밀번호변겨이점',
  PRIMARY KEY (`EMPLYR_ID`),
  UNIQUE KEY `EMPLYR_INFO_PK` (`EMPLYR_ID`),
  KEY `EMPLYR_INFO_i01` (`ORGNZT_ID`),
  KEY `EMPLYR_INFO_i02` (`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='업무사용자정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `emplyrscrtyestbs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `emplyrscrtyestbs` (
  `SCRTY_DTRMN_TRGET_ID` varchar(20) NOT NULL COMMENT '보안설정대상ID',
  `MBER_TY_CODE` char(5) DEFAULT NULL COMMENT '회원유형코드',
  `AUTHOR_CODE` varchar(30) NOT NULL COMMENT '권한코드',
  PRIMARY KEY (`SCRTY_DTRMN_TRGET_ID`),
  UNIQUE KEY `EMPLYRSCRTYESTBS_PK` (`SCRTY_DTRMN_TRGET_ID`),
  KEY `EMPLYRSCRTYESTBS_i04` (`AUTHOR_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='사용자보안설정';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `en_cart_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `en_cart_item` (
  `cart_item_id` char(36) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `mst_code` varchar(32) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `price_snapshot` decimal(12,0) NOT NULL DEFAULT 0,
  `added_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`cart_item_id`),
  UNIQUE KEY `uk_en_cart_user_mst` (`user_id`,`mst_code`),
  KEY `idx_en_cart_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='수강 장바구니';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `en_enrollment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `en_enrollment` (
  `enrollment_id` char(36) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `mst_code` varchar(32) NOT NULL,
  `order_id` char(36) DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'ACTIVE',
  `period_start` date DEFAULT NULL,
  `period_end` date DEFAULT NULL,
  `manual_progress` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `canceled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `uk_en_enroll_user_mst` (`user_id`,`mst_code`),
  KEY `idx_en_enroll_user` (`user_id`),
  KEY `idx_en_enroll_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='수강권';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `entrprs_mber`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `entrprs_mber` (
  `ENTRPRS_MBER_ID` varchar(20) NOT NULL DEFAULT '' COMMENT '기업회원ID',
  `ENTRPRS_SE_CODE` char(8) DEFAULT NULL COMMENT '기업구분코드',
  `BIZRNO` varchar(10) DEFAULT NULL COMMENT '사업자등록번호',
  `JURIRNO` varchar(13) DEFAULT NULL COMMENT '법인등록번호',
  `CMPNY_NM` varchar(60) NOT NULL COMMENT '회사명',
  `CXFC` varchar(50) DEFAULT NULL COMMENT '대표이사',
  `ZIP` varchar(6) NOT NULL COMMENT '우편번호',
  `ADRES` varchar(100) NOT NULL COMMENT '주소',
  `ENTRPRS_MIDDLE_TELNO` varchar(4) NOT NULL COMMENT '기업중간전화번호',
  `FXNUM` varchar(20) DEFAULT NULL COMMENT '팩스번호',
  `INDUTY_CODE` char(1) DEFAULT NULL COMMENT '업종코드',
  `APPLCNT_NM` varchar(50) NOT NULL COMMENT '신청인명',
  `APPLCNT_IHIDNUM` varchar(200) DEFAULT NULL COMMENT '신청인주민등록번호',
  `SBSCRB_DE` datetime DEFAULT NULL COMMENT '가입일자',
  `ENTRPRS_MBER_STTUS` varchar(15) DEFAULT NULL COMMENT '기업회원상태',
  `ENTRPRS_MBER_PASSWORD` varchar(200) DEFAULT NULL COMMENT '기업회원비밀번호',
  `ENTRPRS_MBER_PASSWORD_HINT` varchar(100) NOT NULL COMMENT '기업회원비밀번호힌트',
  `ENTRPRS_MBER_PASSWORD_CNSR` varchar(100) NOT NULL COMMENT '기업회원비밀번호정답',
  `GROUP_ID` char(20) DEFAULT NULL COMMENT '그룹ID',
  `DETAIL_ADRES` varchar(100) DEFAULT NULL COMMENT '상세주소',
  `ENTRPRS_END_TELNO` varchar(4) NOT NULL COMMENT '기업끝전화번호',
  `AREA_NO` varchar(4) NOT NULL COMMENT '지역번호',
  `APPLCNT_EMAIL_ADRES` varchar(50) NOT NULL COMMENT '신청자이메일주소',
  `ESNTL_ID` char(20) NOT NULL COMMENT '고유ID',
  `LOCK_AT` char(1) DEFAULT NULL COMMENT '잠금여부',
  `LOCK_CNT` decimal(3,0) DEFAULT NULL COMMENT '잠금회수',
  `LOCK_LAST_PNTTM` datetime DEFAULT NULL COMMENT '잠금최종시점',
  PRIMARY KEY (`ENTRPRS_MBER_ID`),
  UNIQUE KEY `ENTRPRS_MBER_PK` (`ENTRPRS_MBER_ID`),
  KEY `ENTRPRS_MBER_i01` (`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='기업회원';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ex_mock_attempt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ex_mock_attempt` (
  `attempt_id` char(36) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `exam_id` char(36) NOT NULL,
  `score` int(11) DEFAULT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'REGISTERED',
  `answer_sheet` text DEFAULT NULL,
  `registered_at` datetime NOT NULL DEFAULT current_timestamp(),
  `submitted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`attempt_id`),
  UNIQUE KEY `uk_ex_attempt_user_exam` (`user_id`,`exam_id`),
  KEY `idx_ex_attempt_exam` (`exam_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='모의고사 응시 기록';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ex_mock_exam`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ex_mock_exam` (
  `exam_id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `subject_cd` varchar(32) DEFAULT NULL,
  `schedule_date` date NOT NULL,
  `max_score` int(11) NOT NULL DEFAULT 100,
  `is_open` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`exam_id`),
  KEY `idx_ex_mock_date` (`schedule_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='모의고사 마스터';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `flyway_schema_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `flyway_schema_history` (
  `installed_rank` int(11) NOT NULL,
  `version` varchar(50) DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(20) NOT NULL,
  `script` varchar(1000) NOT NULL,
  `checksum` int(11) DEFAULT NULL,
  `installed_by` varchar(100) NOT NULL,
  `installed_on` timestamp NOT NULL DEFAULT current_timestamp(),
  `execution_time` int(11) NOT NULL,
  `success` tinyint(1) NOT NULL,
  PRIMARY KEY (`installed_rank`),
  KEY `flyway_schema_history_s_idx` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gnrl_mber`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gnrl_mber` (
  `MBER_ID` varchar(20) NOT NULL DEFAULT '' COMMENT '회원ID',
  `PASSWORD` varchar(200) NOT NULL COMMENT '비밀번호',
  `PASSWORD_HINT` varchar(100) DEFAULT NULL COMMENT '비밀번호힌트',
  `PASSWORD_CNSR` varchar(100) DEFAULT NULL COMMENT '비밀번호정답',
  `IHIDNUM` varchar(200) DEFAULT NULL COMMENT '주민등록번호',
  `MBER_NM` varchar(50) DEFAULT NULL COMMENT '회원명',
  `ZIP` varchar(6) DEFAULT NULL COMMENT '우편번호',
  `ADRES` varchar(100) DEFAULT NULL COMMENT '주소',
  `AREA_NO` varchar(4) DEFAULT NULL COMMENT '지역번호',
  `MBER_STTUS` varchar(15) DEFAULT NULL COMMENT '회원상태',
  `DETAIL_ADRES` varchar(100) DEFAULT NULL COMMENT '상세주소',
  `END_TELNO` varchar(4) DEFAULT NULL COMMENT '끝전화번호',
  `MBTLNUM` varchar(20) DEFAULT NULL COMMENT '이동전화번호',
  `GROUP_ID` char(20) DEFAULT NULL COMMENT '그룹ID',
  `MBER_FXNUM` varchar(20) DEFAULT NULL COMMENT '회원팩스번호',
  `MBER_EMAIL_ADRES` varchar(50) DEFAULT NULL COMMENT '회원이메일주소',
  `MIDDLE_TELNO` varchar(4) DEFAULT NULL COMMENT '중간전화번호',
  `SBSCRB_DE` datetime DEFAULT NULL COMMENT '가입일자',
  `SEXDSTN_CODE` char(1) DEFAULT NULL COMMENT '성별코드',
  `ESNTL_ID` char(20) DEFAULT NULL COMMENT '고유ID',
  `LOCK_AT` char(1) DEFAULT NULL COMMENT '잠금여부',
  `LOCK_CNT` decimal(3,0) DEFAULT NULL COMMENT '잠금회수',
  `LOCK_LAST_PNTTM` datetime DEFAULT NULL COMMENT '잠금최종시점',
  PRIMARY KEY (`MBER_ID`),
  UNIQUE KEY `GNRL_MBER_PK` (`MBER_ID`),
  KEY `GNRL_MBER_i01` (`GROUP_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='일반회원';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_area_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_area_mst` (
  `GOSI_TYPE` varchar(2) DEFAULT NULL,
  `GOSI_AREA` varchar(1) DEFAULT NULL,
  `GOSI_AREA_NM` varchar(100) DEFAULT NULL,
  `GOSI_AREA_FULL_NM` varchar(200) DEFAULT NULL,
  `REQ_NUM` varchar(10) DEFAULT NULL,
  `USE_NUM` varchar(20) DEFAULT NULL,
  `GOSI_CMP_STAT` varchar(20) DEFAULT NULL,
  `PASS_2014` varchar(10) DEFAULT NULL,
  `PASS_2015_S` varchar(10) DEFAULT NULL,
  `PASS_2015_E` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_cod`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_cod` (
  `GOSI_TYPE` varchar(2) DEFAULT NULL,
  `GOSI_TYPE_NM` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_mst` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `GOSI_NM` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_pass_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_pass_mst` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `EXAM_TYPE` varchar(1) DEFAULT NULL,
  `ITEM_NO` bigint(20) DEFAULT NULL,
  `PASS_ANS` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_pass_sta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_pass_sta` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `GOSI_TYPE` varchar(10) DEFAULT NULL,
  `PASS_POINT` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_rst_det`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_rst_det` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `RST_NO` varchar(20) DEFAULT NULL,
  `USER_ID` varchar(20) DEFAULT NULL,
  `EXAM_TYPE` varchar(1) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `ITEM_NO` bigint(20) DEFAULT NULL,
  `ANS` bigint(20) DEFAULT NULL,
  `YN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_rst_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_rst_mst` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `RST_NO` varchar(20) DEFAULT NULL,
  `USER_ID` varchar(20) DEFAULT NULL,
  `GOSI_TYPE` varchar(10) DEFAULT NULL,
  `GOSI_AREA` varchar(10) DEFAULT NULL,
  `EXAM_TYPE` varchar(10) DEFAULT NULL,
  `ADD_POINT` varchar(1) DEFAULT NULL,
  `STUDY_YN` varchar(1) DEFAULT NULL,
  `STUDY_TYPE` varchar(1) DEFAULT NULL,
  `STUDY_WAIT` varchar(1) DEFAULT NULL,
  `STUDY_TIME` varchar(1) DEFAULT NULL,
  `MO_POINT` bigint(20) DEFAULT NULL,
  `SEL_CATE` varchar(20) DEFAULT NULL,
  `SEL_SBJ` varchar(20) DEFAULT NULL,
  `NEXT_EXAM` varchar(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPT_DT` date DEFAULT NULL,
  `EXAM_STAT` bigint(20) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_rst_sbj`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_rst_sbj` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `RST_NO` varchar(20) DEFAULT NULL,
  `EXAM_TYPE` varchar(1) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `SUM_POINT` bigint(20) DEFAULT NULL,
  `ADJ_POINT` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_rst_smp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_rst_smp` (
  `AREA_01` varchar(100) DEFAULT NULL,
  `AREA_02` varchar(100) DEFAULT NULL,
  `RST_NO` varchar(20) DEFAULT NULL,
  `USER_NM` varchar(20) DEFAULT NULL,
  `USER_AGE` varchar(10) DEFAULT NULL,
  `STUDY_WAIT` varchar(100) DEFAULT NULL,
  `STUDY_TYPE` varchar(100) DEFAULT NULL,
  `ADD_POINT` varchar(100) DEFAULT NULL,
  `EXAM_STAT` varchar(20) DEFAULT NULL,
  `SEL_SBJ_01` varchar(100) DEFAULT NULL,
  `SEL_SBJ_02` varchar(100) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `SBJ_01` varchar(10) DEFAULT NULL,
  `SBJ_MO_01` varchar(10) DEFAULT NULL,
  `SBJ_02` varchar(10) DEFAULT NULL,
  `SBJ_MO_02` varchar(10) DEFAULT NULL,
  `SBJ_03` varchar(10) DEFAULT NULL,
  `SBJ_MO_03` varchar(10) DEFAULT NULL,
  `SBJ_04` varchar(10) DEFAULT NULL,
  `SBJ_MO_04` varchar(10) DEFAULT NULL,
  `SBJ_05` varchar(10) DEFAULT NULL,
  `SBJ_MO_05` varchar(10) DEFAULT NULL,
  `USER_SEX` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_sbj_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_sbj_mst` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `SBJ_TYPE` varchar(20) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `SUBJECT_NM` varchar(20) DEFAULT NULL,
  `REQ_USR_NUM` bigint(20) DEFAULT NULL,
  `SUM_POINT` bigint(20) DEFAULT NULL,
  `AVR_POINT` bigint(20) DEFAULT NULL,
  `SDV` bigint(20) DEFAULT NULL,
  `AVR_3_POINT` bigint(20) DEFAULT NULL,
  `AVR_10_POINT` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_stat_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_stat_mst` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `GOSI_TYPE` varchar(20) DEFAULT NULL,
  `GOSI_AREA` varchar(20) DEFAULT NULL,
  `GOSI_SUBJECT_CD` varchar(20) DEFAULT NULL,
  `GOSI_SUBJEC_NM` varchar(20) DEFAULT NULL,
  `GOSI_USER_NUM` bigint(20) DEFAULT NULL,
  `GOSI_AVR_POINT` bigint(20) DEFAULT NULL,
  `GOSI_3_POINT` bigint(20) DEFAULT NULL,
  `GOSI_10_POINT` bigint(20) DEFAULT NULL,
  `GOSI_ADJ_AVR_POINT` bigint(20) DEFAULT NULL,
  `GOSI_ADJ_3_POINT` bigint(20) DEFAULT NULL,
  `GOSI_ADJ_10_POINT` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_subject` (
  `GOSI_TYPE` varchar(2) DEFAULT NULL,
  `GOSI_SUBJECT_CD` varchar(3) DEFAULT NULL,
  `GOSI_SUBJECT_TYPE` varchar(1) DEFAULT NULL,
  `GOSI_SUBJECT_NM` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `gosi_vod`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gosi_vod` (
  `GOSI_CD` varchar(20) DEFAULT NULL,
  `PRF_ID` varchar(20) DEFAULT NULL,
  `PRF_NM` varchar(50) DEFAULT NULL,
  `SBJ_NM` varchar(200) DEFAULT NULL,
  `TITLE` varchar(200) DEFAULT NULL,
  `VOD_URL` varchar(500) DEFAULT NULL,
  `FILE_URL` varchar(500) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `IDX` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `id_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `id_admin` (
  `admin_id` char(36) NOT NULL,
  `username` varchar(64) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password_hash` varchar(100) NOT NULL,
  `display_name` varchar(100) DEFAULT NULL,
  `role` varchar(32) NOT NULL DEFAULT 'ROLE_ADMIN',
  `enabled` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login_at` datetime DEFAULT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `uk_id_admin_username` (`username`),
  UNIQUE KEY `uk_id_admin_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='관리자 계정 (Sprint 1-1b — ADR-002/005)';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `material_menu_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `material_menu_mst` (
  `menu_no` int(11) NOT NULL AUTO_INCREMENT COMMENT '메뉴일련번호',
  `menu_id` varchar(100) DEFAULT NULL COMMENT '메뉴 아이디',
  `menu_title` varchar(100) NOT NULL COMMENT '메뉴명',
  `menu_en` varchar(100) DEFAULT NULL COMMENT '메뉴 영문명',
  `menu_type` varchar(20) DEFAULT NULL COMMENT '메뉴 타입',
  `menu_icon` varchar(30) DEFAULT NULL COMMENT '메뉴 아이콘',
  `menu_url` varchar(100) DEFAULT NULL COMMENT '메뉴 URL',
  `menu_classes` varchar(20) DEFAULT NULL COMMENT 'classes',
  `menu_exact` varchar(1) DEFAULT NULL COMMENT '메뉴연결여부',
  `menu_target` varchar(1) DEFAULT NULL COMMENT '메뉴 새창 여부',
  `menu_breadcrumbs` varchar(1) DEFAULT NULL COMMENT 'breadcrumbs',
  `menu_external` varchar(1) DEFAULT NULL COMMENT 'external',
  `menu_left` varchar(1) DEFAULT NULL COMMENT '메뉴 여부',
  `menu_path` varchar(100) DEFAULT NULL COMMENT '메뉴연결명',
  `menu_element` varchar(200) DEFAULT NULL COMMENT '메뉴 링크',
  `menu_layout` varchar(20) DEFAULT NULL COMMENT '화면 레이아웃',
  `menu_upper_id` int(11) DEFAULT NULL COMMENT '메뉴 상위코드',
  `menu_depth` int(11) DEFAULT NULL COMMENT '메뉴 단계',
  `menu_sort` int(11) DEFAULT NULL COMMENT '메뉴순서',
  `is_use` varchar(1) DEFAULT NULL COMMENT '사용여부',
  PRIMARY KEY (`menu_no`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci COMMENT='사용자 메뉴';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mb_access_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mb_access_log` (
  `ACCESS_DT` date DEFAULT NULL,
  `USERID` varchar(20) DEFAULT NULL,
  `USER_IP` varchar(100) DEFAULT NULL,
  `IS_LOGIN` varchar(1) DEFAULT NULL,
  `IS_LEC_OPEN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `notuse_coupon_lecture`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notuse_coupon_lecture` (
  `LECCODE` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `od_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `od_order` (
  `order_id` char(36) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'PENDING',
  `total_amount` decimal(12,0) NOT NULL DEFAULT 0,
  `discount_amount` decimal(12,0) NOT NULL DEFAULT 0,
  `mileage_used` decimal(12,0) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `paid_at` datetime DEFAULT NULL,
  `canceled_at` datetime DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `idx_od_order_user` (`user_id`),
  KEY `idx_od_order_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='주문';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `od_order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `od_order_item` (
  `order_item_id` char(36) NOT NULL,
  `order_id` char(36) NOT NULL,
  `mst_code` varchar(32) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `unit_price` decimal(12,0) NOT NULL DEFAULT 0,
  PRIMARY KEY (`order_item_id`),
  KEY `idx_od_order_item_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='주문 아이템';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `od_payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `od_payment` (
  `payment_id` char(36) NOT NULL,
  `order_id` char(36) NOT NULL,
  `method` varchar(32) NOT NULL DEFAULT 'MOCK',
  `status` varchar(32) NOT NULL DEFAULT 'PENDING',
  `pg_txn_id` varchar(128) DEFAULT NULL,
  `amount` decimal(12,0) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `approved_at` datetime DEFAULT NULL,
  `canceled_at` datetime DEFAULT NULL,
  `raw_response` text DEFAULT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `idx_od_payment_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='결제 (Sprint 3 mock PG · Sprint 4+ 실 연동)';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `off_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `off_user` (
  `users_group_code` bigint(20) DEFAULT NULL,
  `userId` varchar(20) DEFAULT NULL,
  `userpass` varchar(20) DEFAULT NULL,
  `userName` varchar(50) DEFAULT NULL,
  `sexCode` varchar(6) DEFAULT NULL,
  `passHintQCode` varchar(6) DEFAULT NULL,
  `passHintAnswer` varchar(200) DEFAULT NULL,
  `birthDay` varchar(8) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `homeUrl` varchar(100) DEFAULT NULL,
  `zipcd` varchar(6) DEFAULT NULL,
  `addr` varchar(200) DEFAULT NULL,
  `addr2` varchar(100) DEFAULT NULL,
  `regDate` date DEFAULT NULL,
  `point` bigint(20) DEFAULT NULL,
  `mailling_yn` varchar(1) DEFAULT NULL,
  `favorites` varchar(200) DEFAULT NULL,
  `path_history` varchar(200) DEFAULT NULL,
  `memo` longblob DEFAULT NULL,
  `relation` bigint(20) DEFAULT NULL,
  `oldid_hl` varchar(20) DEFAULT NULL,
  `oldid_gosimain` varchar(20) DEFAULT NULL,
  `oldid_passhaja` varchar(20) DEFAULT NULL,
  `oldid_bookgosimain` varchar(20) DEFAULT NULL,
  `id_url` varchar(200) DEFAULT NULL,
  `user_ip` varchar(15) DEFAULT NULL,
  `userRegType` varchar(1) DEFAULT NULL,
  `pub_code` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `on_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `on_user` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NM` varchar(50) DEFAULT NULL,
  `USER_NICKNM` varchar(50) DEFAULT NULL,
  `USER_POSITION` varchar(100) DEFAULT NULL,
  `SEX` varchar(1) DEFAULT NULL,
  `USER_ROLE` varchar(4) DEFAULT NULL,
  `ADMIN_ROLE` varchar(1) DEFAULT NULL,
  `USER_PWD` varchar(20) DEFAULT NULL,
  `BIRTH_DAY` varchar(8) DEFAULT NULL,
  `EMAIL` varchar(50) DEFAULT NULL,
  `ZIP_CODE` varchar(7) DEFAULT NULL,
  `ADDRESS1` varchar(150) DEFAULT NULL,
  `ADDRESS2` varchar(150) DEFAULT NULL,
  `CATEGORY_CODE` varchar(10) DEFAULT NULL,
  `USER_POINT` varchar(1000) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `REMARK` varchar(1000) DEFAULT NULL,
  `MEMO` varchar(8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `pt_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pt_coupon` (
  `coupon_id` char(36) NOT NULL,
  `name` varchar(128) NOT NULL,
  `discount_type` varchar(16) NOT NULL DEFAULT 'AMOUNT',
  `discount_value` decimal(12,0) NOT NULL,
  `min_order` decimal(12,0) NOT NULL DEFAULT 0,
  `valid_from` datetime NOT NULL,
  `valid_to` datetime NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`coupon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='쿠폰 마스터';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `pt_coupon_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pt_coupon_user` (
  `coupon_user_id` char(36) NOT NULL,
  `user_id` varchar(64) NOT NULL,
  `coupon_id` char(36) NOT NULL,
  `issued_at` datetime NOT NULL DEFAULT current_timestamp(),
  `used_at` datetime DEFAULT NULL,
  `order_id` char(36) DEFAULT NULL,
  PRIMARY KEY (`coupon_user_id`),
  KEY `idx_pt_coupon_user_user` (`user_id`),
  KEY `idx_pt_coupon_user_coupon` (`coupon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='사용자 보유 쿠폰';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `pt_mileage_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pt_mileage_ledger` (
  `ledger_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) NOT NULL,
  `delta` decimal(12,0) NOT NULL,
  `reason` varchar(64) NOT NULL,
  `order_id` char(36) DEFAULT NULL,
  `balance_after` decimal(12,0) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`ledger_id`),
  KEY `idx_pt_mileage_user` (`user_id`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='마일리지 원장 (append-only)';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `role_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_info` (
  `ROLE_CODE` varchar(50) NOT NULL DEFAULT '' COMMENT '롤코드',
  `ROLE_NM` varchar(60) NOT NULL COMMENT '롤명',
  `ROLE_PTTRN` varchar(300) DEFAULT NULL COMMENT '롤패턴',
  `ROLE_DC` varchar(200) DEFAULT NULL COMMENT '롤설명',
  `ROLE_TY` varchar(80) DEFAULT NULL COMMENT '롤유형',
  `ROLE_SORT` varchar(10) DEFAULT NULL COMMENT '롤정렬',
  `ROLE_CREAT_DE` char(20) NOT NULL COMMENT '롤생성일',
  PRIMARY KEY (`ROLE_CODE`),
  UNIQUE KEY `ROLE_INFO_PK` (`ROLE_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='롤정보';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles_hierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles_hierarchy` (
  `PARNTS_ROLE` varchar(30) NOT NULL COMMENT '부모롤',
  `CHLDRN_ROLE` varchar(30) NOT NULL COMMENT '자식롤',
  PRIMARY KEY (`PARNTS_ROLE`,`CHLDRN_ROLE`),
  UNIQUE KEY `ROLES_HIERARCHY_PK` (`PARNTS_ROLE`,`CHLDRN_ROLE`),
  UNIQUE KEY `ROLES_HIERARCHY_i01` (`PARNTS_ROLE`),
  KEY `ROLES_HIERARCHY_i02` (`CHLDRN_ROLE`),
  CONSTRAINT `ROLES_HIERARCHY_FK1` FOREIGN KEY (`PARNTS_ROLE`) REFERENCES `author_info` (`AUTHOR_CODE`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `ROLES_HIERARCHY_FK2` FOREIGN KEY (`CHLDRN_ROLE`) REFERENCES `author_info` (`AUTHOR_CODE`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='롤 계층구조';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sc_tran`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sc_tran` (
  `TR_NUM` bigint(20) DEFAULT NULL,
  `TR_SENDDATE` date DEFAULT NULL,
  `TR_ID` varchar(16) DEFAULT NULL,
  `TR_SENDSTAT` varchar(1) DEFAULT NULL,
  `TR_RSLTSTAT` varchar(2) DEFAULT NULL,
  `TR_MSGTYPE` varchar(1) DEFAULT NULL,
  `TR_PHONE` varchar(20) DEFAULT NULL,
  `TR_CALLBACK` varchar(20) DEFAULT NULL,
  `TR_RSLTDATE` date DEFAULT NULL,
  `TR_MODIFIED` date DEFAULT NULL,
  `TR_MSG` varchar(160) DEFAULT NULL,
  `TR_NET` varchar(4) DEFAULT NULL,
  `TR_ETC1` varchar(160) DEFAULT NULL,
  `TR_ETC2` varchar(160) DEFAULT NULL,
  `TR_ETC3` varchar(160) DEFAULT NULL,
  `TR_ETC4` varchar(160) DEFAULT NULL,
  `TR_ETC5` varchar(160) DEFAULT NULL,
  `TR_ETC6` varchar(160) DEFAULT NULL,
  `TR_REALSENDDATE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sys_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_log` (
  `REQUST_ID` varchar(20) NOT NULL COMMENT '요청ID',
  `JOB_SE_CODE` char(3) DEFAULT NULL COMMENT '업무구분코드',
  `INSTT_CODE` char(7) DEFAULT NULL COMMENT '기관코드',
  `OCCRRNC_DE` datetime DEFAULT NULL COMMENT '발생일',
  `RQESTER_IP` varchar(23) DEFAULT NULL COMMENT '요청자IP',
  `RQESTER_ID` varchar(20) DEFAULT NULL COMMENT '요청자ID',
  `TRGET_MENU_NM` varchar(255) DEFAULT NULL COMMENT '대상메뉴명',
  `SVC_NM` varchar(255) DEFAULT NULL COMMENT '서비스명',
  `METHOD_NM` varchar(60) DEFAULT NULL COMMENT '메서드명',
  `PROCESS_SE_CODE` char(3) DEFAULT NULL COMMENT '처리구분코드',
  `PROCESS_CO` decimal(10,0) DEFAULT NULL COMMENT '처리수',
  `PROCESS_TIME` varchar(14) DEFAULT NULL COMMENT '처리시간',
  `RSPNS_CODE` char(3) DEFAULT NULL COMMENT '응답코드',
  `ERROR_SE` char(1) DEFAULT NULL COMMENT '오류구분',
  `ERROR_CO` decimal(10,0) DEFAULT NULL COMMENT '오류수',
  `ERROR_CODE` char(3) DEFAULT NULL COMMENT '오류코드',
  PRIMARY KEY (`REQUST_ID`),
  UNIQUE KEY `SYS_LOG_PK` (`REQUST_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='시스템로그';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_approvals` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `PRICE` bigint(20) DEFAULT NULL,
  `ADDPRICE` bigint(20) DEFAULT NULL,
  `PAYCODE` varchar(6) DEFAULT NULL,
  `ACCTNOCODE` varchar(6) DEFAULT NULL,
  `PAYNAME` varchar(50) DEFAULT NULL,
  `POINT` bigint(20) DEFAULT NULL,
  `RETURNVALUE` varchar(2000) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `BANNER_NAME` varchar(40) DEFAULT NULL,
  `REPRICE` bigint(20) DEFAULT NULL,
  `REPRICEDATE` date DEFAULT NULL,
  `ORDERURL` varchar(10) DEFAULT NULL,
  `VCDBANK` varchar(2) DEFAULT NULL,
  `VACCT` varchar(30) DEFAULT NULL,
  `VACCT_NAME` varchar(30) DEFAULT NULL,
  `REFUND_POINT` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_ba_config_cd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_ba_config_cd` (
  `SYS_CD` varchar(20) DEFAULT NULL,
  `CODE_NO` bigint(20) DEFAULT NULL,
  `SYS_NM` varchar(100) DEFAULT NULL,
  `CODE_NM` varchar(100) DEFAULT NULL,
  `CODE_VAL` varchar(20) DEFAULT NULL,
  `CODE_INFO` varchar(1000) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `CODE_CD` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_banner`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_banner` (
  `SEQ` bigint(20) DEFAULT NULL,
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `SCREEN_GUBUN` varchar(1) DEFAULT NULL,
  `CATEGORY_CD` varchar(100) DEFAULT NULL,
  `BANNER_NO` bigint(20) DEFAULT NULL,
  `BANNER_TITLE` varchar(100) DEFAULT NULL,
  `BANNER_IMAGE` varchar(100) DEFAULT NULL,
  `BANNER_THUMBNAIL_IMAGE` varchar(100) DEFAULT NULL,
  `BANNER_LINK` varchar(1000) DEFAULT NULL,
  `BANNER_LINK_TARGET` varchar(1) DEFAULT NULL,
  `OPEN_STARTDATE` date DEFAULT NULL,
  `OPEN_ENDDATE` date DEFAULT NULL,
  `IS_USE` varchar(1) DEFAULT NULL,
  `VIEW_COUNT` bigint(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `ROL_IDX` bigint(20) DEFAULT NULL,
  `BANNER_TYP` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_banner_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_banner_item` (
  `SEQ` bigint(20) DEFAULT NULL,
  `P_SEQ` bigint(20) DEFAULT NULL,
  `ROL_IDX` bigint(20) DEFAULT NULL,
  `BANNER_SUBTITLE` varchar(100) DEFAULT NULL,
  `BANNER_NOTE` varchar(1000) DEFAULT NULL,
  `BANNER_IMAGE` varchar(100) DEFAULT NULL,
  `BANNER_THUMBNAIL_IMAGE` varchar(100) DEFAULT NULL,
  `BANNER_LINK` varchar(1000) DEFAULT NULL,
  `BANNER_LINK_TARGET` varchar(1) DEFAULT NULL,
  `BANNER_SDT` date DEFAULT NULL,
  `BANNER_EDT` date DEFAULT NULL,
  `CLICK_CNT` bigint(20) DEFAULT NULL,
  `IS_USE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_board`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_board` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `OPEN_YN` varchar(1) DEFAULT NULL,
  `SUBJECT` varchar(200) DEFAULT NULL,
  `CONTENT` longblob DEFAULT NULL,
  `FILE_PATH` varchar(100) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `REAL_FILE_NAME` varchar(100) DEFAULT NULL,
  `NOTICE_TOP_YN` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `HITS` bigint(20) DEFAULT NULL,
  `CREATENAME` varchar(30) DEFAULT NULL,
  `ANSWER` longblob DEFAULT NULL,
  `THUMBNAIL_FILE_PATH` varchar(100) DEFAULT NULL,
  `THUMBNAIL_FILE_NAME` varchar(100) DEFAULT NULL,
  `THUMBNAIL_FILE_REAL_NAME` varchar(100) DEFAULT NULL,
  `IS_USE` varchar(1) DEFAULT NULL,
  `RECOMMEND` varchar(1) DEFAULT NULL,
  `BOARD_SEQ3` bigint(20) DEFAULT NULL,
  `EXAM_TYPE` varchar(1) DEFAULT NULL,
  `EXAM_AREA` varchar(50) DEFAULT NULL,
  `EXAM_CATE` varchar(1) DEFAULT NULL,
  `EXAM_SUB` varchar(50) DEFAULT NULL,
  `CATEGORY_CODE` varchar(100) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `PARENT_BOARD_SEQ` varchar(20) DEFAULT NULL,
  `PROF_ID` varchar(30) DEFAULT NULL,
  `BOARD_TYPE` varchar(2) DEFAULT NULL,
  `MOCKCODE` varchar(20) DEFAULT NULL,
  `DIVICE_TYPE` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_board2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_board2` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `OPEN_YN` varchar(1) DEFAULT NULL,
  `SUBJECT` varchar(200) DEFAULT NULL,
  `CONTENT` longblob DEFAULT NULL,
  `FILE_PATH` varchar(100) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `REAL_FILE_NAME` varchar(100) DEFAULT NULL,
  `PARENT_BOARD_SEQ` varchar(20) DEFAULT NULL,
  `NOTICE_TOP_YN` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `HITS` bigint(20) DEFAULT NULL,
  `CREATENAME` varchar(30) DEFAULT NULL,
  `ANSWER` longblob DEFAULT NULL,
  `THUMBNAIL_FILE_PATH` varchar(100) DEFAULT NULL,
  `THUMBNAIL_FILE_NAME` varchar(100) DEFAULT NULL,
  `THUMBNAIL_FILE_REAL_NAME` varchar(100) DEFAULT NULL,
  `ISSUE` varchar(1) DEFAULT NULL,
  `RECOMMEND` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_board_category_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_board_category_info` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `CATEGORY_CODE` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_board_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_board_comment` (
  `SEQ` bigint(20) DEFAULT NULL,
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NAME` varchar(50) DEFAULT NULL,
  `TITLE` varchar(200) DEFAULT NULL,
  `CONTENT` varchar(4000) DEFAULT NULL,
  `CHOICE_POINT` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_board_cs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_board_cs` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `CS_DIV` varchar(20) DEFAULT NULL,
  `CS_KIND` varchar(20) DEFAULT NULL,
  `OPEN_YN` varchar(1) DEFAULT NULL,
  `SUBJECT` varchar(200) DEFAULT NULL,
  `CONTENT` longblob DEFAULT NULL,
  `FILE_PATH` varchar(100) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `REAL_FILE_NAME` varchar(100) DEFAULT NULL,
  `PARENT_BOARD_SEQ` varchar(20) DEFAULT NULL,
  `NOTICE_TOP_YN` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `HITS` bigint(20) DEFAULT NULL,
  `CREATENAME` varchar(30) DEFAULT NULL,
  `ANSWER` longblob DEFAULT NULL,
  `THUMBNAIL_FILE_PATH` varchar(100) DEFAULT NULL,
  `THUMBNAIL_FILE_NAME` varchar(100) DEFAULT NULL,
  `THUMBNAIL_FILE_REAL_NAME` varchar(100) DEFAULT NULL,
  `ISSUE` varchar(1) DEFAULT NULL,
  `RECOMMEND` varchar(1) DEFAULT NULL,
  `COUNSELOR_ID` varchar(30) DEFAULT NULL,
  `ACTION_YN` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_board_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_board_file` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `FILE_NO` varchar(20) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `FILE_PATH` varchar(100) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `PARENT_BOARD_SEQ` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_board_mng`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_board_mng` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_MNG_NAME` varchar(200) DEFAULT NULL,
  `BOARD_MNG_TYPE` varchar(20) DEFAULT NULL,
  `ATTACH_FILE_YN` varchar(1) DEFAULT NULL,
  `OPEN_YN` varchar(1) DEFAULT NULL,
  `REPLY_YN` varchar(1) DEFAULT NULL,
  `IS_USE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_board_voting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_board_voting` (
  `BOARD_MNG_SEQ` varchar(20) DEFAULT NULL,
  `BOARD_SEQ` varchar(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `ISTYPE` varchar(1) DEFAULT NULL,
  `VOTING` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_bookmark`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_bookmark` (
  `USER_ID` varchar(100) DEFAULT NULL,
  `ORDERNO` varchar(30) DEFAULT NULL,
  `PACKAGE_NO` varchar(30) DEFAULT NULL,
  `LECTURE_NO` varchar(30) DEFAULT NULL,
  `MOVIE_NO` varchar(30) DEFAULT NULL,
  `BOOKMARK_NO` bigint(20) DEFAULT NULL,
  `BOOKMARK_NAME` varchar(4000) DEFAULT NULL,
  `BOOKMARK_TIME` bigint(20) DEFAULT NULL,
  `BOOKMARK_SPEED` varchar(50) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_ca_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_ca_book` (
  `SEQ` bigint(20) DEFAULT NULL,
  `RSC_ID` varchar(100) DEFAULT NULL,
  `SUBJECT_SJT_CD` varchar(1000) DEFAULT NULL,
  `CATEGORY_CD` varchar(55) DEFAULT NULL,
  `LEARNING_CD` varchar(20) DEFAULT NULL,
  `BOOK_NM` varchar(4000) DEFAULT NULL,
  `BOOK_INFO` longblob DEFAULT NULL,
  `BOOK_MEMO` varchar(4000) DEFAULT NULL,
  `BOOK_KEYWORD` varchar(4000) DEFAULT NULL,
  `ISSUE_DATE` varchar(8) DEFAULT NULL,
  `COVER_TYPE` varchar(1) DEFAULT NULL,
  `BOOK_CONTENTS` varchar(4000) DEFAULT NULL,
  `PRICE` bigint(20) DEFAULT NULL,
  `DISCOUNT` bigint(20) DEFAULT NULL,
  `DISCOUNT_PRICE` bigint(20) DEFAULT NULL,
  `POINT` bigint(20) DEFAULT NULL,
  `BOOK_PUBLISHERS` varchar(100) DEFAULT NULL,
  `BOOK_AUTHOR` varchar(50) DEFAULT NULL,
  `BOOK_SUPPLEMENTDATA` varchar(1) DEFAULT NULL,
  `BOOK_PRINTINGDATE` varchar(1) DEFAULT NULL,
  `BOOK_MAIN` varchar(1) DEFAULT NULL,
  `BOOK_SUB` varchar(1) DEFAULT NULL,
  `BOOK_STUDENTBOOK` varchar(1) DEFAULT NULL,
  `ATTACH_FILE` varchar(100) DEFAULT NULL,
  `ATTACH_IMG_L` varchar(100) DEFAULT NULL,
  `ATTACH_IMG_M` varchar(100) DEFAULT NULL,
  `ATTACH_IMG_S` varchar(100) DEFAULT NULL,
  `ATTACH_DETAIL_INFO` varchar(100) DEFAULT NULL,
  `BOOK_STOCK` bigint(20) DEFAULT NULL,
  `FREE_POST` varchar(1) DEFAULT NULL,
  `BOOK_DATE` varchar(8) DEFAULT NULL,
  `NEW_BOOK` varchar(1) DEFAULT NULL,
  `MAIN_VIEW` varchar(1) DEFAULT NULL,
  `USE_YN` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_category_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_category_info` (
  `ID` bigint(20) DEFAULT NULL,
  `CODE` varchar(20) DEFAULT NULL,
  `NAME` varchar(50) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `USE_ON` varchar(1) DEFAULT NULL,
  `USE_OFF` varchar(1) DEFAULT NULL,
  `P_CODE` varchar(20) DEFAULT NULL,
  `CODE_VAL` varchar(20) DEFAULT NULL,
  `ORDR` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_category_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_category_mapping` (
  `legacy_cs_div` varchar(20) NOT NULL COMMENT 'TB_BOARD_CS.CS_DIV',
  `legacy_cs_kind` varchar(20) NOT NULL DEFAULT '' COMMENT 'TB_BOARD_CS.CS_KIND. 빈 문자열 = CS_DIV 만으로 매칭',
  `std_category` varchar(30) NOT NULL COMMENT '표준 4분류 — ACADEMIC|ORDER|SYSTEM|OTHER',
  `remark` varchar(200) DEFAULT NULL,
  `reg_dt` datetime NOT NULL DEFAULT current_timestamp(),
  `upd_dt` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`legacy_cs_div`,`legacy_cs_kind`),
  KEY `idx_std` (`std_category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='legacy CS 분류 ↔ 신규 4분류 매핑 마스터';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_category_series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_category_series` (
  `SEQ` bigint(20) DEFAULT NULL,
  `CAT_CD` varchar(20) DEFAULT NULL,
  `SRS_CD` varchar(20) DEFAULT NULL,
  `ORDR` bigint(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_category_subject_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_category_subject_order` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `CATEGORY_CODE` varchar(50) DEFAULT NULL,
  `SUBJECT_CD` varchar(50) DEFAULT NULL,
  `IDX` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_cc_cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_cc_cart` (
  `SEQ` bigint(20) DEFAULT NULL,
  `USER_ID` varchar(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `KIND_TYPE` varchar(1) DEFAULT NULL,
  `RSC_ID` varchar(30) DEFAULT NULL,
  `RSC_TYPE` varchar(1) DEFAULT NULL,
  `MOVIE_TYPE` varchar(2) DEFAULT NULL,
  `REGDATE` date DEFAULT NULL,
  `REPRICE` bigint(20) DEFAULT NULL,
  `PACKAGE_PERIOD` bigint(20) DEFAULT NULL,
  `SDATE` varchar(50) DEFAULT NULL,
  `EDATE` varchar(50) DEFAULT NULL,
  `BOOK_COUNT` bigint(20) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_cc_j_cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_cc_j_cart` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `MST_LECCODE` varchar(30) DEFAULT NULL,
  `UPDATE_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `PRICE` bigint(20) DEFAULT NULL,
  `KIND_TYPE` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_choice_jong_no`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_choice_jong_no` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `NO` bigint(20) DEFAULT NULL,
  `CATEGORY_CD` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_comment` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NAME` varchar(50) DEFAULT NULL,
  `CONTENT` varchar(4000) DEFAULT NULL,
  `CHOICE_POINT` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `TITLE` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_comment_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_comment_book` (
  `SEQ` bigint(20) DEFAULT NULL,
  `RSC_ID` varchar(100) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NAME` varchar(50) DEFAULT NULL,
  `TITLE` varchar(200) DEFAULT NULL,
  `CONTENT` varchar(4000) DEFAULT NULL,
  `CHOICE_POINT` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_common_password`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_common_password` (
  `COMMON_PWD` varchar(100) DEFAULT NULL,
  `PWD_DESC` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_danintcount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_danintcount` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `DAN_INT_COUNT` bigint(20) DEFAULT NULL,
  `REAL_CARTSUM` bigint(20) DEFAULT NULL,
  `REGDATE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_danpint`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_danpint` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `DAN_POINT` bigint(20) DEFAULT NULL,
  `REAL_CARTSUM` bigint(20) DEFAULT NULL,
  `REGDATE` date DEFAULT NULL,
  `BOOK_POINT` bigint(20) DEFAULT NULL,
  `USER_ID` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_dday`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_dday` (
  `DDAY_IDX` bigint(20) DEFAULT NULL,
  `USER_ID` varchar(20) DEFAULT NULL,
  `DDAY_TYPE` varchar(1) DEFAULT NULL,
  `DDAY_CATEGORY` varchar(20) DEFAULT NULL,
  `DDAY_NAME` varchar(200) DEFAULT NULL,
  `DDAY_DATE` varchar(10) DEFAULT NULL,
  `REGDATE` date NOT NULL,
  `DDAY_LINK` bigint(20) DEFAULT NULL,
  `DDAY_ACTIVE` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_delivers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_delivers` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `SENDNO` varchar(50) DEFAULT NULL,
  `USERNAME` varchar(100) DEFAULT NULL,
  `ZIPCD` varchar(7) DEFAULT NULL,
  `ADDR` varchar(400) DEFAULT NULL,
  `MEMO` varchar(2000) DEFAULT NULL,
  `REGDATE` date NOT NULL,
  `SENDDATE` date DEFAULT NULL,
  `DLEORDER` varchar(6) DEFAULT NULL,
  `CHARGE` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_discount`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_discount` (
  `LEC_MENU1` varchar(10) DEFAULT NULL,
  `LEC_MENU2` varchar(10) DEFAULT NULL,
  `START_EVENT_DATE` date NOT NULL,
  `END_EVENT_DATE` date NOT NULL,
  `EVENT_COUNT` bigint(20) DEFAULT NULL,
  `EVENT_PERCENT` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_event_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_event_file` (
  `EVENT_NO` varchar(20) DEFAULT NULL,
  `FILE_NO` varchar(20) DEFAULT NULL,
  `FILE_NAME` varchar(100) DEFAULT NULL,
  `FILE_PATH` varchar(100) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_event_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_event_info` (
  `EVENT_NO` varchar(20) DEFAULT NULL,
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `CATEGORY_CODE` varchar(30) DEFAULT NULL,
  `NOTICE_GUBUN` varchar(10) DEFAULT NULL,
  `OPEN_YN` varchar(1) DEFAULT NULL,
  `MEMBER_GUBUN` varchar(1) DEFAULT NULL,
  `HIT` bigint(20) DEFAULT NULL,
  `START_DATE` varchar(8) DEFAULT NULL,
  `START_TIME` varchar(2) DEFAULT NULL,
  `END_DATE` varchar(8) DEFAULT NULL,
  `END_TIME` varchar(2) DEFAULT NULL,
  `TITLE` varchar(500) DEFAULT NULL,
  `CONTENTS_TEXT` longblob DEFAULT NULL,
  `CONTENTS_IMG` varchar(100) DEFAULT NULL,
  `LIST_THUMBNAIL` varchar(100) DEFAULT NULL,
  `ISSUE_THUMBNAIL` varchar(100) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `OPTION1_YN` varchar(1) DEFAULT NULL,
  `OPTION2_YN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_event_option1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_event_option1` (
  `EVENT_NO` varchar(20) DEFAULT NULL,
  `OPTION_NO` varchar(20) DEFAULT NULL,
  `OPTION_NAME` varchar(2000) DEFAULT NULL,
  `PEOPLE_GUBUN` varchar(1) DEFAULT NULL,
  `PEOPLE_CNT` bigint(20) DEFAULT NULL,
  `MULTI_SELECT_YN` varchar(1) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_event_option2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_event_option2` (
  `EVENT_NO` varchar(20) DEFAULT NULL,
  `NO` bigint(20) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NM` varchar(50) DEFAULT NULL,
  `TXT` varchar(4000) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_event_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_event_result` (
  `EVENT_NO` varchar(20) DEFAULT NULL,
  `OPTION_NO` varchar(20) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NAME` varchar(50) DEFAULT NULL,
  `PHONE_NO` varchar(20) DEFAULT NULL,
  `EMAIL` varchar(50) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_inquiry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_inquiry` (
  `inquiry_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `user_name` varchar(50) NOT NULL,
  `title` varchar(300) NOT NULL,
  `body` mediumtext NOT NULL,
  `inquiry_date` datetime NOT NULL DEFAULT current_timestamp(),
  `predicted_category` varchar(30) DEFAULT NULL COMMENT 'ACADEMIC|ORDER|SYSTEM|OTHER',
  `predicted_confidence` decimal(5,4) DEFAULT NULL COMMENT '0.0000 ~ 1.0000',
  `classified_by_model` varchar(50) DEFAULT NULL COMMENT 'qwen2.5:7b@v3 식 모델 버전',
  `classified_at` datetime DEFAULT NULL,
  `actual_category` varchar(30) DEFAULT NULL COMMENT '운영자 확정 카테고리',
  `assigned_to` varchar(50) DEFAULT NULL COMMENT '담당자 user_id',
  `reroute_count` int(11) NOT NULL DEFAULT 0,
  `answer_body` mediumtext DEFAULT NULL,
  `answered_by` varchar(50) DEFAULT NULL,
  `answered_at` datetime DEFAULT NULL,
  `resolution_state` varchar(20) NOT NULL DEFAULT 'OPEN' COMMENT 'OPEN|ANSWERED|RESOLVED|CLOSED',
  `user_satisfaction` tinyint(4) DEFAULT NULL COMMENT '1-5 별점',
  `reg_dt` datetime NOT NULL DEFAULT current_timestamp(),
  `upd_dt` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `is_deleted` char(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`inquiry_id`),
  KEY `idx_user` (`user_id`,`inquiry_date`),
  KEY `idx_state` (`resolution_state`,`inquiry_date`),
  KEY `idx_predicted` (`predicted_category`,`classified_at`),
  KEY `idx_actual` (`actual_category`,`reg_dt`),
  KEY `idx_assigned` (`assigned_to`,`resolution_state`),
  KEY `idx_inquiry_date` (`inquiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='1:1 문의 운영 테이블 (Phase D 이후 신규 인입 전용)';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_inquiry_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_inquiry_analysis` (
  `analysis_seq` bigint(20) NOT NULL AUTO_INCREMENT,
  `inquiry_id` bigint(20) NOT NULL,
  `model_name` varchar(50) NOT NULL COMMENT 'qwen2.5:7b 등',
  `model_version` varchar(50) DEFAULT NULL COMMENT 'Ollama digest',
  `prompt_template` varchar(50) NOT NULL COMMENT 'v1, v2 ... few-shot 버전',
  `raw_output` text DEFAULT NULL COMMENT 'LLM 원 응답 (감사)',
  `parsed_category` varchar(30) DEFAULT NULL,
  `confidence` decimal(5,4) DEFAULT NULL,
  `latency_ms` int(11) DEFAULT NULL,
  `error_msg` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`analysis_seq`),
  KEY `idx_cs_time` (`inquiry_id`,`created_at`),
  KEY `idx_model` (`model_name`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='AI 분류 원시 결과 이력 (재현·디버깅 용)';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_inquiry_embedding`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_inquiry_embedding` (
  `inquiry_id` bigint(20) NOT NULL,
  `model_name` varchar(50) NOT NULL COMMENT 'nomic-embed-text 등',
  `dim` int(11) NOT NULL,
  `embedding` blob NOT NULL COMMENT 'float32 array, little-endian',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`inquiry_id`,`model_name`),
  KEY `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='임베딩 벡터 DB 백업 — ChromaDB 컬렉션 유실시 재구축 용';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_inquiry_file`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_inquiry_file` (
  `file_seq` bigint(20) NOT NULL AUTO_INCREMENT,
  `inquiry_id` bigint(20) NOT NULL,
  `file_name` varchar(300) NOT NULL COMMENT '원본 파일명',
  `stored_path` varchar(500) NOT NULL COMMENT '저장 경로 (서버 디스크 또는 S3 key)',
  `mime_type` varchar(100) DEFAULT NULL,
  `size_bytes` bigint(20) DEFAULT NULL,
  `upload_target` varchar(20) NOT NULL DEFAULT 'QUESTION' COMMENT 'QUESTION (사용자 첨부) | ANSWER (운영자 첨부)',
  `reg_dt` datetime NOT NULL DEFAULT current_timestamp(),
  `is_deleted` char(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`file_seq`),
  KEY `idx_inquiry` (`inquiry_id`,`upload_target`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='1:1 문의 첨부파일 메타';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_inquiry_routing_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_inquiry_routing_log` (
  `log_seq` bigint(20) NOT NULL AUTO_INCREMENT,
  `inquiry_id` bigint(20) NOT NULL,
  `from_category` varchar(30) DEFAULT NULL COMMENT 'AI 최초 분류 또는 직전 할당',
  `to_category` varchar(30) NOT NULL,
  `from_user` varchar(50) DEFAULT NULL,
  `to_user` varchar(50) NOT NULL,
  `reason` varchar(500) DEFAULT NULL,
  `changed_by` varchar(50) NOT NULL,
  `changed_at` datetime NOT NULL DEFAULT current_timestamp(),
  `is_ai_error` char(1) NOT NULL DEFAULT 'N' COMMENT 'Y=AI 오분류로 간주 → few-shot 학습 셋 포함',
  PRIMARY KEY (`log_seq`),
  KEY `idx_cs` (`inquiry_id`),
  KEY `idx_learning` (`is_ai_error`,`changed_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='재배정 이력. is_ai_error=Y 건은 주간 few-shot 갱신 입력';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_inquiry_stats_monthly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_inquiry_stats_monthly` (
  `stat_ym` char(7) NOT NULL COMMENT 'YYYY-MM',
  `category` varchar(30) NOT NULL,
  `total_count` int(11) NOT NULL DEFAULT 0,
  `resolved_count` int(11) NOT NULL DEFAULT 0,
  `avg_response_hours` decimal(8,2) DEFAULT NULL,
  `avg_satisfaction` decimal(3,2) DEFAULT NULL COMMENT '1-5',
  `ai_correct_rate` decimal(5,4) DEFAULT NULL COMMENT 'is_ai_error=N 비율',
  `mom_delta_pct` decimal(6,2) DEFAULT NULL COMMENT '전월 대비 변화율',
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`stat_ym`,`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='월간 카테고리별 인사이트 (매월 1일 배치)';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_inquiry_train`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_inquiry_train` (
  `inquiry_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `source_table` varchar(20) NOT NULL DEFAULT 'TB_BOARD_CS' COMMENT '원본 테이블 — TB_BOARD_CS | tb_inquiry',
  `source_id` varchar(50) DEFAULT NULL COMMENT '원본 PK (TB_BOARD_CS.BOARD_SEQ 또는 tb_inquiry.inquiry_id)',
  `legacy_board_seq` varchar(20) DEFAULT NULL COMMENT 'tb_board_cs.BOARD_SEQ',
  `legacy_cs_div` varchar(20) DEFAULT NULL COMMENT 'tb_board_cs.CS_DIV — CSCOUNSEL/CSREFUND 등',
  `legacy_cs_kind` varchar(20) DEFAULT NULL COMMENT 'tb_board_cs.CS_KIND — CSC120/CSR220 등',
  `inquiry_user_id` varchar(50) NOT NULL COMMENT '마스킹된 usr_{hash}',
  `inquiry_name` varchar(50) NOT NULL COMMENT 'Faker 한국어 이름',
  `inquiry_title` varchar(300) NOT NULL,
  `inquiry_body` mediumtext NOT NULL COMMENT '본문 (정규식 PII 치환 후)',
  `inquiry_date` datetime NOT NULL,
  `predicted_category` varchar(30) DEFAULT NULL COMMENT 'ACADEMIC|ORDER|SYSTEM|OTHER',
  `predicted_confidence` decimal(5,4) DEFAULT NULL COMMENT '0.0000 ~ 1.0000',
  `classified_by_model` varchar(50) DEFAULT NULL COMMENT 'ex: qwen2.5:7b',
  `classified_at` datetime DEFAULT NULL,
  `actual_category` varchar(30) DEFAULT NULL,
  `assigned_to` varchar(50) DEFAULT NULL COMMENT '담당자 user_id',
  `reroute_count` int(11) NOT NULL DEFAULT 0,
  `answer_body` mediumtext DEFAULT NULL,
  `answered_by` varchar(50) DEFAULT NULL,
  `answered_at` datetime DEFAULT NULL,
  `resolution_state` varchar(20) NOT NULL DEFAULT 'OPEN' COMMENT 'OPEN|ANSWERED|RESOLVED|CLOSED',
  `user_satisfaction` tinyint(4) DEFAULT NULL COMMENT '1-5 별점',
  `reg_dt` datetime NOT NULL DEFAULT current_timestamp(),
  `upd_dt` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  `is_deleted` char(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`inquiry_id`),
  UNIQUE KEY `uk_legacy` (`legacy_board_seq`),
  KEY `idx_predicted` (`predicted_category`,`classified_at`),
  KEY `idx_actual` (`actual_category`,`reg_dt`),
  KEY `idx_state` (`resolution_state`),
  KEY `idx_assigned` (`assigned_to`,`resolution_state`),
  KEY `idx_inquiry_date` (`inquiry_date`),
  KEY `idx_user` (`inquiry_user_id`),
  KEY `idx_source` (`source_table`,`source_id`)
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='CS/1:1문의 — AI 분류·라우팅 대상. tb_board_cs 이관';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_learning_form_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_learning_form_info` (
  `LEC_DIV` varchar(10) DEFAULT NULL,
  `CODE` varchar(20) DEFAULT NULL,
  `NAME` varchar(50) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_lec_bridge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_lec_bridge` (
  `SEQ` bigint(20) DEFAULT NULL,
  `BRIDGE_LECCODE` varchar(30) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_lec_jong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_lec_jong` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `MST_LECCODE` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `SORT` bigint(20) DEFAULT NULL,
  `GUBUN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_lec_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_lec_mst` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `CATEGORY_CD` varchar(20) DEFAULT NULL,
  `LEARNING_CD` varchar(20) DEFAULT NULL,
  `SUBJECT_TEACHER` varchar(30) DEFAULT NULL,
  `SUBJECT_TEACHER_PAYMENT` varchar(50) DEFAULT NULL,
  `SUBJECT_TITLE` varchar(200) DEFAULT NULL,
  `SUBJECT_KEYWORD` varchar(200) DEFAULT NULL,
  `SUBJECT_PERIOD` bigint(20) DEFAULT NULL,
  `SUBJECT_OFF_OPEN_YEAR` varchar(4) DEFAULT NULL,
  `SUBJECT_OFF_OPEN_MONTH` varchar(2) DEFAULT NULL,
  `SUBJECT_OFF_OPEN_DAY` varchar(2) DEFAULT NULL,
  `SUBJECT_DISCOUNT` bigint(20) DEFAULT NULL,
  `SUBJECT_PRICE` bigint(20) DEFAULT NULL,
  `SUBJECT_POINT` bigint(20) DEFAULT NULL,
  `SUBJECT_MOVIE` bigint(20) DEFAULT NULL,
  `SUBJECT_PMP` bigint(20) DEFAULT NULL,
  `SUBJECT_MOVIE_PMP` bigint(20) DEFAULT NULL,
  `SUBJECT_MOVIE_MP4` bigint(20) DEFAULT NULL,
  `SUBJECT_MOVIE_VOD_MP4` bigint(20) DEFAULT NULL,
  `SUBJECT_SUMNAIL` varchar(200) DEFAULT NULL,
  `SUBJECT_EVENT_IMAGE` varchar(200) DEFAULT NULL,
  `SUBJECT_OUTSIDE` varchar(1) DEFAULT NULL,
  `SUBJECT_OPTION` varchar(200) DEFAULT NULL,
  `SUBJECT_ISUSE` varchar(1) DEFAULT NULL,
  `SUBJECT_SJT_CD` varchar(50) DEFAULT NULL,
  `TWO_SUBJECT` varchar(30) DEFAULT NULL,
  `THREE_SUBJECT` varchar(30) DEFAULT NULL,
  `FIVE_SUBJECT` varchar(30) DEFAULT NULL,
  `SUBJECT_VOD_DEFAULT_PATH` varchar(500) DEFAULT NULL,
  `SUBJECT_MP4_DEFAULT_PATH` varchar(500) DEFAULT NULL,
  `SUBJECT_PMP_DEFAULT_PATH` varchar(500) DEFAULT NULL,
  `SUBJECT_PASS` varchar(50) DEFAULT NULL,
  `SUBJECT_JANG` varchar(1) DEFAULT NULL,
  `RE_COURSE` varchar(30) DEFAULT NULL,
  `LEC_SCHEDULE` varchar(50) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `LEC_TYPE_CHOICE` varchar(1) DEFAULT NULL,
  `REC_GUBUN` varchar(1) DEFAULT NULL,
  `LEC_GUBUN` varchar(1) DEFAULT NULL,
  `MOV_ING` varchar(1) DEFAULT NULL,
  `GIFT_FLAG` varchar(1) DEFAULT NULL,
  `GIFT_COUPON_CCODE` varchar(40) DEFAULT NULL,
  `GIFT_LECCODE` varchar(40) DEFAULT NULL,
  `COUPON_NAME` varchar(200) DEFAULT NULL,
  `GIFT_NAME` varchar(200) DEFAULT NULL,
  `TEACHERNO` bigint(20) DEFAULT NULL,
  `ICON_GUBUN` varchar(10) DEFAULT NULL,
  `MO_COUPON_NAME` varchar(200) DEFAULT NULL,
  `MO_COUPON_CCODE` varchar(40) DEFAULT NULL,
  `FREE_TAB` varchar(10) DEFAULT NULL,
  `SUBJECT_MONITORMODE` varchar(100) DEFAULT NULL,
  `SUBJECT_WIDE_DEFAULT_PATH` varchar(500) DEFAULT NULL,
  `MUST_PRF_IMG` varchar(200) DEFAULT NULL,
  `SEL_PRF_IMG` varchar(200) DEFAULT NULL,
  `SUBJECT_DESC_VARCHAR` varchar(4000) DEFAULT NULL,
  `SUBJECT_MEMO_VARCHAR` varchar(4000) DEFAULT NULL,
  `PLAN_VARCHAR` varchar(4000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_lec_mst_memo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_lec_mst_memo` (
  `BRIDGE_LECCODE` varchar(30) DEFAULT NULL,
  `MOVIE_ORDER1` bigint(20) DEFAULT NULL,
  `MOVIE_ORDER2` bigint(20) DEFAULT NULL,
  `POSITION` varchar(50) DEFAULT NULL,
  `MST_TEXT` varchar(4000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_ma_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_ma_member` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NM` varchar(50) DEFAULT NULL,
  `USER_NICKNM` varchar(100) DEFAULT NULL,
  `USER_POSITION` varchar(100) DEFAULT NULL,
  `SEX` varchar(1) DEFAULT NULL,
  `USER_ROLE` varchar(20) DEFAULT NULL,
  `ADMIN_ROLE` varchar(20) DEFAULT NULL,
  `USER_PWD` varchar(100) DEFAULT NULL,
  `BIRTH_DAY` varchar(8) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL,
  `ZIP_CODE` varchar(10) DEFAULT NULL,
  `ADDRESS1` varchar(200) DEFAULT NULL,
  `ADDRESS2` varchar(200) DEFAULT NULL,
  `CATEGORY_CODE` varchar(20) DEFAULT NULL,
  `USER_POINT` varchar(50) DEFAULT NULL,
  `PAYMENT` varchar(50) DEFAULT NULL,
  `PIC1` varchar(100) DEFAULT NULL,
  `PIC2` varchar(100) DEFAULT NULL,
  `PIC3` varchar(100) DEFAULT NULL,
  `PIC4` varchar(100) DEFAULT NULL,
  `ACCOUNT` varchar(100) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `OFF_PAYMENT` varchar(50) DEFAULT NULL,
  `OFF_PIC1` varchar(100) DEFAULT NULL,
  `OFF_PIC2` varchar(100) DEFAULT NULL,
  `OFF_PIC3` varchar(100) DEFAULT NULL,
  `OFF_PIC4` varchar(100) DEFAULT NULL,
  `OFF_PIC5` varchar(100) DEFAULT NULL,
  `ON_OPENYN` varchar(1) DEFAULT NULL,
  `OFF_OPENYN` varchar(1) DEFAULT NULL,
  `OFF_MOVIE_PAYMENT` varchar(50) DEFAULT NULL,
  `TITLE` varchar(4000) DEFAULT NULL,
  `OFF_TITLE` varchar(500) DEFAULT NULL,
  `PROFILE_SUMMARY` varchar(2000) DEFAULT NULL,
  `BOOK_LOG_SUMMARY` varchar(2000) DEFAULT NULL,
  `JOIN_CHANNEL` varchar(10) DEFAULT NULL,
  `JOB` varchar(10) DEFAULT NULL,
  `EXAM_REQ` varchar(10) DEFAULT NULL,
  `F_CAT_CD` varchar(50) DEFAULT NULL,
  `F_AREA` varchar(55) DEFAULT NULL,
  `S_CAT_CD` varchar(50) DEFAULT NULL,
  `S_AREA` varchar(55) DEFAULT NULL,
  `INFO_REQ` varchar(20) DEFAULT NULL,
  `EVENT_REQ` varchar(20) DEFAULT NULL,
  `SBJ_REQ` varchar(10) DEFAULT NULL,
  `EVENT_REQ_ETC` varchar(100) DEFAULT NULL,
  `ISOK_SMS` varchar(1) DEFAULT NULL,
  `ISOK_EMAIL` varchar(1) DEFAULT NULL,
  `COOP_CD` varchar(10) DEFAULT NULL,
  `ON_URL` varchar(500) DEFAULT NULL,
  `OFF_URL` varchar(500) DEFAULT NULL,
  `PIC5` varchar(100) DEFAULT NULL,
  `BRD_YN` varchar(1) DEFAULT NULL,
  `OFF_BRD_YN` varchar(1) DEFAULT NULL,
  `PROF_HTML` varchar(2000) DEFAULT NULL,
  `REFERRAL_YN` varchar(1) DEFAULT NULL,
  `PRF_BRD_OF` varchar(1) DEFAULT NULL,
  `PRF_BRD_ON` varchar(1) DEFAULT NULL,
  `MACADDRESS_YN` varchar(1) DEFAULT NULL,
  `TEACHERONOFF_YN` varchar(1) DEFAULT NULL,
  `PRF_ONPIC1` varchar(100) DEFAULT NULL,
  `PRF_ONPIC2` varchar(100) DEFAULT NULL,
  `PRF_ONPIC3` varchar(100) DEFAULT NULL,
  `PRF_OFFPIC1` varchar(100) DEFAULT NULL,
  `PRF_OFFPIC2` varchar(100) DEFAULT NULL,
  `PRF_OFFPIC3` varchar(100) DEFAULT NULL,
  `PRF_LISTONBANNER` varchar(100) DEFAULT NULL,
  `PRF_LISTOFFBANNER` varchar(100) DEFAULT NULL,
  `PRF_TOPONIMG` varchar(100) DEFAULT NULL,
  `PRF_TOPOFFIMG` varchar(100) DEFAULT NULL,
  `U_AREA` varchar(2) DEFAULT NULL,
  `REMARK` varchar(2000) DEFAULT NULL,
  `MEMO` varchar(2000) DEFAULT NULL,
  `PROFILE` varchar(2000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_ma_member_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_ma_member_category` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `CATEGORY_CODE` varchar(20) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `OFF_SEQ` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_ma_member_main_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_ma_member_main_category` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `CATEGORY_CODE` varchar(20) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `SUBJECT_CD` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_ma_member_prf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_ma_member_prf` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NM` varchar(50) DEFAULT NULL,
  `USER_NICKNM` varchar(100) DEFAULT NULL,
  `USER_POSITION` varchar(100) DEFAULT NULL,
  `SEX` varchar(1) DEFAULT NULL,
  `USER_ROLE` varchar(20) DEFAULT NULL,
  `ADMIN_ROLE` varchar(20) DEFAULT NULL,
  `USER_PWD` varchar(100) DEFAULT NULL,
  `BIRTH_DAY` varchar(8) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL,
  `ZIP_CODE` varchar(10) DEFAULT NULL,
  `ADDRESS1` varchar(200) DEFAULT NULL,
  `ADDRESS2` varchar(200) DEFAULT NULL,
  `CATEGORY_CODE` varchar(20) DEFAULT NULL,
  `USER_POINT` varchar(50) DEFAULT NULL,
  `REMARK` longblob DEFAULT NULL,
  `MEMO` longblob DEFAULT NULL,
  `PAYMENT` varchar(50) DEFAULT NULL,
  `PIC1` varchar(100) DEFAULT NULL,
  `PIC2` varchar(100) DEFAULT NULL,
  `PIC3` varchar(100) DEFAULT NULL,
  `PIC4` varchar(100) DEFAULT NULL,
  `PROFILE` longblob DEFAULT NULL,
  `ACCOUNT` varchar(100) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `OFF_PAYMENT` varchar(50) DEFAULT NULL,
  `OFF_PROFILE` longblob DEFAULT NULL,
  `OFF_PIC1` varchar(100) DEFAULT NULL,
  `OFF_PIC2` varchar(100) DEFAULT NULL,
  `OFF_PIC3` varchar(100) DEFAULT NULL,
  `OFF_PIC4` varchar(100) DEFAULT NULL,
  `OFF_PIC5` varchar(100) DEFAULT NULL,
  `ON_OPENYN` varchar(1) DEFAULT NULL,
  `OFF_OPENYN` varchar(1) DEFAULT NULL,
  `OFF_MOVIE_PAYMENT` varchar(50) DEFAULT NULL,
  `TITLE` varchar(4000) DEFAULT NULL,
  `BOOK_LOG` longblob DEFAULT NULL,
  `YPLAN` longblob DEFAULT NULL,
  `LECINFO` longblob DEFAULT NULL,
  `OFF_TITLE` varchar(4000) DEFAULT NULL,
  `OFF_YPLAN` longblob DEFAULT NULL,
  `OFF_LECINFO` longblob DEFAULT NULL,
  `PROFILE_SUMMARY` varchar(4000) DEFAULT NULL,
  `BOOK_LOG_SUMMARY` varchar(4000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_ma_member_series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_ma_member_series` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `SERIES_CD` varchar(20) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL,
  `OFF_SEQ` bigint(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_ma_member_subject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_ma_member_subject` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `SUBJECT_CD` varchar(50) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_main_category_subject_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_main_category_subject_order` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `CATEGORY_CODE` varchar(50) DEFAULT NULL,
  `SUBJECT_CD` varchar(50) DEFAULT NULL,
  `IDX` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_mileage_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_mileage_history` (
  `IDX` bigint(20) DEFAULT NULL,
  `USERID` varchar(30) DEFAULT NULL,
  `POINT` bigint(20) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `MGNTNO` varchar(20) DEFAULT NULL,
  `REGDATE` date DEFAULT NULL,
  `COMMENT1` varchar(200) DEFAULT NULL,
  `MANAGER` varchar(20) DEFAULT NULL,
  `SITE` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_movie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_movie` (
  `MOVIE_NO` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `MOVIE_NAME` varchar(300) DEFAULT NULL,
  `MOVIE_DESC` varchar(300) DEFAULT NULL,
  `MOVIE_URL` varchar(800) DEFAULT NULL,
  `MOVIE_FILENAME1` varchar(500) DEFAULT NULL,
  `MP4_URL` varchar(800) DEFAULT NULL,
  `MOVIE_FILENAME2` varchar(500) DEFAULT NULL,
  `MOVIE_FILENAME3` varchar(500) DEFAULT NULL,
  `MOVIE_DATA_FILE_YN` varchar(1) DEFAULT NULL,
  `MOVIE_DATA_FILENAME` varchar(500) DEFAULT NULL,
  `MOVIE_TIME` bigint(20) DEFAULT NULL,
  `MOVIE_ORDER1` bigint(20) DEFAULT NULL,
  `MOVIE_ORDER2` bigint(20) DEFAULT NULL,
  `MOVIE_FREE_FLAG` varchar(1) DEFAULT NULL,
  `PMP_URL` varchar(800) DEFAULT NULL,
  `PMP_FILENAME` varchar(500) DEFAULT NULL,
  `STOP` varchar(1) DEFAULT NULL,
  `WIDE_URL` varchar(800) DEFAULT NULL,
  `MOVIE_FILENAME4` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_mylecture`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_mylecture` (
  `USERID` varchar(30) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `PACKAGE_NO` varchar(30) DEFAULT NULL,
  `LECTURE_NO` varchar(30) DEFAULT NULL,
  `START_DATE` date DEFAULT NULL,
  `END_DATE` date DEFAULT NULL,
  `PERIOD` bigint(20) DEFAULT NULL,
  `STUDY_PERCENT` bigint(20) DEFAULT NULL,
  `STOP_LECTURE` varchar(1) DEFAULT NULL,
  `FREE_ID` varchar(30) DEFAULT NULL,
  `PLUS_BUY` bigint(20) DEFAULT NULL,
  `PLAYYN` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `ADD_LENGTH` bigint(20) DEFAULT NULL,
  `FIRSTSTART_DATE` date DEFAULT NULL,
  `PARENT_ORDERNO` varchar(20) DEFAULT NULL,
  `GIFT_YN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_mylecture_pause`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_mylecture_pause` (
  `USER_ID` varchar(20) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `PACKAGE_NO` varchar(30) DEFAULT NULL,
  `LECTURE_NO` varchar(30) DEFAULT NULL,
  `MYLECTURE_PAUSED` varchar(1) DEFAULT NULL,
  `MYLECTURE_PAUSED_COUNT` bigint(20) DEFAULT NULL,
  `MYLECTURE_PAUSED_PERIOD` bigint(20) DEFAULT NULL,
  `MYLECTURE_PAUSED_DATE1` date DEFAULT NULL,
  `MYLECTURE_PAUSED_PERIOD1` bigint(20) DEFAULT NULL,
  `MYLECTURE_PAUSED_DATE2` date DEFAULT NULL,
  `MYLECTURE_PAUSED_PERIOD2` bigint(20) DEFAULT NULL,
  `MYLECTURE_PAUSED_DATE3` date DEFAULT NULL,
  `MYLECTURE_PAUSED_PERIOD3` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_mymovie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_mymovie` (
  `USERID` varchar(30) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `PACKAGE_NO` varchar(30) DEFAULT NULL,
  `LECTURE_NO` varchar(30) DEFAULT NULL,
  `MOVIE_NO` bigint(20) DEFAULT NULL,
  `CURR_TIME` bigint(20) DEFAULT NULL,
  `TOTAL_TIME` bigint(20) DEFAULT NULL,
  `STUDY_PERCENT` bigint(20) DEFAULT NULL,
  `STUDY_TIME` bigint(20) DEFAULT NULL,
  `TOTAL_BAESU` bigint(20) DEFAULT NULL,
  `BAESU_TIME` bigint(20) DEFAULT NULL,
  `LAST_POSITION_TIME` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_note_send_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_note_send_info` (
  `NOTEID` bigint(20) DEFAULT NULL,
  `FROM_USERID` varchar(30) DEFAULT NULL,
  `SEND_DT` date DEFAULT NULL,
  `SEND_ID` varchar(30) DEFAULT NULL,
  `CONT` varchar(4000) DEFAULT NULL,
  `READ_YN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_approvals` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `PRICE` bigint(20) DEFAULT NULL,
  `ADDPRICE` bigint(20) DEFAULT NULL,
  `PAYCODE` varchar(6) DEFAULT NULL,
  `ACCTNOCODE` varchar(6) DEFAULT NULL,
  `PAYNAME` varchar(50) DEFAULT NULL,
  `POINT` bigint(20) DEFAULT NULL,
  `RETURNVALUE` varchar(2000) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `BANNER_NAME` varchar(40) DEFAULT NULL,
  `REPRICE` bigint(20) DEFAULT NULL,
  `REPRICEDATE` date DEFAULT NULL,
  `ORDERURL` varchar(10) DEFAULT NULL,
  `VCDBANK` varchar(2) DEFAULT NULL,
  `VACCT` varchar(30) DEFAULT NULL,
  `VACCT_NAME` varchar(30) DEFAULT NULL,
  `REFUND_POINT` bigint(20) DEFAULT NULL,
  `PRICE_CARD` bigint(20) DEFAULT NULL,
  `PRICE_CASH` bigint(20) DEFAULT NULL,
  `PRICE_BANK` bigint(20) DEFAULT NULL,
  `PRICE_UNPAID` bigint(20) DEFAULT NULL,
  `PRICE_DISCOUNT` bigint(20) DEFAULT NULL,
  `PRICE_DISCOUNT_TYPE` varchar(10) DEFAULT NULL,
  `PRICE_DISCOUNT_REASON` varchar(500) DEFAULT NULL,
  `CARD_NAME` varchar(40) DEFAULT NULL,
  `DUE_DT` date DEFAULT NULL,
  `TID` varchar(50) DEFAULT NULL,
  `MEMO` varchar(2000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_box`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_box` (
  `BOX_CD` varchar(10) DEFAULT NULL,
  `BOX_NM` varchar(200) DEFAULT NULL,
  `BOX_COUNT` bigint(20) DEFAULT NULL,
  `BOX_PRICE` bigint(20) DEFAULT NULL,
  `DEPOSIT` bigint(20) DEFAULT NULL,
  `ROW_COUNT` bigint(20) DEFAULT NULL,
  `ROW_NUM` bigint(20) DEFAULT NULL,
  `UPDATE_DT` date DEFAULT NULL,
  `UPDATE_ID` varchar(30) DEFAULT NULL,
  `START_NUM` bigint(20) DEFAULT NULL,
  `END_NUM` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_box_num`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_box_num` (
  `BOX_CD` varchar(10) DEFAULT NULL,
  `BOX_NUM` bigint(20) DEFAULT NULL,
  `USERID` varchar(30) DEFAULT NULL,
  `BOX_FLAG` varchar(1) DEFAULT NULL,
  `UPDATE_DT` date DEFAULT NULL,
  `UPDATE_ID` varchar(30) DEFAULT NULL,
  `RENT_SEQ` bigint(20) DEFAULT NULL,
  `RENT_MEMO` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_box_rent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_box_rent` (
  `BOX_CD` varchar(10) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL,
  `BOX_NUM` bigint(20) DEFAULT NULL,
  `USERID` varchar(30) DEFAULT NULL,
  `RENT_START` date DEFAULT NULL,
  `RENT_END` date DEFAULT NULL,
  `DEPOSIT` bigint(20) DEFAULT NULL,
  `DEPOSIT_YN` varchar(20) DEFAULT NULL,
  `EXTEND_YN` varchar(20) DEFAULT NULL,
  `KEY_YN` varchar(20) DEFAULT NULL,
  `UPDATE_DT` date DEFAULT NULL,
  `UPDATE_ID` varchar(30) DEFAULT NULL,
  `RENT_TYPE` varchar(10) DEFAULT NULL,
  `ORDER_ID` varchar(20) DEFAULT NULL,
  `PAY_GUBUN` varchar(20) DEFAULT NULL,
  `DEPOSIT_REFUND` bigint(20) DEFAULT NULL,
  `RENT_MEMO` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_cc_cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_cc_cart` (
  `SEQ` bigint(20) DEFAULT NULL,
  `USER_ID` varchar(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `KIND_TYPE` varchar(1) DEFAULT NULL,
  `RSC_ID` varchar(30) DEFAULT NULL,
  `RSC_TYPE` varchar(1) DEFAULT NULL,
  `MOVIE_TYPE` varchar(2) DEFAULT NULL,
  `REGDATE` date DEFAULT NULL,
  `REPRICE` bigint(20) DEFAULT NULL,
  `PACKAGE_PERIOD` bigint(20) DEFAULT NULL,
  `SDATE` varchar(50) DEFAULT NULL,
  `EDATE` varchar(50) DEFAULT NULL,
  `BOOK_COUNT` bigint(20) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_cc_j_cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_cc_j_cart` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `MST_LECCODE` varchar(30) DEFAULT NULL,
  `UPDATE_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `PRICE` bigint(20) DEFAULT NULL,
  `KIND_TYPE` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_choice_jong_no`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_choice_jong_no` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `NO` bigint(20) DEFAULT NULL,
  `CATEGORY_CD` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_lec_bridge`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_lec_bridge` (
  `SEQ` bigint(20) DEFAULT NULL,
  `BRIDGE_LECCODE` varchar(30) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_lec_jong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_lec_jong` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `MST_LECCODE` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `SORT` bigint(20) DEFAULT NULL,
  `GUBUN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_lec_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_lec_mst` (
  `SEQ` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `CATEGORY_CD` varchar(20) DEFAULT NULL,
  `LEARNING_CD` varchar(20) DEFAULT NULL,
  `SUBJECT_TYPE` varchar(1) DEFAULT NULL,
  `SUBJECT_GUBUN` varchar(1) DEFAULT NULL,
  `SUBJECT_MEMBER_CNT` bigint(20) DEFAULT NULL,
  `SUBJECT_TEACHER` varchar(30) DEFAULT NULL,
  `SUBJECT_TEACHER_PAYMENT` varchar(50) DEFAULT NULL,
  `SUBJECT_SJT_CD` varchar(50) DEFAULT NULL,
  `SUBJECT_TITLE` varchar(1000) DEFAULT NULL,
  `SUBJECT_DESC` longblob DEFAULT NULL,
  `SUBJECT_KEYWORD` varchar(600) DEFAULT NULL,
  `SUBJECT_OPEN_DATE` varchar(8) DEFAULT NULL,
  `LEC_SCHEDULE` varchar(20) DEFAULT NULL,
  `WEEK1` varchar(1) DEFAULT NULL,
  `WEEK2` varchar(1) DEFAULT NULL,
  `WEEK3` varchar(1) DEFAULT NULL,
  `WEEK4` varchar(1) DEFAULT NULL,
  `WEEK5` varchar(1) DEFAULT NULL,
  `WEEK6` varchar(1) DEFAULT NULL,
  `WEEK7` varchar(1) DEFAULT NULL,
  `SUBJECT_DISCOUNT` bigint(20) DEFAULT NULL,
  `SUBJECT_PRICE` bigint(20) DEFAULT NULL,
  `SUBJECT_REAL_PRICE` bigint(20) DEFAULT NULL,
  `SUBJECT_SUMNAIL` varchar(1000) DEFAULT NULL,
  `SUBJECT_ISUSE` varchar(1) DEFAULT NULL,
  `LEC_TYPE_CHOICE` varchar(1) DEFAULT NULL,
  `LEC_GUBUN` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `SUBJECT_TEACHER_MOVIE_PAYMENT` varchar(50) DEFAULT NULL,
  `PLAN` longblob DEFAULT NULL,
  `REC_GUBUN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_lecture_date`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_lecture_date` (
  `LECCODE` varchar(30) DEFAULT NULL,
  `NUM` bigint(20) DEFAULT NULL,
  `LEC_DATE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_mylecture`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_mylecture` (
  `USERID` varchar(30) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `PACKAGE_NO` varchar(20) DEFAULT NULL,
  `LECTURE_NO` varchar(20) DEFAULT NULL,
  `START_DATE` date DEFAULT NULL,
  `END_DATE` date DEFAULT NULL,
  `PERIOD` bigint(20) DEFAULT NULL,
  `STUDY_PERCENT` bigint(20) DEFAULT NULL,
  `STOP_LECTURE` varchar(1) DEFAULT NULL,
  `FREE_ID` varchar(30) DEFAULT NULL,
  `PLUS_BUY` bigint(20) DEFAULT NULL,
  `PLAYYN` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `ADD_LENGTH` bigint(20) DEFAULT NULL,
  `FIRSTSTART_DATE` date DEFAULT NULL,
  `REALPRICE` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_order_mgnt_no`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_order_mgnt_no` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `MGNTNO` varchar(20) DEFAULT NULL,
  `ISCANCEL` bigint(20) DEFAULT NULL,
  `CNT` bigint(20) DEFAULT NULL,
  `PRICE` bigint(20) DEFAULT NULL,
  `STATUSCODE` varchar(6) DEFAULT NULL,
  `CANCELDATE` date DEFAULT NULL,
  `CONFIRMDATE` date DEFAULT NULL,
  `SDATE` varchar(10) DEFAULT NULL,
  `ISCONFIRM` date DEFAULT NULL,
  `REPAYMENT_DAY` date DEFAULT NULL,
  `REPAYMENT_PRICE` bigint(20) DEFAULT NULL,
  `MEMO` varchar(4000) DEFAULT NULL,
  `CONFIRMID` varchar(20) DEFAULT NULL,
  `WMV_PMP` varchar(10) DEFAULT NULL,
  `USER_PACKAGE_FLAG` varchar(1) DEFAULT NULL,
  `ORDERURL` varchar(30) DEFAULT NULL,
  `OPEN_ADMIN_ID` varchar(30) DEFAULT NULL,
  `DISCOUNTPER` bigint(20) DEFAULT NULL,
  `SPO` varchar(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `PTYPE` varchar(2) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_orders` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NM` varchar(50) DEFAULT NULL,
  `ZIP_CODE` varchar(7) DEFAULT NULL,
  `ADDRESS1` varchar(200) DEFAULT NULL,
  `EMAIL` varchar(50) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `TID` varchar(30) DEFAULT NULL,
  `IPDATE` date DEFAULT NULL,
  `FREE_MOVIE` varchar(10) DEFAULT NULL,
  `OFF_LINE` varchar(1) DEFAULT NULL,
  `ADDRESS2` varchar(200) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `ORDER_TYPE` varchar(5) DEFAULT NULL,
  `TICKET_PRINT_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_plus_ca_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_plus_ca_book` (
  `IDX` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `RSC_ID` varchar(20) DEFAULT NULL,
  `FLAG` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_refund`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_refund` (
  `IDX` bigint(20) DEFAULT NULL,
  `ORDER_ID` varchar(20) DEFAULT NULL,
  `REFUND_PAY` bigint(20) DEFAULT NULL,
  `SET_YN` varchar(1) DEFAULT NULL,
  `SET_DATE` date DEFAULT NULL,
  `REG_DATE` date NOT NULL,
  `ACC_BANK_NAME` varchar(30) DEFAULT NULL,
  `ACC_BANK_NUM` varchar(30) DEFAULT NULL,
  `REFUND_CARD` bigint(20) DEFAULT NULL,
  `REFUND_CASH` bigint(20) DEFAULT NULL,
  `REFUND_MEMO` varchar(300) DEFAULT NULL,
  `ACC_BANK_DEPOSITOR` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_room` (
  `ROOM_CD` varchar(10) DEFAULT NULL,
  `ROOM_NM` varchar(200) DEFAULT NULL,
  `ROOM_COUNT` bigint(20) DEFAULT NULL,
  `UPDATE_DT` date DEFAULT NULL,
  `UPDATE_ID` varchar(30) DEFAULT NULL,
  `START_NUM` bigint(20) DEFAULT NULL,
  `END_NUM` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_off_room_num`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_off_room_num` (
  `ROOM_CD` varchar(10) DEFAULT NULL,
  `ROOM_NUM` bigint(20) DEFAULT NULL,
  `USERID` varchar(30) DEFAULT NULL,
  `ROOM_FLAG` varchar(1) DEFAULT NULL,
  `UPDATE_DT` date DEFAULT NULL,
  `UPDATE_ID` varchar(30) DEFAULT NULL,
  `RENT_SEQ` bigint(20) DEFAULT NULL,
  `RENT_MEMO` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_order_mgnt_no`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_order_mgnt_no` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `MGNTNO` varchar(20) DEFAULT NULL,
  `ISCANCEL` bigint(20) DEFAULT NULL,
  `CNT` bigint(20) DEFAULT NULL,
  `PRICE` bigint(20) DEFAULT NULL,
  `STATUSCODE` varchar(6) DEFAULT NULL,
  `CANCELDATE` date DEFAULT NULL,
  `CONFIRMDATE` date DEFAULT NULL,
  `SDATE` varchar(10) DEFAULT NULL,
  `ISCONFIRM` date DEFAULT NULL,
  `REPAYMENT_DAY` date DEFAULT NULL,
  `REPAYMENT_PRICE` bigint(20) DEFAULT NULL,
  `MEMO` varchar(4000) DEFAULT NULL,
  `CONFIRMID` varchar(20) DEFAULT NULL,
  `WMV_PMP` varchar(10) DEFAULT NULL,
  `USER_PACKAGE_FLAG` varchar(1) DEFAULT NULL,
  `ORDERURL` varchar(30) DEFAULT NULL,
  `OPEN_ADMIN_ID` varchar(30) DEFAULT NULL,
  `DISCOUNTPER` bigint(20) DEFAULT NULL,
  `SPO` varchar(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `PTYPE` varchar(2) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL,
  `GIFT_YN` varchar(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_order_yearpackage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_order_yearpackage` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `PACKAGE_NO` varchar(30) DEFAULT NULL,
  `SUBJECT_TEACHER` varchar(50) DEFAULT NULL,
  `LEARNING_CD` varchar(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `START_DATE` date DEFAULT NULL,
  `END_DATE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_orders` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NM` varchar(50) DEFAULT NULL,
  `ZIP_CODE` varchar(7) DEFAULT NULL,
  `ADDRESS1` varchar(200) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `TID` varchar(30) DEFAULT NULL,
  `IPDATE` date DEFAULT NULL,
  `FREE_MOVIE` varchar(10) DEFAULT NULL,
  `OFF_LINE` varchar(1) DEFAULT NULL,
  `ADDRESS2` varchar(200) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_paysettlement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_paysettlement` (
  `SEQ` bigint(20) DEFAULT NULL,
  `ONOFF` varchar(4) DEFAULT NULL,
  `TEACHER_ID` varchar(30) DEFAULT NULL,
  `TEACHER_NM` varchar(50) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `PREAMOUNT` bigint(20) DEFAULT NULL,
  `AMOUNT` bigint(20) DEFAULT NULL,
  `TEACHERAMOUNT` bigint(20) DEFAULT NULL,
  `DEDUCTAMOUNT` bigint(20) DEFAULT NULL,
  `CALCUCRITERIA_DTYPE` varchar(4) DEFAULT NULL,
  `CALCUCRITERIA_DVALUE` bigint(20) DEFAULT NULL,
  `CALCUCRITERIA_JTYPE` varchar(4) DEFAULT NULL,
  `CALCUCRITERIA_JVALUE` bigint(20) DEFAULT NULL,
  `TEACHERPAY` bigint(20) DEFAULT NULL,
  `WITHHOLDRATIO` bigint(20) DEFAULT NULL,
  `WITHHOLDTAX` bigint(20) DEFAULT NULL,
  `DEDUCTAMOUNT_ETC` bigint(20) DEFAULT NULL,
  `ADJUSTAMOUNT` bigint(20) DEFAULT NULL,
  `SETTLE_DT` date DEFAULT NULL,
  `REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_paysettlement_add`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_paysettlement_add` (
  `TEACHER_ID` varchar(30) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `ADDTYPE` varchar(2) DEFAULT NULL,
  `ADDMEMO` varchar(100) DEFAULT NULL,
  `ADDMONEY` bigint(20) DEFAULT NULL,
  `ADDREG_DT` date DEFAULT NULL,
  `ADDUPD_DT` date DEFAULT NULL,
  `ETCYN` varchar(2) DEFAULT NULL,
  `PSA_NO` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_plus_ca_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_plus_ca_book` (
  `IDX` bigint(20) DEFAULT NULL,
  `LECCODE` varchar(30) DEFAULT NULL,
  `RSC_ID` varchar(20) DEFAULT NULL,
  `FLAG` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_pmp_downlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_pmp_downlog` (
  `IDX` bigint(20) DEFAULT NULL,
  `USERID` varchar(30) DEFAULT NULL,
  `CONTENTID` varchar(20) DEFAULT NULL,
  `DOWNLOGINFO` varchar(60) DEFAULT NULL,
  `PMP_REGDATE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_popup_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_popup_info` (
  `NO` varchar(20) DEFAULT NULL,
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `CATEGORY_CODE` varchar(30) DEFAULT NULL,
  `START_DATE` varchar(8) DEFAULT NULL,
  `START_TIME` varchar(2) DEFAULT NULL,
  `END_DATE` varchar(8) DEFAULT NULL,
  `END_TIME` varchar(2) DEFAULT NULL,
  `OPEN_YN` varchar(1) DEFAULT NULL,
  `HIT` bigint(20) DEFAULT NULL,
  `TITLE` varchar(500) DEFAULT NULL,
  `POPUP_IMG` varchar(100) DEFAULT NULL,
  `THUMBNAIL` varchar(100) DEFAULT NULL,
  `LINK_ADDR` varchar(500) DEFAULT NULL,
  `LINK_TARGET` varchar(10) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `POPUP_IMG_NM` varchar(100) DEFAULT NULL,
  `THUMBNAIL_NM` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_renew_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_renew_history` (
  `ORDERNO` varchar(20) DEFAULT NULL,
  `OLD_PACKAGE_NO` varchar(20) DEFAULT NULL,
  `NEW_PACKAGE_NO` varchar(20) DEFAULT NULL,
  `REGDATE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_seq_orderno`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_seq_orderno` (
  `GUBUN` varchar(3) DEFAULT NULL,
  `GYEAR` bigint(20) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_seqoff_orderno`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_seqoff_orderno` (
  `GUBUN` varchar(3) DEFAULT NULL,
  `GYEAR` bigint(20) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_series_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_series_info` (
  `SRS_CD` varchar(20) DEFAULT NULL,
  `SRS_NM` varchar(50) DEFAULT NULL,
  `ORDR` bigint(20) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `P_SRSCD` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_sg_menu_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_sg_menu_mst` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `MENU_ID` varchar(20) DEFAULT NULL,
  `MENU_NM` varchar(50) DEFAULT NULL,
  `MENU_SEQ` varchar(100) DEFAULT NULL,
  `MENU_URL` varchar(150) DEFAULT NULL,
  `P_MENUID` varchar(20) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `TARGET` varchar(20) DEFAULT NULL,
  `MENU_INFO` varchar(255) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_sg_menu_mst2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_sg_menu_mst2` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `MENU_ID` varchar(20) DEFAULT NULL,
  `MENU_NM` varchar(50) DEFAULT NULL,
  `MENU_SEQ` varchar(100) DEFAULT NULL,
  `MENU_URL` varchar(250) DEFAULT NULL,
  `P_MENUID` varchar(20) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `TARGET` varchar(20) DEFAULT NULL,
  `MENU_INFO` varchar(255) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `CODE` varchar(3) DEFAULT NULL,
  `TOP_IMG_URL` varchar(200) DEFAULT NULL,
  `LEFT_IMG_URL` varchar(200) DEFAULT NULL,
  `TITL_IMG_URL` varchar(200) DEFAULT NULL,
  `SUBTITL_IMG_URL` varchar(200) DEFAULT NULL,
  `PBLC_YN` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_sg_site`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_sg_site` (
  `ONOFF_DIV` varchar(1) DEFAULT NULL,
  `SITE_ID` varchar(20) DEFAULT NULL,
  `SITE_NM` varchar(50) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_sg_site_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_sg_site_menu` (
  `SITE_ID` varchar(20) DEFAULT NULL,
  `MENU_ID` varchar(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_stat_prf`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_stat_prf` (
  `S_YEAR` varchar(4) DEFAULT NULL,
  `S_MONTH` varchar(2) DEFAULT NULL,
  `S_TYPE` varchar(2) DEFAULT NULL,
  `PRF_ID` varchar(20) DEFAULT NULL,
  `SALE_CNT` bigint(20) DEFAULT NULL,
  `REFUND_CNT` bigint(20) DEFAULT NULL,
  `SALE_SUM` bigint(20) DEFAULT NULL,
  `REFUND_SUM` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_subject_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_subject_category` (
  `SUBJECT_CD` varchar(50) DEFAULT NULL,
  `CATEGORY_CODE` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_subject_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_subject_info` (
  `SUBJECT_CD` varchar(50) DEFAULT NULL,
  `SUBJECT_NM` varchar(500) DEFAULT NULL,
  `SUBJECT_SHORT_NM` varchar(60) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `USE_ON` varchar(1) DEFAULT NULL,
  `USE_OFF` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_subject_series`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_subject_series` (
  `SUBJECT_CD` varchar(50) DEFAULT NULL,
  `SERIES_CD` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tapprovals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tapprovals` (
  `TID` varchar(30) DEFAULT NULL,
  `IDENTYID` varchar(20) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `PAYMENTTARGETAMOUNT` bigint(20) DEFAULT NULL,
  `PAYMENTAMOUNT` bigint(20) DEFAULT NULL,
  `ADDDISCOUNTRATIO` bigint(20) DEFAULT NULL,
  `ADDDISCOUNTAMOUNT` bigint(20) DEFAULT NULL,
  `ADDDISCOUNTREASON` varchar(100) DEFAULT NULL,
  `PAYMENTDUEDATE` varchar(20) DEFAULT NULL,
  `PAYMENTSTATE` bigint(20) DEFAULT NULL,
  `PAYMENTTYPE` bigint(20) DEFAULT NULL,
  `CARDKIND` varchar(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date NOT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tattachfile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tattachfile` (
  `ATTACHFILEID` bigint(20) DEFAULT NULL,
  `FILENAME` varchar(250) DEFAULT NULL,
  `FILEPATH` varchar(250) DEFAULT NULL,
  `FILESIZE` varchar(11) DEFAULT NULL,
  `REGDATE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tboardtestclass`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tboardtestclass` (
  `BCONTENTID` bigint(20) DEFAULT NULL,
  `CLASSCODE` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tboardtestenv`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tboardtestenv` (
  `BOARDENVID` bigint(20) DEFAULT NULL,
  `BOARDTITLE` varchar(50) DEFAULT NULL,
  `DESCRIPTION` varchar(200) DEFAULT NULL,
  `BOARDTYPE` varchar(20) DEFAULT NULL,
  `HASREPLY` bigint(20) DEFAULT NULL,
  `HASCOMMENT` bigint(20) DEFAULT NULL,
  `REG_ID` varchar(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(20) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `LEVELUSER` bigint(20) DEFAULT NULL,
  `LEVELPROF` bigint(20) DEFAULT NULL,
  `LEVELADMIN` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tccsrssubjectinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tccsrssubjectinfo` (
  `ID` bigint(20) DEFAULT NULL,
  `CLASSCODE` varchar(20) DEFAULT NULL,
  `CLASSSERIESCODE` varchar(20) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `SUBJECTTYPEDIVISION` bigint(20) DEFAULT NULL,
  `SUBJECTORDER` bigint(20) DEFAULT NULL,
  `REG_ID` varchar(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(20) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tcommoncode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tcommoncode` (
  `ID` bigint(20) DEFAULT NULL,
  `CODE` varchar(20) DEFAULT NULL,
  `PARENTCODE` varchar(20) DEFAULT NULL,
  `CODENAME` varchar(40) DEFAULT NULL,
  `CODEDESC` varchar(100) DEFAULT NULL,
  `CODEVALUE` varchar(20) DEFAULT NULL,
  `CODERANK` bigint(20) DEFAULT NULL,
  `USEFLAG` bigint(20) DEFAULT NULL,
  `REG_ID` varchar(20) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(20) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_texamidseq`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_texamidseq` (
  `GUBUN` varchar(2) DEFAULT NULL,
  `IDTYPE` varchar(10) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_texamineeanswer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_texamineeanswer` (
  `ID` bigint(20) DEFAULT NULL,
  `IDENTYID` varchar(20) DEFAULT NULL,
  `ITEMID` bigint(20) DEFAULT NULL,
  `QUESTIONNUMBER` bigint(20) DEFAULT NULL,
  `MOCKCODE` varchar(20) DEFAULT NULL,
  `ANSWERNUMBER` varchar(200) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date NOT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `CORRECTYN` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_titem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_titem` (
  `ITEMID` bigint(20) DEFAULT NULL,
  `EXAMYEAR` bigint(20) DEFAULT NULL,
  `EXAMROUND` bigint(20) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `PROFCODE` varchar(20) DEFAULT NULL,
  `ENTRYNUM` bigint(20) DEFAULT NULL,
  `QUESTIONNUM` bigint(20) DEFAULT NULL,
  `QUESTIONREGISTRATIONOPTION` bigint(20) DEFAULT NULL,
  `OPENSTATE` bigint(20) DEFAULT NULL,
  `DELETEFLAG` bigint(20) DEFAULT NULL,
  `REG_ID` varchar(20) DEFAULT NULL,
  `REG_DT` date NOT NULL,
  `UPD_ID` varchar(20) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `FEE_PROF` varchar(5) DEFAULT NULL,
  `CODE_NM` varchar(150) DEFAULT NULL,
  `QUESTIONFID` bigint(20) DEFAULT NULL,
  `ANSWERFID` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_titempool`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_titempool` (
  `QUESTIONNUMBER` bigint(20) DEFAULT NULL,
  `ITEMID` bigint(20) DEFAULT NULL,
  `QUESTION` varchar(500) DEFAULT NULL,
  `QUESTIONFILEID` bigint(20) DEFAULT NULL,
  `ANSWEREXPLAIN` varchar(500) DEFAULT NULL,
  `ANSWEREXPLAINFILEID` bigint(20) DEFAULT NULL,
  `ANSWERNUMBER` varchar(200) DEFAULT NULL,
  `QUESTIONRANGE` bigint(20) DEFAULT NULL,
  `LEVELDIFFICULTY` bigint(20) DEFAULT NULL,
  `QUESTIONPATTERN` varchar(20) DEFAULT NULL,
  `USEFLAG` bigint(20) DEFAULT NULL,
  `REFERENCEEXAMYEAR` bigint(20) DEFAULT NULL,
  `REFERENCEEXAMROUND` bigint(20) DEFAULT NULL,
  `REFERENCEEXAMQUESTIONNUMBER` bigint(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date NOT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tm_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tm_admin` (
  `IDX` bigint(20) DEFAULT NULL,
  `ADMINID` varchar(30) DEFAULT NULL,
  `ADMINNAME` varchar(30) DEFAULT NULL,
  `DELETEFLAG` varchar(1) DEFAULT NULL,
  `REG_DT` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tm_board`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tm_board` (
  `IDX` bigint(20) DEFAULT NULL,
  `VOCCODE` varchar(20) DEFAULT NULL,
  `DUTYCODE` varchar(20) DEFAULT NULL,
  `CONTENT` varchar(4000) DEFAULT NULL,
  `REQUSERID` varchar(30) DEFAULT NULL,
  `REQUSERNAME` varchar(30) DEFAULT NULL,
  `REGUSERID` varchar(30) DEFAULT NULL,
  `REGUSERNAME` varchar(30) DEFAULT NULL,
  `REGDATE` date NOT NULL,
  `UPDDATE` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tm_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tm_coupon` (
  `CCODE` varchar(20) DEFAULT NULL,
  `CNAME` varchar(150) DEFAULT NULL,
  `CCONTENT` varchar(1000) DEFAULT NULL,
  `REGDATE` date NOT NULL,
  `REGTYPE` varchar(1) DEFAULT NULL,
  `REGPRICE` bigint(20) DEFAULT NULL,
  `EXPDATES` date DEFAULT NULL,
  `EXPDATEE` date NOT NULL,
  `EXPDAY` bigint(20) DEFAULT NULL,
  `TCLASS` varchar(20) DEFAULT NULL,
  `TCLASSCAT` bigint(20) DEFAULT NULL,
  `PUB_COUPON_GUBUN` varchar(2) DEFAULT NULL,
  `TERM` varchar(2) DEFAULT NULL,
  `DAN_JONG` varchar(1) DEFAULT NULL,
  `DAN_MENU` varchar(10) DEFAULT NULL,
  `SUBJECT` varchar(50) DEFAULT NULL,
  `TEACHER` varchar(30) DEFAULT NULL,
  `PRICE` bigint(20) DEFAULT NULL,
  `ADD_FLAG` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tm_mycoupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tm_mycoupon` (
  `IDX` bigint(20) DEFAULT NULL,
  `CCODE` varchar(20) DEFAULT NULL,
  `USERID` varchar(30) DEFAULT NULL,
  `REGDATE` date NOT NULL,
  `EXPDATES` date NOT NULL,
  `EXPDATEE` date NOT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `ORDERDATE` date DEFAULT NULL,
  `ORDERFLAG` varchar(1) DEFAULT NULL,
  `REG_ID` varchar(20) DEFAULT NULL,
  `EVENT_NO` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tm_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tm_users` (
  `IDX` bigint(20) DEFAULT NULL,
  `USERID` varchar(30) DEFAULT NULL,
  `USERNAME` varchar(30) DEFAULT NULL,
  `TEL` varchar(20) DEFAULT NULL,
  `PHONE` varchar(20) DEFAULT NULL,
  `EMAIL` varchar(50) DEFAULT NULL,
  `ADMUSERID` varchar(30) DEFAULT NULL,
  `ADMUSERNAME` varchar(20) DEFAULT NULL,
  `ALLOCDATE` date DEFAULT NULL,
  `USERTYPE` varchar(1) DEFAULT NULL,
  `ORIADMUSERID` varchar(30) DEFAULT NULL,
  `ORIADMUSERNAME` varchar(30) DEFAULT NULL,
  `ORIALLOCDATE` date DEFAULT NULL,
  `ORIUSERTYPE` varchar(1) DEFAULT NULL,
  `ALLOCADMIN` varchar(30) DEFAULT NULL,
  `DBSOUACE` varchar(20) DEFAULT NULL,
  `IDX_TMBOARD` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tmockclsclsseries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tmockclsclsseries` (
  `ID` bigint(20) DEFAULT NULL,
  `MOCKCODE` varchar(20) DEFAULT NULL,
  `CLASSSERIESCODE` varchar(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date NOT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tmockgrade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tmockgrade` (
  `ID` bigint(20) DEFAULT NULL,
  `IDENTYID` varchar(20) DEFAULT NULL,
  `MOCKCODE` varchar(20) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `CLASSCODE` varchar(20) DEFAULT NULL,
  `CLASSSERIESCODE` varchar(20) DEFAULT NULL,
  `ORIGINGRADE` bigint(20) DEFAULT NULL,
  `ADJUSTGRADE` bigint(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `ITEMID` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tmockregistration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tmockregistration` (
  `ID` bigint(20) DEFAULT NULL,
  `MOCKCODE` varchar(20) DEFAULT NULL,
  `MOCKNAME` varchar(50) DEFAULT NULL,
  `EXAMYEAR` bigint(20) DEFAULT NULL,
  `EXAMROUND` bigint(20) DEFAULT NULL,
  `OFFCLOSEPERSONNUMBER` bigint(20) DEFAULT NULL,
  `CLASSCODE` varchar(20) DEFAULT NULL,
  `EXAMSTARTTIME` varchar(20) DEFAULT NULL,
  `EXAMENDTIME` varchar(20) DEFAULT NULL,
  `EXAMPERIOD` bigint(20) DEFAULT NULL,
  `EXAMTIME` bigint(20) DEFAULT NULL,
  `RECEIPTSTARTTIME` varchar(20) DEFAULT NULL,
  `RECEIPTENDTIME` varchar(20) DEFAULT NULL,
  `EXAMCOST` bigint(20) DEFAULT NULL,
  `DISCOUNTRATIO` bigint(20) DEFAULT NULL,
  `SALEAMOUNTS` bigint(20) DEFAULT NULL,
  `USEFLAG` varchar(1) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `ISEXAMTYPEON` bigint(20) DEFAULT NULL,
  `ISEXAMTYPEOFF` bigint(20) DEFAULT NULL,
  `EXAMPERIODTYPE` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tmocksubject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tmocksubject` (
  `ID` bigint(20) DEFAULT NULL,
  `MOCKCODE` varchar(20) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `ITEMID` bigint(20) DEFAULT NULL,
  `SUBJECTORDER` bigint(20) DEFAULT NULL,
  `SUBJECTTYPEDIVISION` bigint(20) DEFAULT NULL,
  `SUBJECTPERIOD` bigint(20) DEFAULT NULL,
  `USEFLAG` bigint(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_top_mst`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_top_mst` (
  `SEQ` bigint(20) DEFAULT NULL,
  `MSTCODE` varchar(30) DEFAULT NULL,
  `SUBJECT_TEACHER` varchar(30) DEFAULT NULL,
  `SUBJECT_TITLE` varchar(1000) DEFAULT NULL,
  `SUBJECT_SJT_CD` varchar(50) DEFAULT NULL,
  `SUBJECT_DESC` longblob DEFAULT NULL,
  `SUBJECT_MEMO` longblob DEFAULT NULL,
  `SUBJECT_PERIOD` bigint(20) DEFAULT NULL,
  `LEC_SCHEDULE` varchar(50) DEFAULT NULL,
  `SUBJECT_OFF_OPEN_YEAR` varchar(4) DEFAULT NULL,
  `SUBJECT_OFF_OPEN_MONTH` varchar(2) DEFAULT NULL,
  `SUBJECT_OFF_OPEN_DAY` varchar(2) DEFAULT NULL,
  `SUBJECT_PRICE` bigint(20) DEFAULT NULL,
  `SUBJECT_OPTION` varchar(1000) DEFAULT NULL,
  `SUBJECT_VOD_DEFAULT_PATH` varchar(800) DEFAULT NULL,
  `SUBJECT_MP4_DEFAULT_PATH` varchar(800) DEFAULT NULL,
  `SUBJECT_PMP_DEFAULT_PATH` varchar(800) DEFAULT NULL,
  `MST_USE_YN` varchar(1) DEFAULT NULL,
  `REG_DT` date DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_torders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_torders` (
  `ID` bigint(20) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `IDENTYID` varchar(20) DEFAULT NULL,
  `EXAMCODE` varchar(20) DEFAULT NULL,
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NM` varchar(50) DEFAULT NULL,
  `RECEIPTTYPE` bigint(20) DEFAULT NULL,
  `EXAMTYPE` bigint(20) DEFAULT NULL,
  `CLASSCODE` varchar(20) DEFAULT NULL,
  `CLASSSERIESCODE` varchar(20) DEFAULT NULL,
  `ADDPOINT1` bigint(20) DEFAULT NULL,
  `ADDPOINT2` bigint(20) DEFAULT NULL,
  `ADDPOINT3` bigint(20) DEFAULT NULL,
  `PRINTFLAG` bigint(20) DEFAULT NULL,
  `PRINTUSER` varchar(20) DEFAULT NULL,
  `PRINTTIME` date DEFAULT NULL,
  `NOTE` varchar(500) DEFAULT NULL,
  `PAYMENTTARGETAMOUNT` bigint(20) DEFAULT NULL,
  `ADDDISCOUNTRATIO` bigint(20) DEFAULT NULL,
  `ADDDISCOUNTAMOUNT` bigint(20) DEFAULT NULL,
  `ADDDISCOUNTREASON` varchar(100) DEFAULT NULL,
  `PAYMENTDUEDATE` varchar(20) DEFAULT NULL,
  `PAYMENTSTATE` bigint(20) DEFAULT NULL,
  `EXAMSTATUS` bigint(20) DEFAULT NULL,
  `EXAMSTARTTIME` date DEFAULT NULL,
  `EXAMENDTIME` date DEFAULT NULL,
  `EXAMSPARETIME` bigint(20) DEFAULT NULL,
  `EXAMIP` varchar(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date NOT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tsubjectarea`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tsubjectarea` (
  `ID` bigint(20) DEFAULT NULL,
  `SUBJECT_CD` varchar(20) DEFAULT NULL,
  `SUBJECTAREA` varchar(80) DEFAULT NULL,
  `AREAORDER` bigint(20) DEFAULT NULL,
  `USEFLAG` bigint(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` varchar(20) DEFAULT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_tuserchoicesubject`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_tuserchoicesubject` (
  `ID` bigint(20) DEFAULT NULL,
  `ITEMID` bigint(20) DEFAULT NULL,
  `ORDERNO` varchar(20) DEFAULT NULL,
  `IDENTYID` varchar(20) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date NOT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `EXAMSTATUS` bigint(20) DEFAULT NULL,
  `SUBJECTORDER` bigint(20) DEFAULT NULL,
  `SUBJECTTYPEDIVISION` bigint(20) DEFAULT NULL,
  `EXAMSSTARTTIME` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_twronganswernote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_twronganswernote` (
  `ID` bigint(20) DEFAULT NULL,
  `IDENTYID` varchar(20) DEFAULT NULL,
  `ITEMID` bigint(20) DEFAULT NULL,
  `QUESTIONNUMBER` bigint(20) DEFAULT NULL,
  `NOTE` varchar(500) DEFAULT NULL,
  `REG_ID` varchar(30) DEFAULT NULL,
  `REG_DT` date NOT NULL,
  `UPD_ID` varchar(30) DEFAULT NULL,
  `UPD_DT` date DEFAULT NULL,
  `MOCKCODE` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_zipcode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_zipcode` (
  `ZIPCD` varchar(7) DEFAULT NULL,
  `SIDO` varchar(500) DEFAULT NULL,
  `GUGUN` varchar(500) DEFAULT NULL,
  `DONG` varchar(500) DEFAULT NULL,
  `RI` varchar(500) DEFAULT NULL,
  `DO` varchar(100) DEFAULT NULL,
  `BUNJI` varchar(500) DEFAULT NULL,
  `JUSO` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tb_zipcode_new`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_zipcode_new` (
  `ZIPCD` varchar(7) DEFAULT NULL,
  `SIDO` varchar(500) DEFAULT NULL,
  `GUGUN` varchar(500) DEFAULT NULL,
  `DONG` varchar(500) DEFAULT NULL,
  `RI` varchar(500) DEFAULT NULL,
  `DO` varchar(500) DEFAULT NULL,
  `BUNJI` varchar(500) DEFAULT NULL,
  `JUSO` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tbl_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_users` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `USER_NM` varchar(50) DEFAULT NULL,
  `USER_PWD` varchar(4000) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tm_device_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tm_device_history` (
  `USER_ID` varchar(30) DEFAULT NULL,
  `DEVICE_ID` varchar(200) DEFAULT NULL,
  `DEVICE_GUBUN` varchar(200) DEFAULT NULL,
  `PC_USEYN` varchar(1) DEFAULT NULL,
  `PC_REG_DT` date DEFAULT NULL,
  `PC_CANCEL_DT` date DEFAULT NULL,
  `DEVICE_DESC` varchar(4000) DEFAULT NULL,
  `ADMIN_ID` varchar(30) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL,
  `MOBILE_USEYN` varchar(1) DEFAULT NULL,
  `MOBILE_CANCEL_DT` date DEFAULT NULL,
  `MOBILE_REG_DT` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tm_ist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tm_ist` (
  `ID` varchar(20) DEFAULT NULL,
  `NAME` varchar(20) DEFAULT NULL,
  `HP` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_summary` (
  `OCCRRNC_DE` char(20) NOT NULL DEFAULT '' COMMENT '발생일',
  `STATS_SE` varchar(10) NOT NULL DEFAULT '' COMMENT '통계구분',
  `DETAIL_STATS_SE` varchar(10) NOT NULL DEFAULT '' COMMENT '세부통계구분',
  `USER_CO` decimal(10,0) DEFAULT NULL COMMENT '사용자수',
  PRIMARY KEY (`OCCRRNC_DE`,`STATS_SE`,`DETAIL_STATS_SE`),
  UNIQUE KEY `USER_SUMMARY_PK` (`OCCRRNC_DE`,`STATS_SE`,`DETAIL_STATS_SE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='사용자통계요약';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `v_inquiry`;
/*!50001 DROP VIEW IF EXISTS `v_inquiry`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_inquiry` AS SELECT
 1 AS `source`,
  1 AS `inquiry_id`,
  1 AS `user_id`,
  1 AS `user_name`,
  1 AS `title`,
  1 AS `body`,
  1 AS `inquiry_date`,
  1 AS `predicted_category`,
  1 AS `predicted_confidence`,
  1 AS `classified_by_model`,
  1 AS `classified_at`,
  1 AS `actual_category`,
  1 AS `assigned_to`,
  1 AS `reroute_count`,
  1 AS `answer_body`,
  1 AS `answered_by`,
  1 AS `answered_at`,
  1 AS `resolution_state`,
  1 AS `user_satisfaction`,
  1 AS `reg_dt`,
  1 AS `upd_dt`,
  1 AS `is_deleted` */;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `vw_lec_req_on`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vw_lec_req_on` (
  `LECCODE` varchar(30) DEFAULT NULL,
  `FREE` varchar(1) DEFAULT NULL,
  `WMV_PMP` varchar(10) DEFAULT NULL,
  `CNT` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `vw_lec_sch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vw_lec_sch` (
  `LECCODE` varchar(30) DEFAULT NULL,
  `SDATE` date DEFAULT NULL,
  `EDATE` date DEFAULT NULL,
  `CNT` bigint(20) DEFAULT NULL,
  `REST` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `vw_series_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `vw_series_info` (
  `SRS_CD` varchar(20) DEFAULT NULL,
  `SRS_NM` varchar(50) DEFAULT NULL,
  `P_SRSCD` varchar(20) DEFAULT NULL,
  `ORDR` bigint(20) DEFAULT NULL,
  `LVL` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `web_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `web_log` (
  `REQUST_ID` varchar(20) NOT NULL COMMENT '요청ID',
  `OCCRRNC_DE` datetime DEFAULT NULL COMMENT '발생일',
  `URL` varchar(200) DEFAULT NULL COMMENT 'URL',
  `RQESTER_ID` varchar(20) DEFAULT NULL COMMENT '요청자ID',
  `RQESTER_IP` varchar(23) DEFAULT NULL COMMENT '요청자IP',
  PRIMARY KEY (`REQUST_ID`),
  UNIQUE KEY `WEB_LOG_PK` (`REQUST_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci ROW_FORMAT=DYNAMIC COMMENT='웹로그';
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `www_poll`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `www_poll` (
  `POLL_ID` bigint(20) DEFAULT NULL,
  `START_DT` varchar(10) DEFAULT NULL,
  `END_DT` varchar(10) DEFAULT NULL,
  `ISUSE` varchar(1) DEFAULT NULL,
  `TITLE` varchar(500) DEFAULT NULL,
  `IS_SHOW` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `www_poll_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `www_poll_item` (
  `POLL_ID` bigint(20) DEFAULT NULL,
  `POLL_ITEM_ID` bigint(20) DEFAULT NULL,
  `VIW` varchar(100) DEFAULT NULL,
  `SEQ` bigint(20) DEFAULT NULL,
  `CNT` bigint(20) DEFAULT NULL,
  `SUBJECT_NM` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50001 DROP VIEW IF EXISTS `comvnusermaster`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `comvnusermaster` AS select `gnrl_mber`.`ESNTL_ID` AS `ESNTL_ID`,`gnrl_mber`.`MBER_ID` AS `USER_ID`,`gnrl_mber`.`PASSWORD` AS `PASSWORD`,`gnrl_mber`.`MBER_NM` AS `USER_NM`,`gnrl_mber`.`ZIP` AS `ZIP`,`gnrl_mber`.`ADRES` AS `ADRES`,`gnrl_mber`.`MBER_EMAIL_ADRES` AS `MBER_EMAIL_ADRES`,' ' AS `Name_exp_8`,'GNR' AS `USER_SE`,' ' AS `ORGNZT_ID` from `gnrl_mber` union all select `emplyr_info`.`ESNTL_ID` AS `ESNTL_ID`,`emplyr_info`.`EMPLYR_ID` AS `EMPLYR_ID`,`emplyr_info`.`PASSWORD` AS `PASSWORD`,`emplyr_info`.`USER_NM` AS `USER_NM`,`emplyr_info`.`ZIP` AS `ZIP`,`emplyr_info`.`HOUSE_ADRES` AS `HOUSE_ADRES`,`emplyr_info`.`EMAIL_ADRES` AS `EMAIL_ADRES`,`emplyr_info`.`GROUP_ID` AS `GROUP_ID`,'USR' AS `USER_SE`,`emplyr_info`.`ORGNZT_ID` AS `ORGNZT_ID` from `emplyr_info` union all select `entrprs_mber`.`ESNTL_ID` AS `ESNTL_ID`,`entrprs_mber`.`ENTRPRS_MBER_ID` AS `ENTRPRS_MBER_ID`,`entrprs_mber`.`ENTRPRS_MBER_PASSWORD` AS `ENTRPRS_MBER_PASSWORD`,`entrprs_mber`.`CMPNY_NM` AS `CMPNY_NM`,`entrprs_mber`.`ZIP` AS `ZIP`,`entrprs_mber`.`ADRES` AS `ADRES`,`entrprs_mber`.`APPLCNT_EMAIL_ADRES` AS `APPLCNT_EMAIL_ADRES`,' ' AS `Name_exp_8`,'ENT' AS `USER_SE`,' ' AS `ORGNZT_ID` from `entrprs_mber` order by `ESNTL_ID` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_inquiry`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_inquiry` AS select 'L' AS `source`,`L`.`BOARD_SEQ` AS `inquiry_id`,`L`.`REG_ID` AS `user_id`,`L`.`CREATENAME` AS `user_name`,`L`.`SUBJECT` AS `title`,left(convert(`L`.`CONTENT` using utf8mb4),65535) AS `body`,`L`.`REG_DT` AS `inquiry_date`,NULL AS `predicted_category`,NULL AS `predicted_confidence`,NULL AS `classified_by_model`,NULL AS `classified_at`,`M`.`std_category` AS `actual_category`,`L`.`COUNSELOR_ID` AS `assigned_to`,0 AS `reroute_count`,left(convert(`L`.`ANSWER` using utf8mb4),65535) AS `answer_body`,`L`.`COUNSELOR_ID` AS `answered_by`,case when `L`.`ANSWER` is not null then `L`.`UPD_DT` else NULL end AS `answered_at`,case `L`.`ACTION_YN` when 'Y' then 'RESOLVED' else 'OPEN' end AS `resolution_state`,NULL AS `user_satisfaction`,`L`.`REG_DT` AS `reg_dt`,`L`.`UPD_DT` AS `upd_dt`,'N' AS `is_deleted` from (`tb_board_cs` `L` left join `tb_category_mapping` `M` on(`M`.`legacy_cs_div` = `L`.`CS_DIV` and (`M`.`legacy_cs_kind` = coalesce(`L`.`CS_KIND`,'') or `M`.`legacy_cs_kind` = ''))) union all select 'N' AS `source`,cast(`N`.`inquiry_id` as char(20) charset utf8mb4) AS `inquiry_id`,`N`.`user_id` AS `user_id`,`N`.`user_name` AS `user_name`,`N`.`title` AS `title`,`N`.`body` AS `body`,`N`.`inquiry_date` AS `inquiry_date`,`N`.`predicted_category` AS `predicted_category`,`N`.`predicted_confidence` AS `predicted_confidence`,`N`.`classified_by_model` AS `classified_by_model`,`N`.`classified_at` AS `classified_at`,`N`.`actual_category` AS `actual_category`,`N`.`assigned_to` AS `assigned_to`,`N`.`reroute_count` AS `reroute_count`,`N`.`answer_body` AS `answer_body`,`N`.`answered_by` AS `answered_by`,`N`.`answered_at` AS `answered_at`,`N`.`resolution_state` AS `resolution_state`,`N`.`user_satisfaction` AS `user_satisfaction`,`N`.`reg_dt` AS `reg_dt`,`N`.`upd_dt` AS `upd_dt`,`N`.`is_deleted` AS `is_deleted` from `tb_inquiry` `N` where `N`.`is_deleted` = 'N' */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

