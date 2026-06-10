package com.example.travely.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ChatMessageRequestDto {

    @NotNull
    private Long senderId;

    @NotBlank
    @Size(max = 500)
    private String content;
}
