import 'dart:convert';

import 'package:babyaid/model/usuario_model.dart';
import 'package:babyaid/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  // Solo una instancia de storage para toda la clase
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Variables de estado
  bool _isLogged = false; // Estado principal de login
  UsuarioModel? _user; // Objeto de usuario si está logueado
  int? _userId; // ID del usuario, obtenido del _user
  String? _email; // Email del usuario, obtenido del _user

  // Getters para acceder al estado desde fuera
  bool get isLogged => _isLogged;
  UsuarioModel? get user => _user;
  int? get userId => _userId;
  String? get email => _email;

  // Constructor: inicializa el estado del usuario al crear el proveedor
  AuthProvider() {
    _initUsuario();
  }

  // --- Métodos de Inicialización y Carga de Usuario ---

  // _initUsuario: Se llama una vez al inicio para establecer el estado de autenticación.
  Future<void> _initUsuario() async {
    print('⚡ Ejecutando verificación de perfil...');
    await loadUser();
  }

  // loadUser: Intenta cargar el usuario desde el token JWT almacenado.
  // Es la fuente de verdad para el estado de autenticación.
  Future<void> loadUser() async {
    final storedToken = await _storage.read(key: 'jwt_token');
    // print('DEBUG: Token almacenado en loadUser: ${storedToken ?? 'null'}');

    if (storedToken == null || storedToken.isEmpty) {
      // Si no hay token, el usuario no está logueado
      _isLogged = false;
      _user = null;
      _userId = null;
      _email = null;
      print('! No hay JWT o no está logueado.');
      notifyListeners();
      return;
    }

    // Si hay un token, intentar validar y obtener el perfil del usuario
    try {
      final userResponse = await makeAuthenticatedRequest(
        'https://helfer.flatzi.com/app/get_user.php',
      );

      // makeAuthenticatedRequest ya devuelve Map<String, dynamic>?
      // Verifica la respuesta directamente
      if (userResponse != null &&
          userResponse['status'] == 'success' &&
          userResponse['user'] != null) {
        _user = UsuarioModel.fromJson(userResponse['user']);
        _userId = _user!.id; // Asignar a la variable privada
        _email = _user!.email; // Asignar a la variable privada
        _isLogged =
            true; // Establecer a true si la carga del usuario fue exitosa
        print('DEBUG: Usuario cargado con éxito. ID: $_userId, Email: $_email');
      } else {
        // La API respondió pero no con éxito (ej. token inválido según get_user.php)
        print(
          "Error al cargar usuario con JWT: Token inválido o datos no encontrados. Forzando logout.",
        );
        await logout(); // Forzar logout para limpiar el token inválido
      }
    } catch (e) {
      // Error de red, parseo, o cualquier otra excepción durante la solicitud
      print("❌ Error de conexión/parseo al cargar usuario con JWT: $e");
      await logout(); // Forzar logout en caso de error
    } finally {
      notifyListeners(); // Notifica a los widgets que el estado ha cambiado
    }
  }

  // --- Métodos de Autenticación ---

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('https://helfer.flatzi.com/app/login.php');
    print('LOGIN: $email | $password');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': password},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'success') {
          final token = data['token'];
          final userJson = data['user'];

          if (token != null && token.isNotEmpty) {
            await _storage.write(
              key: 'jwt_token',
              value: token,
            ); // Usar _storage
            _user = UsuarioModel.fromJson(userJson);
            _userId = _user!.id; // Asignar a la variable privada
            _email = _user!.email; // Asignar a la variable privada
            _isLogged = true; // El login fue exitoso
            print('DEBUG: JWT Guardado en loginUser: $token');
            print('DEBUG: Usuario ID asignado en loginUser: $_userId');
            return {'ok': true, 'message': 'Login exitoso'};
          } else {
            _isLogged = false;
            _user = null;
            _userId = null;
            _email = null;
            return {
              'ok': false,
              'message': 'Token no recibido o vacío del servidor',
            };
          }
        } else {
          _isLogged = false;
          _user = null;
          _userId = null;
          _email = null;
          return {
            'ok': false,
            'message': data['message'] ?? 'Credenciales inválidas',
          };
        }
      } else {
        _isLogged = false;
        _user = null;
        _userId = null;
        _email = null;
        print(
          'DEBUG: Error HTTP en login: ${response.statusCode} - ${response.body}',
        );
        return {
          'ok': false,
          'message': 'Error de servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      _isLogged = false;
      _user = null;
      _userId = null;
      _email = null;
      print('DEBUG: Excepción durante el login: $e');
      return {'ok': false, 'message': 'Error de conexión: $e'};
    } finally {
      notifyListeners(); // Notifica los cambios de estado (siempre)
    }
  }

  // makeAuthenticatedRequest: Centraliza las llamadas a la API que requieren JWT.
  Future<Map<String, dynamic>?> makeAuthenticatedRequest(String url) async {
    final String? jwtToken = await _storage.read(
      key: 'jwt_token',
    ); // Usar _storage

    if (jwtToken == null || jwtToken.isEmpty) {
      print("No hay token JWT disponible para la solicitud autenticada.");
      await logout(); // Forzar logout si no hay token al intentar una solicitud autenticada
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $jwtToken'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print(
          "Solicitud no autorizada (401). Token expirado o inválido. Forzando logout.",
        );
        await logout(); // Forzar logout si el token es rechazado por el servidor
        return null;
      } else {
        print(
          "Error en la solicitud HTTP autenticada: ${response.statusCode}, Body: ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("Error de red/parseo al realizar solicitud autenticada: $e");
      return null;
    }
  }

  // --- Métodos de Gestión de Sesión ---

  // logout: Limpia todos los datos de sesión.
  Future<void> logout() async {
    // Limpia el JWT de FlutterSecureStorage
    await _storage.delete(key: 'jwt_token');

    // Limpia los datos de SharedPreferences si aún los usas
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      'isLogged',
    ); // Si 'isLogged' ya no es el flag principal, puedes eliminar esta línea

    // Restablece las variables de estado del proveedor
    _isLogged = false;
    _user = null;
    _userId = null;
    _email = null;

    print("Usuario ha cerrado sesión y JWT eliminado.");
    notifyListeners(); // Notifica a los widgets para que reaccionen al logout
  }

  void setUserAuthenticated(UsuarioModel user) {
    _user = user;
    _userId = user.id;
    notifyListeners();
  }

  // Método que se llama cuando el token expira
  Future<void> handleTokenExpired(BuildContext context) async {
    // 1. Limpia los datos de la sesión (token, etc.)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');

    // 2. Muestra un mensaje al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.',
        ),
        backgroundColor: Colors.red,
      ),
    );

    // 3. Navega de regreso a la pantalla de login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // CERRAR SESSION
  void clearUserData() {
    _user = null;
    _email = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
