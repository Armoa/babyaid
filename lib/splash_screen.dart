import 'package:bebito/services/version.dart';
import 'package:bebito/widget/wrapper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
      await _checkInitialConditions(); // Un nuevo método para organizar
    });

    // Mueve la carga de cupones a donde sea más apropiado si no es dependiente del Splash
    // Future.microtask(() {
    //   Provider.of<CuponProvider>(context, listen: false).cargarCuponesPorProducto();
    // });
  }

  Future<void> _checkInitialConditions() async {
    var connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetMessage();
    } else {
      // Si hay conexión, primero revisa la actualización, luego el resto
      await checkForUpdate(context);
      // Después de la actualización (o si no es necesaria),
      // navega al Wrapper para que él decida la autenticación.
      if (context.mounted) {
        // Redirige al Wrapper después de que el SplashScreen haya hecho sus chequeos.
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Wrapper())); // Usar pushReplacement
        // O simplemente puedes dejar que el Wrapper sea la primera ruta en main.dart y lo muestre directamente
        // después de que el splashscreen complete sus tareas y no haga pushReplacement, sino que el widget se "vaya".
        // Sin embargo, si quieres que el SplashScreen se "vapore", un pushReplacement a Wrapper es válido.
        // Para este caso, como el Wrapper será la raíz de la navegación de auth, podemos usarlo así:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Wrapper()),
        );
      }
    }
    setState(() {
      _isChecking = false; // Detenemos el indicador de progreso
    });
  }

  //Verificador de version
  Future<void> checkForUpdate(BuildContext context) async {
    String currentVersion =
        await getAppVersion(); // Asegúrate de que getAppVersion esté definido

    if (await isUpdateRequired(currentVersion)) {
      // Asegúrate de que isUpdateRequired esté definido
      final latestData =
          await getLatestVersion(); // Asegúrate de que getLatestVersion esté definido
      if (context.mounted) {
        showUpdateDialog(context, latestData["update_url"]);
        return; // Evita continuar con la ejecución si hay actualización requerida
      } else {
        return;
      }
    }
  }

  //Verificador de version
  void showUpdateDialog(BuildContext context, String updateUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Align(
            // Hice el Text const
            alignment: Alignment.center,
            child: Text(
              "¡Actualización requerida!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          content: const Text(
            "Por favor, actualiza la aplicación para continuar.",
          ), // Hice el Text const
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
              child: const Text("Actualizar ahora"), // Hice el Text const
            ),
          ],
        );
      },
    );
  }

  void _showNoInternetMessage() {
    // Manejo de no conexión a Internet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay conexión a internet'),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  // --- Método _checkConnectivityAndSession ORIGINAL (AHORA SIMPLIFICADO) ---
  // Este método ya no necesita manejar la navegación de autenticación.
  // Solo se asegura de que haya conexión y luego redirige al Wrapper.
  // La lógica de autenticación se moverá al Wrapper.
  Future<void> _checkConnectivityAndSession() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showNoInternetMessage();
    } else {
      // Ya no llamamos a loadUser ni hacemos la navegación aquí.
      // Simplemente navegamos al Wrapper si todo lo demás está bien.
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Wrapper()),
        );
      }
    }
    setState(() {
      _isChecking = false;
    });
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
                    _checkConnectivityAndSession(); // Reintenta conectividad
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
