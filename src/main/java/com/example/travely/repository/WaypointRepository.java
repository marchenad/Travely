package com.example.travely.repository;

import com.example.travely.entity.Waypoint;
import com.example.travely.entity.WaypointType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WaypointRepository extends JpaRepository<Waypoint, Long> {
    List<Waypoint> findByTripIdOrderByWaypointOrderAsc(Long tripId);
    List<Waypoint> findByTripIdAndType(Long tripId, WaypointType type);
}
