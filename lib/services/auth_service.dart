import 'dart:convert';

import 'package:bebito/model/usuario_model.dart';
import 'package:bebito/provider/auth_provider.dart' as local_auth;
import 'package:bebito/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final _storage = const FlutterSecureStorage();

  // 🔥 FUNCION PRINCIPAL DE LOGIN CON GOOGLE
  Future<UsuarioModel?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final UserCredential userCredential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        ),
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        String apiUrl = "https://helfer.flatzi.com/app/google_login.php";
        var response = await http.post(
          Uri.parse(apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": firebaseUser.email,
            "name": firebaseUser.displayName,
            "photo": firebaseUser.photoURL,
          }),
        );

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          String status = jsonResponse['status'];
          String jwtToken = jsonResponse['jwt'];

          // Crear el modelo de usuario con los datos del backend
          final UsuarioModel user = UsuarioModel(
            id: jsonResponse['user_id'],
            name: jsonResponse['name'] ?? '',
            email: firebaseUser.email ?? '',
            photo: firebaseUser.photoURL ?? '',
            token: jwtToken,
            lastName: '',
            address: '',
            phone: '',
            city: '',
            barrio: '',
            razonsocial: '',
            ruc: '',
            dateBirth: '',
            dateCreated: '',
            tipoCi: '',
            ci: '',
          );

          // Guardar el token y los datos de usuario de forma segura
          await _storage.write(key: 'jwt_token', value: jwtToken);
          await _storage.write(
            key: 'user_data',
            value: jsonEncode(user.toJson()),
          );
          await _storage.write(key: 'user_status', value: status);

          // Actualizar el estado con el nuevo usuario
          // Esta línea es crucial para que la app sepa que hay un usuario autenticado
          Provider.of<local_auth.AuthProvider>(
            context,
            listen: false,
          ).setUserAuthenticated(user);

          // Retornar el usuario para que el widget que llamó a esta función lo reciba
          return user;
        } else {
          // En caso de un error en el servidor, mostrar el mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error del servidor: ${response.statusCode}"),
              duration: Duration(seconds: 2),
            ),
          );
          return null;
        }
      }
    } catch (e) {
      print("Error en login con Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al iniciar sesión. Inténtalo de nuevo."),
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }
    return null;
  }

  // Future<UsuarioModel?> signInWithGoogle(BuildContext context) async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null;

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final UserCredential userCredential = await _auth.signInWithCredential(
  //       credential,
  //     );
  //     final User? firebaseUser = userCredential.user;

  //     if (firebaseUser != null) {
  //       // 1. Envía el email del usuario a tu nuevo endpoint
  //       String apiUrl = "https://helfer.flatzi.com/app/google_login.php";
  //       var response = await http.post(
  //         Uri.parse(apiUrl),
  //         headers: {"Content-Type": "application/json"},
  //         body: jsonEncode({
  //           "email": firebaseUser.email,
  //           "name": firebaseUser.displayName, // <-- Añade esta línea
  //           "photo": firebaseUser.photoURL, // <-- Añade esta línea
  //         }),
  //       );

  //       print(
  //         'Respuesta de Google Login: ${response.statusCode}, ${response.body}',
  //       );

  //       if (response.statusCode == 200) {
  //         var jsonResponse = jsonDecode(response.body);
  //         if (jsonResponse['status'] == 'success') {
  //           String jwtToken = jsonResponse['jwt'];

  //           // 2. Guarda el JWT en el Secure Storage
  //           await _storage.write(key: 'jwt_token', value: jwtToken);

  //           // 3. Crear el modelo de usuario con los datos de Firebase y el ID del backend
  //           final UsuarioModel user = UsuarioModel(
  //             id: jsonResponse['user_id'],
  //             name: firebaseUser.displayName ?? '',
  //             lastName: '',
  //             address: '',
  //             phone: '',
  //             city: '',
  //             barrio: '',
  //             razonsocial: '',
  //             ruc: '',
  //             dateBirth: '',
  //             dateCreated: '',
  //             email: firebaseUser.email ?? '',
  //             photo: firebaseUser.photoURL ?? '',
  //             token: jwtToken, // Usar el JWT de tu backend
  //             tipoCi: '',
  //             ci: '',
  //           );

  //           // 4. Actualizar el estado con el nuevo usuario y el JWT
  //           Provider.of<local_auth.AuthProvider>(
  //             context,
  //             listen: false,
  //           ).setUserAuthenticated(user);
  //           await _storage.write(
  //             key: 'user_data',
  //             value: jsonEncode(user.toJson()),
  //           );

  //           return user;
  //         } else {
  //           // El usuario de Google no existe en tu base de datos
  //           // Podrías mostrar un mensaje o, mejor aún, redirigir al registro
  //           print(
  //             "Error: Usuario de Google no encontrado en la base de datos.",
  //           );
  //           return null;
  //         }
  //       } else {
  //         print("Error en el endpoint de Google Login: ${response.statusCode}");
  //         return null;
  //       }
  //     }
  //   } catch (e) {
  //     print("Error en login con Google: $e");
  //     return null;
  //   }
  //   return null;
  // }

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
        tipoCi: userJson['tipoCi'] ?? '',
        ci: userJson['ci'] ?? '',
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
