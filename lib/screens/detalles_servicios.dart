import 'package:flutter/material.dart';

class DetalleServicio extends StatelessWidget {
  final int id;
  final String nombre;

  const DetalleServicio({super.key, required this.id, required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Servicio: $nombre')),
      body: Center(child: Text('ID: $id')),
    );
  }
}
