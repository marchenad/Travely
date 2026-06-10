package com.example.travely.service.impl;

import com.example.travely.dto.request.VehicleRequestDto;
import com.example.travely.dto.response.VehicleResponseDto;
import com.example.travely.entity.Trip;
import com.example.travely.entity.User;
import com.example.travely.entity.Vehicle;
import com.example.travely.exception.ResourceNotFoundException;
import com.example.travely.mapper.VehicleMapper;
import com.example.travely.repository.TripRepository;
import com.example.travely.repository.UserRepository;
import com.example.travely.repository.VehicleRepository;
import com.example.travely.service.VehicleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class VehicleServiceImpl implements VehicleService {

    private final VehicleRepository vehicleRepository;
    private final TripRepository tripRepository;
    private final UserRepository userRepository;
    private final VehicleMapper vehicleMapper;

    @Override
    public VehicleResponseDto create(VehicleRequestDto dto) {
        Trip trip = findTripById(dto.getTripId());
        Vehicle vehicle = vehicleMapper.toEntity(dto);
        vehicle.setTrip(trip);
        if (dto.getDriverId() != null) {
            vehicle.setDriver(findUserById(dto.getDriverId()));
        }
        return vehicleMapper.toResponseDto(vehicleRepository.save(vehicle));
    }

    @Override
    @Transactional(readOnly = true)
    public VehicleResponseDto findById(Long id) {
        return vehicleMapper.toResponseDto(findEntityById(id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<VehicleResponseDto> findByTrip(Long tripId) {
        return vehicleRepository.findByTripId(tripId).stream()
                .map(vehicleMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<VehicleResponseDto> findByDriver(Long driverId) {
        return vehicleRepository.findByDriverId(driverId).stream()
                .map(vehicle -> {
                    VehicleResponseDto dto = vehicleMapper.toResponseDto(vehicle);
                    // Mapeo manual de campos del viaje para garantizar que se rellenen
                    if (vehicle.getTrip() != null) {
                        dto.setTripStatus(vehicle.getTrip().getStatus().name());
                        dto.setTripTitle(vehicle.getTrip().getTitle());
                        dto.setTripDestinationName(vehicle.getTrip().getDestinationName());
                        dto.setTripDestinationLatitude(vehicle.getTrip().getDestinationLatitude());
                        dto.setTripDestinationLongitude(vehicle.getTrip().getDestinationLongitude());
                        if (vehicle.getTrip().getCreator() != null) {
                            dto.setTripCreatorId(vehicle.getTrip().getCreator().getId());
                            dto.setTripCreatorName(vehicle.getTrip().getCreator().getName());
                        }
                    }
                    return dto;
                })
                .toList();
    }

    @Override
    public VehicleResponseDto update(Long id, VehicleRequestDto dto) {
        Vehicle vehicle = findEntityById(id);
        vehicleMapper.updateEntityFromDto(dto, vehicle);
        if (dto.getTripId() != null) {
            vehicle.setTrip(findTripById(dto.getTripId()));
        }
        if (dto.getDriverId() != null) {
            vehicle.setDriver(findUserById(dto.getDriverId()));
        }
        return vehicleMapper.toResponseDto(vehicleRepository.save(vehicle));
    }

    @Override
    public void delete(Long id) {
        findEntityById(id);
        vehicleRepository.deleteById(id);
    }

    private Vehicle findEntityById(Long id) {
        return vehicleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehicle", id));
    }

    private Trip findTripById(Long id) {
        return tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Trip", id));
    }

    private User findUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }
}
