import 'package:babyaid/provider/auth_provider.dart' as app_auth;
import 'package:babyaid/provider/auth_provider.dart' as local_auth;
import 'package:babyaid/provider/cart_provider.dart';
import 'package:babyaid/provider/notificaciones_provider.dart';
import 'package:babyaid/provider/payment_provider.dart';
import 'package:babyaid/provider/personal_provider.dart';
import 'package:babyaid/provider/theme.dart';
import 'package:babyaid/screens/home.dart';
import 'package:babyaid/screens/login.dart';
import 'package:babyaid/services/auth_service.dart';
import 'package:babyaid/services/firebase_messaging_service.dart';
import 'package:babyaid/services/http_client.dart';
import 'package:babyaid/services/notificaction.dart';
import 'package:babyaid/splash_screen.dart';
import 'package:babyaid/widget/theme_mode.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_PY', null);
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('bannerShown');

  FirebaseMessagingService messagingService = FirebaseMessagingService();
  await messagingService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PersonalProvider()),
        ChangeNotifierProvider(create: (context) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => NotificacionesProvider()),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
        ChangeNotifierProvider(create: (context) => local_auth.AuthProvider()),
        Provider<AuthService>(create: (context) => AuthService()),

        // Aquí agregamos el cliente Dio como un provider
        // De esta forma, cualquier widget puede acceder a él a través del contexto
        Provider<Dio>(create: (context) => HttpClient.getDio(context)),
      ],
      child: const MyApp(),
    ),
  );
  NotifHelper.initNotif();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const SplashScreen(),
      routes: {
        'MyHomePage': (context) => const MyHomePage(),
        'login': (context) => LoginScreen(),
      },
    );
  }
}
