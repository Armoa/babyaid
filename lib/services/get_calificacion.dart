import 'dart:convert';

import 'package:http/http.dart' as http;

// ENVIAR CALIFICACION DEL PERSONAL Primero
Future<Map<String, dynamic>> enviarCalificacion({
  required int idReserva,
  required int idPersonal,
  required int calificacion,
  required String comentario,
  List<String>? sugerenciasSeleccionadas,
}) async {
  final url = Uri.parse(
    "https://helfer.flatzi.com/app/get_calificacion_original.php",
  );

  // Prepara el cuerpo del request
  Map<String, String> bodyData = {
    'id_reserva': idReserva.toString(),
    'id_personal': idPersonal.toString(),
    'calificacion': calificacion.toString(),
    'comentario': comentario,
  };

  // Convertir la lista de sugerencias a un string JSON si no es nula o vacía
  if (sugerenciasSeleccionadas != null && sugerenciasSeleccionadas.isNotEmpty) {
    bodyData['sugerencias'] = json.encode(
      sugerenciasSeleccionadas,
    ); // <-- ¡Cambio clave aquí!
  } else {
    bodyData['sugerencias'] =
        '[]'; // O enviar un string vacío, o no enviar la clave
  }

  try {
    final response = await http.post(
      url,
      body: bodyData, // Usa el Map que hemos preparado
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      // Intenta decodificar el mensaje de error del servidor si está disponible
      String errorMessage = "Servidor no respondió correctamente";
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'];
        }
      } catch (_) {
        // Ignora si no se puede decodificar el cuerpo como JSON
      }
      return {
        "status": "error",
        "message": "$errorMessage (Código: ${response.statusCode})",
      };
    }
  } catch (e) {
    return {"status": "error", "message": "Error de conexión: $e"};
  }
}

// OBTENER PROMEDIO DE CALIFICACION
Future<double?> obtenerPromedioCalificacion(int idPersonal) async {
  final url = Uri.parse(
    "https://helfer.flatzi.com/app/get_promedio_calificacion.php?id_personal=$idPersonal",
  );

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final promedioStr = data['calificacion'];

      print('Respuesta: ${response.statusCode} - ${response.body}');

      if (promedioStr != null) {
        return double.tryParse(promedioStr.toString());
      }
    }
  } catch (e) {
    print('Error obteniendo calificación: $e');
  }

  return null; // si falla o no hay calificación
}
