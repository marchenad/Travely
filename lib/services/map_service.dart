import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../core/constants.dart';

class MapService {
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      '${AppConstants.osrmBaseUrl}/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': AppConstants.mapUserAgent, // Requerido para evitar 403
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
      } else {
        throw Exception('Error en OSRM: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener ruta: $e');
    }
  }
}
