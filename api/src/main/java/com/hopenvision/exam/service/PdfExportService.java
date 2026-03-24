package com.hopenvision.exam.service;

import com.hopenvision.exam.entity.Exam;
import com.hopenvision.exam.repository.ExamRepository;
import com.hopenvision.user.entity.UserScore;
import com.hopenvision.user.entity.UserTotalScore;
import com.hopenvision.user.repository.UserScoreRepository;
import com.hopenvision.user.repository.UserTotalScoreRepository;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class PdfExportService {

    private final ExamRepository examRepository;
    private final ExamSubjectRepository subjectRepository;
    private final UserTotalScoreRepository userTotalScoreRepository;
    private final UserScoreRepository userScoreRepository;

    public byte[] generateScoreReport(String userId, String examCd) throws IOException {
        Exam exam = examRepository.findById(examCd)
                .orElseThrow(() -> new EntityNotFoundException("시험을 찾을 수 없습니다: " + examCd));

        UserTotalScore total = userTotalScoreRepository.findByUserIdAndExamCd(userId, examCd)
                .orElseThrow(() -> new EntityNotFoundException("채점 결과를 찾을 수 없습니다."));

        List<UserScore> userScores = userScoreRepository.findByUserIdAndExamCd(userId, examCd);
        List<ExamSubject> subjects = subjectRepository.findByExamCdOrderBySortOrder(examCd);
        Map<String, ExamSubject> subjectMap = subjects.stream()
                .collect(Collectors.toMap(ExamSubject::getSubjectCd, s -> s));

        Long totalApplicants = userTotalScoreRepository.countByExamCd(examCd);

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 50, 50, 50, 50);

        try {
            PdfWriter.getInstance(document, out);
            document.open();

            // 한글 폰트 (시스템 기본 폰트 사용, 없으면 Helvetica)
            BaseFont baseFont;
            Font titleFont, headerFont, normalFont, smallFont;
            try {
                baseFont = BaseFont.createFont("HeiseiKakuGo-W5", "UniJIS-UCS2-H", BaseFont.NOT_EMBEDDED);
                titleFont = new Font(baseFont, 18, Font.BOLD);
                headerFont = new Font(baseFont, 11, Font.BOLD);
                normalFont = new Font(baseFont, 10);
                smallFont = new Font(baseFont, 9);
            } catch (Exception e) {
                titleFont = new Font(Font.HELVETICA, 18, Font.BOLD);
                headerFont = new Font(Font.HELVETICA, 11, Font.BOLD);
                normalFont = new Font(Font.HELVETICA, 10);
                smallFont = new Font(Font.HELVETICA, 9);
            }

            // 제목
            Paragraph title = new Paragraph("Score Report", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20);
            document.add(title);

            // 시험 정보
            PdfPTable infoTable = new PdfPTable(4);
            infoTable.setWidthPercentage(100);
            infoTable.setSpacingAfter(15);

            addInfoCell(infoTable, "Exam Code", exam.getExamCd(), headerFont, normalFont);
            addInfoCell(infoTable, "Exam Name", exam.getExamNm(), headerFont, normalFont);
            addInfoCell(infoTable, "User ID", userId, headerFont, normalFont);
            addInfoCell(infoTable, "Applicants", String.valueOf(totalApplicants), headerFont, normalFont);
            document.add(infoTable);

            // 총점 요약
            PdfPTable summaryTable = new PdfPTable(6);
            summaryTable.setWidthPercentage(100);
            summaryTable.setSpacingAfter(15);

            String[] summaryHeaders = {"Total Score", "Average", "Ranking", "Percentile", "Pass/Fail", "Cut Fail"};
            for (String h : summaryHeaders) {
                PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
                cell.setBackgroundColor(new Color(240, 240, 240));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setPadding(6);
                summaryTable.addCell(cell);
            }

            addCenterCell(summaryTable, total.getTotalScore() != null ? total.getTotalScore().toString() : "-", normalFont);
            addCenterCell(summaryTable, total.getAvgScore() != null ? total.getAvgScore().toString() : "-", normalFont);
            addCenterCell(summaryTable, total.getTotalRanking() != null ? total.getTotalRanking() + "/" + totalApplicants : "-", normalFont);
            addCenterCell(summaryTable, total.getPercentile() != null ? total.getPercentile() + "%" : "-", normalFont);
            addCenterCell(summaryTable, "Y".equals(total.getPassYn()) ? "PASS" : "FAIL", normalFont);
            addCenterCell(summaryTable, "Y".equals(total.getCutFailYn()) ? "YES" : "NO", normalFont);
            document.add(summaryTable);

            // 과목별 성적
            Paragraph subTitle = new Paragraph("Subject Scores", headerFont);
            subTitle.setSpacingAfter(10);
            document.add(subTitle);

            PdfPTable subjectTable = new PdfPTable(6);
            subjectTable.setWidthPercentage(100);
            subjectTable.setWidths(new float[]{3, 2, 1.5f, 1.5f, 1.5f, 1.5f});

            String[] subHeaders = {"Subject", "Score", "Correct", "Wrong", "Rate", "Cut"};
            for (String h : subHeaders) {
                PdfPCell cell = new PdfPCell(new Phrase(h, headerFont));
                cell.setBackgroundColor(new Color(240, 240, 240));
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setPadding(5);
                subjectTable.addCell(cell);
            }

            for (UserScore us : userScores) {
                ExamSubject subject = subjectMap.get(us.getId().getSubjectCd());
                String subjectNm = subject != null ? subject.getSubjectNm() : us.getId().getSubjectCd();
                int total2 = (us.getCorrectCnt() != null ? us.getCorrectCnt() : 0) + (us.getWrongCnt() != null ? us.getWrongCnt() : 0);
                String rate = total2 > 0 ? String.format("%.1f%%", us.getCorrectCnt() * 100.0 / total2) : "-";
                java.math.BigDecimal cutLine = subject != null && subject.getCutLine() != null ? subject.getCutLine() : java.math.BigDecimal.valueOf(40);
                boolean isCutFail = us.getRawScore() != null && us.getRawScore().compareTo(cutLine) < 0;

                addCell(subjectTable, subjectNm, smallFont);
                addCenterCell(subjectTable, us.getRawScore() != null ? us.getRawScore().toString() : "-", smallFont);
                addCenterCell(subjectTable, String.valueOf(us.getCorrectCnt() != null ? us.getCorrectCnt() : 0), smallFont);
                addCenterCell(subjectTable, String.valueOf(us.getWrongCnt() != null ? us.getWrongCnt() : 0), smallFont);
                addCenterCell(subjectTable, rate, smallFont);
                addCenterCell(subjectTable, isCutFail ? "FAIL" : "OK", smallFont);
            }

            document.add(subjectTable);

            document.close();
        } catch (DocumentException e) {
            throw new IOException("PDF generation failed", e);
        }

        return out.toByteArray();
    }

    private void addInfoCell(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell labelCell = new PdfPCell(new Phrase(label, labelFont));
        labelCell.setBorder(0);
        labelCell.setPadding(4);
        table.addCell(labelCell);
        PdfPCell valueCell = new PdfPCell(new Phrase(value != null ? value : "-", valueFont));
        valueCell.setBorder(0);
        valueCell.setPadding(4);
        table.addCell(valueCell);
    }

    private void addCell(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(5);
        table.addCell(cell);
    }

    private void addCenterCell(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setPadding(5);
        table.addCell(cell);
    }
}
