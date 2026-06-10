package com.example.travely.dto.response;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class VehicleLocationResponseDto {
    private Long id;
    private Long vehicleId;
    private String vehicleName;
    private Double latitude;
    private Double longitude;
    private Double speed;
    private Double heading;
    private LocalDateTime timestamp;
}
