class PersonalModel {
  final int id;
  final String nombre;
  final String apellido;
  final String ci;
  final String foto;
  final int antiguedad;
  final double calificacion;
  final int verificado;
  final double distancia;
  final String horaDesde;
  final String horaHasta;

  PersonalModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.ci,
    required this.foto,
    required this.antiguedad,
    required this.calificacion,
    required this.verificado,
    required this.distancia,
    required this.horaDesde,
    required this.horaHasta,
  });

  factory PersonalModel.fromJson(Map<String, dynamic> json) {
    return PersonalModel(
      id: json['id'],
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido'],
      ci: json['ci'],
      foto: json['foto'],
      antiguedad: int.tryParse(json['antiguedad'].toString()) ?? 0,
      calificacion: (json['calificacion'] ?? 0).toDouble(),
      verificado: int.tryParse(json['verificado'].toString()) ?? 0,
      distancia: (json['distancia'] ?? 0).toDouble(),
      horaDesde: json['hora_desde'] ?? '',
      horaHasta: json['hora_hasta'] ?? '',
    );
  }
}
