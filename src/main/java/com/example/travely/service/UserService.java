package com.example.travely.service;

import com.example.travely.dto.request.UserRequestDto;
import com.example.travely.dto.response.UserResponseDto;

import java.util.List;

public interface UserService {
    UserResponseDto create(UserRequestDto dto);
    UserResponseDto findById(Long id);
    List<UserResponseDto> findAll();
    UserResponseDto findByEmail(String email);
    UserResponseDto update(Long id, UserRequestDto dto);
    UserResponseDto uploadAvatar(Long id, String base64);
    void delete(Long id);
}
