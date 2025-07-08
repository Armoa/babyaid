import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool> eliminarUbicacion(int id) async {
  String apiUrl = "https://farma.staweno.com/delete_address.php?id=$id";
  var response = await http.delete(Uri.parse(apiUrl)); // Usamos DELETE

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);
    return jsonResponse["status"] ==
        "success"; // Retorna `true` si la eliminación fue exitosa
  }
  return false;
}
