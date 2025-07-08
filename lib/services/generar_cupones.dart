import 'dart:convert'; // Necesario para jsonEncode

import 'package:http/http.dart' as http;

// Future<void> generarCuponParaCliente(int clienteId, int cuponBaseId) async {
//   final response = await http.post(
//     Uri.parse('https://farma.staweno.com/cupones/generar_cupon_cliente.php'),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'cliente_id': clienteId, 'cupon_base_id': cuponBaseId}),
//   );

//   if (response.statusCode == 200) {
//     print('Cupón generado');
//   } else {
//     print('❌ Error al generar cupón. Status: ${response.statusCode}');
//     print('Respuesta del servidor: ${response.body}');
//   }
// }

Future<void> asignarCuponParaCliente(int clienteId, int cuponId) async {
  final response = await http.post(
    Uri.parse('https://farma.staweno.com/cupones/asignar_cupon_cliente.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'cliente_id': clienteId, 'cupon_id': cuponId}),
  );

  if (response.statusCode == 200) {
    print('Cupón Enviado!');
  } else {
    print('❌ Error al enviar cupón. Status: ${response.statusCode}');
    print('Respuesta del servidor: ${response.body}');
  }
}
