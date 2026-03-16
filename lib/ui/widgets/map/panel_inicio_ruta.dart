import 'package:flutter/material.dart';

class PanelInicioRuta extends StatelessWidget {
  final String? nombreViaje;
  final int paxActual;
  final String tiempoEstimado;
  final String distancia;
  final VoidCallback onAddFriend;
  final VoidCallback onAction;

  const PanelInicioRuta({
    super.key,
    this.nombreViaje,
    required this.paxActual,
    required this.tiempoEstimado,
    required this.distancia,
    required this.onAddFriend,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, -5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // INDICADOR SUPERIOR
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          
          // FILA DE DESTINO Y PAX
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "DESTINO SELECCIONADO:",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
                    ),
                    Text(
                      nombreViaje?.toUpperCase() ?? "SITIO",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1FF00),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Text(
                  "$paxActual/5 PAX",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          
          // FILA DE ESTADÍSTICAS (TIEMPO Y DISTANCIA)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("TIEMPO", tiempoEstimado),
              Container(width: 2, height: 40, color: Colors.black12),
              _buildStat("DISTANCIA", distancia),
            ],
          ),
          const SizedBox(height: 30),
          
          // BOTONES DE ACCIÓN
          Row(
            children: [
              // BOTÓN INVITAR
              GestureDetector(
                onTap: onAddFriend,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                  ),
                  child: const Icon(Icons.person_add, color: Colors.black),
                ),
              ),
              const SizedBox(width: 15),
              // BOTÓN INICIAR RUTA
              Expanded(
                child: GestureDetector(
                  onTap: onAction,
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1FF00),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                    ),
                    child: const Text(
                      "INICIAR RUTA",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
