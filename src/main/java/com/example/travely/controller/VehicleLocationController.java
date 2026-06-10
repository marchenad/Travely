package com.example.travely.controller;

import com.example.travely.dto.request.VehicleLocationRequestDto;
import com.example.travely.dto.response.VehicleLocationResponseDto;
import com.example.travely.service.VehicleLocationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class VehicleLocationController {

    private final VehicleLocationService vehicleLocationService;

    @PostMapping("/api/v1/vehicles/{vehicleId}/location")
    public ResponseEntity<VehicleLocationResponseDto> updateLocation(
            @PathVariable Long vehicleId,
            @Valid @RequestBody VehicleLocationRequestDto dto) {
        return ResponseEntity.ok(vehicleLocationService.updateLocation(vehicleId, dto));
    }

    @GetMapping("/api/v1/vehicles/{vehicleId}/location/latest")
    public ResponseEntity<VehicleLocationResponseDto> getLatestByVehicle(
            @PathVariable Long vehicleId) {
        return ResponseEntity.ok(vehicleLocationService.getLatestByVehicle(vehicleId));
    }

    @GetMapping("/api/v1/trips/{tripId}/locations")
    public ResponseEntity<List<VehicleLocationResponseDto>> getLatestByTrip(
            @PathVariable Long tripId) {
        return ResponseEntity.ok(vehicleLocationService.getLatestByTrip(tripId));
    }
}
