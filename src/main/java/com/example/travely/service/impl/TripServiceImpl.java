package com.example.travely.service.impl;

import com.example.travely.dto.request.TripRequestDto;
import com.example.travely.dto.response.TripResponseDto;
import com.example.travely.entity.Trip;
import com.example.travely.entity.TripStatus;
import com.example.travely.entity.User;
import com.example.travely.exception.ResourceNotFoundException;
import com.example.travely.mapper.TripMapper;
import com.example.travely.repository.TripRepository;
import com.example.travely.repository.UserRepository;
import com.example.travely.service.TripService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class TripServiceImpl implements TripService {

    private final TripRepository tripRepository;
    private final UserRepository userRepository;
    private final TripMapper tripMapper;

    @Override
    public TripResponseDto create(TripRequestDto dto) {
        User creator = findUserById(dto.getCreatorId());
        Trip trip = tripMapper.toEntity(dto);
        trip.setCreator(creator);
        if (trip.getStartDate() == null) {
            trip.setStartDate(LocalDate.now());
        }
        return tripMapper.toResponseDto(tripRepository.save(trip));
    }

    @Override
    @Transactional(readOnly = true)
    public TripResponseDto findById(Long id) {
        return tripMapper.toResponseDto(findEntityById(id));
    }

    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDto> findAll() {
        return tripRepository.findAll().stream()
                .map(tripMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<TripResponseDto> findByCreator(Long creatorId) {
        return tripRepository.findByCreatorId(creatorId).stream()
                .map(tripMapper::toResponseDto)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<TripResponseDto> findByCreatorPaged(Long creatorId, Pageable pageable) {
        return tripRepository.findByCreatorId(creatorId, pageable)
                .map(tripMapper::toResponseDto);
    }

    @Override
    public TripResponseDto update(Long id, TripRequestDto dto) {
        Trip trip = findEntityById(id);
        tripMapper.updateEntityFromDto(dto, trip);
        if (dto.getCreatorId() != null) {
            trip.setCreator(findUserById(dto.getCreatorId()));
        }
        return tripMapper.toResponseDto(tripRepository.save(trip));
    }

    @Override
    public TripResponseDto updateStatus(Long id, TripStatus status) {
        Trip trip = findEntityById(id);
        if (status == TripStatus.NAVIGATING) {
            trip.setNavigationVersion(trip.getNavigationVersion() + 1);
        }
        trip.setStatus(status);
        return tripMapper.toResponseDto(tripRepository.save(trip));
    }

    @Override
    public void delete(Long id) {
        findEntityById(id);
        tripRepository.deleteById(id);
    }

    private Trip findEntityById(Long id) {
        return tripRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Trip", id));
    }

    private User findUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }
}
