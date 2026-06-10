package com.example.travely.service;

import com.example.travely.dto.request.TripRequestDto;
import com.example.travely.dto.response.TripResponseDto;
import com.example.travely.entity.TripStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface TripService {
    TripResponseDto create(TripRequestDto dto);
    TripResponseDto findById(Long id);
    List<TripResponseDto> findAll();
    List<TripResponseDto> findByCreator(Long creatorId);
    Page<TripResponseDto> findByCreatorPaged(Long creatorId, Pageable pageable);
    TripResponseDto update(Long id, TripRequestDto dto);
    TripResponseDto updateStatus(Long id, TripStatus status);
    void delete(Long id);
}
