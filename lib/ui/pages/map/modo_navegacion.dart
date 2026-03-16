import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../core/route_service.dart';
import '../../../core/maniobra_pro.dart';
import '../../widgets/map/panel_instrucciones.dart';
import '../../widgets/map/barra_navegacion.dart';

class ModoNavegacion extends StatefulWidget {
  final LatLng destinoCoords;
  final LatLng usuarioCoords;
  final String destinoNombre;
  final String tiempo;
  final String distancia;

  const ModoNavegacion({
    super.key, 
    required this.destinoCoords, 
    required this.usuarioCoords, 
    required this.destinoNombre,
    required this.tiempo,
    required this.distancia,
  });

  @override
  State<ModoNavegacion> createState() => _ModoNavegacionState();
}

class _ModoNavegacionState extends State<ModoNavegacion> {
  final MapController _mapController = MapController();
  final Distance _distanceTool = const Distance();

  List<LatLng> _rutaPoints = [];
  List<ManiobraPro> _hojaDeRuta = [];
  LatLng? _currentPos;
  double _heading = 0.0;
  int _indiceManiobra = 0;
  bool _autoSeguir = true;
  int _velocidadActual = 0;

  Timer? _timerSimulacion;
  int _indiceSimulacion = 0;
  bool _estaSimulando = false;

  static const Color colorNeoBlue = Color(0xFF1A73E8);

  @override
  void initState() {
    super.initState();
    _currentPos = widget.usuarioCoords;
    _cargarYProcesarRuta();
    _iniciarSeguimientoGPS();
  }

  @override
  void dispose() {
    _timerSimulacion?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _iniciarSimulacion() {
    if (_rutaPoints.isEmpty) return;

    _timerSimulacion?.cancel();
    setState(() {
      _estaSimulando = true;
      _indiceSimulacion = 0;
      _autoSeguir = true;
      _indiceManiobra = 0;
    });

    _timerSimulacion = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_indiceSimulacion < _rutaPoints.length) {
        setState(() {
          _currentPos = _rutaPoints[_indiceSimulacion];

          if (_indiceSimulacion < _rutaPoints.length - 1) {
            _heading = _calcularBearing(
                _rutaPoints[_indiceSimulacion],
                _rutaPoints[_indiceSimulacion + 1]
            );
          }

          _velocidadActual = 55;
          _indiceSimulacion++;
        });

        _gestionarProximaManiobra();
        if (_autoSeguir) _actualizarCamara();
      } else {
        timer.cancel();
        setState(() => _estaSimulando = false);
      }
    });
  }

  double _calcularBearing(LatLng inicio, LatLng fin) {
    double lat1 = inicio.latitude * math.pi / 180;
    double lon1 = inicio.longitude * math.pi / 180;
    double lat2 = fin.latitude * math.pi / 180;
    double lon2 = fin.longitude * math.pi / 180;
    double dLon = lon2 - lon1;
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  void _iniciarSeguimientoGPS() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2
      ),
    ).listen((pos) {
      if (!mounted || _estaSimulando) return;
      setState(() {
        _currentPos = LatLng(pos.latitude, pos.longitude);
        _heading = pos.heading;
        _velocidadActual = (pos.speed * 3.6).round();
      });
      _gestionarProximaManiobra();
      if (_autoSeguir) _actualizarCamara();
    });
  }

  Future<void> _cargarYProcesarRuta() async {
    final pts = await RouteService.obtenerPuntosRuta(widget.usuarioCoords, widget.destinoCoords);
    if (mounted) {
      setState(() {
        _rutaPoints = pts;
        _analizarRutaParaVoz(pts);
      });
    }
  }

  void _analizarRutaParaVoz(List<LatLng> puntos) {
    _hojaDeRuta.clear();
    if (puntos.isEmpty) return;

    if (puntos.length > 30) {
      _hojaDeRuta.add(ManiobraPro(
        punto: puntos[25],
        titulo: "GIRO PRÓXIMO",
        instruccion: "Gire a la derecha por Calle Mayor",
        icono: Icons.turn_right,
        tipo: TipoManiobra.giro,
      ));
    }

    _hojaDeRuta.add(ManiobraPro(
      punto: puntos.last,
      titulo: widget.destinoNombre,
      instruccion: "Llegada al destino",
      icono: Icons.flag,
      tipo: TipoManiobra.destino,
    ));
  }

  void _gestionarProximaManiobra() {
    if (_hojaDeRuta.isEmpty || _indiceManiobra >= _hojaDeRuta.length) return;
    double d = _distanceTool.as(LengthUnit.Meter, _currentPos!, _hojaDeRuta[_indiceManiobra].punto);

    if (d < 15 && _indiceManiobra < _hojaDeRuta.length - 1) {
      setState(() => _indiceManiobra++);
    }
  }

  void _actualizarCamara() {
    if (_currentPos != null) {
      _mapController.moveAndRotate(_currentPos!, 18.5, -_heading);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maniobraActual = _hojaDeRuta.isNotEmpty ? _hojaDeRuta[_indiceManiobra] : null;
    final double dist = (maniobraActual != null && _currentPos != null)
        ? _distanceTool.as(LengthUnit.Meter, _currentPos!, maniobraActual.punto)
        : 0;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.usuarioCoords,
              initialZoom: 18.5,
              onPositionChanged: (pos, hasGesture) { if (hasGesture) _autoSeguir = false; },
            ),
            children: [
              TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png'),

              PolylineLayer(polylines: [
                Polyline(
                    points: _rutaPoints,
                    color: colorNeoBlue,
                    strokeWidth: 8,
                    borderColor: Colors.black,
                    borderStrokeWidth: 2.5
                ),
              ]),

              MarkerLayer(markers: [
                if (_currentPos != null)
                  Marker(
                    point: _currentPos!,
                    width: 60, height: 60,
                    child: _buildNeoUserIndicator(),
                  ),
              ]),
            ],
          ),

          if (maniobraActual != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 0, right: 0,
              child: PanelInstruccionesNeo(
                instruccion: maniobraActual.instruccion,
                distanciaMetros: dist,
                icono: maniobraActual.icono,
                carril: maniobraActual.carril,
                numeroSalida: maniobraActual.numeroSalida,
                nombreVia: maniobraActual.nombreVia,
              ),
            ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: GestureDetector(
              onTap: () {
                if (!_estaSimulando) {
                  _iniciarSimulacion();
                } else {
                  setState(() => _autoSeguir = true);
                  _actualizarCamara();
                }
              },
              child: BarraNavegacion(
                velocidad: _velocidadActual,
                tiempoRestante: _estaSimulando ? "MODO DEMO" : widget.tiempo,
                distanciaRestante: widget.distancia,
                onDetener: () {
                  _timerSimulacion?.cancel();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeoUserIndicator() {
    return Transform.rotate(
      angle: (_heading * (math.pi / 180)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 34, height: 34,
            margin: const EdgeInsets.only(top: 4, left: 4),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
          ),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2.5),
            ),
            child: Center(
              child: Container(
                width: 14, height: 14,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: colorNeoBlue),
              ),
            ),
          ),
          Positioned(
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}
