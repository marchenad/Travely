package com.example.travely.controller;

import com.example.travely.dto.request.TripRequestDto;
import com.example.travely.dto.response.TripResponseDto;
import com.example.travely.entity.TripStatus;
import com.example.travely.service.TripService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/trips")
@RequiredArgsConstructor
public class TripController {

    private final TripService tripService;

    @PostMapping
    public ResponseEntity<TripResponseDto> create(@Valid @RequestBody TripRequestDto dto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(tripService.create(dto));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TripResponseDto> findById(@PathVariable Long id) {
        return ResponseEntity.ok(tripService.findById(id));
    }

    @GetMapping
    public ResponseEntity<List<TripResponseDto>> findAll(
            @RequestParam(required = false) Long creatorId) {
        if (creatorId != null) {
            return ResponseEntity.ok(tripService.findByCreator(creatorId));
        }
        return ResponseEntity.ok(tripService.findAll());
    }

    // Endpoint paginado: GET /api/v1/trips?creatorId=X&page=0&size=10
    @GetMapping(params = "page")
    public ResponseEntity<Page<TripResponseDto>> findAllPaged(
            @RequestParam(required = false) Long creatorId,
            @PageableDefault(size = 10, sort = "updatedAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(tripService.findByCreatorPaged(creatorId, pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TripResponseDto> update(
            @PathVariable Long id,
            @Valid @RequestBody TripRequestDto dto) {
        return ResponseEntity.ok(tripService.update(id, dto));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<TripResponseDto> updateStatus(
            @PathVariable Long id,
            @RequestParam TripStatus status) {
        return ResponseEntity.ok(tripService.updateStatus(id, status));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        tripService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
