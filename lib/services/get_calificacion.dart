import 'dart:convert';

import 'package:http/http.dart' as http;

// ENVIAR CALIFICACION DEL PERSONAL
Future<Map<String, dynamic>> enviarCalificacion({
  required int idReserva,
  required int idPersonal,
  required int calificacion,
  required String comentario,
}) async {
  final url = Uri.parse("https://helfer.flatzi.com/app/get_calificacion.php");

  try {
    final response = await http.post(
      url,
      body: {
        'id_reserva': idReserva.toString(),
        'id_personal': idPersonal.toString(),
        'calificacion': calificacion.toString(),
        'comentario': comentario,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      return {
        "status": "error",
        "message": "Servidor no respondió correctamente",
      };
    }
  } catch (e) {
    return {"status": "error", "message": "Error de conexión"};
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
