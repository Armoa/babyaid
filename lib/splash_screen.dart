import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth;
import 'package:helfer/provider/cupon_provider.dart';
import 'package:helfer/screens/home.dart';
import 'package:helfer/screens/login.dart';
import 'package:helfer/services/version.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late Connectivity _connectivity;
  bool _isChecking = true; // Estado para controlar el chequeo de conectividad

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _checkConnectivityAndSession();
      } else {
        checkForUpdate(context);
      }
    });
    Future.microtask(() {
      Provider.of<CuponProvider>(
        context,
        listen: false,
      ).cargarCuponesPorProducto();
    });
  }

  //Verificador de version
  Future<void> checkForUpdate(BuildContext context) async {
    String currentVersion = await getAppVersion();

    if (await isUpdateRequired(currentVersion)) {
      final latestData = await getLatestVersion();
      // Verifica si el contexto todavía es válido antes de mostrar el diálogo.
      if (context.mounted) {
        showUpdateDialog(context, latestData["update_url"]);
        return; // Evita continuar con la ejecución
      } else {
        // print("Contexto no válido, no se muestra el diálogo de actualización");
        return;
      }
    }
    // Solo verificamos la conectividad si NO es necesaria una actualización
    _checkConnectivityAndSession();
  }

  //Verificador de version
  void showUpdateDialog(BuildContext context, String updateUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Align(
            alignment: Alignment.center,
            child: Text(
              "¡Actualización requerida!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text("Por favor, actualiza la aplicación para continuar."),
          actions: [
            TextButton(
              onPressed: () async {
                Uri uri = Uri.parse(updateUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw Exception(
                    "No se pudo abrir el enlace de actualización.",
                  );
                }
              },
              child: Text("Actualizar ahora"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkConnectivityAndSession() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    // Aseguramos que connectivityResult se maneje correctamente
    if (connectivityResult.toString().contains('ConnectivityResult.none')) {
      // Manejo de no conexión a Internet
      setState(() {
        _isChecking = false; // Detenemos el indicador de progreso
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay conexión a internet'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    } else {
      // Procede a verificar la sesión si hay conexión
      final authProvider = Provider.of<local_auth.AuthProvider>(
        context,
        listen: false,
      );

      await authProvider.loadUser();
      await authProvider.loadUser();

      if (authProvider.user == null) {
        print("Usuario aún no cargado");
      } else {
        print("Usuario cargado correctamente");
      }

      final isFirebaseUser = FirebaseAuth.instance.currentUser != null;
      final isLocalUser = authProvider.user != null;

      print("Usuario cargado: ${authProvider.user}");
      print("Token: ${authProvider.user?.token}");
      print("isLocalUser: $isLocalUser");

      if (isFirebaseUser || isLocalUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            _isChecking
                ? const CircularProgressIndicator()
                : GestureDetector(
                  onTap: () {
                    _checkConnectivityAndSession();
                  },
                  child: const Icon(
                    Icons.wifi_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
      ),
    );
  }
}
