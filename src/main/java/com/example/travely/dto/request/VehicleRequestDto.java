package com.example.travely.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class VehicleRequestDto {

    @NotBlank(message = "Vehicle name is required")
    private String name;

    private String licensePlate;
    private String color;
    private Long driverId;

    @NotNull(message = "Trip ID is required")
    private Long tripId;
}
