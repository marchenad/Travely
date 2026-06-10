import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'dart:async';

import '../../../core/location_service.dart';
import '../../../core/route_service.dart';
import '../../../core/constants.dart';
import '../../../core/config.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/map/avatar_perfil.dart';
import '../../widgets/map/panel_inicio_ruta.dart';
import '../profile/perfil_page.dart';
import '../friends/amigos_page.dart';
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
  late IO.Socket _socket;
  
  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  String? _destinationName;
  String _tiempoEstimado = "0 MIN";
  String _distanciaEstimada = "0 KM";
  bool _isPanelVisible = false;

  List<dynamic> _suggestions = [];
  Timer? _debounce;
  bool _isSearching = false;
  List<UserModel> _amigosSeleccionados = [];
  List<UserModel> _misAmigosTotales = []; 
  
  Map<int, LatLng> _posicionesAmigos = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initSocket();
    _cargarAmigosIniciales();
  }

  void _initSocket() {
    _socket = IO.io(AppConfig.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Conectado al servidor de tiempo real');
      if (_misAmigosTotales.isNotEmpty) {
        _socket.emit('pedir_posiciones_iniciales', _misAmigosTotales.map((e) => e.id).toList());
      }
    });

    _socket.on('posiciones_initiales', (data) {
      if (mounted) {
        setState(() {
          data.forEach((userId, pos) {
            _posicionesAmigos[int.parse(userId)] = LatLng(pos['lat'], pos['lon']);
          });
        });
      }
    });

    _socket.on('amigo_moviendose', (data) {
      if (mounted) {
        setState(() {
          _posicionesAmigos[data['userId']] = LatLng(data['lat'], data['lon']);
        });
      }
    });
  }

  Future<void> _cargarAmigosIniciales() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/amigos/mis-amigos/${widget.usuario['id']}'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _misAmigosTotales = data.map((u) => UserModel.fromMap(u)).toList();
        if (_socket.connected) {
          _socket.emit('pedir_posiciones_iniciales', _misAmigosTotales.map((e) => e.id).toList());
        }
      }
    } catch (e) {
      debugPrint("Error cargando amigos iniciales: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _socket.dispose();
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
        _iniciarSeguimientoGPS();
      }
    } catch (e) {
      debugPrint("Error ubicación: $e");
    }
  }

  void _iniciarSeguimientoGPS() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      if (mounted) {
        setState(() => _currentPosition = LatLng(position.latitude, position.longitude));
        _socket.emit('actualizar_gps', {
          'lat': position.latitude,
          'lon': position.longitude,
          'userId': widget.usuario['id'],
          'viajeId': 'general'
        });
      }
    });
  }

  Future<void> _buscarSitios(String query) async {
    if (query.length < 3) {
      setState(() { _suggestions = []; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query, 'format': 'json', 'limit': '5', 'accept-language': 'es', 'addressdetails': '1',
    });
    try {
      final response = await http.get(url, headers: {'User-Agent': 'Travely_GPS_${DateTime.now().millisecondsSinceEpoch}'});
      if (response.statusCode == 200) {
        setState(() { _suggestions = json.decode(response.body); _isSearching = false; });
      }
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _abrirModalAmigos() async {
    await _cargarAmigosIniciales();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("INVITAR AMIGOS AL VIAJE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const Divider(color: Colors.black, thickness: 2),
              const SizedBox(height: 10),
              if (_misAmigosTotales.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("NO TIENES AMIGOS AÑADIDOS AÚN"),
                ),
              ..._misAmigosTotales.map((amigo) {
                final isSelected = _amigosSeleccionados.any((a) => a.id == amigo.id);
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.black),
                  title: Text(amigo.nameUsuario.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: Colors.black),
                  onTap: () {
                    setModalState(() {
                      setState(() {
                        if (isSelected) {
                          _amigosSeleccionados.removeWhere((a) => a.id == amigo.id);
                        } else {
                          _amigosSeleccionados.add(amigo);
                        }
                      });
                    });
                  },
                );
              }),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0xFFE1FF00), border: Border.all(color: Colors.black, width: 2)),
                  child: const Text("LISTO", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarDestino(LatLng point, String nombre) async {
    setState(() {
      _destinationPosition = point;
      _destinationName = nombre;
      _isPanelVisible = true;
      _suggestions = []; 
      _searchController.clear();
      _isSearching = false;
      _amigosSeleccionados = [];
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 15,
              onTap: (tapPosition, point) => _seleccionarDestino(point, "Destino Seleccionado"),
            ),
            children: [
              TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png'),
              MarkerLayer(markers: [
                if (_currentPosition != null)
                  Marker(point: _currentPosition!, width: 40, height: 40, child: const Icon(Icons.my_location, color: Colors.blue, size: 30)),
                ..._posicionesAmigos.entries.map((entry) => Marker(
                  point: entry.value,
                  width: 40, height: 40,
                  child: const Icon(Icons.person_pin_circle, color: Colors.green, size: 35),
                )),
                if (_destinationPosition != null)
                  Marker(point: _destinationPosition!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 40)),
              ]),
            ],
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20, right: 90,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 600), () => _buscarSitios(val));
                    },
                    decoration: InputDecoration(
                      hintText: "BUSCAR DESTINO...",
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty && _searchController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 3), boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))]),
                    child: Material(
                      color: Colors.transparent,
                      child: ListView.separated(
                        padding: EdgeInsets.zero, shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
                        itemBuilder: (context, i) {
                          final item = _suggestions[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on, color: Colors.black, size: 20),
                            title: Text(item['display_name'].toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900), maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              final p = LatLng(double.parse(item['lat']), double.parse(item['lon']));
                              _seleccionarDestino(p, item['display_name']);
                              _mapController.move(p, 15);
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

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 20,
            child: AvatarPerfil(
              fotoBase64: widget.usuario['foto_perfil'],
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PerfilPage(usuario: widget.usuario))),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 85,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AmigosPage(usuario: widget.usuario)),
              ),
              child: Container(
                width: 55, height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1FF00),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                ),
                child: const Icon(Icons.group, color: Colors.black, size: 30),
              ),
            ),
          ),

          if (_isPanelVisible)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: PanelInicioRuta(
                nombreViaje: _destinationName,
                paxActual: _amigosSeleccionados.length + 1,
                nombresAmigos: _amigosSeleccionados.map((a) => a.nameUsuario).toList(),
                tiempoEstimado: _tiempoEstimado,
                distancia: _distanciaEstimada,
                onAddFriend: _abrirModalAmigos,
                onRemoveFriend: (index) {
                  setState(() {
                    _amigosSeleccionados.removeAt(index);
                  });
                },
                onUserTap: (index) {
                  final amigoId = _amigosSeleccionados[index].id;
                  if (amigoId != null && _posicionesAmigos.containsKey(amigoId)) {
                    _mapController.move(_posicionesAmigos[amigoId]!, 17);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${_amigosSeleccionados[index].nameUsuario} no está compartiendo ubicación.")),
                    );
                  }
                },
                onAction: () async {
                  if (_destinationPosition != null) {
                    await http.post(
                      Uri.parse('${AppConfig.baseUrl}/viajes/compartir'),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "creadorId": widget.usuario['id'],
                        "destinoNombre": _destinationName,
                        "destinoLat": _destinationPosition!.latitude,
                        "destinoLon": _destinationPosition!.longitude,
                        "amigosIds": _amigosSeleccionados.map((a) => a.id).toList()
                      }),
                    );

                    if (!mounted) return;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ModoNavegacion(
                      destinoCoords: _destinationPosition!,
                      usuarioCoords: _currentPosition!,
                      destinoNombre: _destinationName ?? "Ruta",
                      tiempo: _tiempoEstimado,
                      distancia: _distanciaEstimada,
                      socket: _socket,
                      amigos: _amigosSeleccionados,
                      usuario: widget.usuario,
                    )));
                  }
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: Colors.white, onPressed: _initLocation, child: const Icon(Icons.gps_fixed, color: Colors.black)),
    );
  }
}
