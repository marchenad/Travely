package com.example.travely.dto.request;

import com.example.travely.entity.WaypointType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class WaypointRequestDto {

    @NotBlank(message = "Name is required")
    private String name;

    private String description;

    @NotNull(message = "Latitude is required")
    private Double latitude;

    @NotNull(message = "Longitude is required")
    private Double longitude;

    @NotNull(message = "Type is required")
    private WaypointType type;

    private Integer waypointOrder;

    @NotNull(message = "Trip ID is required")
    private Long tripId;
}
