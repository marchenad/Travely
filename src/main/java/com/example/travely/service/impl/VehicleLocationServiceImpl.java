package com.example.travely.service.impl;

import com.example.travely.dto.request.VehicleLocationRequestDto;
import com.example.travely.dto.response.VehicleLocationResponseDto;
import com.example.travely.entity.Vehicle;
import com.example.travely.entity.VehicleLocation;
import com.example.travely.exception.ResourceNotFoundException;
import com.example.travely.repository.VehicleLocationRepository;
import com.example.travely.repository.VehicleRepository;
import com.example.travely.service.VehicleLocationService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class VehicleLocationServiceImpl implements VehicleLocationService {

    private final VehicleLocationRepository vehicleLocationRepository;
    private final VehicleRepository vehicleRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    public VehicleLocationResponseDto updateLocation(Long vehicleId, VehicleLocationRequestDto dto) {
        Vehicle vehicle = findVehicleById(vehicleId);
        VehicleLocation location = VehicleLocation.builder()
                .vehicle(vehicle)
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .speed(dto.getSpeed())
                .heading(dto.getHeading())
                .timestamp(dto.getTimestamp() != null ? dto.getTimestamp() : LocalDateTime.now())
                .build();
        VehicleLocationResponseDto saved = toResponseDto(vehicleLocationRepository.save(location));
        Long tripId = vehicle.getTrip() != null ? vehicle.getTrip().getId() : null;
        if (tripId != null) {
            messagingTemplate.convertAndSend("/topic/trips/" + tripId + "/locations", saved);
        }
        return saved;
    }

    @Override
    @Transactional(readOnly = true)
    public VehicleLocationResponseDto getLatestByVehicle(Long vehicleId) {
        findVehicleById(vehicleId);
        return vehicleLocationRepository.findTopByVehicleIdOrderByTimestampDesc(vehicleId)
                .map(this::toResponseDto)
                .orElseThrow(() -> new ResourceNotFoundException("Location for vehicle", vehicleId));
    }

    @Override
    @Transactional(readOnly = true)
    public List<VehicleLocationResponseDto> getLatestByTrip(Long tripId) {
        return vehicleLocationRepository.findLatestLocationsByTripId(tripId).stream()
                .map(this::toResponseDto)
                .toList();
    }

    private Vehicle findVehicleById(Long id) {
        return vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle", id));
    }

    private VehicleLocationResponseDto toResponseDto(VehicleLocation location) {
        VehicleLocationResponseDto dto = new VehicleLocationResponseDto();
        dto.setId(location.getId());
        dto.setVehicleId(location.getVehicle().getId());
        dto.setVehicleName(location.getVehicle().getName());
        dto.setLatitude(location.getLatitude());
        dto.setLongitude(location.getLongitude());
        dto.setSpeed(location.getSpeed());
        dto.setHeading(location.getHeading());
        dto.setTimestamp(location.getTimestamp());
        return dto;
    }
}
