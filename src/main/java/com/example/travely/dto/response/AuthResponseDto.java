package com.example.travely.dto.response;

public record AuthResponseDto(
        String token,
        Long userId,
        String name,
        String email
) {}
