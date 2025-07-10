import 'package:flutter/material.dart';
import 'package:helfer/model/usuario_model.dart';

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
