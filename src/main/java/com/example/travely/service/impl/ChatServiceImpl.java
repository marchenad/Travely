package com.example.travely.service.impl;

import com.example.travely.dto.request.ChatMessageRequestDto;
import com.example.travely.dto.response.ChatMessageResponseDto;
import com.example.travely.entity.ChatMessage;
import com.example.travely.entity.Trip;
import com.example.travely.entity.User;
import com.example.travely.exception.ResourceNotFoundException;
import com.example.travely.repository.ChatMessageRepository;
import com.example.travely.repository.TripRepository;
import com.example.travely.repository.UserRepository;
import com.example.travely.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ChatServiceImpl implements ChatService {

    private final ChatMessageRepository chatMessageRepository;
    private final TripRepository        tripRepository;
    private final UserRepository        userRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    public ChatMessageResponseDto send(Long tripId, ChatMessageRequestDto dto) {
        Trip trip   = tripRepository.findById(tripId)
                .orElseThrow(() -> new ResourceNotFoundException("Trip", tripId));
        User sender = userRepository.findById(dto.getSenderId())
                .orElseThrow(() -> new ResourceNotFoundException("User", dto.getSenderId()));

        ChatMessage msg = ChatMessage.builder()
                .trip(trip)
                .sender(sender)
                .content(dto.getContent().trim())
                .sentAt(LocalDateTime.now())
                .build();

        ChatMessageResponseDto response = toResponseDto(chatMessageRepository.save(msg));
        messagingTemplate.convertAndSend("/topic/trips/" + tripId + "/chat", response);
        return response;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ChatMessageResponseDto> getHistory(Long tripId) {
        return chatMessageRepository.findByTripIdOrderBySentAtAsc(tripId)
                .stream().map(this::toResponseDto).toList();
    }

    private ChatMessageResponseDto toResponseDto(ChatMessage msg) {
        ChatMessageResponseDto dto = new ChatMessageResponseDto();
        dto.setId(msg.getId());
        dto.setTripId(msg.getTrip().getId());
        dto.setSenderId(msg.getSender().getId());
        dto.setSenderName(msg.getSender().getName());
        dto.setContent(msg.getContent());
        dto.setSentAt(msg.getSentAt());
        return dto;
    }
}
