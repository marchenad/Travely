import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static Future<Map<String, dynamic>?> obtenerInfoRuta(LatLng origen, LatLng destino) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${origen.longitude},${origen.latitude};${destino.longitude},${destino.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'Travely_App'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          double segundos = route['duration'].toDouble();
          double metros = route['distance'].toDouble();

          return {
            'tiempo': '${(segundos / 60).toStringAsFixed(0)} MIN',
            'distancia': '${(metros / 1000).toStringAsFixed(1)} KM',
          };
        }
      }
    } catch (e) {
      print("Error calculando ruta: $e");
    }
    return null;
  }

  // Método añadido para obtener los puntos de la línea (polilínea)
  static Future<List<LatLng>> obtenerPuntosRuta(LatLng origen, LatLng destino) async {
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${origen.longitude},${origen.latitude};${destino.longitude},${destino.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'Travely_App'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];
        return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
      }
    } catch (e) {
      print("Error obteniendo puntos: $e");
    }
    return [];
  }
}
