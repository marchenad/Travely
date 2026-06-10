package com.example.travely.service;

import com.example.travely.dto.request.LoginRequestDto;
import com.example.travely.dto.request.RegisterRequestDto;
import com.example.travely.dto.response.AuthResponseDto;

public interface AuthService {
    AuthResponseDto register(RegisterRequestDto dto);
    AuthResponseDto login(LoginRequestDto dto);
}
