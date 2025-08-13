// import 'package:flutter/material.dart';
// import 'package:helfer/model/orders_model.dart';
// import 'package:helfer/widget/ventana_calificacion.dart';

// class ReservaItem extends StatelessWidget {
//   final Order reserva;
//   final int
//   idPersonalAsignado; // Suponiendo que la reserva contiene el ID del personal

//   const ReservaItem({
//     super.key,
//     required this.reserva,
//     required this.idPersonalAsignado,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Aquí puedes usar los datos de 'reserva' para mostrar la información del servicio
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text('Reserva #${reserva.id}'),
//             Text('Fecha: ${reserva.fechaServicio}'),
//             Text('Estado: ${reserva.status}'),
//             // ... otros detalles de la reserva ...
//             if (reserva.status ==
//                 'finalizada') // Por ejemplo, solo muestra el botón si la reserva está finalizada
//               ElevatedButton(
//                 onPressed: () {
//                   // Aquí es donde pasas los valores reales del objeto 'reserva'
//                   mostrarCalificacion(
//                     context,
//                     idReserva: reserva.id,
//                     idPersonal:
//                         idPersonalAsignado, // Usas el ID real del personal
//                   );
//                 },
//                 child: const Text('Calificar Servicio'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
