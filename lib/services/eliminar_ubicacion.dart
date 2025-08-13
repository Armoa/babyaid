// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:helfer/model/usuario_model.dart';
// import 'package:helfer/services/ubicacion_service.dart';
// import 'package:http/http.dart' as http;

// class EliminarUbicacion extends StatefulWidget {
//   const EliminarUbicacion({super.key});

//   @override
//   State<EliminarUbicacion> createState() => _EliminarUbicacionState();
// }

// class _EliminarUbicacionState extends State<EliminarUbicacion> {
//   late Future<List<UbicacionModel>> ubicacionesFuture;
//   final UbicacionService _ubicacionService = UbicacionService();

//   void actualizarLista() {
//     setState(() {
//       // Pasa el BuildContext a obtenerUbicaciones al recargar
//       ubicacionesFuture = _ubicacionService.obtenerUbicaciones(context);
//     });
//   }

//   Future<void> confirmarEliminacion(
//     BuildContext context,
//     UbicacionModel ubicacion,
//   ) async {
//     final token = await _ubicacionService.storage.read(key: 'jwt_token');
//     if (token == null || token.isEmpty) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Error: No autenticado para eliminar.")),
//         );
//       }
//       return;
//     }

//     // Usamos 'await' para esperar a que el diálogo se cierre
//     final bool? shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Eliminar Dirección"),
//           content: Text(
//             "¿Estás seguro de que quieres eliminar la dirección '${ubicacion.nombreUbicacion}'?",
//           ),
//           actions: [
//             TextButton(
//               onPressed:
//                   () => Navigator.pop(
//                     context,
//                     false,
//                   ), // Cierra el diálogo y retorna 'false'
//               child: const Text("Cancelar"),
//             ),
//             TextButton(
//               onPressed:
//                   () => Navigator.pop(
//                     context,
//                     true,
//                   ), // Cierra el diálogo y retorna 'true'
//               child: const Text(
//                 "Eliminar",
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     // Si el usuario confirmó la eliminación (shouldDelete es true)
//     if (shouldDelete == true) {
//       final deleteUrl = Uri.parse(
//         'https://helfer.flatzi.com/app/delete_address.php',
//       );

//       try {
//         final response = await http.post(
//           deleteUrl,
//           headers: {
//             'Content-Type': 'application/json',
//             'Authorization': 'Bearer $token',
//           },
//           body: jsonEncode({'address_id': ubicacion.id}),
//         );

//         if (!context.mounted) return;

//         if (response.statusCode == 200) {
//           final responseData = json.decode(response.body);
//           if (responseData['status'] == 'success') {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("Dirección eliminada correctamente."),
//               ),
//             );
//             // ¡Aquí está la magia! Llama a `actualizarLista()` para refrescar el estado
//             actualizarLista();
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   "Error al eliminar: ${responseData['message'] ?? 'Desconocido'}",
//                 ),
//               ),
//             );
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 "Error del servidor al eliminar: ${response.statusCode}",
//               ),
//             ),
//           );
//         }
//       } catch (e) {
//         if (!context.mounted) return;
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Excepción al eliminar: $e")));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
