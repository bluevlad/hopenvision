package com.hopenvision.exam.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 답안지 JSON 파일 파싱용 DTO
 *
 * JSON 형식:
 * {
 *   "filename": "1-1.jpg",
 *   "category": "고대사-선사시대",
 *   "difficulty": "하",
 *   "title": "청동기 및 철기 시대의 무덤 양식",
 *   "content": "해설 내용",
 *   "correction_note": "오답 분석",
 *   "correct_answer": "④",
 *   "original_image_text": "원본 텍스트"
 * }
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AnswerSheetJsonDto {

    @JsonProperty("filename")
    private String filename;

    @JsonProperty("category")
    private String category;

    @JsonProperty("difficulty")
    private String difficulty;

    @JsonProperty("title")
    private String title;

    @JsonProperty("content")
    private String content;

    @JsonProperty("correction_note")
    private String correctionNote;

    @JsonProperty("correct_answer")
    private String correctAnswer;

    @JsonProperty("original_image_text")
    private String originalImageText;

    /**
     * 정답을 숫자로 변환 (①→1, ②→2, ③→3, ④→4, ⑤→5)
     */
    public Integer getCorrectAnswerAsNumber() {
        if (correctAnswer == null || correctAnswer.isEmpty()) return null;

        String answer = correctAnswer.trim();

        // 원문자 처리 (①②③④⑤)
        switch (answer) {
            case "①": return 1;
            case "②": return 2;
            case "③": return 3;
            case "④": return 4;
            case "⑤": return 5;
        }

        // 숫자 문자열 처리 (1, 2, 3, 4, 5)
        try {
            return Integer.parseInt(answer);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
