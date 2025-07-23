import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapaScreen extends StatefulWidget {
  final String direccion;
  final Function(Map<String, dynamic>) onUbicacionConfirmada;

  const MapaScreen({
    required this.direccion,
    required this.onUbicacionConfirmada,
    super.key,
  });

  @override
  MapaScreenState createState() => MapaScreenState();
}

class MapaScreenState extends State<MapaScreen> {
  double latitud = -25.2637; // Coordenadas iniciales predeterminadas
  double longitud = -57.5759; // Coordenadas iniciales predeterminadas

  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _obtenerCoordenadas(widget.direccion);
  }

  Future<void> _obtenerCoordenadas(String direccion) async {
    if (direccion.isEmpty || !direccion.contains(',')) {
      print(
        'Error: La dirección debe incluir ciudad y calle separadas por una coma.',
      );
      setState(() {
        latitud = -25.2637; // Coordenadas predeterminadas
        longitud = -57.5759;
      });
      return;
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$direccion&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'shop/1.0 (armoanet@gmail.com)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final nuevaLatitud = double.parse(data[0]['lat']);
          final nuevaLongitud = double.parse(data[0]['lon']);

          setState(() {
            latitud = nuevaLatitud;
            longitud = nuevaLongitud;
          });

          // Mueve el centro del mapa a las nuevas coordenadas
          _mapController.move(LatLng(nuevaLatitud, nuevaLongitud), 17);
        } else {
          print('No se encontraron coordenadas para la dirección.');
        }
      } else {
        throw Exception('Error al obtener coordenadas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        latitud = -25.2637; // Coordenadas predeterminadas
        longitud = -57.5759;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubicar en Mapa')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(latitud, longitud),
          zoom: 16,
          onTap: (tapPosition, point) {
            setState(() {
              latitud = point.latitude;
              longitud = point.longitude;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYXJtb2EiLCJhIjoiY2wzd2lta2RvMDJnYjNsbnhoc3JvcXBibiJ9.PVMSz2_hBAH76Uvq714spw',
            additionalOptions: {
              'access_token':
                  'pk.eyJ1IjoiYXJtb2EiLCJhIjoiY2wzd2lta2RvMDJnYjNsbnhoc3JvcXBibiJ9.PVMSz2_hBAH76Uvq714spw',
            },
            tileProvider: NetworkTileProvider(),
          ),
          // TileLayer(
          //   urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          //   subdomains: const ['a', 'b', 'c'],
          //   additionalOptions: {
          //     'User-Agent':
          //         'FlutterMapApp/1.0 (armanet@gmail.com)', // Reemplazá con tu correo o info de contacto
          //   },
          // ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(latitud, longitud),
                builder:
                    (ctx) => const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Confirmar'),
        icon: const Icon(Icons.check),
        onPressed: () {
          final partesDireccion = widget.direccion.split(',');
          if (partesDireccion.length >= 2) {
            widget.onUbicacionConfirmada({
              'ciudad': partesDireccion[0].trim(),
              'calle': partesDireccion[1].trim(),
              'latitud': latitud,
              'longitud': longitud,
            });
          } else {
            // Manejo de error si la dirección no tiene el formato esperado
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'La dirección debe incluir ciudad y calle separadas por una coma.',
                ),
              ),
            );
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}
