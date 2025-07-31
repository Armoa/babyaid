import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<UsuarioModel?> obtenerUsuarioDesdeMySQL() async {
  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('user');
  final token = prefs.getString('token');

  debugPrint('1. userString desde SharedPreferences: $userString');
  debugPrint('1. Token obtenido de SharedPreferences: $token');

  // Si el token no existe o está vacío, no podemos autenticarnos.
  if (token == null || token.isEmpty) {
    debugPrint(
      '2. Token es null o vacío, retornando null. No se puede autenticar.',
    );
    return null;
  }
  String apiUrl = "https://helfer.flatzi.com/app/get_user.php";
  debugPrint('4. URL de la API a consultar: $apiUrl');

  try {
    var response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization':
            'Bearer $token', // Envía el token en el header 'Authorization'
        'Content-Type': 'application/json', // Buena práctica
      },
    );

    debugPrint(
      '5. Código de estado de la respuesta de la API: ${response.statusCode}',
    );
    debugPrint('6. Cuerpo de la respuesta de la API: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      debugPrint('7. JSON decodificado de la respuesta: $jsonResponse');

      // Tu PHP devuelve "status":"success" y los datos del usuario dentro de la clave "user".
      if (jsonResponse["status"] == "success" &&
          jsonResponse.containsKey("user")) {
        debugPrint(
          '8. Datos encontrados y "status" es "success", intentando parsear a UsuarioModel.',
        );
        // ¡Importante! Pasa el sub-map 'user' a fromJson, no el jsonResponse completo.
        return UsuarioModel.fromJson(jsonResponse["user"]);
      } else if (jsonResponse["status"] == "not_found") {
        debugPrint(
          '9. Estado "not_found" recibido de la API, retornando null.',
        );
      } else {
        debugPrint(
          '10. Respuesta inesperada de la API: ${jsonResponse["status"]}',
        );
      }
    } else if (response.statusCode == 401) {
      // 401 Unauthorized
      debugPrint(
        '11. Error 401: Token de autenticación inválido o expirado. Considera cerrar sesión.',
      );
    } else {
      debugPrint(
        '12. Error en la respuesta de la API, status code: ${response.statusCode}',
      );
    }
  } catch (e) {
    debugPrint('13. Error al realizar la petición HTTP: $e');
  }

  return null;
}

// Future<UsuarioModel?> obtenerUsuarioDesdeMySQL() async {
//   final prefs = await SharedPreferences.getInstance();
//   final userString = prefs.getString('user');

//   if (userString == null) return null;
//   final userJson = json.decode(userString);
//   final email = userJson['email'];
//   if (email == null || email.isEmpty) return null;

//   String apiUrl = "https://helfer.flatzi.com/app/get_user.php?email=$email";

//   var response = await http.get(Uri.parse(apiUrl));

//   if (response.statusCode == 200) {
//     var jsonResponse = jsonDecode(response.body);
//     if (jsonResponse["status"] != "not_found") {
//       return UsuarioModel.fromJson(jsonResponse);
//     }
//   }
//   return null;
// }
