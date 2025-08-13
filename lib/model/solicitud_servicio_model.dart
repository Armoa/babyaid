import 'package:babyaid/model/usuario_model.dart';
import 'package:flutter/material.dart';

class SolicitudServicioModel {
  final String frecuencia;
  final int duracionHoras;
  final RangeValues rangoHorario;
  final DateTime fecha;
  final UbicacionModel ubicacion;

  SolicitudServicioModel({
    required this.frecuencia,
    required this.duracionHoras,
    required this.rangoHorario,
    required this.fecha,
    required this.ubicacion,
  });
}
