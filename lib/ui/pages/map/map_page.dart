import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../../core/location_service.dart';
import '../../../core/route_service.dart';
import '../../../core/constants.dart';
import '../../widgets/map/avatar_perfil.dart';
import '../../widgets/map/panel_inicio_ruta.dart';
import '../profile/perfil_page.dart';
import 'modo_navegacion.dart';

class MapPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const MapPage({super.key, required this.usuario});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  String? _destinationName;
  String _tiempoEstimado = "0 MIN";
  String _distanciaEstimada = "0 KM";
  bool _isPanelVisible = false;

  // Variables para la búsqueda integrada
  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      Position? position = await LocationService.determinarPosicion();
      if (position != null) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, 15);
      }
    } catch (e) {
      debugPrint("Error obteniendo ubicación: $e");
    }
  }

  // Lógica de búsqueda integrada robusta
  Future<void> _buscarSitios(String query) async {
    if (query.length < 3) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '5',
      'accept-language': 'es',
      'addressdetails': '1',
    });

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'Travely_GPS_App_v3_${DateTime.now().millisecondsSinceEpoch}'
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _suggestions = data;
            _isSearching = false;
          });
        }
      } else {
        if (mounted) setState(() => _isSearching = false);
      }
    } catch (e) {
      debugPrint("Error en búsqueda: $e");
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _seleccionarDestino(LatLng point, String nombre) async {
    setState(() {
      _destinationPosition = point;
      _destinationName = nombre;
      _isPanelVisible = true;
      _suggestions = []; 
      _searchController.clear();
      _isSearching = false;
    });

    if (_currentPosition != null) {
      final info = await RouteService.obtenerInfoRuta(_currentPosition!, point);
      if (info != null) {
        setState(() {
          _tiempoEstimado = info['tiempo'];
          _distanciaEstimada = info['distancia'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAPA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 15,
              onTap: (tapPosition, point) => _seleccionarDestino(point, "Destino Seleccionado"),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                userAgentPackageName: AppConstants.mapUserAgent,
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                    ),
                  ],
                ),
              if (_destinationPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _destinationPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),

          // BARRA DE BÚSQUEDA INTEGRADA (DISEÑO NEOBRUTALISTA)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 90,
            child: Column(
              children: [
                // CAJA DE TEXTO
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 600), () => _buscarSitios(val));
                    },
                    onTap: () => setState(() => _isPanelVisible = false),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "BUSCAR DESTINO...",
                      hintStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: _isSearching 
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 15, height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            ),
                          )
                        : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                
                // DESPLEGABLE DE SUGERENCIAS
                if (_suggestions.isNotEmpty && _searchController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1, thickness: 1),
                        itemBuilder: (context, i) {
                          final item = _suggestions[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on, color: Colors.black, size: 20),
                            title: Text(
                              item['display_name'].toString().toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              final lat = double.parse(item['lat']);
                              final lon = double.parse(item['lon']);
                              final point = LatLng(lat, lon);
                              
                              _seleccionarDestino(point, item['display_name']);
                              _mapController.move(point, 15);
                              FocusScope.of(context).unfocus();
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // AVATAR PERFIL (Esquina superior derecha)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: AvatarPerfil(
              fotoBase64: widget.usuario['foto_perfil'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilPage(usuario: widget.usuario),
                  ),
                );
              },
            ),
          ),

          // PANEL DE INICIO DE RUTA
          if (_isPanelVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: PanelInicioRuta(
                nombreViaje: _destinationName,
                paxActual: 1,
                tiempoEstimado: _tiempoEstimado,
                distancia: _distanciaEstimada,
                onAddFriend: () {
                  // Lógica para invitar
                },
                onAction: () {
                  if (_currentPosition != null && _destinationPosition != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModoNavegacion(
                          destinoCoords: _destinationPosition!,
                          usuarioCoords: _currentPosition!,
                          destinoNombre: _destinationName ?? "Ruta",
                          tiempo: _tiempoEstimado,
                          distancia: _distanciaEstimada,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _initLocation,
        child: const Icon(Icons.gps_fixed, color: Colors.black),
      ),
    );
  }
}
