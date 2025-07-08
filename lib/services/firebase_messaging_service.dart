import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Solicitar permisos para notificaciones (iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permisos de notificaciones: ${settings.authorizationStatus}');

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje en primer plano: ${message.notification?.title}');
    });

    // Aquí puedes manejar otros eventos como mensajes en segundo plano
  }
}
