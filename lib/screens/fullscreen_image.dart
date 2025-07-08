import 'package:flutter/material.dart';

class FullscreenImage extends StatelessWidget {
  final String imageUrl;

  const FullscreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Cerrar imagen al tocar
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                panEnabled: false, // ✅ Desactiva el desplazamiento lateral
                minScale: 1.0, // ✅ Zoom mínimo (sin cambios)
                maxScale: 5.0, // ✅ Zoom máximo (hasta 5x)
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
