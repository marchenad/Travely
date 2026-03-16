import 'package:flutter/material.dart';

class BarraNavegacion extends StatelessWidget {
  final int velocidad;
  final String tiempoRestante;
  final String distanciaRestante;
  final VoidCallback onDetener;
  final VoidCallback? onShowFriends; // Nuevo callback para mostrar amigos

  const BarraNavegacion({
    super.key,
    required this.velocidad,
    required this.tiempoRestante,
    required this.distanciaRestante,
    required this.onDetener,
    this.onShowFriends,
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

            // BOTONES DE ACCIÓN (GRUPO Y CERRAR)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onShowFriends != null) ...[
                  GestureDetector(
                    onTap: onShowFriends,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE1FF00),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2.5),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                      ),
                      child: const Icon(Icons.group, color: Colors.black, size: 24),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
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
          ],
        ),
      ),
    );
  }
}
