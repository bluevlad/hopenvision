package com.hopenvision.exam.controller;

import com.hopenvision.exam.dto.JsonImportResultDto;
import com.hopenvision.exam.service.JsonImportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Path;
import java.nio.file.Paths;

@Tag(name = "JSON Import", description = "JSON 파일 가져오기 API")
@RestController
@RequestMapping("/api/import/json")
@RequiredArgsConstructor
public class JsonImportController {

    private final JsonImportService jsonImportService;

    @Value("${app.upload.path:upload}")
    private String uploadPath;

    @Operation(summary = "문제은행 JSON 미리보기",
            description = "문제지 JSON과 답안지 JSON을 파싱하여 미리보기 (저장하지 않음)")
    @PostMapping(value = "/preview", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<JsonImportResultDto> previewQuestionBank(
            @Parameter(description = "문제지 JSON 파일")
            @RequestParam("questionFile") MultipartFile questionFile,
            @Parameter(description = "답안지 JSON 파일")
            @RequestParam("answerFile") MultipartFile answerFile) {

        validateJsonFile(questionFile, "문제지");
        validateJsonFile(answerFile, "답안지");

        JsonImportResultDto result = jsonImportService.previewQuestionBank(questionFile, answerFile);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "문제은행 JSON 가져오기",
            description = "문제지 JSON과 답안지 JSON을 파싱하여 DB에 저장")
    @PostMapping(value = "/exams/{examCd}/subjects/{subjectCd}/questions",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<JsonImportResultDto> importQuestionBank(
            @Parameter(description = "시험 코드")
            @PathVariable String examCd,
            @Parameter(description = "과목 코드")
            @PathVariable String subjectCd,
            @Parameter(description = "문제지 JSON 파일")
            @RequestParam("questionFile") MultipartFile questionFile,
            @Parameter(description = "답안지 JSON 파일")
            @RequestParam("answerFile") MultipartFile answerFile) {

        validateJsonFile(questionFile, "문제지");
        validateJsonFile(answerFile, "답안지");

        JsonImportResultDto result = jsonImportService.importQuestionBank(
                examCd, subjectCd, questionFile, answerFile);
        return ResponseEntity.ok(result);
    }

    @Operation(summary = "upload 폴더에서 문제은행 가져오기",
            description = "서버의 upload 폴더에 있는 JSON 파일을 읽어 DB에 저장")
    @PostMapping("/exams/{examCd}/subjects/{subjectCd}/questions/from-upload")
    public ResponseEntity<JsonImportResultDto> importFromUploadFolder(
            @Parameter(description = "시험 코드")
            @PathVariable String examCd,
            @Parameter(description = "과목 코드")
            @PathVariable String subjectCd,
            @Parameter(description = "문제지 JSON 파일명 (upload 폴더 내)")
            @RequestParam String questionFileName,
            @Parameter(description = "답안지 JSON 파일명 (upload 폴더 내)")
            @RequestParam String answerFileName) {

        Path questionFilePath = Paths.get(uploadPath, questionFileName);
        Path answerFilePath = Paths.get(uploadPath, answerFileName);

        if (!questionFilePath.toFile().exists()) {
            throw new IllegalArgumentException("문제지 파일을 찾을 수 없습니다: " + questionFileName);
        }
        if (!answerFilePath.toFile().exists()) {
            throw new IllegalArgumentException("답안지 파일을 찾을 수 없습니다: " + answerFileName);
        }

        JsonImportResultDto result = jsonImportService.importQuestionBankFromPath(
                examCd, subjectCd, questionFilePath, answerFilePath);
        return ResponseEntity.ok(result);
    }

    private void validateJsonFile(MultipartFile file, String fileType) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException(fileType + " 파일이 비어있습니다");
        }

        String filename = file.getOriginalFilename();
        if (filename == null || !filename.toLowerCase().endsWith(".json")) {
            throw new IllegalArgumentException(fileType + "는 JSON 파일만 업로드 가능합니다 (.json)");
        }
    }
}
