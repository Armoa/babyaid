import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth_provider;
import 'package:helfer/provider/notificaciones_provider.dart';
import 'package:helfer/provider/theme.dart';
import 'package:helfer/screens/home.dart';
import 'package:helfer/screens/login.dart';
import 'package:helfer/screens/my_acount.dart';
import 'package:helfer/screens/my_cupon.dart';
import 'package:helfer/screens/notification_screen.dart';
import 'package:helfer/screens/wishlist_screen.dart';
import 'package:helfer/services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewDrawer extends StatefulWidget {
  const NewDrawer({super.key});

  @override
  State<NewDrawer> createState() => _NewDrawerState();
}

class _NewDrawerState extends State<NewDrawer> {
  String appVersion = "Cargando...";

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    // verificarPerfilUsuario(context);
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final authProvider = Provider.of<local_auth_provider.AuthProvider>(
      context,
      listen: false,
    );
    final email = authProvider.user?.email ?? 'info@pharma.com';
    final nombre = authProvider.user?.name ?? 'Usuario';

    final photoUrl =
        (authProvider.user?.photo != null &&
                authProvider.user!.photo.isNotEmpty)
            ? authProvider.user!.photo
            : 'https://cdn-icons-png.flaticon.com/512/64/64572.png';

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.blueBlak
                            : AppColors.blueLight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            // ignore: unnecessary_null_comparison
                            photoUrl != null
                                ? NetworkImage(photoUrl)
                                : AssetImage("assets/google_logo.png")
                                    as ImageProvider,
                      ),
                      SizedBox(height: 5),
                      Text(
                        nombre,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.blueLight
                                  : AppColors.blueBlak,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.blueLight
                                  : AppColors.blueBlak,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home_outlined),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                ),

                Visibility(
                  visible:
                      (FirebaseAuth.instance.currentUser != null ||
                          authProvider.isAuthenticated),
                  child: ListTile(
                    leading: Icon(Icons.account_circle_outlined),
                    title: Text('Mi Cuenta'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyAcount()),
                      );
                    },
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.card_giftcard_rounded),
                  title: const Text('Mis Cupones'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CuponesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notificaciones'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                  trailing: Consumer<NotificacionesProvider>(
                    builder: (context, provider, child) {
                      return Visibility(
                        visible: provider.totalNoLeidas > 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent, // Color de fondo
                            shape: BoxShape.circle, // Forma circular
                          ),
                          child: Text(
                            '${provider.totalNoLeidas}',
                            style: TextStyle(
                              color: Colors.white,
                            ), // Estilos del texto
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.favorite_border),
                  title: Text('Mi Favoritos'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WishlistScreen()),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Provider.of<ThemeProvider>(context).themeMode ==
                            ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode_outlined,
                  ),
                  title: Text(
                    Provider.of<ThemeProvider>(context).themeMode ==
                            ThemeMode.dark
                        ? "Modo día"
                        : "Modo noche",
                  ),
                  trailing: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) => themeProvider.toggleTheme(),
                    ),
                  ),
                ),
                // INICIAR y CERRAR SESSION
                ListTile(
                  leading: Icon(
                    (FirebaseAuth.instance.currentUser != null ||
                            Provider.of<local_auth_provider.AuthProvider>(
                              context,
                            ).isAuthenticated)
                        ? Icons.logout
                        : Icons.login,
                  ),
                  title: Text(
                    (FirebaseAuth.instance.currentUser != null ||
                            Provider.of<local_auth_provider.AuthProvider>(
                              context,
                            ).isAuthenticated)
                        ? "Cerrar sesión"
                        : "Iniciar sesión",
                  ),
                  onTap: () async {
                    final authService = AuthService();
                    final prefs = await SharedPreferences.getInstance();
                    final authProvider =
                        Provider.of<local_auth_provider.AuthProvider>(
                          // ignore: use_build_context_synchronously
                          context,
                          listen: false,
                        );

                    if (FirebaseAuth.instance.currentUser != null ||
                        authProvider.isAuthenticated) {
                      // Cierra sesión en Firebase y Google si aplica
                      if (FirebaseAuth.instance.currentUser != null) {
                        // ignore: use_build_context_synchronously
                        authService.signOut(context);
                      }

                      // Elimina datos guardados en SharedPreferences (usuarios con email/contraseña)
                      await prefs.remove('user');
                      await prefs.remove('token');

                      // Limpiar datos de usuario en AuthProvider
                      authProvider.clearUserData();

                      // Navegar a LoginScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                ),

                ListTile(
                  title: Text("Cerrar Applicacion"),
                  leading: Icon(Icons.close),
                  onTap: () => exit(0),
                ),
              ],
            ),
          ),
          // Version del la App
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                "Versión $appVersion",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
