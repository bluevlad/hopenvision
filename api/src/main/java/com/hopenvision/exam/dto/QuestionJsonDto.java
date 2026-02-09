package com.hopenvision.exam.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Map;

/**
 * 문제지 JSON 파일 파싱용 DTO
 *
 * JSON 형식:
 * {
 *   "image_file": "h-01.jpg",
 *   "question": "문제 텍스트",
 *   "choices": { "1": "선택지1", "2": "선택지2", "3": "선택지3", "4": "선택지4" },
 *   "context": ["지문1", "지문2"]
 * }
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionJsonDto {

    @JsonProperty("image_file")
    private String imageFile;

    @JsonProperty("question")
    private String question;

    @JsonProperty("choices")
    private Map<String, String> choices;

    @JsonProperty("context")
    private List<String> context;

    public String getChoice(int number) {
        if (choices == null) return null;
        return choices.get(String.valueOf(number));
    }

    public String getContextAsText() {
        if (context == null || context.isEmpty()) return null;
        return String.join("\n", context);
    }
}
