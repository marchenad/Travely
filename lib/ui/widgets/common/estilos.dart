import 'package:flutter/material.dart';

class NeoButton extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  final Color? color;
  final double height;

  const NeoButton({
    super.key,
    required this.texto,
    required this.onTap,
    this.color,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color ?? const Color(0xFFE6FF00),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            texto.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
