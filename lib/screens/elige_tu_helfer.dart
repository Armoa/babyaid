import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/personal_model.dart';
import 'package:helfer/model/solicitud_servicio_model.dart';
import 'package:helfer/screens/pago_facturacion.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ElegirHerfer extends StatefulWidget {
  final SolicitudServicioModel solicitud;

  const ElegirHerfer({required this.solicitud, super.key});

  @override
  State<ElegirHerfer> createState() => _ElegirHerferState();
}

String formatHora(TimeOfDay hora) {
  final dt = DateTime(0, 1, 1, hora.hour, hora.minute);
  return DateFormat('HH:mm').format(dt); // Resultado: "14:00"
}

class _ElegirHerferState extends State<ElegirHerfer> {
  Future<List<PersonalModel>> obtenerPersonalesDisponibles(
    DateTime fecha,
    TimeOfDay horaInicio,
    TimeOfDay horaFin,
  ) async {
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
    final inicioStr = formatHora(horaInicio);
    final finStr = formatHora(horaFin);

    final url = Uri.parse(
      'https://helfer.flatzi.com/app/listar_personal_disponible.php?fecha=$fechaStr&hora_desde=$inicioStr&hora_hasta=$finStr',
    );

    print("URL consultada: $url");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final lista = data['disponibles'] as List;

      print("Personal disponible: ${lista.length}");

      return lista.map((e) => PersonalModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener personal disponible');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        toolbarHeight: 120,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Image.asset('assets/logo-blanco.png', scale: 2.5),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              "¿Elegí a tu Helfer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 25),
          ],
        ),

        backgroundColor: AppColors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.blueBlak
                  : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<PersonalModel>>(
                  future: obtenerPersonalesDisponibles(
                    widget.solicitud.fecha,
                    TimeOfDay(
                      hour: widget.solicitud.rangoHorario.start.round(),
                      minute: 0,
                    ),
                    TimeOfDay(
                      hour: widget.solicitud.rangoHorario.end.round(),
                      minute: 0,
                    ),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "No hay personal disponible para esta fecha",
                        ),
                      );
                    } else {
                      final lista = snapshot.data!;

                      for (final personal in lista) {
                        precacheImage(NetworkImage(personal.foto), context);
                      }

                      return _listaPersonalDisponible(lista);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listaPersonalDisponible(List<PersonalModel> personalDisponible) {
    return ListView.builder(
      itemCount: personalDisponible.length,
      itemBuilder: (context, index) {
        final personal = personalDisponible[index];

        return Card(
          elevation: 0.5,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            onTap: () {
              final solicitud = SolicitudServicioModel(
                frecuencia: widget.solicitud.frecuencia,
                duracionHoras: widget.solicitud.duracionHoras,
                rangoHorario: widget.solicitud.rangoHorario,
                fecha: widget.solicitud.fecha,
                ubicacion: widget.solicitud.ubicacion,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PagoFacturacion(
                        solicitud: solicitud,
                        personal:
                            personalDisponible[index], // 👈 este es el seleccionado
                      ),
                ),
              );
            },

            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(personal.foto),
              child: ClipOval(
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/placeholder.jpg',
                  image: personal.foto,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              "${personal.nombre} ${personal.apellido} ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color:
                          personal.verificado == 1 ? Colors.green : Colors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      personal.verificado == 1
                          ? 'Perfil Verificado'
                          : 'Perfil sin verificar',
                    ),
                  ],
                ),

                Row(
                  children: [
                    Icon(Icons.home, size: 16),
                    SizedBox(width: 8),
                    Text('Servicios: ${personal.antiguedad}'),
                  ],
                ),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: AppColors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${personal.horaDesde.substring(0, 5)} a ${personal.horaHasta.substring(0, 5)}',
                    ),
                  ],
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                Text(personal.calificacion.toStringAsFixed(1)),
              ],
            ),
          ),
        );
      },
    );
  }
}
