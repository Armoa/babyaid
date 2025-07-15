import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/services/obtener_usuario.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  UsuarioModel? usuario;
  int? userId;
  int? tokenData;
  String? _email;
  String? get email => _email;
  bool? isLogged;
  bool get isAuthenticated => _user != null;

  UsuarioModel? _user;
  UsuarioModel? get user => _user;

  void setUserEmail(String email) {
    _email = email;
    notifyListeners();
  }

  AuthProvider() {
    _initUsuario();
  }

  Future<void> _initUsuario() async {
    usuario = await obtenerUsuarioDesdeMySQL();
    if (usuario != null) {
      userId = usuario?.id;
      _email = usuario?.email;
      notifyListeners();
    }
  }

  // ✅ Notificar cambios para actualizar la UI

  void setUserAuthenticated(UsuarioModel user) {
    _user = user;
    userId = user.id;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final url = Uri.parse("https://helfer.flatzi.com/login.php");

    try {
      print('LOGIN: $email | $password');

      final response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          final usuarioJson = data['user'];
          _user = UsuarioModel.fromJson(usuarioJson);
          userId = _user!.id;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', json.encode(usuarioJson));
          await prefs.setBool('isLogged', true);

          notifyListeners();
          return data;
        } else {
          return {
            "status": "error",
            "message": data['message'] ?? "Usuario o contraseña incorrectos",
          };
        }
      } else {
        return {
          "status": "error",
          "message":
              "Servidor no respondió correctamente (${response.statusCode})",
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Error al conectar con el servidor",
      };
    }
  }

  Future<Map<String, dynamic>?> registerUser(
    String username,
    String email,
    String password,
  ) async {
    final url = Uri.parse("https://farma.staweno.com/register.php");

    try {
      final response = await http.post(
        url,
        body: {'name': username, 'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData; // 🔥 Retorna un mapa en lugar de un String
      } else {
        return {"status": "error", "message": "Error de conexión"};
      }
    } catch (e) {
      return {
        "status": "error",
        "message": "Error al conectar con el servidor",
      };
    }
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final tokenData = prefs.getString('token');
    final isLogged = prefs.getBool('isLogged') ?? false;

    print("Datos recuperados de SharedPreferences:");
    print("SharedPreferences: $userData");
    print("Token: $tokenData");

    if (userData != null && isLogged) {
      final userJson = json.decode(userData);
      _user = UsuarioModel.fromJson(userJson);
      userId = _user!.id;
      notifyListeners();
    }
  }

  // CERRAR SESSION
  void clearUserData() {
    _user = null;
    userId = null;
    _email = null;
    notifyListeners();
  }

  late BuildContext _context; // ✅ Guardar referencia del contexto
  @override
  void dispose() {
    _logoutSafely();
    super.dispose();
  }

  void _logoutSafely() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(_context, listen: false).logout();
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    await prefs.remove('isLogged');

    _user = null;
    notifyListeners();
  }
}
