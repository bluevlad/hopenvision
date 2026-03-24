package com.hopenvision.exam.service;

import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.hopenvision.user.entity.UserScore;
import com.hopenvision.user.entity.UserTotalScore;
import com.hopenvision.user.repository.UserScoreRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class ExcelExportService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository subjectRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;
    private final UserScoreRepository userScoreRepository;

    /**
     * 시험 성적 데이터를 Excel 파일로 내보내기
     */
    public byte[] exportScores(String examCd) throws IOException {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        List<UserTotalScore> totalScores = userTotalScoreRepository.findByExamCdOrderByTotalScoreDesc(examCd);

        // 사용자별 과목 점수 맵 구성
        Map<String, List<UserScore>> userScoresMap = totalScores.stream()
                .collect(Collectors.toMap(
                        UserTotalScore::getUserId,
                        ts -> userScoreRepository.findByUserIdAndExamCd(ts.getUserId(), examCd)
                ));

        try (XSSFWorkbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("성적");

            // 헤더 스타일
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);

            // 헤더 행 생성
            Row headerRow = sheet.createRow(0);
            int colIdx = 0;
            String[] fixedHeaders = {"사용자ID", "총점", "평균", "석차", "백분위", "합격여부", "과락여부"};
            for (String h : fixedHeaders) {
                Cell cell = headerRow.createCell(colIdx++);
                cell.setCellValue(h);
                cell.setCellStyle(headerStyle);
            }
            // 과목별 헤더
            for (ExamSubject subject : subjects) {
                Cell cell = headerRow.createCell(colIdx++);
                cell.setCellValue(subject.getSubjectNm() + " (점수)");
                cell.setCellStyle(headerStyle);

                Cell cell2 = headerRow.createCell(colIdx++);
                cell2.setCellValue(subject.getSubjectNm() + " (정답수)");
                cell2.setCellStyle(headerStyle);
            }

            // 숫자 스타일
            CellStyle numberStyle = workbook.createCellStyle();
            DataFormat format = workbook.createDataFormat();
            numberStyle.setDataFormat(format.getFormat("0.00"));

            // 데이터 행
            int rowIdx = 1;
            for (UserTotalScore ts : totalScores) {
                Row row = sheet.createRow(rowIdx++);
                int col = 0;

                row.createCell(col++).setCellValue(ts.getUserId());

                Cell totalCell = row.createCell(col++);
                if (ts.getTotalScore() != null) {
                    totalCell.setCellValue(ts.getTotalScore().doubleValue());
                    totalCell.setCellStyle(numberStyle);
                }

                Cell avgCell = row.createCell(col++);
                if (ts.getAvgScore() != null) {
                    avgCell.setCellValue(ts.getAvgScore().doubleValue());
                    avgCell.setCellStyle(numberStyle);
                }

                if (ts.getTotalRanking() != null) {
                    row.createCell(col++).setCellValue(ts.getTotalRanking());
                } else {
                    col++;
                }

                Cell pctCell = row.createCell(col++);
                if (ts.getPercentile() != null) {
                    pctCell.setCellValue(ts.getPercentile().doubleValue());
                    pctCell.setCellStyle(numberStyle);
                }

                row.createCell(col++).setCellValue("Y".equals(ts.getPassYn()) ? "합격" : "불합격");
                row.createCell(col++).setCellValue("Y".equals(ts.getCutFailYn()) ? "과락" : "-");

                // 과목별 점수
                List<UserScore> userScores = userScoresMap.getOrDefault(ts.getUserId(), List.of());
                Map<String, UserScore> scoreMap = userScores.stream()
                        .collect(Collectors.toMap(us -> us.getId().getSubjectCd(), us -> us));

                for (ExamSubject subject : subjects) {
                    UserScore us = scoreMap.get(subject.getSubjectCd());
                    if (us != null && us.getRawScore() != null) {
                        Cell scoreCell = row.createCell(col++);
                        scoreCell.setCellValue(us.getRawScore().doubleValue());
                        scoreCell.setCellStyle(numberStyle);
                        row.createCell(col++).setCellValue(us.getCorrectCnt() != null ? us.getCorrectCnt() : 0);
                    } else {
                        col += 2;
                    }
                }
            }

            // 컬럼 너비 자동 조정
            for (int i = 0; i < colIdx; i++) {
                sheet.autoSizeColumn(i);
            }

            // 시험 정보 시트
            Sheet infoSheet = workbook.createSheet("시험정보");
            Row infoRow0 = infoSheet.createRow(0);
            infoRow0.createCell(0).setCellValue("시험코드");
            infoRow0.createCell(1).setCellValue(exam.getExamCd());
            Row infoRow1 = infoSheet.createRow(1);
            infoRow1.createCell(0).setCellValue("시험명");
            infoRow1.createCell(1).setCellValue(exam.getExamNm());
            Row infoRow2 = infoSheet.createRow(2);
            infoRow2.createCell(0).setCellValue("시험유형");
            infoRow2.createCell(1).setCellValue(exam.getExamType());
            Row infoRow3 = infoSheet.createRow(3);
            infoRow3.createCell(0).setCellValue("응시자수");
            infoRow3.createCell(1).setCellValue(totalScores.size());
            Row infoRow4 = infoSheet.createRow(4);
            infoRow4.createCell(0).setCellValue("합격점수");
            infoRow4.createCell(1).setCellValue(exam.getPassScore() != null ? exam.getPassScore().doubleValue() : 0);
            infoSheet.autoSizeColumn(0);
            infoSheet.autoSizeColumn(1);

            ByteArrayOutputStream out = new ByteArrayOutputStream();
            workbook.write(out);
            return out.toByteArray();
        }
    }
}
