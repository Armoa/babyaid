import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth;
import 'package:helfer/screens/login.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔥 FUNCION PRINCIPAL DE LOGIN CON GOOGLE
  Future<UsuarioModel?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuario canceló el login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final prefs = await SharedPreferences.getInstance();

        // 🔥 Obtener ID real desde MySQL
        String apiUrl =
            "https://helfer.flatzi.com/app/get_user_id.php?email=${firebaseUser.email}";
        var response = await http.get(Uri.parse(apiUrl));

        int userId = 0; // ID por defecto
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          userId = jsonResponse["user_id"];
        }

        // 🔥 Crear usuario con datos de Google
        final UsuarioModel user = UsuarioModel(
          id: userId,
          name: firebaseUser.displayName ?? '',
          lastName: '', // Provide appropriate value if available
          address: '', // Provide appropriate value if available
          phone: '', // Provide appropriate value if available
          city: '', // Provide appropriate value if available
          barrio: '', // Provide appropriate value if available
          razonsocial: '', // Provide appropriate value if available
          ruc: '', // Provide appropriate value if available
          dateBirth: '', // Provide appropriate value if available
          dateCreated: '', // Provide appropriate value if available
          email: firebaseUser.email ?? '',
          photo: firebaseUser.photoURL ?? '',
          token: googleAuth.idToken ?? '',
        );

        // 🔥 Guardar datos en `AuthProvider`
        Provider.of<local_auth.AuthProvider>(
          context,
          listen: false,
        ).setUserAuthenticated(user);

        // 🔥 Guardar datos en `SharedPreferences`
        await prefs.setString(
          'user',
          json.encode({
            "name": user.name,
            "email": user.email,
            "photo": user.photo,
            "token": user.token,
          }),
        );
        await prefs.setString('token', user.token);

        return user; // ✅ Retorna el usuario correctamente
      }
    } catch (e) {
      print("Error en login con Google: $e");
      return null;
    }
    return null;
  }

  // 🚀 OBTENER USUARIO ACTUAL DESDE `SharedPreferences`
  Future<UsuarioModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final tokenData = prefs.getString('token');

    if (userData != null && tokenData != null && tokenData.isNotEmpty) {
      final userJson = json.decode(userData);
      return UsuarioModel(
        id: userJson['id'] ?? 0,
        name: userJson['name'] ?? '',
        lastName: userJson['lastName'] ?? '',
        address: userJson['address'] ?? '',
        phone: userJson['phone'] ?? '',
        city: userJson['city'] ?? '',
        barrio: userJson['barrio'] ?? '',
        razonsocial: userJson['razonsocial'] ?? '',
        ruc: userJson['ruc'] ?? '',
        dateBirth: userJson['dateBirth'] ?? '',
        dateCreated: userJson['dateCreated'] ?? '',
        email: userJson['email'] ?? '',
        photo: userJson['photo'] ?? '',
        token: tokenData,
      );
    }
    return null;
  }

  // 🚪 CERRAR SESIÓN Y BORRAR DATOS
  void signOut(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');

    // 🔥 Limpiar datos en `AuthProvider`
    Provider.of<local_auth.AuthProvider>(
      context,
      listen: false,
    ).clearUserData();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
