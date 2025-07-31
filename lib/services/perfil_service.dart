import 'dart:convert';

import 'package:helfer/model/usuario_model.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PerfilService {
  // Crear una Nueva Ubicación adicionales
  Future<bool> crearUbicacion(UbicacionModel nuevaUbicacion) async {
    String apiUrl = "https://helfer.flatzi.com/app/add_address.php";
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(nuevaUbicacion.toJson()), // Convertir modelo a JSON
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse["status"] ==
          "success"; // Retorna `true` si se guardó correctamente
    }
    return false;
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
