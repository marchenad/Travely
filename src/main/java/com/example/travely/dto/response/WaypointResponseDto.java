package com.example.travely.dto.response;

import com.example.travely.entity.WaypointType;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class WaypointResponseDto {
    private Long id;
    private String name;
    private String description;
    private Double latitude;
    private Double longitude;
    private WaypointType type;
    private Integer waypointOrder;
    private Long tripId;
    private LocalDateTime visitedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
