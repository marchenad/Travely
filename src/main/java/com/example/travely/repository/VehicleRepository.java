package com.example.travely.repository;

import com.example.travely.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {
    @Query("SELECT v FROM Vehicle v LEFT JOIN FETCH v.driver LEFT JOIN FETCH v.trip t LEFT JOIN FETCH t.creator WHERE t.id = :tripId")
    List<Vehicle> findByTripId(@Param("tripId") Long tripId);

    @Query("SELECT v FROM Vehicle v JOIN FETCH v.driver d JOIN FETCH v.trip t JOIN FETCH t.creator WHERE d.id = :driverId")
    List<Vehicle> findByDriverId(@Param("driverId") Long driverId);
}
