import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> actualizarUsuarioEnMySQL(
  String name,
  String lastName,
  String email,
  String address,
  String city,
  String barrio,
  String phone,
  String razonsocial,
  String ruc,
  String dateBirth,
) async {
  final prefs = await SharedPreferences.getInstance();
  final userString = prefs.getString('user');

  if (userString == null) return false;

  final userJson = json.decode(userString);
  final email = userJson['email'];

  if (email == null || email.isEmpty) return false;

  String apiUrl = "https://helfer.flatzi.com/app/update_user.php";
  Map<String, String> userData = {
    "name": name,
    "last_name": lastName,
    "email": email?.isNotEmpty == true ? email! : "sin_email",
    "address": address,
    "city": city,
    "barrio": barrio,
    "phone": phone,
    "razonsocial": razonsocial,
    "ruc": ruc,
    "date_birth": dateBirth,
  };

  print("Datos enviados: ${jsonEncode(userData)}");

  var response = await http.post(
    Uri.parse(apiUrl),
    body: jsonEncode(userData),
    headers: {"Content-Type": "application/json"},
  );

  print("Código de respuesta: ${response.statusCode}");
  print("Respuesta API: ${response.body}");

  // Verificar si la respuesta está vacía
  if (response.body.isEmpty) {
    print("Error: La respuesta de la API está vacía.");
    return false;
  }

  var jsonResponse = jsonDecode(response.body);
  return jsonResponse["status"] == "success";
}
