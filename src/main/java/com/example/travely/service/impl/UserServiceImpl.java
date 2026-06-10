package com.example.travely.service.impl;

import com.example.travely.dto.request.UserRequestDto;
import com.example.travely.dto.response.UserResponseDto;
import com.example.travely.entity.User;
import com.example.travely.exception.ResourceNotFoundException;
import com.example.travely.mapper.UserMapper;
import com.example.travely.repository.UserRepository;
import com.example.travely.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Override
    public UserResponseDto create(UserRequestDto dto) {
        User user = userMapper.toEntity(dto);
        return userMapper.toResponseDto(userRepository.save(user));
    }

    @Override
    @Transactional(readOnly = true)
    public UserResponseDto findById(Long id) {
        return userMapper.toResponseDto(findEntityById(id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<UserResponseDto> findAll() {
        return userRepository.findAll().stream()
                .map(userMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public UserResponseDto findByEmail(String email) {
        return userRepository.findByEmail(email)
                .map(userMapper::toResponseDto)
                .orElseThrow(() -> new ResourceNotFoundException("User", 0L));
    }

    @Override
    public UserResponseDto update(Long id, UserRequestDto dto) {
        User user = findEntityById(id);
        userMapper.updateEntityFromDto(dto, user);
        return userMapper.toResponseDto(userRepository.save(user));
    }

    @Override
    public UserResponseDto uploadAvatar(Long id, String base64) {
        User user = findEntityById(id);
        user.setProfilePicture(base64);
        return userMapper.toResponseDto(userRepository.save(user));
    }

    @Override
    public void delete(Long id) {
        findEntityById(id);
        userRepository.deleteById(id);
    }

    private User findEntityById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }
}
