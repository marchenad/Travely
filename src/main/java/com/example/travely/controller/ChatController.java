package com.example.travely.controller;

import com.example.travely.dto.request.ChatMessageRequestDto;
import com.example.travely.dto.response.ChatMessageResponseDto;
import com.example.travely.service.ChatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @MessageMapping("/trips/{tripId}/chat")
    public void sendMessage(@DestinationVariable Long tripId,
                            @Valid ChatMessageRequestDto dto) {
        chatService.send(tripId, dto);
    }

    @GetMapping("/api/v1/trips/{tripId}/chat")
    public ResponseEntity<List<ChatMessageResponseDto>> getHistory(@PathVariable Long tripId) {
        return ResponseEntity.ok(chatService.getHistory(tripId));
    }
}
