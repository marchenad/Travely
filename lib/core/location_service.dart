import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> determinarPosicion() async {
    bool servicioHabilitado;
    LocationPermission permiso;

    // 1. Verificar si el GPS del móvil está encendido
    servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return Future.error('El GPS está desactivado.');
    }

    // 2. Verificar permisos
    permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        return Future.error('Permisos de ubicación denegados.');
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      return Future.error('Los permisos están denegados permanentemente. Ve a ajustes.');
    }

    // 3. Si todo ok, devolver la posición actual
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
  }
}