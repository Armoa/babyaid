import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helfer/provider/auth_provider.dart';
import 'package:helfer/provider/cart_provider.dart';
import 'package:helfer/provider/cupon_provider.dart';
import 'package:helfer/provider/notificaciones_provider.dart';
import 'package:helfer/provider/payment_provider.dart';
import 'package:helfer/provider/theme.dart';
import 'package:helfer/provider/wishlist_provider.dart';
import 'package:helfer/screens/home.dart';
import 'package:helfer/services/firebase_messaging_service.dart';
import 'package:helfer/services/notificaction.dart';
import 'package:helfer/splash_screen.dart';
import 'package:helfer/widget/theme_mode.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_PY', null);
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('bannerShown');
  // Inicializar el servicio de notificaciones
  FirebaseMessagingService messagingService = FirebaseMessagingService();
  await messagingService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => NotificacionesProvider()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(create: (context) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => CuponProvider()),
      ],
      child: MyApp(),
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
      initialRoute: 'SplashScreenState',
      routes: {
        'MyHomePage': (context) => const MyHomePage(),
        'SplashScreenState': (context) => SplashScreen(),
      },
    );
  }
}
