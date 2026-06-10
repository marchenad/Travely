import 'dart:convert';
import 'package:flutter/material.dart';

class AvatarPerfil extends StatelessWidget {
  final String? fotoBase64;
  final VoidCallback onTap;

  const AvatarPerfil({
    super.key, 
    required this.fotoBase64, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        height: 55,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (fotoBase64 != null && fotoBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(fotoBase64!),
          fit: BoxFit.cover,
        );
      } catch (e) {
        return const Icon(Icons.person, size: 30, color: Colors.black);
      }
    } else {
      return const Icon(Icons.person, size: 30, color: Colors.black);
    }
  }
}
