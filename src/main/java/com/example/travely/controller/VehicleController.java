package com.example.travely.controller;

import com.example.travely.dto.request.VehicleRequestDto;
import com.example.travely.dto.response.VehicleResponseDto;
import com.example.travely.service.VehicleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/vehicles")
@RequiredArgsConstructor
public class VehicleController {

    private final VehicleService vehicleService;

    @PostMapping
    public ResponseEntity<VehicleResponseDto> create(@Valid @RequestBody VehicleRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(vehicleService.create(dto));
    }

    @GetMapping("/{id}")
    public ResponseEntity<VehicleResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(vehicleService.findById(id));
    }

    @GetMapping
    public ResponseEntity<List<VehicleResponseDto>> findVehicles(
            @RequestParam(required = false) Long tripId,
            @RequestParam(required = false) Long driverId) {
        if (driverId != null) {
            return ResponseEntity.ok(vehicleService.findByDriver(driverId));
        }
        return ResponseEntity.ok(vehicleService.findByTrip(tripId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<VehicleResponseDto> update(
            @PathVariable Long id,
            @Valid @RequestBody VehicleRequestDto dto) {
        return ResponseEntity.ok(vehicleService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        vehicleService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
