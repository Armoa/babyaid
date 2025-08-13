import 'dart:convert';

import 'package:babyaid/model/colors.dart';
import 'package:babyaid/model/usuario_model.dart';
import 'package:babyaid/screens/add_address_screen.dart';
import 'package:babyaid/services/ubicacion_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Future<List<UbicacionModel>> _ubicacionesFuture;

  final UbicacionService _ubicacionService = UbicacionService();

  @override
  void initState() {
    super.initState();
    _ubicacionesFuture = _ubicacionService.obtenerUbicaciones(context);
  }

  void actualizarLista() {
    setState(() {
      // Pasa el BuildContext a obtenerUbicaciones al recargar
      _ubicacionesFuture = _ubicacionService.obtenerUbicaciones(context);
    });
  }

  Future<void> confirmarEliminacion(
    BuildContext context,
    UbicacionModel ubicacion,
  ) async {
    final token = await _ubicacionService.storage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: No autenticado para eliminar.")),
        );
      }
      return;
    }

    // Usamos 'await' para esperar a que el diálogo se cierre
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar Dirección"),
          content: Text(
            "¿Estás seguro de que quieres eliminar la dirección '${ubicacion.nombreUbicacion}'?",
          ),
          actions: [
            TextButton(
              onPressed:
                  () => Navigator.pop(
                    context,
                    false,
                  ), // Cierra el diálogo y retorna 'false'
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed:
                  () => Navigator.pop(
                    context,
                    true,
                  ), // Cierra el diálogo y retorna 'true'
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // Si el usuario confirmó la eliminación (shouldDelete es true)
    if (shouldDelete == true) {
      final deleteUrl = Uri.parse(
        'https://helfer.flatzi.com/app/delete_address.php',
      );

      try {
        final response = await http.post(
          deleteUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'address_id': ubicacion.id}),
        );

        if (!context.mounted) return;

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Dirección eliminada correctamente."),
              ),
            );
            // ¡Aquí está la magia! Llama a `actualizarLista()` para refrescar el estado
            actualizarLista();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Error al eliminar: ${responseData['message'] ?? 'Desconocido'}",
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error del servidor al eliminar: ${response.statusCode}",
              ),
            ),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Excepción al eliminar: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Direcciones")),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Botón para Guardar Ubicación
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAddressScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 24,
                        color: AppColors.white,
                      ),
                      label: const Text(
                        'Agregar nueva dirección',
                        style: TextStyle(color: AppColors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<UbicacionModel>>(
                  future: _ubicacionesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No tienes direcciones guardadas"),
                      );
                    }

                    final ubicaciones = snapshot.data!;

                    return ListView.builder(
                      itemCount: ubicaciones.length,
                      itemBuilder: (context, index) {
                        final ubicacion = ubicaciones[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                            ),
                            title: Text(
                              ubicacion.nombreUbicacion,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${ubicacion.callePrincipal}, ${ubicacion.numeracion}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                confirmarEliminacion(context, ubicacion);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
