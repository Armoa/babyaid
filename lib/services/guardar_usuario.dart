import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> guardarUsuarioEnMySQL() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String apiUrl =
        "https://helfer.flatzi.com/app/register_user.php"; // Cambia por la URL de tu servidor
    Map<String, String> userData = {
      "name": user.displayName ?? "",
      "last_name": "Apellido ejemplo", // Puedes pedir al usuario que lo ingrese
      "email": user.email ?? "",
      "photo": user.photoURL ?? "",
      "address": "Dirección de ejemplo", // Puedes pedirlo al usuario
      "date_birth": "1990-01-01", // Puedes cambiarlo según el usuario
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(userData),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      print("Respuesta del servidor: ${response.body}");

      var jsonResponse = jsonDecode(response.body);
      print("Respuesta del servidor: ${jsonResponse['message']}");
    } else {
      print("Error al enviar datos: ${response.statusCode}");
    }
  }
}
