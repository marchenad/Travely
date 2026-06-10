package com.example.travely.mapper;

import com.example.travely.dto.request.WaypointRequestDto;
import com.example.travely.dto.response.WaypointResponseDto;
import com.example.travely.entity.Waypoint;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface WaypointMapper {

    @Mapping(source = "trip.id", target = "tripId")
    WaypointResponseDto toResponseDto(Waypoint waypoint);

    @Mapping(target = "trip", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "visitedAt", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Waypoint toEntity(WaypointRequestDto dto);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "trip", ignore = true)
    void updateEntityFromDto(WaypointRequestDto dto, @MappingTarget Waypoint waypoint);
}
