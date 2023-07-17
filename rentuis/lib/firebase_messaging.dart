import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Obtén el token de registro FCM
    String? token = await _firebaseMessaging.getToken();
    print('Token de registro FCM: $token');

    // Escucha los mensajes entrantes mientras la aplicación está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación en primer plano: ${message.notification?.body}');
    });

    // Escucha los mensajes entrantes mientras la aplicación está en segundo plano
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Notificación en segundo plano: ${message.notification?.body}');
  }
}