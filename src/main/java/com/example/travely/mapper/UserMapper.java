package com.example.travely.mapper;

import com.example.travely.dto.request.UserRequestDto;
import com.example.travely.dto.response.UserResponseDto;
import com.example.travely.entity.User;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface UserMapper {
    User toEntity(UserRequestDto dto);
    UserResponseDto toResponseDto(User user);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateEntityFromDto(UserRequestDto dto, @MappingTarget User user);
}
