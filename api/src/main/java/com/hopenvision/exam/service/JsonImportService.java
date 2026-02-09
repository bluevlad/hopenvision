package com.hopenvision.exam.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.hopenvision.exam.dto.AnswerSheetJsonDto;
import com.hopenvision.exam.dto.JsonImportResultDto;
import com.hopenvision.exam.dto.QuestionJsonDto;
import com.hopenvision.exam.entity.ExamAnswerKey;
import com.hopenvision.exam.entity.ExamQuestion;
import com.hopenvision.exam.entity.ExamSubject;
import com.hopenvision.exam.entity.ExamSubjectId;
import com.hopenvision.exam.repository.ExamAnswerKeyRepository;
import com.hopenvision.exam.repository.ExamQuestionRepository;
import com.hopenvision.exam.repository.ExamSubjectRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class JsonImportService {

    private final ExamSubjectRepository examSubjectRepository;
    private final ExamQuestionRepository examQuestionRepository;
    private final ExamAnswerKeyRepository examAnswerKeyRepository;
    private final ObjectMapper objectMapper;

    /**
     * 문제지 JSON과 답안지 JSON을 함께 파싱하여 DB에 저장
     *
     * @param examCd         시험 코드
     * @param subjectCd      과목 코드
     * @param questionFile   문제지 JSON 파일
     * @param answerFile     답안지 JSON 파일
     * @return 결과 DTO
     */
    @Transactional
    public JsonImportResultDto importQuestionBank(
            String examCd,
            String subjectCd,
            MultipartFile questionFile,
            MultipartFile answerFile) {

        List<String> errors = new ArrayList<>();
        List<JsonImportResultDto.ImportedQuestion> importedQuestions = new ArrayList<>();
        int totalCount = 0;
        int successCount = 0;
        int failCount = 0;

        try {
            // JSON 파일 파싱
            List<QuestionJsonDto> questions = parseQuestionJson(questionFile.getInputStream());
            List<AnswerSheetJsonDto> answers = parseAnswerJson(answerFile.getInputStream());

            totalCount = questions.size();

            // 과목 존재 여부 확인
            ensureSubjectExists(examCd, subjectCd, totalCount);

            // 문제와 답안 병합하여 저장
            for (int i = 0; i < questions.size(); i++) {
                int questionNo = i + 1;
                try {
                    QuestionJsonDto question = questions.get(i);
                    AnswerSheetJsonDto answer = (i < answers.size()) ? answers.get(i) : null;

                    JsonImportResultDto.ImportedQuestion imported = saveQuestion(
                            examCd, subjectCd, questionNo, question, answer);
                    importedQuestions.add(imported);
                    successCount++;

                } catch (Exception e) {
                    failCount++;
                    errors.add("문항 " + questionNo + ": " + e.getMessage());
                    log.error("문항 {} 처리 중 오류: {}", questionNo, e.getMessage());
                }
            }

            // 과목의 문항 수 업데이트
            updateSubjectQuestionCount(examCd, subjectCd, successCount);

        } catch (IOException e) {
            log.error("JSON 파일 읽기 오류: {}", e.getMessage());
            errors.add("JSON 파일을 읽을 수 없습니다: " + e.getMessage());
            failCount = 1;
        }

        return JsonImportResultDto.builder()
                .totalCount(totalCount)
                .successCount(successCount)
                .failCount(failCount)
                .errors(errors)
                .importedQuestions(importedQuestions)
                .build();
    }

    /**
     * 로컬 파일 경로로부터 Import (upload 폴더 등)
     */
    @Transactional
    public JsonImportResultDto importQuestionBankFromPath(
            String examCd,
            String subjectCd,
            Path questionFilePath,
            Path answerFilePath) {

        List<String> errors = new ArrayList<>();
        List<JsonImportResultDto.ImportedQuestion> importedQuestions = new ArrayList<>();
        int totalCount = 0;
        int successCount = 0;
        int failCount = 0;

        try {
            // JSON 파일 파싱
            List<QuestionJsonDto> questions = parseQuestionJson(Files.newInputStream(questionFilePath));
            List<AnswerSheetJsonDto> answers = parseAnswerJson(Files.newInputStream(answerFilePath));

            totalCount = questions.size();

            // 과목 존재 여부 확인
            ensureSubjectExists(examCd, subjectCd, totalCount);

            // 문제와 답안 병합하여 저장
            for (int i = 0; i < questions.size(); i++) {
                int questionNo = i + 1;
                try {
                    QuestionJsonDto question = questions.get(i);
                    AnswerSheetJsonDto answer = (i < answers.size()) ? answers.get(i) : null;

                    JsonImportResultDto.ImportedQuestion imported = saveQuestion(
                            examCd, subjectCd, questionNo, question, answer);
                    importedQuestions.add(imported);
                    successCount++;

                } catch (Exception e) {
                    failCount++;
                    errors.add("문항 " + questionNo + ": " + e.getMessage());
                    log.error("문항 {} 처리 중 오류: {}", questionNo, e.getMessage());
                }
            }

            // 과목의 문항 수 업데이트
            updateSubjectQuestionCount(examCd, subjectCd, successCount);

        } catch (IOException e) {
            log.error("JSON 파일 읽기 오류: {}", e.getMessage());
            errors.add("JSON 파일을 읽을 수 없습니다: " + e.getMessage());
            failCount = 1;
        }

        return JsonImportResultDto.builder()
                .totalCount(totalCount)
                .successCount(successCount)
                .failCount(failCount)
                .errors(errors)
                .importedQuestions(importedQuestions)
                .build();
    }

    /**
     * 미리보기 (저장 없이 파싱만)
     */
    public JsonImportResultDto previewQuestionBank(
            MultipartFile questionFile,
            MultipartFile answerFile) {

        List<String> errors = new ArrayList<>();
        List<JsonImportResultDto.ImportedQuestion> importedQuestions = new ArrayList<>();
        int totalCount = 0;
        int successCount = 0;
        int failCount = 0;

        try {
            List<QuestionJsonDto> questions = parseQuestionJson(questionFile.getInputStream());
            List<AnswerSheetJsonDto> answers = parseAnswerJson(answerFile.getInputStream());

            totalCount = questions.size();

            for (int i = 0; i < questions.size(); i++) {
                int questionNo = i + 1;
                try {
                    QuestionJsonDto question = questions.get(i);
                    AnswerSheetJsonDto answer = (i < answers.size()) ? answers.get(i) : null;

                    JsonImportResultDto.ImportedQuestion preview = JsonImportResultDto.ImportedQuestion.builder()
                            .questionNo(questionNo)
                            .questionText(truncate(question.getQuestion(), 100))
                            .category(answer != null ? answer.getCategory() : null)
                            .difficulty(answer != null ? answer.getDifficulty() : null)
                            .correctAnswer(answer != null ? answer.getCorrectAnswerAsNumber() : null)
                            .title(answer != null ? answer.getTitle() : null)
                            .build();

                    importedQuestions.add(preview);
                    successCount++;

                } catch (Exception e) {
                    failCount++;
                    errors.add("문항 " + questionNo + ": " + e.getMessage());
                }
            }

        } catch (IOException e) {
            errors.add("JSON 파일을 읽을 수 없습니다: " + e.getMessage());
        }

        return JsonImportResultDto.builder()
                .totalCount(totalCount)
                .successCount(successCount)
                .failCount(failCount)
                .errors(errors)
                .importedQuestions(importedQuestions)
                .build();
    }

    private List<QuestionJsonDto> parseQuestionJson(InputStream is) throws IOException {
        return objectMapper.readValue(is, new TypeReference<List<QuestionJsonDto>>() {});
    }

    private List<AnswerSheetJsonDto> parseAnswerJson(InputStream is) throws IOException {
        return objectMapper.readValue(is, new TypeReference<List<AnswerSheetJsonDto>>() {});
    }

    private void ensureSubjectExists(String examCd, String subjectCd, int questionCnt) {
        ExamSubjectId subjectId = new ExamSubjectId(examCd, subjectCd);
        if (!examSubjectRepository.existsById(subjectId)) {
            ExamSubject subject = ExamSubject.builder()
                    .examCd(examCd)
                    .subjectCd(subjectCd)
                    .subjectNm(subjectCd)
                    .subjectType("M")
                    .questionType("CHOICE")
                    .questionCnt(questionCnt)
                    .scorePerQ(new BigDecimal("5"))
                    .build();
            examSubjectRepository.save(subject);
        }
    }

    private void updateSubjectQuestionCount(String examCd, String subjectCd, int questionCnt) {
        ExamSubjectId subjectId = new ExamSubjectId(examCd, subjectCd);
        examSubjectRepository.findById(subjectId).ifPresent(subject -> {
            subject.setQuestionCnt(questionCnt);
            examSubjectRepository.save(subject);
        });
    }

    private JsonImportResultDto.ImportedQuestion saveQuestion(
            String examCd,
            String subjectCd,
            int questionNo,
            QuestionJsonDto question,
            AnswerSheetJsonDto answer) {

        // ExamQuestion 저장
        ExamQuestion examQuestion = ExamQuestion.builder()
                .examCd(examCd)
                .subjectCd(subjectCd)
                .questionNo(questionNo)
                .questionText(question.getQuestion())
                .contextText(question.getContextAsText())
                .choice1(question.getChoice(1))
                .choice2(question.getChoice(2))
                .choice3(question.getChoice(3))
                .choice4(question.getChoice(4))
                .choice5(question.getChoice(5))
                .imageFile(question.getImageFile())
                .category(answer != null ? answer.getCategory() : null)
                .difficulty(answer != null ? answer.getDifficulty() : null)
                .title(answer != null ? answer.getTitle() : null)
                .explanation(answer != null ? answer.getContent() : null)
                .correctionNote(answer != null ? answer.getCorrectionNote() : null)
                .build();

        examQuestionRepository.save(examQuestion);

        // ExamAnswerKey 저장 (정답이 있는 경우)
        if (answer != null && answer.getCorrectAnswerAsNumber() != null) {
            ExamAnswerKey answerKey = ExamAnswerKey.builder()
                    .examCd(examCd)
                    .subjectCd(subjectCd)
                    .questionNo(questionNo)
                    .correctAns(String.valueOf(answer.getCorrectAnswerAsNumber()))
                    .score(new BigDecimal("5"))
                    .build();

            examAnswerKeyRepository.save(answerKey);
        }

        return JsonImportResultDto.ImportedQuestion.builder()
                .questionNo(questionNo)
                .questionText(truncate(question.getQuestion(), 100))
                .category(answer != null ? answer.getCategory() : null)
                .difficulty(answer != null ? answer.getDifficulty() : null)
                .correctAnswer(answer != null ? answer.getCorrectAnswerAsNumber() : null)
                .title(answer != null ? answer.getTitle() : null)
                .build();
    }

    private String truncate(String text, int maxLength) {
        if (text == null) return null;
        if (text.length() <= maxLength) return text;
        return text.substring(0, maxLength) + "...";
    }
}
