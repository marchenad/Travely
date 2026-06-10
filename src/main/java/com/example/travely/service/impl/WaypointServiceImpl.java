package com.example.travely.service.impl;

import com.example.travely.dto.request.WaypointRequestDto;
import com.example.travely.dto.response.WaypointResponseDto;
import com.example.travely.entity.Trip;
import com.example.travely.entity.Waypoint;
import com.example.travely.exception.ResourceNotFoundException;
import com.example.travely.mapper.WaypointMapper;
import com.example.travely.repository.TripRepository;
import com.example.travely.repository.WaypointRepository;
import com.example.travely.service.WaypointService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class WaypointServiceImpl implements WaypointService {

    private final WaypointRepository waypointRepository;
    private final TripRepository tripRepository;
    private final WaypointMapper waypointMapper;

    @Override
    public WaypointResponseDto create(WaypointRequestDto dto) {
        Trip trip = findTripById(dto.getTripId());
        Waypoint waypoint = waypointMapper.toEntity(dto);
        waypoint.setTrip(trip);
        return waypointMapper.toResponseDto(waypointRepository.save(waypoint));
    }

    @Override
    @Transactional(readOnly = true)
    public WaypointResponseDto findById(Long id) {
        return waypointMapper.toResponseDto(findEntityById(id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<WaypointResponseDto> findByTrip(Long tripId) {
        return waypointRepository.findByTripIdOrderByWaypointOrderAsc(tripId).stream()
                .map(waypointMapper::toResponseDto)
                .toList();
    }

    @Override
    public WaypointResponseDto update(Long id, WaypointRequestDto dto) {
        Waypoint waypoint = findEntityById(id);
        waypointMapper.updateEntityFromDto(dto, waypoint);
        if (dto.getTripId() != null) {
            waypoint.setTrip(findTripById(dto.getTripId()));
        }
        return waypointMapper.toResponseDto(waypointRepository.save(waypoint));
    }

    @Override
    public WaypointResponseDto markVisited(Long id) {
        Waypoint waypoint = findEntityById(id);
        waypoint.setVisitedAt(LocalDateTime.now());
        return waypointMapper.toResponseDto(waypointRepository.save(waypoint));
    }

    @Override
    public void delete(Long id) {
        findEntityById(id);
        waypointRepository.deleteById(id);
    }

    private Waypoint findEntityById(Long id) {
        return waypointRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Waypoint", id));
    }

    private Trip findTripById(Long id) {
        return tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Trip", id));
    }
}
