import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/screens/add_address_screen.dart';
import 'package:helfer/services/delete_address.dart';
import 'package:helfer/services/ubicacion_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Future<List<UbicacionModel>> _ubicacionesFuture;

  @override
  void initState() {
    super.initState();
    _ubicacionesFuture = obtenerUbicaciones(); // Cargar direcciones al iniciar
  }

  void actualizarLista() {
    setState(() {
      _ubicacionesFuture = obtenerUbicaciones(); // Recargar direcciones
    });
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
                        backgroundColor: AppColors.blueDark,
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

  void confirmarEliminacion(BuildContext context, UbicacionModel ubicacion) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: Text(
            "¿Estás seguro de que quieres eliminar la ubicación '${ubicacion.nombreUbicacion}'?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(); // Cerrar ventana sin eliminar
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Cerrar diálogo
                bool eliminado = await eliminarUbicacion(ubicacion.id);

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      eliminado
                          ? "Ubicación eliminada correctamente."
                          : "Error al eliminar la ubicación.",
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );

                if (eliminado) {
                  actualizarLista(); // Recargar lista si se eliminó
                }
              },
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
