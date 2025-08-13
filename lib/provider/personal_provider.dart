import 'dart:convert';

import 'package:babyaid/model/personal_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PersonalProvider with ChangeNotifier {
  // Estado para la calificación y el comentario
  int _calificacion = 0;
  String _comentario = '';
  List<String> _sugerenciasSeleccionadas = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para acceder al estado
  int get calificacion => _calificacion;
  String get comentario => _comentario;
  List<String> get sugerenciasSeleccionadas => _sugerenciasSeleccionadas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PersonalCalificado? _ultimoPersonalACalificar;
  PersonalCalificado? get ultimoPersonalACalificar => _ultimoPersonalACalificar;

  Map<String, dynamic>? _servicioPendiente;
  Map<String, dynamic>? get servicioPendiente => _servicioPendiente;

  // Nuevo método para manejar el estado de carga
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Nueva función para obtener el último servicio finalizado y el personal asociado
  Future<void> obtenerUltimoServicioFinalizado(int usuarioId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        // Utiliza la URL de tu endpoint
        Uri.parse(
          'https://helfer.flatzi.com/app/ultimo_servicio_finalizado.php?user_id=$usuarioId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          final reservaData = data['data']['reserva'];
          final personalData = data['data']['personal'];

          // Almacena solo la información necesaria
          _servicioPendiente = {
            'idReserva': reservaData['id'],
            'idPersonal': personalData['id'],
          };
        } else {
          _servicioPendiente = null;
        }
      } else {
        _servicioPendiente = null;
        _errorMessage = 'Error al obtener el servicio: ${response.body}';
      }
    } catch (e) {
      _servicioPendiente = null;
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Función para actualizar la calificación
  void setCalificacion(int calificacion) {
    _calificacion = calificacion;
    _sugerenciasSeleccionadas
        .clear(); // Limpiamos las sugerencias al cambiar la calificación
    notifyListeners();
  }

  // Función para agregar o quitar sugerencias
  void toggleSugerencia(String sugerencia) {
    if (_sugerenciasSeleccionadas.contains(sugerencia)) {
      _sugerenciasSeleccionadas.remove(sugerencia);
    } else {
      _sugerenciasSeleccionadas.add(sugerencia);
    }
    notifyListeners();
  }

  // Función para actualizar el comentario de texto
  void setComentario(String comentario) {
    _comentario = comentario;
    notifyListeners();
  }

  // Función para limpiar el estado después de enviar la calificación
  void resetState() {
    _calificacion = 0;
    _comentario = '';
    _sugerenciasSeleccionadas.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Lógica para enviar la calificación Para Inicio de Pantalla
  Future<Map<String, dynamic>> enviarCalificacion() async {
    if (_servicioPendiente == null) {
      return {
        'status': 'error',
        'message': 'No hay un servicio pendiente para calificar.',
      };
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final int idReserva = _servicioPendiente!['idReserva'];
    final int idPersonal = _servicioPendiente!['idPersonal'];
    final int calificacion = _calificacion;
    final String comentario = _comentario;
    final List<String> sugerencias = _sugerenciasSeleccionadas;

    try {
      // Aquí deberías colocar la URL de tu API
      final response = await http.post(
        Uri.parse('https://helfer.flatzi.com/app/get_calificacion.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_reserva': idReserva,
          'id_personal': idPersonal,
          'calificacion': calificacion,
          'comentario': comentario,
          'sugerencias': sugerencias,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isLoading = false;
        notifyListeners();
        return {
          'status': 'success',
          'message': data['message'] ?? 'Calificación enviada con éxito.',
        };
      } else {
        _isLoading = false;
        _errorMessage = 'Error: ${response.body}';
        notifyListeners();
        return {'status': 'error', 'message': _errorMessage};
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ocurrió un error inesperado: $e';
      notifyListeners();
      return {'status': 'error', 'message': _errorMessage};
    }
  }

  void recargarServicios() {
    // Aquí puedes llamar a tu función que obtiene la lista de servicios
    // obtenerServiciosPendientes(); // O la función que uses para cargar los servicios
    // Si no tienes una, simplemente llama a notifyListeners() para que los widgets se redibujen
    notifyListeners();
  }
}
