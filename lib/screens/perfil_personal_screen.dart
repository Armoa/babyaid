import 'package:bebito/model/colors.dart';
import 'package:bebito/model/personal_model.dart';
import 'package:bebito/screens/comentario_screen.dart';
import 'package:bebito/services/functions.dart';
import 'package:flutter/material.dart';

// Peril del Personal de limpieza
class PerfilPersonalScreen extends StatefulWidget {
  final PersonalCalificado personalRating;
  final PersonalModel personalModel;

  const PerfilPersonalScreen({
    required this.personalRating,
    required this.personalModel,
    super.key,
  });

  @override
  State<PerfilPersonalScreen> createState() => _PerfilPersonalScreenState();
}

class _PerfilPersonalScreenState extends State<PerfilPersonalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.primario),
      ),

      body: Center(
        child: Column(
          children: [
            SizedBox(height: 14),
            Container(
              width: 340,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36), // Bordes redondeados
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.3), // Sombra suave
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // Desplazamiento de la sombra
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      child: Image.network(
                        'https://helfer.flatzi.com/img/personal/${widget.personalRating.foto}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Espacio entre la imagen y el contenido de texto
                  const SizedBox(height: 10),

                  // Sección del nombre y la descripción
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start, // Alinea el texto a la izquierda
                      children: [
                        Row(
                          children: [
                            Text(
                              '${widget.personalRating.nombre} ${widget.personalRating.apellido}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Espacio entre el nombre y el ícono

                            Image.asset(
                              widget.personalModel.verificado == 1
                                  ? 'assets/verify.png'
                                  : 'assets/verify-off.png',
                              scale: 3,
                            ),
                          ],
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < widget.personalRating.promedio.round()
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 20,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.credit_card),
                            const SizedBox(width: 8),
                            Text(
                              numberFormat(widget.personalModel.ci),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.place_outlined),
                            const SizedBox(width: 8),
                            Text(
                              'Vive a ${widget.personalModel.distancia} Km.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes_sharp),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 260,
                              child: Text(
                                widget.personalModel.mensaje,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  height: 1.4,
                                  overflow:
                                      TextOverflow.ellipsis, // Interlineado
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween, // Espacia los elementos
                      children: [
                        _buildStatItem(
                          Icons.star,
                          widget.personalRating.promedio.toStringAsFixed(1),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ComentarioScreen(
                                      personal: widget.personalRating,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.comment_outlined,
                            color: Colors.black87,
                            size: 24,
                          ), // Icono de suma
                          label: const Text(
                            'Comentarios',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.grey[200]!,
                            ), // Fondo gris claro
                            foregroundColor: WidgetStateProperty.all<Color>(
                              Colors.black87,
                            ), // Color del texto y icono
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                ),
                            elevation: WidgetStateProperty.all(0), // Sin sombra
                            padding:
                                WidgetStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 15,
                                  ), // Padding interno del botón
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // Espacio al final de la tarjeta
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Función auxiliar para construir los ítems de estadísticas (personas, fotos)
Widget _buildStatItem(IconData icon, String count) {
  return Padding(
    padding: const EdgeInsets.only(right: 20.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(width: 5),
        Text(
          count,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}
