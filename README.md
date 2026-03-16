# Travely 🚗📍

Travely es una aplicación de navegación y GPS desarrollada en **Flutter** con un diseño moderno basado en el estilo **Neobrutalista** (bordes gruesos, sombras sólidas y colores vibrantes).

## ✨ Características Principales

*   **Mapa Interactivo**: Integración con `flutter_map` (OpenStreetMap).
*   **Búsqueda Global**: Barra de búsqueda integrada utilizando la API de **Nominatim** para encontrar cualquier localización en el mundo.
*   **Geolocalización en Tiempo Real**: Seguimiento de la posición del usuario mediante `geolocator`.
*   **Cálculo de Rutas**: Estimación de tiempo y distancia entre el punto actual y el destino usando `OSRM`.
*   **Modo Navegación**: Pantalla dedicada para la ruta con seguimiento automático de cámara y simulación de trayecto.
*   **Perfil de Usuario**: Gestión de perfil con soporte para avatares en Base64.

## 🎨 Estilo Visual
La aplicación utiliza una estética **Neobrutalista** personalizada:
*   Bordes negros de alto contraste.
*   Sombras sólidas proyectadas (`Offset(4, 4)`).
*   Tipografías en negrita para máxima legibilidad.

## 🛠️ Tecnologías Utilizadas

*   **Lenguaje**: Dart
*   **Framework**: Flutter
*   **Mapas**: Flutter Map / OpenStreetMap
*   **Servicios**: OSRM (Open Source Routing Machine)
*   **API de Búsqueda**: Nominatim (OSM)
*   **Base de Datos**: Soporte para integración con PostgreSQL.

## 🚀 Cómo ejecutar el proyecto

1. Clona el repositorio:
   ```bash
   git clone https://github.com/marchenad/Travely.git
   ```
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Asegúrate de tener un emulador Android/iOS con conexión a internet.
4. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

---
Desarrollado con ❤️ por [Marchenad](https://github.com/marchenad)
