/*M!999999\- enable the sandbox mode */ 
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `ADVANCE_RECEIVED`(I_START_DATE        VARCHAR(8),
    I_PERIOD            INT,
    I_PAUSE_COUNT       INT,
    I_PAUSE_DATE1       VARCHAR(8),
    I_PAUSE_DATE2       VARCHAR(8),
    I_PAUSE_DATE3       VARCHAR(8),
    I_PAUSE_PERIOD1     INT,
    I_PAUSE_PERIOD2     INT,
    I_PAUSE_PERIOD3     INT,
    I_SEARCH_DATE       VARCHAR(8)
) RETURNS int(11)
    DETERMINISTIC
BEGIN
    DECLARE V_START_DATE        VARCHAR(8);
    DECLARE V_PERIOD            INT;
    DECLARE V_PAUSE_COUNT       INT;
    DECLARE V_PAUSE_DATE1       VARCHAR(8);
    DECLARE V_PAUSE_DATE2       VARCHAR(8);
    DECLARE V_PAUSE_DATE3       VARCHAR(8);
    DECLARE V_PAUSE_PERIOD1     INT;
    DECLARE V_PAUSE_PERIOD2     INT;
    DECLARE V_PAUSE_PERIOD3     INT;
    DECLARE V_SEARCH_DATE       VARCHAR(8);

    DECLARE V_RE_PERIOD_TEMP    INT;   
    DECLARE V_RE_PERIOD         INT;   
    DECLARE V_RE_PAUSE_PERIOD   INT;   

    DECLARE V_END_DATE          VARCHAR(8);
    DECLARE V_TEMPDATE          VARCHAR(8);

    DECLARE V_PAUSE_DATE        VARCHAR(8);
    DECLARE V_PAUSE_END_DATE    VARCHAR(8);
    DECLARE V_PAUSE_PERIOD      INT;

    SET V_START_DATE        = I_START_DATE;
    SET V_PERIOD            = I_PERIOD;
    SET V_PAUSE_COUNT       = I_PAUSE_COUNT;
    SET V_PAUSE_DATE1       = I_PAUSE_DATE1;
    SET V_PAUSE_DATE2       = I_PAUSE_DATE2;
    SET V_PAUSE_DATE3       = I_PAUSE_DATE3;
    SET V_PAUSE_PERIOD1     = I_PAUSE_PERIOD1;
    SET V_PAUSE_PERIOD2     = I_PAUSE_PERIOD2;
    SET V_PAUSE_PERIOD3     = I_PAUSE_PERIOD3;
    SET V_SEARCH_DATE       = I_SEARCH_DATE;

    SET V_END_DATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_START_DATE,'%Y%m%d'), INTERVAL (V_PERIOD-1) DAY), '%Y%m%d');

    IF(V_PAUSE_COUNT >= 1) THEN
        SET V_PAUSE_DATE = V_PAUSE_DATE1;
        SET V_PAUSE_PERIOD = V_PAUSE_PERIOD1;

        IF(V_PAUSE_DATE1 <= V_END_DATE) THEN
            SET V_TEMPDATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_END_DATE,'%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d');
            SET V_END_DATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_TEMPDATE,'%Y%m%d'), INTERVAL (V_PAUSE_PERIOD1-1) DAY), '%Y%m%d');
        END IF;
    END IF;

    IF(V_PAUSE_COUNT >= 2) THEN
        SET V_PAUSE_DATE = V_PAUSE_DATE2;
        SET V_PAUSE_PERIOD = V_PAUSE_PERIOD2;

        IF(V_PAUSE_DATE2 <= V_END_DATE) THEN
            SET V_TEMPDATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_END_DATE,'%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d');
            SET V_END_DATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_TEMPDATE,'%Y%m%d'), INTERVAL (V_PAUSE_PERIOD2-1) DAY), '%Y%m%d');
        END IF;
    END IF;

    IF(V_PAUSE_COUNT >= 3) THEN
        SET V_PAUSE_DATE = V_PAUSE_DATE3;
        SET V_PAUSE_PERIOD = V_PAUSE_PERIOD3;

        IF(V_PAUSE_DATE3 <= V_END_DATE) THEN
            SET V_TEMPDATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_END_DATE,'%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d');
            SET V_END_DATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_TEMPDATE,'%Y%m%d'), INTERVAL (V_PAUSE_PERIOD3-1) DAY), '%Y%m%d');
        END IF;
    END IF;

    IF(V_PAUSE_COUNT >= 1) THEN
        SET V_PAUSE_END_DATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_PAUSE_DATE,'%Y%m%d'), INTERVAL (V_PAUSE_PERIOD-1) DAY), '%Y%m%d');
    END IF;

    SET V_END_DATE = DATE_FORMAT(DATE_ADD(STR_TO_DATE(V_END_DATE,'%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d');

    SET V_PERIOD = DATEDIFF(STR_TO_DATE(V_END_DATE,'%Y%m%d'), STR_TO_DATE(V_START_DATE,'%Y%m%d'));

    IF V_PERIOD < 0 THEN
        SET V_PERIOD = V_PERIOD * -1;
    END IF;
    SET V_PERIOD = V_PERIOD + 1;

    SET V_RE_PERIOD_TEMP = DATEDIFF(STR_TO_DATE(V_SEARCH_DATE,'%Y%m%d'), STR_TO_DATE(V_START_DATE,'%Y%m%d'));

    IF V_RE_PERIOD_TEMP < 0 THEN
        SET V_RE_PERIOD_TEMP = V_RE_PERIOD_TEMP * -1;
    END IF;
    SET V_RE_PERIOD_TEMP = V_RE_PERIOD_TEMP + 1;

    SET V_RE_PERIOD = V_PERIOD - V_RE_PERIOD_TEMP;

    IF V_PAUSE_COUNT > 0 THEN
        IF(V_SEARCH_DATE >= V_PAUSE_DATE) THEN
            IF(V_PAUSE_END_DATE >= V_SEARCH_DATE) THEN
                SET V_RE_PAUSE_PERIOD = DATEDIFF(STR_TO_DATE(V_SEARCH_DATE,'%Y%m%d'), STR_TO_DATE(V_PAUSE_END_DATE,'%Y%m%d'));

                IF(V_RE_PAUSE_PERIOD < 0) THEN
                    SET V_RE_PAUSE_PERIOD = V_RE_PAUSE_PERIOD * -1;
                END IF;

                SET V_RE_PAUSE_PERIOD = V_RE_PAUSE_PERIOD + 1;
                SET V_RE_PERIOD = V_RE_PERIOD - V_RE_PAUSE_PERIOD;
            END IF;
        ELSEIF(V_PAUSE_DATE <= V_END_DATE) THEN
            SET V_RE_PERIOD = V_RE_PERIOD - V_PAUSE_PERIOD;
        END IF;
    END IF;

    IF(V_RE_PERIOD < 0) THEN
        SET V_RE_PERIOD = V_RE_PERIOD * -1;
    END IF;

    SET V_RE_PERIOD = V_RE_PERIOD -1;

    RETURN V_RE_PERIOD;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `DECRYPT`(XCRYPT VARBINARY(2048), HASH_KEY VARCHAR(255)) RETURNS varchar(2000) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    
    DECLARE PADDED_KEY VARCHAR(16);
    SET PADDED_KEY = RPAD(HASH_KEY, 16, '#');
    RETURN AES_DECRYPT(XCRYPT, PADDED_KEY);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `ENCRYPT`(STR VARCHAR(2000), HASH_KEY VARCHAR(255)) RETURNS varbinary(2048)
    DETERMINISTIC
BEGIN
    
    DECLARE PADDED_KEY VARCHAR(16);
    SET PADDED_KEY = RPAD(HASH_KEY, 16, '#');
    RETURN AES_ENCRYPT(STR, PADDED_KEY);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_BOOK_ORDER_CNT`(V_RSC_ID VARCHAR(255),   
    V_LECCODE VARCHAR(255),  
    V_USER_ID VARCHAR(255)   
) RETURNS int(11)
    DETERMINISTIC
BEGIN
    DECLARE CNT1 INT;
    DECLARE CNT2 INT;
    DECLARE CNT INT;

    SET CNT1 = 0;
    SET CNT2 = 0;
    SET CNT = 0;

    SELECT COUNT(*) INTO CNT1
    FROM TB_ORDERS A, TB_ORDER_MGNT_NO B
    WHERE A.ORDERNO = B.ORDERNO
    AND A.USER_ID = V_USER_ID
    AND B.MGNTNO = V_RSC_ID;

    SELECT COUNT(*) INTO CNT2
    FROM TB_ORDERS A, TB_ORDER_MGNT_NO B
    WHERE A.ORDERNO = B.ORDERNO
    AND A.USER_ID = V_USER_ID
    AND B.MGNTNO = V_LECCODE
    AND B.MGNTNO IN ('D201401365', 'D201401406', 'D201401448', 'D201401418', 'D201401481', 'D201401495')
    AND A.REG_DT < '2014-08-15';

    SET CNT = CNT1 + CNT2;
    
   RETURN CNT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_DATE_EXPIRED`(V_DATE    VARCHAR(8)    
) RETURNS varchar(1) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE RET VARCHAR(1);
    DECLARE TMPVAR INT;

   SET TMPVAR = CAST(V_DATE AS SIGNED) - CAST(DATE_FORMAT(CURDATE(), '%Y%m%d') AS SIGNED);

   IF TMPVAR >= 0 THEN
    SET RET = 'Y';
   ELSE
    SET RET = 'N';
   END IF;

   RETURN RET;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_GOSI_STANDARD`(V_SUBJECT_CD VARCHAR(255)    
) RETURNS decimal(10,5)
    DETERMINISTIC
BEGIN
    DECLARE I_POINT DECIMAL(10, 5); 
    DECLARE I_USR_CNT INT;
    DECLARE I_USR_AVR DECIMAL(10, 5);
    DECLARE I_GAP_POINT DECIMAL(10, 5); 
    DECLARE I_STN_DIV DECIMAL(10, 5); 
    DECLARE I_ADJ_POINT DECIMAL(10, 5);

    DECLARE v_sum_point DECIMAL(10, 5);
    DECLARE done INT DEFAULT FALSE;
    DECLARE C1 CURSOR FOR
        SELECT SUM_POINT
        FROM GOSI_RST_SBJ
        WHERE SUBJECT_CD = V_SUBJECT_CD
        AND SUM_POINT > 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET I_GAP_POINT = 0;
    SET I_STN_DIV = 0;

    SELECT COUNT(SUM_POINT), ROUND(SUM(SUM_POINT)/COUNT(SUM_POINT), 2) INTO I_USR_CNT, I_USR_AVR
    FROM GOSI_RST_SBJ
    WHERE SUBJECT_CD = V_SUBJECT_CD
    AND SUM_POINT > 0;
    
    OPEN C1;
    
    read_loop: LOOP
        FETCH C1 INTO v_sum_point;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET I_GAP_POINT = I_GAP_POINT + ((v_sum_point - I_USR_AVR) * (v_sum_point - I_USR_AVR));
    END LOOP;
    
    CLOSE C1;
    
    IF (I_GAP_POINT > 0 AND I_USR_CNT > 1) THEN
        SET I_STN_DIV = POWER((I_GAP_POINT / (I_USR_CNT - 1)), 1/2); 
    END IF;

   RETURN I_STN_DIV;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_LEC_BRG_REQ_CNT`(V_LECCODE VARCHAR(255)    
) RETURNS int(11)
    DETERMINISTIC
BEGIN
    DECLARE CNT INT;
    SET CNT = 0;

    SELECT IFNULL(SUM(T.CNT), 0) into CNT
    FROM (
        SELECT COUNT(B.MGNTNO) AS CNT
        FROM TB_OFF_MYLECTURE A, TB_OFF_ORDER_MGNT_NO B, TB_OFF_LEC_BRIDGE C, 
             (SELECT BRIDGE_LECCODE, LECCODE FROM TB_OFF_LEC_BRIDGE WHERE LECCODE = V_LECCODE) D
        WHERE A.ORDERNO = B.ORDERNO
        AND A.PACKAGE_NO = B.MGNTNO
        AND A.LECTURE_NO = C.LECCODE
        AND B.STATUSCODE IN ('DLV105', 'DLV230')
        AND C.BRIDGE_LECCODE = D.BRIDGE_LECCODE
        GROUP BY B.ORDERNO
        HAVING COUNT(B.MGNTNO) = 1
    ) T;
   
   RETURN CNT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_LEC_ON_REQ_CNT`(V_LECCODE VARCHAR(255),    
    V_WMP_PMP VARCHAR(255),    
    V_FREE VARCHAR(1)    
) RETURNS int(11)
    DETERMINISTIC
BEGIN
    DECLARE CNT INT;
    SET CNT = 0;

    IF V_FREE = 'Y' THEN
        SELECT IFNULL(COUNT(B.MGNTNO),0) INTO CNT
        FROM TB_MYLECTURE A, TB_ORDER_MGNT_NO B
        WHERE A.ORDERNO = B.ORDERNO
        AND A.PACKAGE_NO = B.MGNTNO
        AND B.STATUSCODE = 'DLV105'
        AND B.ISCANCEL <> '2'
        AND B.PRICE = 0
        AND B.WMV_PMP = V_WMP_PMP
        AND A.PACKAGE_NO = V_LECCODE;
    ELSE
        SELECT IFNULL(COUNT(B.MGNTNO),0) INTO CNT
        FROM TB_MYLECTURE A, TB_ORDER_MGNT_NO B
        WHERE A.ORDERNO = B.ORDERNO
        AND A.PACKAGE_NO = B.MGNTNO
        AND B.STATUSCODE = 'DLV105'
        AND B.ISCANCEL <> '2'
        AND B.PRICE > 0
        AND B.WMV_PMP = V_WMP_PMP
        AND A.PACKAGE_NO = V_LECCODE;
    END IF;
    
   RETURN CNT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_LEC_REST`(V_LECCODE VARCHAR(255),    
    V_DATE    VARCHAR(255)    
) RETURNS int(11)
    DETERMINISTIC
BEGIN
   DECLARE TMPVAR INT;
   SET TMPVAR = 0;

   SELECT COUNT(NUM) INTO TMPVAR FROM TB_OFF_LECTURE_DATE WHERE LECCODE = V_LECCODE AND LEC_DATE > V_DATE;    

   RETURN TMPVAR;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_MULTI_BOOK_NM`(V_ORDERNO VARCHAR(255)) RETURNS varchar(1000) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE V_BOOK_ALL_NM VARCHAR(1000);
    DECLARE V_BOOK_NM varchar(100);
    DECLARE V_NM varchar(200);
    DECLARE done INT DEFAULT FALSE;

    DECLARE C1 CURSOR FOR
        SELECT CONCAT(B.BOOK_NM, ' ', B.BOOK_AUTHOR)
        FROM    TB_ORDER_MGNT_NO A, TB_CA_BOOK B
        WHERE    A.ORDERNO = V_ORDERNO
        AND A.MGNTNO = B.RSC_ID
        AND A.STATUSCODE = 'DLV105';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    SET V_BOOK_ALL_NM = '';

    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO V_NM;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET V_BOOK_ALL_NM = CONCAT(V_BOOK_ALL_NM, '\r\n', V_NM);
    END LOOP;
    CLOSE C1;

   RETURN V_BOOK_ALL_NM;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_OFF_PRICE_PRF_PACKAGE`(V_ORDERNO VARCHAR(255), V_PACKAGE_NO VARCHAR(255), V_LECTURE_NO VARCHAR(255)) RETURNS decimal(19,4)
    DETERMINISTIC
BEGIN
    DECLARE O_PRICE DECIMAL(19,4);
    DECLARE P_PRICE DECIMAL(19,4);
    DECLARE L_PRICE DECIMAL(19,4);
    DECLARE S_PRICE DECIMAL(19,4) DEFAULT 0;
    DECLARE O_DAY VARCHAR(10);

    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_LECTURE_NO VARCHAR(255);
    DECLARE R1_LECCODE VARCHAR(255);
    DECLARE R1_SUBJECT_PRICE DECIMAL(19,4);

    DECLARE C1 CURSOR FOR
        SELECT A.LECTURE_NO, B.LECCODE, B.SUBJECT_PRICE
        FROM TB_OFF_MYLECTURE A, TB_OFF_LEC_MST B
        WHERE A.LECTURE_NO = B.LECCODE
        AND A.ORDERNO = V_ORDERNO
        AND A.PACKAGE_NO = V_PACKAGE_NO;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT DATE_FORMAT(REG_DT, '%Y-%m-%d') INTO O_DAY FROM TB_OFF_ORDERS WHERE ORDERNO = V_ORDERNO;
    
    IF O_DAY >= '2015-09-01' THEN
        SELECT REALPRICE INTO P_PRICE
        FROM TB_OFF_MYLECTURE
        WHERE ORDERNO = V_ORDERNO
        AND PACKAGE_NO = V_PACKAGE_NO
        AND LECTURE_NO = V_LECTURE_NO;
    ELSE
        SELECT PRICE INTO O_PRICE
        FROM TB_OFF_ORDER_MGNT_NO
        WHERE ORDERNO = V_ORDERNO
        AND MGNTNO = V_PACKAGE_NO;

        OPEN C1;
        read_loop: LOOP
            FETCH C1 INTO R1_LECTURE_NO, R1_LECCODE, R1_SUBJECT_PRICE;
            IF done THEN
                LEAVE read_loop;
            END IF;
            SET S_PRICE = S_PRICE + R1_SUBJECT_PRICE;
        END LOOP;
        CLOSE C1;

        SELECT SUBJECT_PRICE INTO L_PRICE
        FROM TB_OFF_LEC_MST
        WHERE LECCODE = V_LECTURE_NO;

        IF S_PRICE > 0 THEN
            SET P_PRICE = ROUND(O_PRICE * (L_PRICE / S_PRICE), 0);
        ELSE
            SET P_PRICE = 0;
        END IF;
    END IF;

    RETURN P_PRICE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_ON_PRICE_PRF_PACKAGE`(V_ORDERNO VARCHAR(255), V_PACKAGE_NO VARCHAR(255), V_LECTURE_NO VARCHAR(255), V_ORDER_STATUS VARCHAR(255)) RETURNS decimal(19,4)
    DETERMINISTIC
BEGIN
    DECLARE O_PRICE DECIMAL(19,4);
    DECLARE P_PRICE DECIMAL(19,4);
    DECLARE L_PRICE DECIMAL(19,4);
    DECLARE S_PRICE DECIMAL(19,4) DEFAULT 0;

    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_LECTURE_NO VARCHAR(255);
    DECLARE R1_LECCODE VARCHAR(255);
    DECLARE R1_SUBJECT_PRICE DECIMAL(19,4);

    DECLARE C1 CURSOR FOR
        SELECT A.LECTURE_NO, B.LECCODE, B.SUBJECT_PRICE
        FROM TB_MYLECTURE A, TB_LEC_MST B
        WHERE A.LECTURE_NO = B.LECCODE
        AND A.ORDERNO = V_ORDERNO
        AND A.PACKAGE_NO = V_PACKAGE_NO;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT IFNULL(CASE WHEN GIFT_YN = 'Y' THEN 0 ELSE PRICE END, 0) INTO O_PRICE
    FROM TB_ORDER_MGNT_NO
    WHERE ORDERNO = V_ORDERNO
    AND MGNTNO = V_PACKAGE_NO
    AND STATUSCODE = V_ORDER_STATUS;

    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_LECTURE_NO, R1_LECCODE, R1_SUBJECT_PRICE;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET S_PRICE = S_PRICE + R1_SUBJECT_PRICE;
    END LOOP;
    CLOSE C1;

    SELECT SUBJECT_PRICE INTO L_PRICE
    FROM TB_LEC_MST
    WHERE LECCODE = V_LECTURE_NO;

    IF S_PRICE > 0 THEN
        SET P_PRICE = ROUND(O_PRICE * (L_PRICE / S_PRICE), 0);
    ELSE
        SET P_PRICE = 0;
    END IF;

    RETURN P_PRICE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_PRICE_PRF_PACKAGE`(V_ORDERNO       VARCHAR(255),  
    V_PACKAGE_NO    VARCHAR(255),  
    V_LECTURE_NO    VARCHAR(255)   
) RETURNS int(11)
    DETERMINISTIC
BEGIN
    DECLARE O_PRICE INT;
    DECLARE P_PRICE INT;
    DECLARE L_PRICE INT;
    DECLARE S_PRICE INT;

    DECLARE v_subject_price INT;
    DECLARE done INT DEFAULT FALSE;
    
    DECLARE C1 CURSOR FOR
        SELECT B.SUBJECT_PRICE
        FROM TB_MYLECTURE A, TB_LEC_MST B
        WHERE A.LECTURE_NO = B.LECCODE
        AND ORDERNO = V_ORDERNO
        AND PACKAGE_NO = V_PACKAGE_NO;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET S_PRICE = 0;
    
    SELECT PRICE INTO O_PRICE
    FROM TB_ORDER_MGNT_NO
    WHERE ORDERNO = V_ORDERNO
    AND MGNTNO = V_PACKAGE_NO;

    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO v_subject_price;
        IF done THEN
            LEAVE read_loop;
        END IF;
        SET S_PRICE = S_PRICE + v_subject_price;
    END LOOP;
    CLOSE C1;

    SELECT SUBJECT_PRICE INTO L_PRICE
    FROM TB_LEC_MST
    WHERE LECCODE = V_LECTURE_NO;

    SET P_PRICE = ROUND(O_PRICE * (L_PRICE / S_PRICE), 0);

   RETURN P_PRICE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `FN_GET_STUDY_DATE`(V_USERID    VARCHAR(255),    
    V_LECCODE   VARCHAR(255),    
    V_TYPE      VARCHAR(1)  
) RETURNS date
    DETERMINISTIC
BEGIN
    DECLARE I_START_DATE VARCHAR(10);
    DECLARE I_END_DATE VARCHAR(10);
    DECLARE I_SUBJECT_PERIOD INT;
    DECLARE I_LEC_ST_DT DATE;
    DECLARE I_DATE DATE;
    DECLARE START_DATE_AS_DATE DATE;

    SELECT A.SDATE, A.EDATE, B.SUBJECT_PERIOD, 
           STR_TO_DATE(CONCAT(B.SUBJECT_OFF_OPEN_YEAR, '-', B.SUBJECT_OFF_OPEN_MONTH, '-', B.SUBJECT_OFF_OPEN_DAY), '%Y-%m-%d')
           INTO I_START_DATE, I_END_DATE, I_SUBJECT_PERIOD, I_LEC_ST_DT
    FROM TB_CC_CART A INNER JOIN TB_LEC_MST B
    ON A.LECCODE = B.LECCODE
    WHERE USER_ID = V_USERID
    AND A.LECCODE = V_LECCODE
    AND A.KIND_TYPE <> 'L';
    
    IF I_LEC_ST_DT < CURDATE() THEN
        SET START_DATE_AS_DATE = IFNULL(STR_TO_DATE(I_START_DATE, '%y-%m-%d'), CURDATE());
        SET I_DATE = DATE_ADD(START_DATE_AS_DATE, INTERVAL (I_SUBJECT_PERIOD - 1) DAY);
    ELSE
        SET START_DATE_AS_DATE = DATE_ADD(I_LEC_ST_DT, INTERVAL 1 DAY);
        SET I_DATE = DATE_ADD(I_LEC_ST_DT, INTERVAL I_SUBJECT_PERIOD DAY);
    END IF;

   IF V_TYPE = 'S' THEN
    RETURN START_DATE_AS_DATE;
   ELSE
    RETURN I_DATE;
   END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GET_COUNSEL_USERCODE_NM`(v_usercode VARCHAR(255)
) RETURNS varchar(1000) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE v_user_code_nm VARCHAR(1000);
    DECLARE v_user_code_val VARCHAR(100);
    DECLARE v_substring VARCHAR(255);
    DECLARE v_remaining_string VARCHAR(255);
    DECLARE v_delimiter_pos INT;
    
    SET v_user_code_nm = '';
    SET v_remaining_string = v_usercode;

    WHILE LENGTH(v_remaining_string) > 0 DO
        SET v_delimiter_pos = INSTR(v_remaining_string, ',');
        IF v_delimiter_pos = 0 THEN
            SET v_substring = v_remaining_string;
            SET v_remaining_string = '';
        ELSE
            SET v_substring = SUBSTRING(v_remaining_string, 1, v_delimiter_pos - 1);
            SET v_remaining_string = SUBSTRING(v_remaining_string, v_delimiter_pos + 1);
        END IF;

        SELECT NAME INTO v_user_code_val FROM TB_CATEGORY_INFO INFO WHERE INFO.CODE = v_substring;
        
        IF LENGTH(v_user_code_val) > 0 AND LENGTH(v_user_code_nm) > 0 THEN
            SET v_user_code_nm = CONCAT(v_user_code_nm, ',', v_user_code_val);
        ELSEIF LENGTH(v_user_code_val) > 0 THEN
            SET v_user_code_nm = v_user_code_val;
        END IF;
    END WHILE;

    RETURN v_user_code_nm;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `GET_COUNSEL_USERLEC_NM`(v_userlec VARCHAR(100)
) RETURNS varchar(100) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE v_user_lec_val INT;
    DECLARE v_user_lec_nm VARCHAR(100);

    SET v_user_lec_nm = '';
    
    IF INSTR(v_userlec, 'F') > 0 THEN
        SET v_user_lec_nm = '학원';
    END IF;

    IF INSTR(v_userlec, 'O') > 0 THEN
        IF LENGTH(v_user_lec_nm) > 0 THEN
            SET v_user_lec_nm = CONCAT(v_user_lec_nm, ',온라인');
        ELSE
            SET v_user_lec_nm = '온라인';
        END IF;
    END IF;

    IF INSTR(v_userlec, 'E') > 0 THEN
        IF LENGTH(v_user_lec_nm) > 0 THEN
            SET v_user_lec_nm = CONCAT(v_user_lec_nm, ',기타');
        ELSE
            SET v_user_lec_nm = '기타';
        END IF;
    END IF;

    RETURN v_user_lec_nm;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `HASH_STR_DATA`() RETURNS int(11)
    DETERMINISTIC
BEGIN
   RETURN 0;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `REVERSE_STR`(I_STRING VARCHAR(4000)) RETURNS varchar(4000) CHARSET utf8mb3 COLLATE utf8mb3_uca1400_ai_ci
    DETERMINISTIC
BEGIN
      RETURN REVERSE(I_STRING);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `DELETE_COOP_COUPON`(IN V_COOP_CD VARCHAR(255), IN V_LECCODE VARCHAR(255))
BEGIN
    DELETE FROM COOP_COUPON_MST
    WHERE COOP_CD = V_COOP_CD
    AND LECCODE = V_LECCODE;

    DELETE FROM COOP_COUPON
    WHERE COOP_CD = V_COOP_CD
    AND LECCODE = V_LECCODE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `EXT_MY_LECTURE_DAY`(IN V_USER_ID VARCHAR(50), IN V_ORDERNO VARCHAR(255), IN V_LECCODE VARCHAR(255), IN V_DAY INT, IN V_FREE VARCHAR(255))
BEGIN
    UPDATE TB_MYLECTURE 
    SET END_DATE = DATE_ADD(END_DATE, INTERVAL V_DAY DAY), 
        FREE_ID = V_FREE, 
        PERIOD = PERIOD + V_DAY
    WHERE LECTURE_NO = V_LECCODE 
    AND USERID = V_USER_ID
    AND ORDERNO = V_ORDERNO;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_DDL_PARTITION`(
	IN `I_OWNER` VARCHAR(255), IN `I_OBJECT_NAME` VARCHAR(255), IN `I_OBJECT_TYPE` VARCHAR(255), 
	OUT `O_PARTITION` VARCHAR(2000), OUT `O_CODE` INT, OUT `O_MSG` VARCHAR(255))
BEGIN
    
    
    
    SET O_CODE = -1;
    SET O_MSG = 'GET_DDL_PARTITION is not implemented in MySQL.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_EXAM_IDENTYID`(
    IN l_gubun VARCHAR(255), 
    IN l_param VARCHAR(255), 
    OUT N_IDENTYID VARCHAR(30)
)
BEGIN
    DECLARE next_seq INT;
    CALL GET_EXAM_NEXTSEQ(l_gubun, l_param, next_seq);
    
    IF next_seq IS NOT NULL THEN
        SET N_IDENTYID = CONCAT(UPPER(l_param), LPAD(next_seq, 4, '0'));
    ELSE
        SET N_IDENTYID = 'NO';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_EXAM_NEXTSEQ`(
    IN l_gubun VARCHAR(255), 
    IN l_param VARCHAR(255), 
    OUT l_nextseq INT
)
BEGIN
    
    
    
    
    
    
    INSERT INTO TB_TEXAMIDSEQ (GUBUN, IDTYPE, SEQ)
    SELECT UPPER(l_gubun), UPPER(l_param), 100
    WHERE NOT EXISTS (SELECT 1 FROM TB_TEXAMIDSEQ WHERE GUBUN = UPPER(l_gubun) AND IDTYPE = UPPER(l_param));

    UPDATE TB_TEXAMIDSEQ
    SET SEQ = SEQ + 1
    WHERE GUBUN = UPPER(l_gubun) AND IDTYPE = UPPER(l_param);

    SELECT SEQ INTO l_nextseq
    FROM TB_TEXAMIDSEQ
    WHERE GUBUN = UPPER(l_gubun) AND IDTYPE = UPPER(l_param);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_EXAM_OFFERERID`(
    IN l_gubun VARCHAR(255),
    IN l_param VARCHAR(255),
    OUT N_OFFERERID VARCHAR(30)
)
BEGIN
    DECLARE next_seq INT;
    CALL GET_EXAM_NEXTSEQ(l_gubun, l_param, next_seq);
    
    IF next_seq IS NOT NULL THEN
        SET N_OFFERERID = CONCAT(UPPER(l_param), LPAD(next_seq, 6, '0'));
    ELSE
        SET N_OFFERERID = 'NO';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_NEXTSEQ_NO`(
    IN l_gubun VARCHAR(255),
    OUT l_nextseq INT
)
BEGIN
    DECLARE current_year VARCHAR(4);
    SET current_year = DATE_FORMAT(CURDATE(), '%Y');

    INSERT INTO TB_SEQ_ORDERNO (GUBUN, GYEAR, SEQ)
    SELECT UPPER(l_gubun), current_year, 1
    WHERE NOT EXISTS (SELECT 1 FROM TB_SEQ_ORDERNO WHERE GUBUN = UPPER(l_gubun) AND GYEAR = current_year);

    UPDATE TB_SEQ_ORDERNO
    SET SEQ = SEQ + 1
    WHERE GUBUN = UPPER(l_gubun) AND GYEAR = current_year;
    
    SELECT SEQ INTO l_nextseq
    FROM TB_SEQ_ORDERNO
    WHERE GUBUN = UPPER(l_gubun) AND GYEAR = current_year;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_NEXTSEQ_OFFNO`(
    IN l_gubun VARCHAR(255),
    OUT l_nextseq INT
)
BEGIN
    DECLARE current_year VARCHAR(4);
    SET current_year = DATE_FORMAT(CURDATE(), '%Y');

    INSERT INTO TB_SEQOFF_ORDERNO (GUBUN, GYEAR, SEQ)
    SELECT UPPER(l_gubun), current_year, 1
    WHERE NOT EXISTS (SELECT 1 FROM TB_SEQOFF_ORDERNO WHERE GUBUN = UPPER(l_gubun) AND GYEAR = current_year);

    UPDATE TB_SEQOFF_ORDERNO
    SET SEQ = SEQ + 1
    WHERE GUBUN = UPPER(l_gubun) AND GYEAR = current_year;
    
    SELECT SEQ INTO l_nextseq
    FROM TB_SEQOFF_ORDERNO
    WHERE GUBUN = UPPER(l_gubun) AND GYEAR = current_year;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_NEXTSEQ_OFFORDERNO`(
    IN l_gubun VARCHAR(255),
    OUT N_ORDERNO VARCHAR(20)
)
BEGIN
    DECLARE next_seq INT;
    CALL GET_NEXTSEQ_OFFNO(l_gubun, next_seq);

    IF next_seq IS NOT NULL THEN
        SET N_ORDERNO = CONCAT(UPPER(l_gubun), 'F', DATE_FORMAT(CURDATE(), '%y'), LPAD(next_seq, 7, '0'));
    ELSE
        SET N_ORDERNO = 'NO';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GET_NEXTSEQ_ORDERNO`(
    IN l_gubun VARCHAR(255),
    OUT N_ORDERNO VARCHAR(20)
)
BEGIN
    DECLARE next_seq INT;
    CALL GET_NEXTSEQ_NO(l_gubun, next_seq);

    IF next_seq IS NOT NULL THEN
        SET N_ORDERNO = CONCAT(UPPER(l_gubun), DATE_FORMAT(CURDATE(), '%y'), LPAD(next_seq, 7, '0'));
    ELSE
        SET N_ORDERNO = 'NO';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_COOP_COUPON`(IN V_COOP_CD VARCHAR(255), IN V_COUPON_NM VARCHAR(255), IN V_LECCODE VARCHAR(255), IN V_ST_DT VARCHAR(255), IN V_ED_DT VARCHAR(255), IN V_COUPON_CNT INT)
BEGIN
    DECLARE I_CNT INT;
    SET I_CNT = V_COUPON_CNT;

    INSERT INTO COOP_COUPON_MST(COOP_CD, COUPON_NM, LECCODE, ST_DT, ED_DT, COUPON_CNT, COUPON_USE, REG_DT) 
    VALUES (V_COOP_CD, V_COUPON_NM, V_LECCODE, V_ST_DT, V_ED_DT, V_COUPON_CNT, 0, NOW());

    WHILE I_CNT > 0 DO
        
        
        INSERT INTO COOP_COUPON(C_CD, COOP_CD, LECCODE) 
        VALUES (LEFT(REPLACE(UUID(),'-',''), 16), V_COOP_CD, V_LECCODE);
        SET I_CNT = I_CNT - 1; 
    END WHILE;    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_COUPON`(IN V_COUPON VARCHAR(255), IN V_USERID VARCHAR(50), IN V_DAY INT, IN V_EVENT_NO INT)
BEGIN
    
    INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID, EVENT_NO) 
    VALUES (V_COUPON, V_USERID, NOW(), NOW(), DATE_ADD(NOW(), INTERVAL V_DAY DAY), 0, 'SYSTEM', V_EVENT_NO);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_LECTURE`(IN V_USER_ID VARCHAR(50), IN V_LECCODE VARCHAR(255), IN V_TXT VARCHAR(255), IN V_DAY INT)
BEGIN
    DECLARE I_ORDERNO VARCHAR(20);
    DECLARE I_USER_NM VARCHAR(255);
    DECLARE I_TEL_NO VARCHAR(255);
    DECLARE I_PHONE_NO VARCHAR(255);
    DECLARE I_ZIP_CODE VARCHAR(255);
    DECLARE I_ADDRESS1 VARCHAR(255);
    DECLARE I_ADDRESS2 VARCHAR(255);
    DECLARE I_EMAIL VARCHAR(255);
    
    SELECT USER_NM, TEL_NO, PHONE_NO, ZIP_CODE, ADDRESS1, ADDRESS2, EMAIL 
    INTO I_USER_NM, I_TEL_NO, I_PHONE_NO, I_ZIP_CODE, I_ADDRESS1, I_ADDRESS2, I_EMAIL
    FROM TB_MA_MEMBER
    WHERE USER_ID = V_USER_ID;

    
    SELECT GET_NEXTSEQ_ORDERNO('M') INTO I_ORDERNO;
            
    INSERT INTO TB_ORDERS(ORDERNO, USER_ID, USER_NM, TEL_NO, PHONE_NO, ZIP_CODE, ADDRESS1, ADDRESS2, EMAIL, REG_DT, OFF_LINE) 
    VALUES (I_ORDERNO, V_USER_ID, I_USER_NM, I_TEL_NO, I_PHONE_NO, I_ZIP_CODE, I_ADDRESS1, I_ADDRESS2, I_EMAIL, NOW(), '0');

    INSERT INTO TB_ORDER_MGNT_NO (ORDERNO, MGNTNO, CNT, ISCANCEL, PRICE, STATUSCODE, CONFIRMDATE, SDATE, ISCONFIRM, WMV_PMP, OPEN_ADMIN_ID, PTYPE, MEMO) 
    VALUES (I_ORDERNO, V_LECCODE, 1, 0, 0, 'DLV105', NOW(), NOW(), NOW(), 'VOD', V_USER_ID, 'D', V_TXT);

    INSERT INTO TB_APPROVALS (ORDERNO, PRICE, ADDPRICE, PAYCODE, ACCTNOCODE, PAYNAME, POINT, REG_DT) 
    VALUES (I_ORDERNO, 0, 0, 'PAY100', 'ACT110', I_USER_NM, 0, NOW());

    INSERT INTO TB_MYLECTURE (ORDERNO, USERID, PACKAGE_NO, LECTURE_NO, START_DATE, END_DATE, PERIOD, STUDY_PERCENT, REG_DT) 
    VALUES (I_ORDERNO, V_USER_ID, V_LECCODE, V_LECCODE, CURDATE(), DATE_ADD(CURDATE(), INTERVAL (V_DAY-1) DAY), V_DAY, 0, NOW());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_LECTURE_PKG`(IN V_USER_ID VARCHAR(50), IN V_LECCODE VARCHAR(255), IN V_TXT VARCHAR(255), IN V_DAY INT)
