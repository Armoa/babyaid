class Notificacion {
  final int id;
  final String nombre;
  final String mensaje;
  final DateTime fecha;
  final bool urgente;
  final bool fueLeida;

  Notificacion({
    required this.id,
    required this.nombre,
    required this.mensaje,
    required this.fecha,
    required this.urgente,
    required this.fueLeida,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: int.parse(json['id']), // Convierte el id de string a int
      nombre: json['nombre'],
      mensaje: json['mensaje'],
      fecha: DateTime.parse(json['fecha']), // Convierte fecha correctamente
      urgente: json['urgente'] == "1", // Convierte "0"/"1" a booleano
      fueLeida: json['fue_leida'] == "1",
    );
  }
}
