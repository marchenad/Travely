package com.example.travely.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
public class CorsConfig {

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {

        CorsConfiguration config = new CorsConfiguration();

        // IMPORTANTE: Debes incluir el dominio HTTPS aquí para que el navegador lo permita
        config.setAllowedOrigins(List.of(
                "https://travely.devdyd.com",
                "http://100.102.137.92:8085",
                "http://localhost:4200"
        ));

        config.setAllowedMethods(List.of(
                "GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"
        ));

        config.setAllowedHeaders(List.of("*"));

        // Se exponen cabeceras para que el frontend pueda leer tokens de autenticación
        config.setExposedHeaders(List.of("Authorization", "Content-Type"));

        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);

        return source;
    }
}