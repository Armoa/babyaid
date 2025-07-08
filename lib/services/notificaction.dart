import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotifHelper {
  NotifHelper._();

  static Future<void> initNotif() async {
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("607cf8cc-38e5-4faf-b8b6-d57802af7edb");

    OneSignal.Notifications.requestPermission(true);
  }
}
