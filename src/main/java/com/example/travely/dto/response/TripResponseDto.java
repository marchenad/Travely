package com.example.travely.dto.response;

import com.example.travely.entity.TripStatus;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class TripResponseDto {
    private Long id;
    private String title;
    private String description;
    private String destinationName;
    private Double destinationLatitude;
    private Double destinationLongitude;
    private LocalDate startDate;
    private LocalDate endDate;
    private TripStatus status;
    private Long creatorId;
    private String creatorName;
    private List<VehicleResponseDto> vehicles;
    private List<WaypointResponseDto> waypoints;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
