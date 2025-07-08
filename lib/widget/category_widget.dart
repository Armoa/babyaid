// CATEGORIAS
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatelessWidget {
  final String
  imagePath; // Cambiamos IconData por String para la ruta de la imagen
  final String label;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.imagePath, // Ahora requerimos la ruta de la imagen
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 10, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              child: Image.network(
                imagePath, // Usa la ruta de la imagen
                width: 65, // Puedes ajustar el ancho según necesites
                height: 65, // Puedes ajustar la altura según necesites
                fit:
                    BoxFit
                        .contain, // Cómo se ajustará la imagen dentro del espacio
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: 84,
              height: 40,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