BEGIN
    DECLARE I_ORDERNO VARCHAR(20);
    DECLARE I_USER_NM VARCHAR(255);
    DECLARE I_TEL_NO VARCHAR(255);
    DECLARE I_PHONE_NO VARCHAR(255);
    DECLARE I_ZIP_CODE VARCHAR(255);
    DECLARE I_ADDRESS1 VARCHAR(255);
    DECLARE I_ADDRESS2 VARCHAR(255);
    DECLARE I_EMAIL VARCHAR(255);
    DECLARE I_LEC_TYPE_CHOICE VARCHAR(255);
    
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_MST_LECCODE VARCHAR(255);
    
    DECLARE C1 CURSOR FOR
        SELECT MST_LECCODE
        FROM TB_LEC_JONG
        WHERE LECCODE = V_LECCODE;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT LEC_TYPE_CHOICE INTO I_LEC_TYPE_CHOICE
    FROM TB_LEC_MST
    WHERE LECCODE = V_LECCODE;

    SELECT USER_NM, TEL_NO, PHONE_NO, ZIP_CODE, ADDRESS1, ADDRESS2, EMAIL 
    INTO I_USER_NM, I_TEL_NO, I_PHONE_NO, I_ZIP_CODE, I_ADDRESS1, I_ADDRESS2, I_EMAIL
    FROM TB_MA_MEMBER
    WHERE USER_ID = V_USER_ID;

    
    SELECT GET_NEXTSEQ_ORDERNO('M') INTO I_ORDERNO;
            
    INSERT INTO TB_ORDERS(ORDERNO, USER_ID, USER_NM, TEL_NO, PHONE_NO, ZIP_CODE, ADDRESS1, ADDRESS2, EMAIL, REG_DT, OFF_LINE) 
    VALUES (I_ORDERNO, V_USER_ID, I_USER_NM, I_TEL_NO, I_PHONE_NO, I_ZIP_CODE, I_ADDRESS1, I_ADDRESS2, I_EMAIL, NOW(), '0');

    INSERT INTO TB_ORDER_MGNT_NO (ORDERNO, MGNTNO, CNT, ISCANCEL, PRICE, STATUSCODE, CONFIRMDATE, SDATE, ISCONFIRM, WMV_PMP, OPEN_ADMIN_ID, PTYPE, MEMO) 
    VALUES (I_ORDERNO, V_LECCODE, 1, 0, 0, 'DLV105', NOW(), NOW(), NOW(), 'VOD', V_USER_ID, I_LEC_TYPE_CHOICE, V_TXT);

    INSERT INTO TB_APPROVALS (ORDERNO, PRICE, ADDPRICE, PAYCODE, ACCTNOCODE, PAYNAME, POINT, REG_DT) 
    VALUES (I_ORDERNO, 0, 0, 'PAY100', 'ACT110', I_USER_NM, 0, NOW());

    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_MST_LECCODE;
        IF done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO TB_MYLECTURE (ORDERNO, USERID, PACKAGE_NO, LECTURE_NO, START_DATE, END_DATE, PERIOD, STUDY_PERCENT, REG_DT) 
        VALUES (I_ORDERNO, V_USER_ID, V_LECCODE, R1_MST_LECCODE, CURDATE(), DATE_ADD(CURDATE(), INTERVAL (V_DAY-1) DAY), V_DAY, 0, NOW());
   
    END LOOP;
    CLOSE C1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERT_POINT`(IN V_POINT DECIMAL(19,4), IN V_USERID VARCHAR(50), IN V_TXT VARCHAR(255), IN V_EVENT_NO VARCHAR(255))
BEGIN
    UPDATE TB_MA_MEMBER SET USER_POINT = USER_POINT + V_POINT WHERE USER_ID = V_USERID;

    
    INSERT INTO TB_MILEAGE_HISTORY (USERID, POINT, COMMENT1, ORDERNO, MANAGER, SITE, REGDATE) 
    VALUES (V_USERID, V_POINT, V_TXT, V_EVENT_NO, V_USERID, 'PASS.WILLBES.NET', NOW());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_BUY_INSERT_POINT`(
   IN V_ORDER_NO VARCHAR(20),
   OUT V_RESULT INT
)
BEGIN
    DECLARE I_USERID VARCHAR(50);
    DECLARE I_CNT INT;
    DECLARE I_W_CNT INT;
    DECLARE I_H_CNT INT;
    DECLARE I_C_CNT INT;
    DECLARE I_S_CNT INT;
    DECLARE I_SUM DECIMAL(10, 2);
    DECLARE I_POINT DECIMAL(10, 2);
    DECLARE I_SJT_CD VARCHAR(20);
    DECLARE I_COUPON VARCHAR(20);
    DECLARE I_H_COUPON VARCHAR(20);
    DECLARE I_C_COUPON VARCHAR(20);
    DECLARE I_S_COUPON VARCHAR(20);
    
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_USER_ID VARCHAR(50);
    DECLARE R1_MGNTNO VARCHAR(20);
    DECLARE R1_PRICE DECIMAL(10, 2);
    DECLARE R1_SUBJECT_SJT_CD VARCHAR(20);

    
    DECLARE C1 CURSOR FOR
        SELECT A.USER_ID, B.MGNTNO, B.PRICE, D.SUBJECT_SJT_CD
        FROM TB_ORDERS A, TB_ORDER_MGNT_NO B, TB_APPROVALS C, TB_LEC_MST D
        WHERE A.ORDERNO = B.ORDERNO
        AND B.ORDERNO = C.ORDERNO
        AND B.PTYPE = 'D'
        AND B.STATUSCODE = 'DLV105'
        AND B.MGNTNO = D.LECCODE
        AND A.ORDERNO = V_ORDER_NO;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    SELECT A.USER_ID, SUM(B.PRICE), ROUND((SUM(B.PRICE)*0.2)) INTO I_USERID, I_SUM, I_POINT
    FROM TB_ORDERS A, TB_ORDER_MGNT_NO B, TB_APPROVALS C, TB_LEC_MST D
    WHERE A.ORDERNO = B.ORDERNO
    AND B.ORDERNO = C.ORDERNO
    AND B.PTYPE IN ('N', 'J', 'D')
    AND B.STATUSCODE = 'DLV105'
    AND B.MGNTNO = D.LECCODE
    AND A.ORDERNO = V_ORDER_NO
    GROUP BY A.USER_ID, A.ORDERNO;

    
    SELECT COUNT(MGNTNO) INTO I_CNT
    FROM TB_ORDERS A, TB_ORDER_MGNT_NO B
    WHERE A.ORDERNO = B.ORDERNO
    AND B.STATUSCODE = 'DLV105'
    AND B.MGNTNO = 'J201400054'
    AND A.ORDERNO = V_ORDER_NO;

    
    SELECT COUNT(MGNTNO) INTO I_H_CNT
    FROM TB_ORDERS A, TB_ORDER_MGNT_NO B
    WHERE A.ORDERNO = B.ORDERNO
    AND B.STATUSCODE = 'DLV105'
    AND B.MGNTNO = 'D201500470'
    AND A.ORDERNO = V_ORDER_NO;
    
    
    SELECT COUNT(MGNTNO) INTO I_C_CNT
    FROM TB_ORDERS A, TB_ORDER_MGNT_NO B
    WHERE A.ORDERNO = B.ORDERNO
    AND B.STATUSCODE = 'DLV105'
    AND B.MGNTNO IN ('D201500892', 'D201500893', 'D201402695', 'D201402775')
    AND A.ORDERNO = V_ORDER_NO;
    
    
    SELECT COUNT(MGNTNO) INTO I_S_CNT
    FROM TB_ORDERS A, TB_ORDER_MGNT_NO B
    WHERE A.ORDERNO = B.ORDERNO
    AND B.STATUSCODE = 'DLV105'
    AND B.MGNTNO IN ('J201500027', 'J201500028', 'J201500029', 'J201500030', 'J201500031',
                    'J201500032', 'J201500033', 'J201500034', 'J201500035', 'J201500036',
                    'J201500037', 'J201500039', 'J201500040', 'J201500042', 'J201500041',
                    'N201500018', 'N201500020', 'N201500019', 'N201500021', 'J201500043',
                    'J201500044', 'J201500045', 'J201500046')
    AND A.ORDERNO = V_ORDER_NO;

    SET I_COUPON = 'C131029001'; 
    SET I_H_COUPON = 'C150402001'; 
    SET I_C_COUPON = 'C150413001'; 
    SET I_S_COUPON = 'C150518001'; 
    
    IF CURDATE() BETWEEN '2015-04-13' AND '2015-05-18' THEN
        IF I_C_CNT > 0 THEN
            INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID) 
            VALUES (I_C_COUPON, I_USERID, NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 'SYSTEM');
        END IF;
    END IF;

    IF CURDATE() BETWEEN '2015-03-18' AND '2015-05-31' THEN
        IF I_CNT > 0 THEN
            SELECT IFNULL(COUNT(*),0) INTO I_CNT
            FROM TB_TM_MYCOUPON 
            WHERE USERID = I_USERID 
            AND DATE(REGDATE) BETWEEN '2015-03-18' AND '2015-05-31'
            AND CCODE = I_COUPON;

            IF I_CNT = 0 THEN
                INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID) 
                VALUES (I_COUPON, I_USERID, NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 'SYSTEM');
            END IF;
        END IF;
    END IF;
     
    IF CURDATE() BETWEEN '2015-05-18' AND '2015-06-03' THEN
        IF I_S_CNT > 0 THEN
            SELECT IFNULL(COUNT(*),0) INTO I_S_CNT
            FROM TB_TM_MYCOUPON 
            WHERE USERID = I_USERID 
            AND CCODE = I_S_COUPON;

            IF I_S_CNT = 0 THEN
                INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID) 
                VALUES (I_S_COUPON, I_USERID, NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 100 DAY), 0, 'SYSTEM');
            END IF;
        END IF;
    END IF;
    
    IF CURDATE() BETWEEN '2015-04-01' AND '2015-08-31' THEN
        IF I_H_CNT > 0 THEN
            INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID) 
            VALUES (I_H_COUPON, I_USERID, NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 'SYSTEM');
        END IF;
    END IF;
    
    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_USER_ID, R1_MGNTNO, R1_PRICE, R1_SUBJECT_SJT_CD;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        SELECT SUBJECT_SJT_CD INTO I_SJT_CD
        FROM TB_LEC_MST 
        WHERE LEARNING_CD = 'M0101' AND UPPER(SUBJECT_TEACHER) = 'WGT53' AND SUBJECT_SJT_CD IN ('1005', '1008') AND LECCODE = R1_MGNTNO;

        SELECT IFNULL(COUNT(USERID),0) INTO I_W_CNT FROM TB_TM_MYCOUPON WHERE USERID = I_USERID AND CCODE = 'C131203001';

        IF I_SJT_CD = '1005' AND R1_PRICE > 0 AND I_W_CNT = 0 THEN  
            
            INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID) 
            VALUES ('C131203001', I_USERID, NOW(), NOW(), '2050-12-31', '0', I_USERID);
        END IF;
               
        SELECT IFNULL(COUNT(USERID),0) INTO I_W_CNT FROM TB_TM_MYCOUPON WHERE USERID = I_USERID AND CCODE = 'C131203002';

        IF I_SJT_CD = '1008' AND R1_PRICE > 0 AND I_W_CNT = 0 THEN 
            
            INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID) 
            VALUES ('C131203002', I_USERID, NOW(), NOW(), '2050-12-31', '0', I_USERID);
        END IF;

    END LOOP;
    CLOSE C1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CART_DELETE`(
    IN V_USERID VARCHAR(50),
    OUT V_RESULT INT
)
BEGIN
    DECLARE I_ON_CNT INT;
    DECLARE I_OFF_CNT INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;
    
    SET V_RESULT = 1;

    SELECT COUNT(*) INTO I_ON_CNT
    FROM TB_CC_CART
    WHERE USER_ID = V_USERID;
    
    SELECT COUNT(*) INTO I_OFF_CNT
    FROM TB_OFF_CC_CART
    WHERE USER_ID = V_USERID;
    
    IF I_ON_CNT > 0 THEN
        DELETE FROM TB_CC_CART 
        WHERE (REGDATE < DATE_SUB(NOW(), INTERVAL 3 DAY) OR SDATE < NOW())
        AND USER_ID = V_USERID;    
    END IF;
    
    IF I_OFF_CNT > 0 THEN
        DELETE FROM TB_OFF_CC_CART 
        WHERE REGDATE < DATE_SUB(NOW(), INTERVAL 3 DAY) 
        AND USER_ID = V_USERID;    
    END IF;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_BOOK_POINT`(
   IN V_ORDERNO VARCHAR(20),
   OUT V_RESULT INT
)
BEGIN
    DECLARE I_BOOKPOINT DECIMAL(10, 2);
    DECLARE I_USERID VARCHAR(50);
    DECLARE I_ORDERNO VARCHAR(20);
    DECLARE I_COMMENT VARCHAR(255);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    SELECT SUM(B.POINT) INTO I_BOOKPOINT
    FROM TB_ORDER_MGNT_NO A, TB_CA_BOOK B
    WHERE A.MGNTNO = B.RSC_ID
    AND A.ORDERNO = V_ORDERNO;

    SELECT DISTINCT REG_ID INTO I_USERID
    FROM TB_ORDER_MGNT_NO 
    WHERE ORDERNO = V_ORDERNO;
    
    SELECT DISTINCT ORDERNO INTO I_ORDERNO
    FROM TB_ORDER_MGNT_NO 
    WHERE ORDERNO = V_ORDERNO;

    UPDATE TB_MA_MEMBER SET USER_POINT = USER_POINT + I_BOOKPOINT
    WHERE USER_ID = I_USERID;
    
    SET I_COMMENT = '도서포인트 적립';
    
    INSERT INTO TB_MILEAGE_HISTORY(USERID, POINT, ORDERNO, MGNTNO, COMMENT1, MANAGER, SITE, REGDATE)
    VALUES(I_USERID, I_BOOKPOINT, I_ORDERNO, '', I_COMMENT, '', 'pass.willbes.net', NOW());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_EVENT_REPLY`(
   IN V_EVENT_NO VARCHAR(20),
   IN V_USER_ID VARCHAR(50),
   IN V_USER_NM VARCHAR(50),
   IN V_TXT VARCHAR(1000),
   OUT V_RESULT INT
)
BEGIN
    DECLARE I_CNT INT;
    DECLARE I_POINT DECIMAL(10, 2);
    DECLARE I_COUPON VARCHAR(20);
    DECLARE I_TXT VARCHAR(255);
    DECLARE I_EVENT_NO VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;
    SET I_POINT = 1000;
    SET I_TXT = '합격의 차이를 만드는 기적의 영어 이리라!';
    SET I_EVENT_NO = '242';
    SET I_COUPON = 'C131029001'; 
    
    INSERT INTO TB_EVENT_OPTION2(EVENT_NO, NO, USER_ID, USER_NM, TXT, REG_DT)
    VALUES(V_EVENT_NO, (SELECT IFNULL(MAX(NO),0) + 1 FROM TB_EVENT_OPTION2 WHERE EVENT_NO = V_EVENT_NO), 
            V_USER_ID, V_USER_NM, V_TXT, NOW());

    SELECT IFNULL(COUNT(EVENT_NO),0) INTO I_CNT
    FROM TB_TM_MYCOUPON
    WHERE USERID = V_USER_ID
    AND EVENT_NO = I_EVENT_NO;

    IF CURDATE() BETWEEN '2015-03-09' AND '2015-04-30' THEN
        IF V_EVENT_NO = I_EVENT_NO AND I_CNT = 0 THEN
            INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID, EVENT_NO) 
            VALUES (I_COUPON, V_USER_ID, NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 'SYSTEM', I_EVENT_NO);
        END IF;
    END IF;   
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_REPLY`(
   IN V_LECCODE VARCHAR(20),
   IN V_USER_ID VARCHAR(50),
   IN V_USER_NM VARCHAR(50),
   IN V_CONTENT TEXT,
   IN V_CHOICE_POINT INT,
   IN V_TITLE VARCHAR(255),
   OUT V_RESULT INT
)
BEGIN
    DECLARE I_DATE DATE;
    DECLARE I_EVENT_Y CHAR(1);
    DECLARE I_ORDERNO VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;
    
    SET V_RESULT = 1;

    INSERT INTO TB_COMMENT(LECCODE, USER_ID, USER_NAME, CONTENT, CHOICE_POINT, TITLE, REG_DT)
    VALUES(V_LECCODE, V_USER_ID, V_USER_NM, V_CONTENT, V_CHOICE_POINT, V_TITLE, NOW());

    IF CURDATE() BETWEEN '2014-09-06' AND '2014-09-11' THEN
        SELECT ORDERNO, IFNULL(FREE_ID, 'N'), END_DATE INTO I_ORDERNO, I_EVENT_Y, I_DATE 
        FROM (
            SELECT TM.*, RANK() OVER(PARTITION BY USERID ORDER BY END_DATE DESC, REG_DT DESC) AS `RANK`
            FROM TB_MYLECTURE TM
            WHERE USERID = V_USER_ID
            AND LECTURE_NO = V_LECCODE
            ORDER BY END_DATE DESC
        ) AS T
        WHERE `RANK` = 1;

        IF I_EVENT_Y != 'Y' AND I_DATE >= CURDATE() THEN
            UPDATE TB_MYLECTURE SET END_DATE = DATE_ADD(END_DATE, INTERVAL 5 DAY), FREE_ID = 'Y'
            WHERE LECTURE_NO = V_LECCODE 
            AND USERID = V_USER_ID
            AND ORDERNO = I_ORDERNO;
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LECTURE_BOOK_INSERT`(
  IN V_MSTCODE VARCHAR(20),
  IN V_RSC_ID VARCHAR(20),
  IN V_FLAG VARCHAR(10),
  IN V_BRIDGE_LEC VARCHAR(20),
  OUT V_RESULT INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_LECCODE VARCHAR(20);
    
    DECLARE C1 CURSOR FOR
        SELECT LECCODE
        FROM TB_LEC_BRIDGE
        WHERE BRIDGE_LECCODE = V_BRIDGE_LEC;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_LECCODE;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO TB_PLUS_CA_BOOK(LECCODE, RSC_ID, FLAG)
        VALUES(R1_LECCODE, V_RSC_ID, V_FLAG); 
    END LOOP;
    CLOSE C1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LECTURE_OFF_BOOK_INSERT`(
  IN V_LECCODE VARCHAR(20),
  IN V_RSC_ID VARCHAR(20),
  IN V_FLAG VARCHAR(10),
  IN V_BRIDGE_LEC VARCHAR(20),
  OUT V_RESULT INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_LECCODE VARCHAR(20);

    DECLARE C1 CURSOR FOR
        SELECT LECCODE 
        FROM TB_OFF_LEC_BRIDGE
        WHERE BRIDGE_LECCODE = V_BRIDGE_LEC;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_LECCODE;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO TB_OFF_PLUS_CA_BOOK(LECCODE, RSC_ID, FLAG)
        VALUES(R1_LECCODE, V_RSC_ID, V_FLAG); 
    END LOOP;
    CLOSE C1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_LECTURE_OFF_DAY_INSERT`(
  IN V_NUM INT,
  IN V_BRIDGE_LEC VARCHAR(20),
  IN V_LEC_DATE VARCHAR(10),
  OUT V_RESULT INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_LECCODE VARCHAR(20);

    DECLARE C1 CURSOR FOR
        SELECT LECCODE 
        FROM TB_OFF_LEC_BRIDGE
        WHERE BRIDGE_LECCODE = V_BRIDGE_LEC;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_LECCODE;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO TB_OFF_LECTURE_DATE(LECCODE, NUM, LEC_DATE)
        VALUES(R1_LECCODE, V_NUM, STR_TO_DATE(V_LEC_DATE, '%Y-%m-%d'));
    END LOOP;
    CLOSE C1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MAKE_GOSI_ADJUST`(
  IN V_GOSI_CD VARCHAR(20),
  IN V_RST_NO VARCHAR(20),
  IN V_SUBJECT_CD VARCHAR(20)
)
BEGIN
    DECLARE I_POINT DECIMAL(10, 2);
    DECLARE I_USR_CNT INT;
    DECLARE I_USR_AVR DECIMAL(10, 2);
    DECLARE I_GAP_POINT DECIMAL(20, 4) DEFAULT 0;
    DECLARE I_STN_DIV DECIMAL(20, 4) DEFAULT 0;
    DECLARE I_ADJ_POINT DECIMAL(10, 2);
    
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_SUM_POINT DECIMAL(10, 2);
    DECLARE R1_SBJ_TYPE VARCHAR(10);
    
    DECLARE C1 CURSOR FOR
        SELECT A.SUM_POINT, B.SBJ_TYPE
        FROM GOSI_RST_SBJ A, GOSI_SBJ_MST B
        WHERE A.SUBJECT_CD = B.SUBJECT_CD
        AND A.GOSI_CD = V_GOSI_CD
        AND A.SUBJECT_CD = V_SUBJECT_CD;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    
    SELECT SUM_POINT INTO I_POINT
    FROM GOSI_RST_SBJ
    WHERE GOSI_CD = V_GOSI_CD
    AND RST_NO = V_RST_NO
    AND SUBJECT_CD = V_SUBJECT_CD;
    
    
    SELECT REQ_USR_NUM, AVR_POINT, SDV INTO I_USR_CNT, I_USR_AVR, I_STN_DIV
    FROM GOSI_SBJ_MST
    WHERE SUBJECT_CD = V_SUBJECT_CD;
    
    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_SUM_POINT, R1_SBJ_TYPE;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        
        SET I_GAP_POINT = I_GAP_POINT + ((R1_SUM_POINT - I_USR_AVR) * (R1_SUM_POINT - I_USR_AVR));
    END LOOP;
    CLOSE C1;
    
    IF (I_GAP_POINT > 0 AND I_USR_CNT > 1) THEN
        SET I_STN_DIV = SQRT((I_GAP_POINT / (I_USR_CNT - 1))); 
        UPDATE GOSI_SBJ_MST SET SDV = ROUND(I_STN_DIV,2) WHERE GOSI_CD = V_GOSI_CD AND SUBJECT_CD = V_SUBJECT_CD; 
        SET I_ADJ_POINT = ( ( (I_POINT - I_USR_AVR) / I_STN_DIV ) * 10 ) + 50; 
    END IF;

    UPDATE GOSI_RST_SBJ SET 
    ADJ_POINT = ROUND(I_ADJ_POINT, 2)
    WHERE GOSI_CD = V_GOSI_CD 
    AND RST_NO = V_RST_NO
    AND SUBJECT_CD = V_SUBJECT_CD;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MAKE_GOSI_ADJ_MST`(
  IN V_GOSI_CD VARCHAR(20),
  OUT V_RESULT INT
)
BEGIN
    DECLARE I_RST_NO VARCHAR(20); 
    DECLARE I_SBJ_CD VARCHAR(20);
    
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_RST_NO VARCHAR(20);
    DECLARE R1_SUBJECT_CD VARCHAR(20);
    DECLARE R1_SUM_POINT DECIMAL(10, 2);
    DECLARE R1_SBJ_TYPE VARCHAR(10);
    
    DECLARE C1 CURSOR FOR
        SELECT A.RST_NO, A.SUBJECT_CD, A.SUM_POINT, B.SBJ_TYPE
        FROM GOSI_RST_SBJ A, GOSI_SBJ_MST B
        WHERE A.GOSI_CD = V_GOSI_CD
        AND A.SUBJECT_CD = B.SUBJECT_CD
        AND A.SUM_POINT IS NOT NULL;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;
    
    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_RST_NO, R1_SUBJECT_CD, R1_SUM_POINT, R1_SBJ_TYPE;
        IF done THEN
            LEAVE read_loop;
        END IF;
    
        IF R1_SBJ_TYPE = 'M' THEN
            UPDATE GOSI_RST_SBJ
            SET ADJ_POINT = R1_SUM_POINT
            WHERE GOSI_CD = V_GOSI_CD
            AND RST_NO = R1_RST_NO
            AND SUBJECT_CD = R1_SUBJECT_CD;
        ELSE 
            IF R1_SUBJECT_CD = 'S21' THEN
                UPDATE GOSI_RST_SBJ
                SET ADJ_POINT = R1_SUM_POINT
                WHERE GOSI_CD = V_GOSI_CD
                AND RST_NO = R1_RST_NO
                AND SUBJECT_CD = R1_SUBJECT_CD;
            ELSE 
                CALL SP_MAKE_GOSI_ADJUST(V_GOSI_CD, R1_RST_NO, R1_SUBJECT_CD);
            END IF;
        END IF;
    END LOOP;
    CLOSE C1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MAKE_GOSI_EXAM_RESULT`(
  IN V_GOSI_CD VARCHAR(20),
  IN V_RST_NO VARCHAR(20),
  IN V_SUBJECT_CD VARCHAR(20),
  OUT V_RESULT INT
)
BEGIN
    DECLARE I_PASS_ANS INT;
    DECLARE I_YN VARCHAR(1);
    DECLARE I_POINT DECIMAL(10, 2) DEFAULT 0;
    DECLARE I_ADD_POINT DECIMAL(10, 2);

    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_GOSI_CD VARCHAR(20);
    DECLARE R1_RST_NO VARCHAR(20);
    DECLARE R1_EXAM_TYPE VARCHAR(20);
    DECLARE R1_SUBJECT_CD VARCHAR(20);
    DECLARE R1_ITEM_NO INT;
    DECLARE R1_ANS INT;
    
    DECLARE C1 CURSOR FOR
        SELECT GOSI_CD, RST_NO, EXAM_TYPE, SUBJECT_CD, ITEM_NO, ANS
        FROM GOSI_RST_DET
        WHERE GOSI_CD = V_GOSI_CD
        AND RST_NO = V_RST_NO
        AND SUBJECT_CD = V_SUBJECT_CD;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    
    SELECT CASE ADD_POINT WHEN 'A' THEN 1 WHEN 'B' THEN 1 WHEN 'C' THEN 0.5 WHEN 'D' THEN 0.5 ELSE 0 END INTO I_ADD_POINT
    FROM GOSI_RST_MST
    WHERE GOSI_CD = V_GOSI_CD
    AND RST_NO = V_RST_NO;
    
    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_GOSI_CD, R1_RST_NO, R1_EXAM_TYPE, R1_SUBJECT_CD, R1_ITEM_NO, R1_ANS;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT PASS_ANS INTO I_PASS_ANS
        FROM GOSI_PASS_MST
        WHERE GOSI_CD = V_GOSI_CD 
        AND EXAM_TYPE = R1_EXAM_TYPE
        AND SUBJECT_CD = R1_SUBJECT_CD
        AND ITEM_NO = R1_ITEM_NO;
        
        IF I_PASS_ANS = R1_ANS THEN
            SET I_YN = 'Y';
            SET I_POINT = I_POINT + 5;
        ELSE
            SET I_YN = 'N';
        END IF;

        UPDATE GOSI_RST_DET SET 
        YN = I_YN
        WHERE GOSI_CD = V_GOSI_CD 
        AND RST_NO = V_RST_NO
        AND EXAM_TYPE = R1_EXAM_TYPE
        AND SUBJECT_CD = R1_SUBJECT_CD
        AND ITEM_NO = R1_ITEM_NO;
    END LOOP;    
    CLOSE C1;

    UPDATE GOSI_RST_SBJ SET 
    SUM_POINT = I_POINT + I_ADD_POINT
    WHERE GOSI_CD = V_GOSI_CD 
    AND RST_NO = V_RST_NO
    AND SUBJECT_CD = V_SUBJECT_CD;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MAKE_GOSI_STANDARD`(
  IN V_GOSI_CD VARCHAR(20)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_SUBJECT_CD VARCHAR(20);
    DECLARE R1_CNT_SUM_POINT INT;
    DECLARE R1_TOT_SUM_POINT DECIMAL(10, 2);
    DECLARE R1_AVR_POINT DECIMAL(10, 2);

    
    DECLARE C1 CURSOR FOR
        SELECT C.SUBJECT_CD, 
        IFNULL(COUNT(C.SUM_POINT),0) AS CNT_SUM_POINT, 
        IFNULL(SUM(C.SUM_POINT),0) AS TOT_SUM_POINT,
        ROUND(IFNULL(SUM(C.SUM_POINT)/COUNT(C.SUM_POINT),0),2) AS AVR_POINT
        FROM GOSI_RST_MST B, GOSI_RST_SBJ C
        WHERE B.RST_NO = C.RST_NO
        AND B.GOSI_CD = V_GOSI_CD
        GROUP BY C.SUBJECT_CD;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_SUBJECT_CD, R1_CNT_SUM_POINT, R1_TOT_SUM_POINT, R1_AVR_POINT;
        IF done THEN
            LEAVE read_loop;
        END IF;

        UPDATE GOSI_SBJ_MST 
        SET 
        REQ_USR_NUM = R1_CNT_SUM_POINT, 
        SUM_POINT = R1_TOT_SUM_POINT, 
        AVR_POINT = R1_AVR_POINT
        WHERE GOSI_CD = V_GOSI_CD 
        AND SUBJECT_CD = R1_SUBJECT_CD;
            
    END LOOP;
    CLOSE C1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MAKE_GOSI_STAT`(
  IN V_GOSI_CD VARCHAR(20),
  OUT V_RESULT INT
)
BEGIN
    DECLARE I_PASS_ANS INT;
    DECLARE I_YN VARCHAR(1);
    DECLARE I_POINT DECIMAL(10, 2);
    DECLARE I_SUBJECT_CD VARCHAR(20);
    DECLARE I_SUM_POINT DECIMAL(10, 2);
    DECLARE I_RANK INT;
    DECLARE I_AVR DECIMAL(10, 2);
    DECLARE I_ADJ_AVR DECIMAL(10, 2);
    DECLARE I_3_NUM INT;
    DECLARE I_10_NUM INT;
    DECLARE I_3_AVR DECIMAL(10, 2);
    DECLARE I_10_AVR DECIMAL(10, 2);
    DECLARE I_ADJ_3_NUM INT;
    DECLARE I_ADJ_10_NUM INT;
    DECLARE I_ADJ_3_AVR DECIMAL(10, 2);
    DECLARE I_ADJ_10_AVR DECIMAL(10, 2);

    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_GOSI_TYPE VARCHAR(20);
    DECLARE R1_GOSI_AREA VARCHAR(20);
    DECLARE R1_SUBJECT_CD VARCHAR(20);
    DECLARE R1_CNT_SUM_POINT INT;
    DECLARE R1_CNT_ADJ_POINT INT;
    DECLARE R1_TOT_SUM_POINT DECIMAL(10, 2);
    DECLARE R1_TOT_ADJ_POINT DECIMAL(10, 2);
    
    
    DECLARE C1 CURSOR FOR
        SELECT A.GOSI_TYPE, A.GOSI_AREA, C.SUBJECT_CD, 
        IFNULL(COUNT(C.SUM_POINT),0) AS CNT_SUM_POINT, IFNULL(COUNT(C.ADJ_POINT),0) AS CNT_ADJ_POINT,
        IFNULL(SUM(C.SUM_POINT),0) AS TOT_SUM_POINT, IFNULL(SUM(C.ADJ_POINT),0) AS TOT_ADJ_POINT
        FROM GOSI_AREA_MST A, GOSI_RST_MST B, GOSI_RST_SBJ C
        WHERE A.GOSI_TYPE = B.GOSI_TYPE
        AND A.GOSI_AREA = B.GOSI_AREA
        AND B.RST_NO = C.RST_NO
        AND B.GOSI_CD = V_GOSI_CD
        GROUP BY A.GOSI_TYPE, A.GOSI_AREA, C.SUBJECT_CD;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;
    
    DELETE FROM GOSI_STAT_MST WHERE GOSI_CD = V_GOSI_CD; 

    SET I_POINT = 0;
    
    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_GOSI_TYPE, R1_GOSI_AREA, R1_SUBJECT_CD, R1_CNT_SUM_POINT, R1_CNT_ADJ_POINT, R1_TOT_SUM_POINT, R1_TOT_ADJ_POINT;
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF R1_CNT_SUM_POINT > 0 THEN
            SET I_3_NUM = TRUNCATE(R1_CNT_SUM_POINT * 0.03, 0);
            SET I_10_NUM = TRUNCATE(R1_CNT_SUM_POINT * 0.1, 0);
            SET I_3_AVR = 0;
            SET I_10_AVR = 0;
        
            
            IF I_3_NUM > 0 THEN
                SELECT ROUND(SUM(SUM_POINT)/COUNT(SUM_POINT), 2) INTO I_3_AVR
                FROM (SELECT B.SUBJECT_CD, B.SUM_POINT,
                       RANK() OVER(PARTITION BY B.SUBJECT_CD ORDER BY B.SUM_POINT DESC) AS RNK
                FROM GOSI_RST_MST A, GOSI_RST_SBJ B, GOSI_AREA_MST C, GOSI_SUBJECT D
                WHERE B.SUM_POINT IS NOT NULL
                AND A.GOSI_CD = B.GOSI_CD
                AND A.RST_NO = B.RST_NO
                AND A.GOSI_TYPE = C.GOSI_TYPE
                AND A.GOSI_AREA = C.GOSI_AREA
                AND A.GOSI_TYPE = D.GOSI_TYPE
                AND B.SUBJECT_CD = D.GOSI_SUBJECT_CD
                AND A.GOSI_TYPE = R1_GOSI_TYPE
                AND A.GOSI_AREA = R1_GOSI_AREA
                AND B.SUBJECT_CD = R1_SUBJECT_CD
                ORDER BY B.SUBJECT_CD, SUM_POINT DESC ) T
                WHERE RNK <= I_3_NUM;
             END IF;

            
            IF I_10_NUM > 0 THEN
                SELECT ROUND(SUM(SUM_POINT)/COUNT(SUM_POINT), 2) INTO I_10_AVR
                FROM (SELECT B.SUBJECT_CD, B.SUM_POINT,
                       RANK() OVER(PARTITION BY B.SUBJECT_CD ORDER BY B.SUM_POINT DESC) RNK
                FROM GOSI_RST_MST A, GOSI_RST_SBJ B, GOSI_AREA_MST C, GOSI_SUBJECT D
                WHERE B.SUM_POINT IS NOT NULL
                AND A.GOSI_CD = B.GOSI_CD
                AND A.RST_NO = B.RST_NO
                AND A.GOSI_TYPE = C.GOSI_TYPE
                AND A.GOSI_AREA = C.GOSI_AREA
                AND A.GOSI_TYPE = D.GOSI_TYPE
                AND B.SUBJECT_CD = D.GOSI_SUBJECT_CD
                AND A.GOSI_TYPE = R1_GOSI_TYPE
                AND A.GOSI_AREA = R1_GOSI_AREA
                AND B.SUBJECT_CD = R1_SUBJECT_CD
                ORDER BY B.SUBJECT_CD, SUM_POINT DESC ) T
                WHERE RNK <= I_10_NUM;
            END IF;
        
            SET I_ADJ_3_NUM = TRUNCATE(R1_CNT_ADJ_POINT * 0.03, 0);
            SET I_ADJ_10_NUM = TRUNCATE(R1_CNT_ADJ_POINT * 0.1, 0);
            SET I_ADJ_3_AVR = 0;
            SET I_ADJ_10_AVR = 0;
        
            
            IF I_ADJ_3_NUM > 0 THEN
                SELECT ROUND(SUM(ADJ_POINT)/COUNT(ADJ_POINT), 2) INTO I_ADJ_3_AVR
                FROM (SELECT B.SUBJECT_CD, B.ADJ_POINT,
                       RANK() OVER(PARTITION BY B.SUBJECT_CD ORDER BY B.ADJ_POINT DESC) RNK
                FROM GOSI_RST_MST A, GOSI_RST_SBJ B, GOSI_AREA_MST C, GOSI_SUBJECT D
                WHERE B.ADJ_POINT IS NOT NULL
                AND A.GOSI_CD = B.GOSI_CD
                AND A.RST_NO = B.RST_NO
                AND A.GOSI_TYPE = C.GOSI_TYPE
                AND A.GOSI_AREA = C.GOSI_AREA
                AND A.GOSI_TYPE = D.GOSI_TYPE
                AND B.SUBJECT_CD = D.GOSI_SUBJECT_CD
                AND A.GOSI_TYPE = R1_GOSI_TYPE
                AND A.GOSI_AREA = R1_GOSI_AREA
                AND B.SUBJECT_CD = R1_SUBJECT_CD
                ORDER BY B.SUBJECT_CD, ADJ_POINT DESC ) T
                WHERE RNK <= I_ADJ_3_NUM;
             END IF;

            
            IF I_ADJ_10_NUM > 0 THEN
                SELECT ROUND(SUM(ADJ_POINT)/COUNT(ADJ_POINT), 2) INTO I_ADJ_10_AVR
                FROM (SELECT B.SUBJECT_CD, B.ADJ_POINT,
                       RANK() OVER(PARTITION BY B.SUBJECT_CD ORDER BY B.ADJ_POINT DESC) RNK
                FROM GOSI_RST_MST A, GOSI_RST_SBJ B, GOSI_AREA_MST C, GOSI_SUBJECT D
                WHERE B.ADJ_POINT IS NOT NULL
                AND A.GOSI_CD = B.GOSI_CD
                AND A.RST_NO = B.RST_NO
                AND A.GOSI_TYPE = C.GOSI_TYPE
                AND A.GOSI_AREA = C.GOSI_AREA
                AND A.GOSI_TYPE = D.GOSI_TYPE
                AND B.SUBJECT_CD = D.GOSI_SUBJECT_CD
                AND A.GOSI_TYPE = R1_GOSI_TYPE
                AND A.GOSI_AREA = R1_GOSI_AREA
                AND B.SUBJECT_CD = R1_SUBJECT_CD
                ORDER BY B.SUBJECT_CD, ADJ_POINT DESC ) T
                WHERE RNK <= I_ADJ_10_NUM;
            END IF;
        
            SET I_AVR = 0;
            SET I_ADJ_AVR = 0;
            
            IF R1_CNT_SUM_POINT > 0 THEN 
                SET I_AVR = ROUND(R1_TOT_SUM_POINT/R1_CNT_SUM_POINT, 2);
            END IF;
            IF R1_CNT_ADJ_POINT > 0 THEN 
                SET I_ADJ_AVR = ROUND(R1_TOT_ADJ_POINT/R1_CNT_ADJ_POINT, 2);
            END IF;
            
            INSERT INTO GOSI_STAT_MST (
                GOSI_CD, GOSI_TYPE, GOSI_AREA, GOSI_SUBJECT_CD,
                GOSI_USER_NUM, 
                GOSI_AVR_POINT, GOSI_3_POINT, GOSI_10_POINT,
                GOSI_ADJ_AVR_POINT, GOSI_ADJ_3_POINT, GOSI_ADJ_10_POINT
            ) VALUES (
                V_GOSI_CD, R1_GOSI_TYPE, R1_GOSI_AREA, R1_SUBJECT_CD,
                R1_CNT_SUM_POINT, 
                I_AVR, I_3_AVR, I_10_AVR,
                I_ADJ_AVR, I_ADJ_3_AVR, I_ADJ_10_AVR
            );
        END IF;
    END LOOP;    
    CLOSE C1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MAKE_OFF_SALES_STAT`(
  IN V_YEAR VARCHAR(4),
  OUT V_RESULT INT
)
BEGIN
    DECLARE I_CNT INT;
    DECLARE I_YEAR VARCHAR(4);
    DECLARE I_MONTH VARCHAR(2);
    
    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_I_DAY VARCHAR(7);
    DECLARE R1_SUBJECT_TEACHER VARCHAR(50);
    DECLARE R1_CNT_MGNTNO INT;
    DECLARE R1_SUM_PRICE DECIMAL(10, 2);

    DECLARE C1 CURSOR FOR
        SELECT DATE_FORMAT(A.REG_DT, '%Y-%m') AS I_DAY, D.SUBJECT_TEACHER, COUNT(B.MGNTNO) AS CNT_MGNTNO, SUM(B.PRICE) AS SUM_PRICE
        FROM TB_OFF_ORDERS A, TB_OFF_ORDER_MGNT_NO B, TB_OFF_MYLECTURE C, TB_OFF_LEC_MST D
        WHERE A.ORDERNO = B.ORDERNO
        AND A.ORDERNO = C.ORDERNO
        AND A.USER_ID = C.USERID
        AND B.MGNTNO = C.PACKAGE_NO
        AND B.MGNTNO = C.LECTURE_NO
        AND B.MGNTNO = D.LECCODE
        AND DATE_FORMAT(A.REG_DT, '%Y') = V_YEAR
        AND B.STATUSCODE = 'DLV105'
        GROUP BY DATE_FORMAT(A.REG_DT, '%Y-%m'), D.SUBJECT_TEACHER;

    DECLARE C2 CURSOR FOR
        SELECT DATE_FORMAT(B.CANCELDATE, '%Y-%m') AS I_DAY, D.SUBJECT_TEACHER, COUNT(B.MGNTNO) AS CNT_MGNTNO, SUM(B.PRICE) AS SUM_PRICE
        FROM TB_OFF_ORDERS A, TB_OFF_ORDER_MGNT_NO B, TB_OFF_MYLECTURE C, TB_OFF_LEC_MST D
        WHERE A.ORDERNO = B.ORDERNO
        AND A.ORDERNO = C.ORDERNO
        AND A.USER_ID = C.USERID
        AND B.MGNTNO = C.PACKAGE_NO
        AND B.MGNTNO = C.LECTURE_NO
        AND B.MGNTNO = D.LECCODE
        AND B.STATUSCODE = 'DLV230'
        GROUP BY DATE_FORMAT(B.CANCELDATE, '%Y-%m'), D.SUBJECT_TEACHER;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    OPEN C1;
    read_loop1: LOOP
        FETCH C1 INTO R1_I_DAY, R1_SUBJECT_TEACHER, R1_CNT_MGNTNO, R1_SUM_PRICE;
        IF done THEN
            SET done = FALSE;
            LEAVE read_loop1;
        END IF;
        
        SET I_YEAR = SUBSTRING(R1_I_DAY, 1, 4);
        SET I_MONTH = SUBSTRING(R1_I_DAY, 6, 2);
        SELECT IFNULL(COUNT(*),0) INTO I_CNT FROM TB_STAT_PRF WHERE S_YEAR = I_YEAR AND S_MONTH = I_MONTH AND S_TYPE = 'ON' AND PRF_ID = R1_SUBJECT_TEACHER;
        
        IF I_CNT = 0 THEN
            INSERT INTO TB_STAT_PRF(S_YEAR, S_MONTH, S_TYPE, PRF_ID, SALE_CNT, REFUND_CNT, SALE_SUM, REFUND_SUM) 
            VALUES (I_YEAR, I_MONTH, 'ON', R1_SUBJECT_TEACHER, R1_CNT_MGNTNO, 0, R1_SUM_PRICE, 0);
        ELSE
            UPDATE TB_STAT_PRF SET SALE_CNT = R1_CNT_MGNTNO, SALE_SUM = R1_SUM_PRICE
            WHERE S_YEAR = I_YEAR AND S_MONTH = I_MONTH AND S_TYPE = 'ON' AND PRF_ID = R1_SUBJECT_TEACHER;
        END IF;
    END LOOP;    
    CLOSE C1;

    OPEN C2;
    read_loop2: LOOP
        FETCH C2 INTO R1_I_DAY, R1_SUBJECT_TEACHER, R1_CNT_MGNTNO, R1_SUM_PRICE;
        IF done THEN
            LEAVE read_loop2;
        END IF;
        
        SET I_YEAR = SUBSTRING(R1_I_DAY, 1, 4);
        SET I_MONTH = SUBSTRING(R1_I_DAY, 6, 2);
        SELECT IFNULL(COUNT(*),0) INTO I_CNT FROM TB_STAT_PRF WHERE S_YEAR = I_YEAR AND S_MONTH = I_MONTH AND S_TYPE = 'ON' AND PRF_ID = R1_SUBJECT_TEACHER;
        
        IF I_CNT = 0 THEN
            INSERT INTO TB_STAT_PRF(S_YEAR, S_MONTH, S_TYPE, PRF_ID, SALE_CNT, REFUND_CNT, SALE_SUM, REFUND_SUM) 
            VALUES (I_YEAR, I_MONTH, 'ON', R1_SUBJECT_TEACHER, 0, R1_CNT_MGNTNO, 0, R1_SUM_PRICE);
        ELSE
            UPDATE TB_STAT_PRF SET REFUND_CNT = R1_CNT_MGNTNO, REFUND_SUM = R1_SUM_PRICE
            WHERE S_YEAR = I_YEAR AND S_MONTH = I_MONTH AND S_TYPE = 'ON' AND PRF_ID = R1_SUBJECT_TEACHER;
        END IF;
    END LOOP;    
    CLOSE C2;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_MAKE_ON_SALES_STAT`(
  IN V_YEAR VARCHAR(4),
  OUT V_RESULT INT
)
BEGIN
    DECLARE I_CNT INT;
    DECLARE I_YEAR VARCHAR(4);
    DECLARE I_MONTH VARCHAR(2);

    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_I_DAY VARCHAR(7);
    DECLARE R1_SUBJECT_TEACHER VARCHAR(50);
    DECLARE R1_CNT_MGNTNO INT;
    DECLARE R1_SUM_PRICE DECIMAL(10, 2);

    DECLARE C1 CURSOR FOR
        SELECT DATE_FORMAT(A.REG_DT, '%Y-%m') AS I_DAY, D.SUBJECT_TEACHER, COUNT(B.MGNTNO) AS CNT_MGNTNO, SUM(B.PRICE) AS SUM_PRICE
        FROM TB_ORDERS A, TB_ORDER_MGNT_NO B, TB_MYLECTURE C, TB_LEC_MST D
        WHERE A.ORDERNO = B.ORDERNO
        AND A.ORDERNO = C.ORDERNO
        AND A.USER_ID = C.USERID
        AND B.MGNTNO = C.PACKAGE_NO
        AND B.MGNTNO = C.LECTURE_NO
        AND B.MGNTNO = D.LECCODE
        AND DATE_FORMAT(A.REG_DT, '%Y') = V_YEAR
        AND B.STATUSCODE = 'DLV105'
        GROUP BY DATE_FORMAT(A.REG_DT, '%Y-%m'), D.SUBJECT_TEACHER;

    DECLARE C2 CURSOR FOR
        SELECT DATE_FORMAT(B.CANCELDATE, '%Y-%m') AS I_DAY, D.SUBJECT_TEACHER, COUNT(B.MGNTNO) AS CNT_MGNTNO, SUM(B.PRICE) AS SUM_PRICE
        FROM TB_ORDERS A, TB_ORDER_MGNT_NO B, TB_MYLECTURE C, TB_LEC_MST D
        WHERE A.ORDERNO = B.ORDERNO
        AND A.ORDERNO = C.ORDERNO
        AND A.USER_ID = C.USERID
        AND B.MGNTNO = C.PACKAGE_NO
        AND B.MGNTNO = C.LECTURE_NO
        AND B.MGNTNO = D.LECCODE
        AND B.STATUSCODE = 'DLV230'
        GROUP BY DATE_FORMAT(B.CANCELDATE, '%Y-%m'), D.SUBJECT_TEACHER;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;
    
    OPEN C1;
    read_loop1: LOOP
        FETCH C1 INTO R1_I_DAY, R1_SUBJECT_TEACHER, R1_CNT_MGNTNO, R1_SUM_PRICE;
        IF done THEN
            SET done = FALSE;
            LEAVE read_loop1;
        END IF;
        
        SET I_YEAR = SUBSTRING(R1_I_DAY, 1, 4);
        SET I_MONTH = SUBSTRING(R1_I_DAY, 6, 2);
        SELECT IFNULL(COUNT(*),0) INTO I_CNT FROM TB_STAT_PRF WHERE S_YEAR = I_YEAR AND S_MONTH = I_MONTH AND S_TYPE = 'ON' AND PRF_ID = R1_SUBJECT_TEACHER;
        
        IF I_CNT = 0 THEN
            INSERT INTO TB_STAT_PRF(S_YEAR, S_MONTH, S_TYPE, PRF_ID, SALE_CNT, REFUND_CNT, SALE_SUM, REFUND_SUM) 
            VALUES (I_YEAR, I_MONTH, 'ON', R1_SUBJECT_TEACHER, R1_CNT_MGNTNO, 0, R1_SUM_PRICE, 0);
        ELSE
            UPDATE TB_STAT_PRF SET SALE_CNT = R1_CNT_MGNTNO, SALE_SUM = R1_SUM_PRICE
            WHERE S_YEAR = I_YEAR AND S_MONTH = I_MONTH AND S_TYPE = 'ON' AND PRF_ID = R1_SUBJECT_TEACHER;
        END IF;
    END LOOP;    
    CLOSE C1;

    OPEN C2;
    read_loop2: LOOP
        FETCH C2 INTO R1_I_DAY, R1_SUBJECT_TEACHER, R1_CNT_MGNTNO, R1_SUM_PRICE;
        IF done THEN
            LEAVE read_loop2;
        END IF;
        
        SET I_YEAR = SUBSTRING(R1_I_DAY, 1, 4);
        SET I_MONTH = SUBSTRING(R1_I_DAY, 6, 2);
        SELECT IFNULL(COUNT(*),0) INTO I_CNT FROM TB_STAT_PRF WHERE S_YEAR = I_YEAR AND S_MONTH = I_MONTH AND S_TYPE = 'ON' AND PRF_ID = R1_SUBJECT_TEACHER;
        
        IF I_CNT = 0 THEN
            INSERT INTO TB_STAT_PRF(S_YEAR, S_MONTH, S_TYPE, PRF_ID, SALE_CNT, REFUND_CNT, SALE_SUM, REFUND_SUM) 
            VALUES (I_YEAR, I_MONTH, 'ON', R1_SUBJECT_TEACHER, 0, R1_CNT_MGNTNO, 0, R1_SUM_PRICE);
        ELSE
            UPDATE TB_STAT_PRF SET REFUND_CNT = R1_CNT_MGNTNO, REFUND_SUM = R1_SUM_PRICE
            WHERE S_YEAR = I_YEAR AND S_MONTH = I_MONTH AND S_TYPE = 'ON' AND PRF_ID = R1_SUBJECT_TECHEAR;
        END IF;
    END LOOP;    
    CLOSE C2;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_NEW_MEMBER_INSERT_EVENT`(
   IN V_USER_ID VARCHAR(50),
   OUT V_RESULT INT
)
BEGIN
    DECLARE I_POINT DECIMAL(10, 2);
    DECLARE I_COUPON VARCHAR(20);
    DECLARE I_CNT INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    IF CURDATE() BETWEEN '2015-02-10' AND '2015-02-22' THEN
        SET I_POINT = 10000;
        
        UPDATE TB_MA_MEMBER SET USER_POINT = USER_POINT + I_POINT WHERE USER_ID = V_USER_ID;

        INSERT INTO TB_MILEAGE_HISTORY (USERID, POINT, COMMENT1, MANAGER, SITE, REGDATE) 
        VALUES (V_USER_ID, I_POINT, '윌비스 패밀리 이벤트 포인트 적립', V_USER_ID, 'PASS.WILLBES.NET', NOW());
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_NEW_MEMBER_UPDATE_EVENT`(
   IN V_USER_ID VARCHAR(50),
   OUT V_RESULT INT
)
BEGIN
    DECLARE I_POINT DECIMAL(10, 2);
    DECLARE I_COUPON VARCHAR(20);
    DECLARE I_CNT INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;

    IF CURDATE() BETWEEN '2015-02-10' AND '2015-02-22' THEN
        SET I_POINT = 5000;
        SET I_COUPON = 'C110531560'; 
            
        SELECT IFNULL(COUNT(*),0) INTO I_CNT
        FROM TB_TM_MYCOUPON
        WHERE USERID = V_USER_ID
        AND DATE(REGDATE) BETWEEN '2015-02-10' AND '2015-02-22'
        AND CCODE = I_COUPON;

        IF I_CNT = 0 THEN
            INSERT INTO TB_TM_MYCOUPON(CCODE, USERID, REGDATE, EXPDATES, EXPDATEE, ORDERFLAG, REG_ID) 
            VALUES (I_COUPON, V_USER_ID, NOW(), NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 0, 'SYSTEM');
            
            UPDATE TB_MA_MEMBER SET USER_POINT = USER_POINT + I_POINT WHERE USER_ID = V_USER_ID;

            INSERT INTO TB_MILEAGE_HISTORY (USERID, POINT, COMMENT1, MANAGER, SITE, REGDATE) 
            VALUES (V_USER_ID, I_POINT, '윌비스 패밀리 이벤트 포인트 적립', V_USER_ID, 'PASS.WILLBES.NET', NOW());
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SNS_INSERT_POINT`(
   IN V_EVENT_NO VARCHAR(20),
   IN V_NO INT,
   IN V_USER_ID VARCHAR(50),
   OUT V_RESULT INT
)
BEGIN
    DECLARE I_USERID VARCHAR(50);
    DECLARE I_SUM DECIMAL(10, 2);
    DECLARE I_POINT DECIMAL(10, 2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        SET V_RESULT = @errno;
    end;

    SET V_RESULT = 1;
    SET I_POINT = 10000;

    IF CURDATE() BETWEEN '2014-09-15' AND '2014-09-26' THEN
        IF I_SUM >= 100000 THEN
            UPDATE TB_MA_MEMBER SET USER_POINT = USER_POINT + I_POINT WHERE USER_ID = I_USERID;

            INSERT INTO TB_MILEAGE_HISTORY (USERID, POINT, COMMENT1, MANAGER, SITE, REGDATE) 
            VALUES (I_USERID, I_POINT, '수강받Go교재받Go 알림이벤트 포인트 적립', I_USERID, 'pass.willbes.net', NOW());
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UPDATE_CART_JONG`(IN V_USER_ID VARCHAR(50), IN V_LECCODE VARCHAR(255))
BEGIN
    DECLARE I_CNT INT;
    DECLARE I_SUM DECIMAL(19,4);
    DECLARE I_ORG_SUM DECIMAL(19,4);
    DECLARE I_AVR DECIMAL(19,4);
    DECLARE I_PRICE DECIMAL(19,4);
    DECLARE I_REAL_PRICE DECIMAL(19,4);
    DECLARE I_LECCODE VARCHAR(255);

    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_LECCODE VARCHAR(255);
    DECLARE R1_KIND_TYPE VARCHAR(255); 
    DECLARE R1_MST_LECCODE VARCHAR(255);
    DECLARE R1_PRICE DECIMAL(19,4);
    DECLARE R1_RANC INT;
    
    DECLARE C1 CURSOR FOR
        SELECT A.LECCODE, A.KIND_TYPE, B.MST_LECCODE, B.PRICE,
               RANK() OVER(PARTITION BY B.LECCODE ORDER BY C.SUBJECT_PRICE ASC) AS RANC
        FROM TB_CC_CART A
        JOIN TB_CC_J_CART B ON A.USER_ID = B.UPDATE_ID AND A.LECCODE = B.LECCODE
        JOIN TB_LEC_MST C ON B.MST_LECCODE = C.LECCODE
        WHERE A.USER_ID = V_USER_ID
        AND A.LECCODE = V_LECCODE;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT SUM(B.PRICE), SUM(C.SUBJECT_PRICE) INTO I_SUM, I_ORG_SUM
    FROM TB_CC_CART A
    JOIN TB_CC_J_CART B ON A.USER_ID = B.UPDATE_ID AND A.LECCODE = B.LECCODE
    JOIN TB_LEC_MST C ON B.MST_LECCODE = C.LECCODE
    WHERE A.USER_ID = V_USER_ID
    AND A.LECCODE = V_LECCODE;

    IF I_ORG_SUM > 0 THEN
        SET I_AVR = I_SUM / I_ORG_SUM;
    ELSE
        SET I_AVR = 0;
    END IF;
    
    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_LECCODE, R1_KIND_TYPE, R1_MST_LECCODE, R1_PRICE, R1_RANC;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT SUBJECT_PRICE INTO I_PRICE FROM TB_LEC_MST WHERE LECCODE = R1_MST_LECCODE;
        
        IF R1_RANC > 1 THEN
            SET I_REAL_PRICE = TRUNCATE((I_PRICE * I_AVR)/100, 0) * 100;
            SET I_LECCODE = R1_MST_LECCODE;
        ELSE
            SET I_REAL_PRICE = ROUND((I_PRICE * I_AVR)/100) * 100;
        END IF;

        UPDATE TB_CC_J_CART
        SET PRICE = I_REAL_PRICE
        WHERE UPDATE_ID = V_USER_ID
        AND LECCODE = V_LECCODE
        AND MST_LECCODE = R1_MST_LECCODE;
        
        SET I_SUM = I_SUM - I_REAL_PRICE;
        
    END LOOP;
    CLOSE C1;
    
    IF I_SUM < 0 THEN
        UPDATE TB_CC_J_CART
        SET PRICE = PRICE + I_SUM
        WHERE UPDATE_ID = V_USER_ID
        AND LECCODE = V_LECCODE
        AND MST_LECCODE = I_LECCODE;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `UPDATE_OFF_CART_JONG`(IN V_USER_ID VARCHAR(50))
BEGIN
    DECLARE I_CNT INT;
    DECLARE I_SUM DECIMAL(19,4);
    DECLARE I_ORG_SUM DECIMAL(19,4);
    DECLARE I_AVR DECIMAL(19,4);
    DECLARE I_PRICE DECIMAL(19,4);
    DECLARE I_REAL_PRICE DECIMAL(19,4);
    DECLARE I_LECCODE VARCHAR(255);

    DECLARE done INT DEFAULT FALSE;
    DECLARE R1_LECCODE VARCHAR(255);
    DECLARE R1_KIND_TYPE VARCHAR(255); 
    DECLARE R1_MST_LECCODE VARCHAR(255);
    DECLARE R1_PRICE DECIMAL(19,4);
    DECLARE R1_SUBJECT_REAL_PRICE DECIMAL(19,4);
    DECLARE R1_RANC INT;

    DECLARE C1 CURSOR FOR
        SELECT A.LECCODE, A.KIND_TYPE, B.MST_LECCODE, B.PRICE, C.SUBJECT_REAL_PRICE,
               RANK() OVER(PARTITION BY B.LECCODE ORDER BY C.SUBJECT_REAL_PRICE ASC) AS RANC
        FROM TB_OFF_CC_CART A
        JOIN TB_OFF_CC_J_CART B ON A.USER_ID = B.UPDATE_ID
        JOIN TB_OFF_LEC_MST C ON B.MST_LECCODE = C.LECCODE
        WHERE A.USER_ID = V_USER_ID;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT SUM(B.PRICE), SUM(C.SUBJECT_REAL_PRICE) INTO I_SUM, I_ORG_SUM
    FROM TB_OFF_CC_CART A
    JOIN TB_OFF_CC_J_CART B ON A.USER_ID = B.UPDATE_ID
    JOIN TB_OFF_LEC_MST C ON B.MST_LECCODE = C.LECCODE
    WHERE A.USER_ID = V_USER_ID;

    IF I_ORG_SUM > 0 THEN
        SET I_AVR = I_SUM / I_ORG_SUM;
    ELSE
        SET I_AVR = 0;
    END IF;

    OPEN C1;
    read_loop: LOOP
        FETCH C1 INTO R1_LECCODE, R1_KIND_TYPE, R1_MST_LECCODE, R1_PRICE, R1_SUBJECT_REAL_PRICE, R1_RANC;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT SUBJECT_REAL_PRICE INTO I_PRICE FROM TB_OFF_LEC_MST WHERE LECCODE = R1_MST_LECCODE;
        
        IF R1_RANC > 1 THEN
            SET I_REAL_PRICE = TRUNCATE((I_PRICE * I_AVR)/100, 0) * 100;
            SET I_LECCODE = R1_MST_LECCODE;
        ELSE
            SET I_REAL_PRICE = ROUND((I_PRICE * I_AVR)/100) * 100;
        END IF;

        UPDATE TB_OFF_CC_J_CART
        SET PRICE = I_REAL_PRICE
        WHERE UPDATE_ID = V_USER_ID
        AND MST_LECCODE = R1_MST_LECCODE;
        
        SET I_SUM = I_SUM - I_REAL_PRICE;
        
    END LOOP;
    CLOSE C1;
    
    IF I_SUM < 0 THEN
        UPDATE TB_OFF_CC_J_CART
        SET PRICE = PRICE + I_SUM
        WHERE UPDATE_ID = V_USER_ID
        AND MST_LECCODE = I_LECCODE;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

