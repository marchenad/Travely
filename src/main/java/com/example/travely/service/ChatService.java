package com.example.travely.service;

import com.example.travely.dto.request.ChatMessageRequestDto;
import com.example.travely.dto.response.ChatMessageResponseDto;

import java.util.List;

public interface ChatService {
    ChatMessageResponseDto send(Long tripId, ChatMessageRequestDto dto);
    List<ChatMessageResponseDto> getHistory(Long tripId);
}
