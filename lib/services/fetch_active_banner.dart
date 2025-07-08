import 'dart:convert';

import 'package:http/http.dart' as http;

// Consulta API para mostrar POPUP
Future<String?> fetchActiveBanner() async {
  final response = await http.get(
    Uri.parse("https://helfer.flatzi.com/app/get_popup_custom.php?id=8"),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['imagen'];
    } else {
      print("No hay banners activos.");
      return null;
    }
  } else {
    print("Error en la solicitud: ${response.statusCode}");
    return null;
  }
}

// Consulta API de Banners Slider para montrar en la portada
Future<List<String>?> fetchShowSliders() async {
  final response = await http.get(
    // ID 5 es le identificador del Dominio
    Uri.parse("https://api.staweno.com/get_slider_custom.php?id=8"),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return List<String>.from(data['imagenes']);
    } else {
      print("No hay banners activos.");
      return null;
    }
  } else {
    print("Error en la solicitud: ${response.statusCode}");
    return null;
  }
}
