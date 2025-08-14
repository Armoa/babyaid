import 'package:bebito/model/colors.dart';
import 'package:bebito/provider/auth_provider.dart';
import 'package:bebito/provider/notificaciones_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<int?> obtenerUsuarioActual() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(
      'usuario_id',
    ); // Asegúrate de guardar este dato al hacer login
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final provider = Provider.of<NotificacionesProvider>(
        context,
        listen: false,
      );
      provider.obtenerNotificaciones(authProvider.userId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      appBar: AppBar(title: const Text("Notificaciones ")),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
          child: Consumer<NotificacionesProvider>(
            builder: (context, provider, child) {
              print(
                "Notificaciones en Provider: ${provider.notificaciones.length}",
              );

              if (provider.cargando) {
                return const Center(
                  child: CircularProgressIndicator(),
                ); // Mostrar indicador de carga
              }

              if (provider.notificaciones.isEmpty) {
                return const Center(child: Text('No hay notificaciones aún.'));
              }

              return ListView.builder(
                itemCount: provider.notificaciones.length,
                itemBuilder: (context, index) {
                  final notificacion = provider.notificaciones[index];
                  return ListTile(
                    title: Text(
                      notificacion.nombre,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      notificacion.mensaje,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12,
                      ),
                    ),
                    leading:
                        notificacion.urgente
                            ? Icon(
                              Icons.notifications_active,
                              color:
                                  notificacion.fueLeida
                                      ? Colors.grey
                                      : Colors.red,
                            )
                            : Icon(
                              Icons.notifications,
                              color:
                                  notificacion.fueLeida
                                      ? Colors.grey
                                      : Colors.orange,
                            ),
                    trailing:
                        notificacion.fueLeida
                            ? const Icon(
                              Icons.remove_red_eye,
                              color: Color.fromARGB(255, 216, 216, 216),
                            )
                            : const Icon(
                              Icons.remove_red_eye,
                              color: Color.fromARGB(255, 180, 211, 66),
                            ),
                    onTap: () {
                      provider.marcarComoLeida(
                        notificacion.id,
                      ); // Marca como leída

                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notificacion.nombre,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    notificacion.mensaje,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cerrar"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
