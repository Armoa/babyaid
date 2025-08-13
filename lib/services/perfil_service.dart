import 'dart:convert';

import 'package:babyaid/model/usuario_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PerfilService {
  final _storage =
      const FlutterSecureStorage(); // Instancia de FlutterSecureStorage

  Future<bool> actualizarUsuarioEnMySQL({
    required int
    userId, // <--- ¡AÑADIDO DE NUEVO! Necesitamos el ID del usuario del AuthProvider
    required String name,
    required String lastName,
    required String
    email, // El email aún se envía, pero el PHP actualiza por ID
    required String address,
    required String city,
    required String barrio,
    required String phone,
    required String razonSocial,
    required String ruc,
    required String dateBirth,
    required String ci,
    required String tipoDocumento,
  }) async {
    // 1. Obtener el token JWT de FlutterSecureStorage
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      print(
        'DEBUG PerfilService: Token JWT no encontrado. No se puede actualizar.',
      );
      return false;
    }

    // 2. Definir la URL de tu API para actualizar el perfil
    final url = Uri.parse('https://helfer.flatzi.com/app/update_user.php');

    try {
      // 3. Preparar los datos que se enviarán en el cuerpo de la solicitud
      // Asegúrate de que los nombres de las claves aquí coincidan con lo que tu PHP espera.
      final Map<String, dynamic> requestBody = {
        // ¡El user_id NO se envía aquí! El PHP lo obtiene del JWT.
        // Solo envías los datos que el PHP espera en el BODY para actualizar.
        'name': name,
        'last_name': lastName,
        'email': email, // Se envía, pero no es la clave de WHERE en PHP
        'address': address,
        'city': city,
        'barrio': barrio,
        'phone': phone,
        'razonsocial': razonSocial,
        'ruc': ruc,
        'date_birth': dateBirth,
        'ci': ci,
        'tipo_ci': tipoDocumento, // Coincide con $data["tipo_ci"] en PHP
      };

      // 4. Realizar la solicitud HTTP POST
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // <--- ¡AHORA SE ENVÍA EL TOKEN!
        },
        body: jsonEncode(requestBody),
      );

      print(
        'DEBUG PerfilService - Código de respuesta de actualización: ${response.statusCode}',
      );
      print(
        'DEBUG PerfilService - Cuerpo de respuesta de actualización: ${response.body}',
      );

      // 5. Procesar la respuesta del servidor
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else if (response.statusCode == 401) {
        print(
          'DEBUG PerfilService - Error 401: Token inválido o no autorizado. El usuario debe re-autenticarse.',
        );
        // Aquí puedes añadir lógica para cerrar sesión si el token es inválido
        return false;
      } else {
        print(
          'DEBUG PerfilService - Error al actualizar perfil. Estado: ${response.statusCode}, Mensaje: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print(
        'DEBUG PerfilService - Excepción durante la actualización del perfil: $e',
      );
      return false;
    }
  }

  // Crear una Nueva Ubicación adicionales
  final storage = const FlutterSecureStorage();
  Future<bool> crearUbicacion(UbicacionModel nuevaUbicacion) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      print("DEBUG: Token JWT no encontrado. No se puede crear la ubicación.");
      return false;
    }

    String apiUrl = "https://helfer.flatzi.com/app/add_address.php";

    // Aquí es importante no enviar el user_id, ya que el backend lo obtendrá del JWT
    // Por lo tanto, crea una copia del mapa JSON sin el 'user_id'
    Map<String, dynamic> ubicacionData = nuevaUbicacion.toJson();
    ubicacionData.remove('user_id');

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Enviar el token en la cabecera
      },
      body: jsonEncode(ubicacionData),
    );

    print("DEBUG PerfilService: Código de respuesta: ${response.statusCode}");
    print("DEBUG PerfilService: Cuerpo de respuesta: ${response.body}");

    if (response.statusCode == 200) {
      try {
        var jsonResponse = jsonDecode(response.body);
        return jsonResponse["status"] == "success";
      } catch (e) {
        print("DEBUG PerfilService: Error al decodificar JSON: $e");
        return false;
      }
    } else {
      print(
        "DEBUG PerfilService: Error al crear ubicación. Estado: ${response.statusCode}",
      );
      return false;
    }
  }

  // // Actualizar foto de perfil
  Future<bool> cargarImagenPerfil(String email, XFile imagen) async {
    String apiUrl = "https://helfer.flatzi.com/app/update_profile_picture.php";

    var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
    request.fields["email"] = email;
    request.files.add(await http.MultipartFile.fromPath("imagen", imagen.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print("Código de respuesta: ${response.statusCode}");
    print("Respuesta API: $responseBody");

    var jsonResponse = jsonDecode(responseBody);
    return jsonResponse["status"] == "success";
  }
}
