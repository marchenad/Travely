package com.example.travely.mapper;

import com.example.travely.dto.request.TripRequestDto;
import com.example.travely.dto.response.TripResponseDto;
import com.example.travely.entity.Trip;
import org.mapstruct.*;

@Mapper(componentModel = "spring", uses = {VehicleMapper.class, WaypointMapper.class})
public interface TripMapper {

    @Mapping(source = "creator.id", target = "creatorId")
    @Mapping(source = "creator.name", target = "creatorName")
    TripResponseDto toResponseDto(Trip trip);

    @Mapping(target = "creator", ignore = true)
    @Mapping(target = "vehicles", ignore = true)
    @Mapping(target = "waypoints", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Trip toEntity(TripRequestDto dto);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "creator", ignore = true)
    @Mapping(target = "vehicles", ignore = true)
    @Mapping(target = "waypoints", ignore = true)
    void updateEntityFromDto(TripRequestDto dto, @MappingTarget Trip trip);
}
