import 'package:flutter/material.dart';

class BarraNavegacion extends StatelessWidget {
  final int velocidad;
  final String tiempoRestante;
  final String distanciaRestante;
  final VoidCallback onDetener;

  const BarraNavegacion({
    super.key,
    required this.velocidad,
    required this.tiempoRestante,
    required this.distanciaRestante,
    required this.onDetener,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Colors.black, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // VELOCIDAD
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "$velocidad",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const Text(
                  "KM/H",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),

            // TIEMPO Y DISTANCIA
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tiempoRestante,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF00C853)),
                ),
                Text(
                  distanciaRestante,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // BOTÓN DETENER (X ROJA)
            GestureDetector(
              onTap: onDetener,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2.5),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
