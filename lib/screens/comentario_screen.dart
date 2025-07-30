import 'package:flutter/material.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/model/personal_model.dart';

// Comentario y Reseñas sobre el Personal de limpieza
class ComentarioScreen extends StatelessWidget {
  final PersonalCalificado personal;

  const ComentarioScreen({required this.personal, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              '${personal.nombre} ${personal.apellido}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 25),
          ],
        ),
      ),
      body:
          personal.comentarios.isEmpty
              ? const Center(
                child: Text('Este personal aún no tiene comentarios'),
              )
              : Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: AppColors.white,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: personal.comentarios.length,
                  itemBuilder: (context, index) {
                    final comentarioDestacado = personal.comentarios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 👤 Nombre e imagen del personal
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(
                                    'https://helfer.flatzi.com/img/personal/${personal.foto}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${personal.nombre} ${personal.apellido}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // ⭐ Promedio como número
                                Text(
                                  '${personal.promedio.toStringAsFixed(1)} ⭐',
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ⭐ Estrellas visuales
                            Row(
                              children: List.generate(5, (index) {
                                final filled =
                                    index < personal.promedio.round();
                                return Icon(
                                  filled ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                            ),

                            const SizedBox(height: 12),

                            // 💬 Comentario destacado
                            Text(
                              '"$comentarioDestacado"',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
