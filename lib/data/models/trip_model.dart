import 'package:latlong2/latlong.dart';

enum TripStatus { buscando, en_ruta, finalizado }

class Trip {
  final String id;
  final String nombreViaje;
  final int paxActual;
  final int paxMax;
  final LatLng destino;
  final TripStatus status;

  Trip({
    required this.id,
    required this.nombreViaje,
    required this.paxActual,
    this.paxMax = 5,
    required this.destino,
    this.status = TripStatus.buscando,
  });

  factory Trip.fromMap(Map<String, dynamic> data, String id) {
    return Trip(
      id: id,
      nombreViaje: data['nombreViaje'] ?? '',
      paxActual: data['paxActual'] ?? 1,
      paxMax: data['paxMax'] ?? 5,
      destino: LatLng(
        data['destino']['lat'] ?? 0.0,
        data['destino']['lng'] ?? 0.0,
      ),
      status: TripStatus.values.firstWhere(
        (e) => e.toString() == 'TripStatus.${data['status']}',
        orElse: () => TripStatus.buscando,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombreViaje': nombreViaje,
      'paxActual': paxActual,
      'paxMax': paxMax,
      'destino': {'lat': destino.latitude, 'lng': destino.longitude},
      'status': status.name,
    };
  }
}
