import 'package:babyaid/provider/auth_provider.dart' as local_auth_provider;
import 'package:babyaid/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

Future<void> logoutUser(BuildContext context) async {
  try {
    // 🔹 Cerrar sesión en Firebase
    await FirebaseAuth.instance.signOut();

    // 🔹 Cerrar sesión en Google
    await GoogleSignIn().signOut();

    // 🔹 Obtener la instancia del AuthProvider para manejar el estado
    final authProvider = Provider.of<local_auth_provider.AuthProvider>(
      context,
      listen: false,
    );

    // Limpiar los datos de autenticación del AuthProvider
    authProvider.logout();

    // Mostrar un mensaje de confirmación al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("¡Has cerrado sesión exitosamente!")),
    );

    // 🔹 Opcional: Redireccionar al usuario a la pantalla inicial o de login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, // Elimina la pila de navegación
    );

    print("Usuario cerró sesión correctamente");
  } catch (e) {
    print("Error al cerrar sesión: $e");
  }
}
