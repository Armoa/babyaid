import 'dart:convert';

import 'package:babyaid/model/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UbicacionService {
  final storage = const FlutterSecureStorage();

  // El método ahora recibe BuildContext
  Future<List<UbicacionModel>> obtenerUbicaciones(BuildContext context) async {
    print("DEBUG UbicacionService: Iniciando carga de ubicaciones... 🚀");

    // Obtener el token JWT
    final token = await storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      print(
        "DEBUG UbicacionService: Token JWT no encontrado. No se pueden obtener ubicaciones.",
      );
      // Opcional: Podrías forzar un logout o redirigir al login aquí si es un error crítico.
      return [];
    }

    // URL de tu API para obtener direcciones. Ya no necesita el ID en la URL.
    String apiUrl = "https://helfer.flatzi.com/app/get_address.php";
    print("DEBUG UbicacionService: Llamando a la API: $apiUrl");

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Enviar el token en la cabecera
          'Content-Type': 'application/json',
        },
      );

      print(
        "DEBUG UbicacionService: Código de respuesta: ${response.statusCode}",
      );
      print("DEBUG UbicacionService: Cuerpo de respuesta: ${response.body}");

      if (response.statusCode == 200) {
        // Si la respuesta es vacía (ej. "[ ]"), jsonDecode la manejará correctamente como una lista vacía.
        if (response.body.isEmpty) {
          print(
            "DEBUG UbicacionService: Respuesta vacía, devolviendo lista vacía.",
          );
          return [];
        }

        final dynamic jsonResponse = jsonDecode(response.body);

        if (jsonResponse is List) {
          List<UbicacionModel> ubicaciones =
              jsonResponse
                  .map(
                    (json) =>
                        UbicacionModel.fromJson(json as Map<String, dynamic>),
                  )
                  .toList();
          print(
            "DEBUG UbicacionService: Ubicaciones cargadas: ${ubicaciones.length}",
          );
          return ubicaciones;
        } else {
          print(
            "DEBUG UbicacionService: Formato de respuesta inesperado: No es una lista.",
          );
          // Puedes loggear el body para depurar: print(response.body);
          return [];
        }
      } else if (response.statusCode == 401) {
        print(
          "DEBUG UbicacionService: Error 401 Unauthorized. Token inválido o expirado. El usuario debe re-autenticarse.",
        );
        // Considera llamar al método de logout del AuthProvider aquí
        // Provider.of<AuthProvider>(context, listen: false).logout();
        return [];
      } else {
        print(
          "DEBUG UbicacionService: Error al cargar ubicaciones. Estado: ${response.statusCode}, Mensaje: ${response.body}",
        );
        return [];
      }
    } catch (e) {
      print(
        "DEBUG UbicacionService: Excepción durante la carga de ubicaciones: $e",
      );
      return [];
    }
  }
}

// Elimina o comenta esta función si ya no la necesitas.
// Future<UsuarioModel?> obtenerUsuarioDesdeMySQL() async {
//   // Esta función ya no debería ser necesaria o debería ser refactorizada
//   // para usar el AuthProvider o ser parte de un servicio de perfil.
//   // Se recomienda obtener el usuario del AuthProvider directamente.
//   return null;
// }

// Future<List<UbicacionModel>> obtenerUbicaciones() async {
//   print("Iniciando carga de ubicaciones... 🚀");

//   UsuarioModel? usuario = await obtenerUsuarioDesdeMySQL();
//   int? userId = usuario?.id;
//   if (userId == null) return [];

//   String apiUrl = "https://helfer.flatzi.com/app/get_address.php?id=$userId";
//   var response = await http.get(Uri.parse(apiUrl));

//   if (response.statusCode == 200) {
//     var jsonResponse = jsonDecode(response.body);

//     print("Respuesta JSON: $jsonResponse");

//     if (jsonResponse is List) {
//       List<UbicacionModel> ubicaciones =
//           jsonResponse.map((json) {
//             return UbicacionModel.fromJson(json);
//           }).toList();

//       print("Ubicaciones cargadas: ${ubicaciones.map((u) => u.id).toList()}");
//       return ubicaciones;
//     }
//   }

//   return [];
// }
