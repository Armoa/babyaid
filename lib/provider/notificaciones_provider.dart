import 'dart:convert';

import 'package:bebito/model/notification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificacionesProvider with ChangeNotifier {
  List<Notificacion> _notificaciones = [];
  bool _cargando = false; // Estado de carga

  List<Notificacion> get notificaciones => _notificaciones;
  bool get cargando => _cargando; // Getter para estado de carga

  // **Aquí agregas la función para contar las no leídas**
  int get totalNoLeidas => _notificaciones.where((n) => !n.fueLeida).length;

  Future<void> obtenerNotificaciones(int usuarioId) async {
    _cargando = true;
    notifyListeners();

    final url = Uri.parse(
      'https://helfer.flatzi.com/app/get_notification.php?usuario_id=$usuarioId',
    );
    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      print(
        "📡 Respuesta de la API: ${respuesta.body}",
      ); // 🔍 Ver JSON de la API
      final List<dynamic> datos = json.decode(respuesta.body);
      List<Notificacion> nuevasNotificaciones =
          datos.map((json) => Notificacion.fromJson(json)).toList();

      // ⚠️ SOLUCIÓN: En lugar de limpiar, verificamos si ya existe para evitar duplicados
      for (var nuevaNotificacion in nuevasNotificaciones) {
        bool yaExiste = _notificaciones.any(
          (n) => n.id == nuevaNotificacion.id,
        );
        if (!yaExiste) {
          _notificaciones.add(nuevaNotificacion);
        }
      }
    }

    _cargando = false;
    notifyListeners();
  }

  void marcarComoLeida(int id) async {
    final url = Uri.parse('https://helfer.flatzi.com/app/marcar_leida.php');
    await http.post(url, body: {'id': id.toString()});

    _notificaciones =
        _notificaciones.map((notificacion) {
          if (notificacion.id == id) {
            return Notificacion(
              id: notificacion.id,
              nombre: notificacion.nombre,
              mensaje: notificacion.mensaje,
              fecha: notificacion.fecha,
              urgente: notificacion.urgente,
              fueLeida: true, // Se actualiza localmente
            );
          }
          return notificacion;
        }).toList();
    notifyListeners(); // Refrescar UI
  }

  // agregar notificaciones
  void agregarNotificacion(Notificacion notificacion) {
    bool yaExiste = _notificaciones.any((n) => n.id == notificacion.id);
    if (!yaExiste) {
      _notificaciones.add(notificacion);
      notifyListeners();
    }
  }
}
