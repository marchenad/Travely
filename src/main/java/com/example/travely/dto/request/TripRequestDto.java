package com.example.travely.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class TripRequestDto {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    @NotBlank(message = "Destination name is required")
    private String destinationName;

    private Double destinationLatitude;
    private Double destinationLongitude;

    private LocalDate startDate;

    private LocalDate endDate;

    @NotNull(message = "Creator ID is required")
    private Long creatorId;
}
