import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travely/ui/pages/map/map_page.dart';
import 'package:travely/ui/pages/auth/register_screen.dart';
import 'package:travely/ui/widgets/common/estilos.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> iniciarSesion() async {
    setState(() => _isLoading = true);
    final url = Uri.parse('https://hemihydrated-gemma-catchingly.ngrok-free.dev/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(usuario: data['usuario']),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de acceso')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TRAVELY',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            const Text(
              'BIENVENIDO DE NUEVO',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 50),
            _buildTextField('E-MAIL', _emailController),
            _buildTextField('CONTRASEÑA', _passwordController, obscure: true),
            const SizedBox(height: 40),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            else
              NeoButton(
                texto: 'ENTRAR',
                onTap: iniciarSesion,
              ),
            const SizedBox(height: 20),
            NeoButton(
              texto: 'CREAR CUENTA',
              color: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Los mismos widgets auxiliares para mantener la simetría
  Widget _buildTextField(
    String etiqueta,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.zero,
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.5),
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

