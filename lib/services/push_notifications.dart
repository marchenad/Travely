import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class PushNotificationService {
  FirebaseMessaging? _fcm;

  Future<void> initialize() async {
    try {
      // Verificamos si Firebase está inicializado antes de acceder a Messaging
      if (Firebase.apps.isNotEmpty) {
        _fcm = FirebaseMessaging.instance;

        // Solicitar permisos
        await _fcm?.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        // Obtener token
        String? token = await _fcm?.getToken();
        print("FCM Token: $token");

        // Escuchar mensajes
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Mensaje recibido: ${message.data}');
        });
      } else {
        print("Firebase no está inicializado. Notificaciones desactivadas.");
      }
    } catch (e) {
      print("Error al inicializar Push Notifications: $e");
    }
  }

  Future<void> sendInvitation(String friendId, String tripId) async {
    print("Invitando al amigo $friendId al viaje $tripId");
  }
}
