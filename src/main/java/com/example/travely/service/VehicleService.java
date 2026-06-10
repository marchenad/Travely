package com.example.travely.service;

import com.example.travely.dto.request.VehicleRequestDto;
import com.example.travely.dto.response.VehicleResponseDto;

import java.util.List;

public interface VehicleService {
    VehicleResponseDto create(VehicleRequestDto dto);
    VehicleResponseDto findById(Long id);
    List<VehicleResponseDto> findByTrip(Long tripId);
    List<VehicleResponseDto> findByDriver(Long driverId);
    VehicleResponseDto update(Long id, VehicleRequestDto dto);
    void delete(Long id);
}
