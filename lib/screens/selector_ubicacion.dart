import 'dart:convert';

import 'package:bebito/model/colors.dart';
import 'package:bebito/model/usuario_model.dart';
import 'package:bebito/provider/auth_provider.dart';
import 'package:bebito/screens/add_address_screen.dart';
import 'package:bebito/screens/frecuencia_servicios.dart';
import 'package:bebito/screens/perfil_update.dart';
import 'package:bebito/services/ubicacion_service.dart';
import 'package:bebito/widget/title_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

class SelectorUbicacion extends StatefulWidget {
  const SelectorUbicacion({super.key});

  @override
  State<SelectorUbicacion> createState() => _SelectorUbicacionState();
}

class _SelectorUbicacionState extends State<SelectorUbicacion> {
  late Future<List<UbicacionModel>> _ubicacionesFuture;
  final UbicacionService _ubicacionService = UbicacionService();

  @override
  void initState() {
    super.initState();
    // Pasa el BuildContext a obtenerUbicaciones
    _ubicacionesFuture = _ubicacionService.obtenerUbicaciones(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      verificarPerfilUsuario(context);
    });
  }

  void actualizarLista() {
    setState(() {
      // Pasa el BuildContext a obtenerUbicaciones al recargar
      _ubicacionesFuture = _ubicacionService.obtenerUbicaciones(context);
    });
  }

  // Ahora obtenemos el usuario directamente del AuthProvider
  Future<void> verificarPerfilUsuario(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UsuarioModel? usuario =
        authProvider.user; // Obtén el usuario del AuthProvider

    if (usuario == null) {
      print(
        "DEBUG SelectorUbicacion: Usuario es null en AuthProvider. No se verifica perfil.",
      );
      return; // Si el usuario no está logueado o cargado, no hacemos nada
    }

    List<String> datosFaltantes = verificarDatosFaltantes(usuario);
    if (datosFaltantes.isNotEmpty) {
      mostrarPopup(context, datosFaltantes);
    }
  }

  // Asegúrate de que esta función esté definida en tu clase o en un archivo de utilidades
  List<String> verificarDatosFaltantes(UsuarioModel usuario) {
    List<String> faltantes = [];

    if (usuario.name.isEmpty) faltantes.add("Nombre");
    if (usuario.lastName.isEmpty) {
      faltantes.add("Apellido");
    }
    if (usuario.address.isEmpty) {
      faltantes.add("Dirección");
    }
    if (usuario.city.isEmpty) faltantes.add("Ciudad");
    if (usuario.barrio.isEmpty) {
      faltantes.add("Barrio");
    }
    if (usuario.phone.isEmpty) {
      faltantes.add("Teléfono");
    }
    if (usuario.razonsocial.isEmpty) {
      faltantes.add("Razón Social");
    }
    if (usuario.ruc.isEmpty) faltantes.add("RUC");
    if (usuario.dateBirth.isEmpty || usuario.dateBirth == '1990-01-01') {
      faltantes.add("Fecha de Nacimiento");
    }
    if (usuario.ci.isEmpty) faltantes.add("C.I.");
    return faltantes;
  }

  void mostrarPopup(BuildContext context, List<String> datosFaltantes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Actualiza tu perfil"),
          content: Text("Falta completar: ${datosFaltantes.join(", ")}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilUpdate()),
                );
              },
              child: const Text("Actualizar"),
            ),
          ],
        );
      },
    );
  }

  // Agrega o asegúrate de tener esta función para la eliminación
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
      backgroundColor: AppColors.green,
      appBar: AppBar(
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        leading: null,
        title: TitleAppbar(),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "¿A dónde vamos?",
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Botón para Guardar Ubicación
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenDark,
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAddressScreen(),
                          ),
                        ).then((result) {
                          if (result == true) {
                            actualizarLista();
                          }
                        });
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
                      print(
                        "DEBUG SelectorUbicacion - FutureBuilder Error: ${snapshot.error}",
                      );
                      return Center(
                        child: Text(
                          "Error al cargar ubicaciones: ${snapshot.error}",
                        ),
                      );
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
                              style: const TextStyle(fontSize: 12),
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
}
