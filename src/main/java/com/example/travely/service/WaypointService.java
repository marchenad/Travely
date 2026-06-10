package com.example.travely.service;

import com.example.travely.dto.request.WaypointRequestDto;
import com.example.travely.dto.response.WaypointResponseDto;

import java.util.List;

public interface WaypointService {
    WaypointResponseDto create(WaypointRequestDto dto);
    WaypointResponseDto findById(Long id);
    List<WaypointResponseDto> findByTrip(Long tripId);
    WaypointResponseDto update(Long id, WaypointRequestDto dto);
    WaypointResponseDto markVisited(Long id);
    void delete(Long id);
}
