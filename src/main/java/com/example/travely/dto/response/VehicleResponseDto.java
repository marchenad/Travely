package com.example.travely.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class VehicleResponseDto {
    private Long id;
    private String name;
    private String licensePlate;
    private String color;
    private Long driverId;
    private String driverName;
    private String driverPhone;
    private String driverProfilePicture;
    private Long tripId;
    private String tripTitle;
    private String tripStatus;
    private String tripDestinationName;
    private Double tripDestinationLatitude;
    private Double tripDestinationLongitude;
    private Long tripCreatorId;
    private String tripCreatorName;
    private LocalDateTime tripUpdatedAt;
    private Integer tripNavigationVersion;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
