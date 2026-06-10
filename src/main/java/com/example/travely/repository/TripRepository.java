package com.example.travely.repository;

import com.example.travely.entity.Trip;
import com.example.travely.entity.TripStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TripRepository extends JpaRepository<Trip, Long> {
    List<Trip> findByCreatorId(Long creatorId);
    Page<Trip> findByCreatorId(Long creatorId, Pageable pageable);
    List<Trip> findByStatus(TripStatus status);
}
