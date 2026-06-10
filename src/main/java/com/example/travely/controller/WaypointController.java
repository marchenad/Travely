package com.example.travely.controller;

import com.example.travely.dto.request.WaypointRequestDto;
import com.example.travely.dto.response.WaypointResponseDto;
import com.example.travely.service.WaypointService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class WaypointController {

    private final WaypointService waypointService;

    @PostMapping("/api/v1/waypoints")
    public ResponseEntity<WaypointResponseDto> create(@Valid @RequestBody WaypointRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(waypointService.create(dto));
    }

    @GetMapping("/api/v1/waypoints/{id}")
    public ResponseEntity<WaypointResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(waypointService.findById(id));
    }

    @GetMapping("/api/v1/trips/{tripId}/waypoints")
    public ResponseEntity<List<WaypointResponseDto>> findByTrip(@PathVariable Long tripId) {
        return ResponseEntity.ok(waypointService.findByTrip(tripId));
    }

    @PutMapping("/api/v1/waypoints/{id}")
    public ResponseEntity<WaypointResponseDto> update(
            @PathVariable Long id,
            @Valid @RequestBody WaypointRequestDto dto) {
        return ResponseEntity.ok(waypointService.update(id, dto));
    }

    @PatchMapping("/api/v1/waypoints/{id}/visit")
    public ResponseEntity<WaypointResponseDto> markVisited(@PathVariable Long id) {
        return ResponseEntity.ok(waypointService.markVisited(id));
    }

    @DeleteMapping("/api/v1/waypoints/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        waypointService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
