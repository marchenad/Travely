package com.example.travely.repository;

import com.example.travely.entity.VehicleLocation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehicleLocationRepository extends JpaRepository<VehicleLocation, Long> {

    Optional<VehicleLocation> findTopByVehicleIdOrderByTimestampDesc(Long vehicleId);

    @Query("SELECT vl FROM VehicleLocation vl WHERE vl.vehicle.trip.id = :tripId " +
           "AND vl.timestamp = (SELECT MAX(vl2.timestamp) FROM VehicleLocation vl2 WHERE vl2.vehicle = vl.vehicle)")
    List<VehicleLocation> findLatestLocationsByTripId(@Param("tripId") Long tripId);
}
