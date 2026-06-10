package com.example.travely.service;

import com.example.travely.dto.request.VehicleLocationRequestDto;
import com.example.travely.dto.response.VehicleLocationResponseDto;

import java.util.List;

public interface VehicleLocationService {
    VehicleLocationResponseDto updateLocation(Long vehicleId, VehicleLocationRequestDto dto);
    VehicleLocationResponseDto getLatestByVehicle(Long vehicleId);
    List<VehicleLocationResponseDto> getLatestByTrip(Long tripId);
}
