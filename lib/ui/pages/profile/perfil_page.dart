import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../core/config.dart'; // Importamos la configuración
import 'package:travely/ui/pages/auth/login_screen.dart';
import 'package:travely/ui/widgets/common/estilos.dart';

class PerfilPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const PerfilPage({super.key, required this.usuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  File? _imageFile;
  String? _fotoBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fotoBase64 = widget.usuario['foto_perfil'];
  }

  // --- FUNCIÓN PARA SELECCIONAR Y GUARDAR ---
  Future<void> _pickAndSaveImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );

    if (selectedImage != null) {
      final file = File(selectedImage.path);
      final imageBytes = await file.readAsBytes();
      final base64String = base64Encode(imageBytes);

      // USAMOS AppConfig.baseUrl
      final url = Uri.parse('${AppConfig.baseUrl}/update-foto');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'correo': widget.usuario['correo'],
            'foto': base64String,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _imageFile = file;
            _fotoBase64 = base64String;
            widget.usuario['foto_perfil'] = base64String;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto guardada permanentemente')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'PERFIL',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _pickAndSaveImage,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: _buildAvatarContent(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.usuario['name_usuario'] ?? 'USUARIO')
                            .toString()
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.usuario['correo']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1.5),
                minimumSize: const Size(double.infinity, 45),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                'CAMBIAR DE CUENTA',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'DATOS DE USUARIO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 2, color: Colors.black),
            const SizedBox(height: 25),
            _buildDatoItem('NOMBRE USUARIO', widget.usuario['name_usuario']),
            _buildDatoItem('NOMBRE REAL', widget.usuario['name']),
            _buildDatoItem('E-MAIL', widget.usuario['correo']),
            _buildDatoItem('CONTRASEÑA', '••••••••'),
            const SizedBox(height: 60),
            if (widget.usuario['premium'] != true)
              NeoButton(
                texto: 'MEJORAR PLAN',
                color: const Color(0xFFE6FF00),
                onTap: () {
                  // Acción futura para mejorar plan
                },
              ),
            const SizedBox(height: 15),
            NeoButton(
              texto: 'CERRAR SESIÓN',
              color: Colors.white,
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- LÓGICA PARA MOSTRAR LA FOTO SIEMPRE ---
  Widget _buildAvatarContent() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (_fotoBase64 != null && _fotoBase64!.isNotEmpty) {
      return Image.memory(
        base64Decode(_fotoBase64!),
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(
        Icons.add_a_photo_outlined,
        size: 40,
        color: Colors.black,
      );
    }
  }

  Widget _buildDatoItem(String etiqueta, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${valor ?? '---'}'.toUpperCase(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
