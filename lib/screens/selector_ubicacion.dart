import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/usuario_model.dart';
import 'package:helfer/screens/add_address_screen.dart';
import 'package:helfer/screens/frecuencia_servicios.dart';
import 'package:helfer/screens/perfil_update.dart';
import 'package:helfer/services/delete_address.dart';
import 'package:helfer/services/obtener_usuario.dart';
import 'package:helfer/services/ubicacion_service.dart';
import 'package:helfer/services/verificar_datos_faltantes.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SelectorUbicacion extends StatefulWidget {
  const SelectorUbicacion({super.key});

  @override
  State<SelectorUbicacion> createState() => _SelectorUbicacionState();
}

class _SelectorUbicacionState extends State<SelectorUbicacion> {
  late Future<List<UbicacionModel>> _ubicacionesFuture;

  @override
  void initState() {
    super.initState();
    _ubicacionesFuture = obtenerUbicaciones(); // Cargar direcciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verificarPerfilUsuario(context);
    });
  }

  void actualizarLista() {
    setState(() {
      _ubicacionesFuture = obtenerUbicaciones(); // Recargar direcciones
    });
  }

  Future<void> verificarPerfilUsuario(BuildContext context) async {
    UsuarioModel? usuario = await obtenerUsuarioDesdeMySQL();
    if (usuario == null) return;
    List<String> datosFaltantes = verificarDatosFaltantes(usuario);
    if (datosFaltantes.isNotEmpty) {
      mostrarPopup(context, datosFaltantes);
    }
  }

  void mostrarPopup(BuildContext context, List<String> datosFaltantes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Actualiza tu perfil"),
          content: Text("Falta completar: ${datosFaltantes.join(", ")}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cerrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PerfilUpdate()),
                );
              },
              child: Text("Actualizar"),
            ),
          ],
        );
      },
    );
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
              "¿A dónde vamos?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 25),
          ],
        ),
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
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Botón para Guardar Ubicación
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenDark,
                        padding: EdgeInsets.all(16),
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
                        Iconsax.add_circle_copy,
                        size: 28,
                        color: AppColors.white,
                      ),
                      label: const Text(
                        'Agregar ubicación',
                        style: TextStyle(color: AppColors.white, fontSize: 18),
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
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => FrecuenciaServicio(
                                        ubicacion: ubicacion,
                                      ),
                                ),
                              );
                            },
                            leading: const Icon(
                              Iconsax.location_copy,
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
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Iconsax.trash_copy,
                                color: Colors.red,
                              ),
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
