import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum TipoManiobra { giro, rotonda, autovia, destino, carril }

class ManiobraPro {
  final LatLng punto;
  final String titulo;
  final String instruccion;
  final IconData icono;
  final TipoManiobra tipo;
  final int? numeroSalida; 
  final String? nombreVia;  
  final String? carril;     

  ManiobraPro({
    required this.punto,
    required this.titulo,
    required this.instruccion,
    required this.icono,
    required this.tipo,
    this.numeroSalida,
    this.nombreVia,
    this.carril,
  });
}
