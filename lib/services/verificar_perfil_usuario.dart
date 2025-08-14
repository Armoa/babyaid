// verfificar perfilUsuario
import 'package:bebito/model/notification.dart';
import 'package:bebito/model/usuario_model.dart';
import 'package:bebito/services/obtener_usuario.dart';
import 'package:bebito/services/verificar_datos_faltantes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/notificaciones_provider.dart';

Future<void> verificarPerfilUsuario(BuildContext context) async {
  print("⚡ Ejecutando verificación de perfil...");
  UsuarioModel? usuario = await obtenerUsuarioDesdeMySQL();

  if (usuario != null) {
    print("✅ Usuario obtenido: ${usuario.name}");
    List<String> datosFaltantes = verificarDatosFaltantes(usuario);

    if (datosFaltantes.isNotEmpty) {
      print("⚠️ Datos faltantes: ${datosFaltantes.join(", ")}");

      Provider.of<NotificacionesProvider>(
        context,
        listen: false,
      ).agregarNotificacion(
        Notificacion(
          id: DateTime.now().millisecondsSinceEpoch,
          nombre: "Perfil incompleto",
          mensaje:
              "Por favor, actualiza tu perfil. Falta completar: ${datosFaltantes.join(", ")}",
          fecha: DateTime.now(),
          urgente: true,
          fueLeida: false,
        ),
      );

      print("✅ Notificación agregada correctamente.");
    } else {
      print("🎉 Todos los datos están completos.");
    }
  } else {
    print("🚨 No se pudo obtener el usuario.");
  }
}
