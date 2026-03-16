import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travely/ui/pages/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Intenta inicializar Firebase. Si falla (por falta de archivo json), la app seguirá funcionando
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase no se pudo inicializar: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travely',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Montserrat', // Fuente pesada recomendada para neobrutalismo
      ),
      home: const LoginScreen(),
    );
  }
}
