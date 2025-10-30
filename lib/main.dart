
import 'package:flutter/material.dart';



import 'widgets/whatsapp_chat_button.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/app.dart';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotifications();
  runApp(const ProviderScope(child: SmartHasApp()));
}
