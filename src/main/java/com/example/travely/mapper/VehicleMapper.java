package com.example.travely.mapper;

import com.example.travely.dto.request.VehicleRequestDto;
import com.example.travely.dto.response.VehicleResponseDto;
import com.example.travely.entity.Vehicle;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface VehicleMapper {

    @Mapping(source = "driver.id",             target = "driverId")
    @Mapping(source = "driver.name",           target = "driverName")
    @Mapping(source = "driver.phone",          target = "driverPhone")
    @Mapping(source = "driver.profilePicture", target = "driverProfilePicture")
    @Mapping(source = "trip.id",     target = "tripId")
    @Mapping(source = "trip.title",  target = "tripTitle")
    @Mapping(target = "tripStatus",  expression = "java(vehicle.getTrip() != null ? vehicle.getTrip().getStatus().name() : null)")
    @Mapping(source = "trip.destinationName",      target = "tripDestinationName")
    @Mapping(source = "trip.destinationLatitude",  target = "tripDestinationLatitude")
    @Mapping(source = "trip.destinationLongitude", target = "tripDestinationLongitude")
    @Mapping(source = "trip.creator.id",           target = "tripCreatorId")
    @Mapping(source = "trip.updatedAt",            target = "tripUpdatedAt")
    @Mapping(source = "trip.navigationVersion",    target = "tripNavigationVersion")
    VehicleResponseDto toResponseDto(Vehicle vehicle);

    @Mapping(target = "driver", ignore = true)
    @Mapping(target = "trip", ignore = true)
    @Mapping(target = "locations", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Vehicle toEntity(VehicleRequestDto dto);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "driver", ignore = true)
    @Mapping(target = "trip", ignore = true)
    @Mapping(target = "locations", ignore = true)
    void updateEntityFromDto(VehicleRequestDto dto, @MappingTarget Vehicle vehicle);
}
