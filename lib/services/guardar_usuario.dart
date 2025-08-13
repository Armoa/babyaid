import 'dart:convert';

import 'package:babyaid/screens/home.dart';
import 'package:babyaid/screens/perfil_update.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Funcion que guarda en la DB los datos Del Usuario de Google
Future<void> guardarUsuarioEnMySQL(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String apiUrl = "https://helfer.flatzi.com/app/register_user.php";
    Map<String, String> userData = {
      "name": user.displayName ?? "",
      "last_name": "",
      "email": user.email ?? "",
      "photo": user.photoURL ?? "",
      "address": "",
      "date_birth": "1990-01-01",
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(userData),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      String status = jsonResponse['status'];
      String message = jsonResponse['message'];
      print("Mensaje del servidor: $message");

      if (status == "exists") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MyHomePage()),
        );
      } else if (status == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PerfilUpdate()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $message")));
      }
    } else {
      print("Error HTTP: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectarse con el servidor")),
      );
    }
  }
}
