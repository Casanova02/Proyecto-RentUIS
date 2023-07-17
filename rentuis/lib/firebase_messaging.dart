import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Configuración de notificaciones locales
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Obtén el token de registro FCM
    String? token = await _firebaseMessaging.getToken();
    print('Token de registro FCM: $token');

    // Escucha los mensajes entrantes mientras la aplicación está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación en primer plano: ${message.notification?.body}');
      _showLocalNotification(message.notification?.title, message.notification?.body);
    });

    // Escucha los mensajes entrantes mientras la aplicación está en segundo plano
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Notificación en segundo plano: ${message.notification?.body}');
    _showLocalNotification(message.notification?.title, message.notification?.body);
  }

  Future<void> _showLocalNotification(String? title, String? body) async {
    var android = AndroidNotificationDetails(
      'ofertas_channel', // channel_id
      'Ofertas', // channel_name
      priority: Priority.high,
      importance: Importance.max,
      enableLights: true,
      color: Colors.blue, // Color de la luz de la notificación
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'), // Sonido personalizado para Android, debe estar en la carpeta 'res/raw'
    );

    var platform = NotificationDetails(android: android);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platform,
    );
  }
}
