import 'package:bebito/model/colors.dart';
import 'package:bebito/provider/personal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<String?> _mostrarCampoComentario(
  BuildContext context,
  TextEditingController controller,
) async {
  // showModalBottomSheet ya devuelve Future<String?>
  final result = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext bc) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bc).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context, null);
                      },
                      color: Colors.grey[800],
                      iconSize: 26,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Deja tu comentario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Haz tu reseña aquí...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primario,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          // Este botón ya devolvía el texto, lo cual es correcto
                          Navigator.pop(context, controller.text);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ],
        ),
      );
    },
  );
  return result;
}

void mostrarCalificacion(BuildContext context) {
  // Obtenemos una instancia del provider
  final personalProvider = Provider.of<PersonalProvider>(
    context,
    listen: false,
  );
  // Reseteamos el estado del provider cada vez que se abre el popup
  personalProvider.resetState();
  // Función auxiliar para obtener el texto de la calificación
  String getCalificacionText(int calificacion) {
    switch (calificacion) {
      case 1:
        return "Fatal";
      case 2:
        return "Aceptable";
      case 3:
        return "Bueno";
      case 4:
        return "Muy Bueno";
      case 5:
        return "¡Excelente!";
      default:
        return "";
    }
  }

  // Define las sugerencias aquí
  List<String> getSugerenciasPorCalificacion(int calificacion) {
    if (calificacion <= 3) {
      return [
        'Llegó tarde',
        'No quedó muy limpio',
        'Desatento',
        'Descuidado',
        'El personal no coincide',
      ];
    } else {
      return [
        'Excelente atención',
        'Puntual',
        'Atento',
        'Fino Cluidado',
        'Recomendado',
      ];
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext bc) {
      // Usamos Consumer para escuchar los cambios en el provider
      return Consumer<PersonalProvider>(
        builder: (context, provider, child) {
          // Aquí va toda la UI que depende del estado del provider
          final int? idReserva = provider.servicioPendiente?['idReserva'];
          final int? idPersonal = provider.servicioPendiente?['idPersonal'];

          if (idReserva == null || idPersonal == null) {
            return const Center(
              child: Text('Error: No se encontraron datos del servicio.'),
            );
          }
          final calificacion = provider.calificacion;

          final currentSugerencias = getSugerenciasPorCalificacion(
            calificacion,
          );

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bc).viewInsets.bottom,
              left: 16.0,
              right: 16.0,
              top: 16.0,
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: const Text(
                          '¿Cómo fue el servicio?',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ⭐ Selector de estrellas y texto descriptivo
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                iconSize: 44,
                                icon: Image.asset(
                                  index < calificacion
                                      ? 'assets/star.png'
                                      : 'assets/star_line.png',
                                  width: 44,
                                  height: 44,
                                ),
                                onPressed: () {
                                  provider.setCalificacion(index + 1);
                                },
                              );
                            }),
                          ),
                          SizedBox(height: 10),
                          if (calificacion > 0)
                            Text(
                              getCalificacionText(calificacion),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          const SizedBox(height: 20),
                          if (calificacion > 0)
                            Divider(
                              height: 20,
                              thickness: 1, // Grosor de la línea
                              indent: 20, // Margen izquierdo
                              endIndent: 20, // Margen derecho
                              color: Colors.grey[400],
                            ),
                          const SizedBox(height: 20),
                          if (calificacion > 0)
                            Text(
                              "¿Quieres añadir algún comentario?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          SizedBox(height: 20),
                        ],
                      ),
                      // --- NUEVO: Chips de sugerencias ---
                      if (calificacion >
                          0) // Muestra las sugerencias solo si hay calificación
                        // dentro del Consumer en ventana_calificacion.dart
                        Align(
                          alignment: Alignment.center,
                          child: Wrap(
                            spacing: 8.0, // Espacio entre los chips
                            runSpacing: 8.0, // Espacio entre las filas de chips
                            alignment: WrapAlignment.center,
                            children: [
                              ...currentSugerencias.map((sugerencia) {
                                // Lee el estado directamente del Provider
                                final isSelected = provider
                                    .sugerenciasSeleccionadas
                                    .contains(sugerencia);

                                return ActionChip(
                                  label: Text(sugerencia),
                                  backgroundColor:
                                      isSelected
                                          ? AppColors.primario
                                          : AppColors.secundario,
                                  side: BorderSide(
                                    width: 2,
                                    color:
                                        isSelected
                                            ? AppColors.primario
                                            : Colors.transparent,
                                  ),
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? AppColors.primario
                                            : AppColors.secundario,
                                  ),
                                  onPressed: () {
                                    // Llama al método del Provider para cambiar el estado
                                    provider.toggleSugerencia(sugerencia);
                                  },
                                );
                              }).toList(),
                              // Botón "Deja un comentario" como un chip
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ActionChip(
                                    avatar: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color:
                                          provider.comentario.isNotEmpty
                                              ? AppColors.primario
                                              : AppColors.secundario,
                                    ),
                                    label: Text(
                                      'Deja un comentario',
                                      style: TextStyle(
                                        color:
                                            provider.comentario.isNotEmpty
                                                ? AppColors.primario
                                                : AppColors.secundario,
                                      ),
                                    ),
                                    backgroundColor:
                                        provider.comentario.isNotEmpty
                                            ? AppColors.primario
                                            : AppColors.secundario,
                                    side: BorderSide(
                                      width: 2,
                                      color:
                                          provider.comentario.isNotEmpty
                                              ? AppColors.primario
                                              : Colors.transparent,
                                    ),
                                    onPressed: () async {
                                      final String? result =
                                          await _mostrarCampoComentario(
                                            context,
                                            TextEditingController(
                                              text: provider.comentario,
                                            ),
                                          );

                                      if (result != null) {
                                        provider.setComentario(result);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: AppColors.primario,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide.none,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Listo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () async {
                                // Asegúrate de obtener la calificación del Provider
                                final int calificacion = provider.calificacion;
                                // Validaciones
                                if (calificacion == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Seleccioná al menos 1 estrella',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Muestra un indicador de carga (opcional, pero buena práctica)
                                provider.setLoading(true);

                                // Llama a la función del Provider para enviar la calificación.
                                final resultado =
                                    await provider.enviarCalificacion();
                                // Oculta el indicador de carga
                                provider.setLoading(false);

                                // Manejo del resultado
                                if (resultado['status'] == 'error') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        resultado['message'] ??
                                            'Error desconocido',
                                      ),
                                    ),
                                  );
                                } else {
                                  // Si la calificación fue exitosa
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        resultado['message'] ??
                                            '¡Calificación enviada!',
                                      ),
                                    ),
                                  );
                                  provider.recargarServicios();

                                  // Cierra el bottom sheet
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 70),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco
                      shape: BoxShape.circle, // Forma circular para el botón
                      boxShadow: [
                        // Sombra
                        BoxShadow(
                          color: const Color.fromARGB(22, 0, 0, 0),
                          spreadRadius: 2, // Cuánto se extiende la sombra
                          blurRadius: 2, // Qué tan difuminada está la sombra
                          offset: const Offset(
                            0,
                            0,
                          ), // Desplazamiento de la sombra (eje X, Y)
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.grey[800],
                      iconSize: 26,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
