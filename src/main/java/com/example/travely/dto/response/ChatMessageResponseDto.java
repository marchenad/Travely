package com.example.travely.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ChatMessageResponseDto {
    private Long id;
    private Long tripId;
    private Long senderId;
    private String senderName;
    private String content;
    private LocalDateTime sentAt;
}
