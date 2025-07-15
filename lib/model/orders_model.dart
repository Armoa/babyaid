class Order {
  final int id;
  final int total;
  final String status;
  final String createdAt;
  final String paqueteHoras;
  final String frecuenciaServicio;
  final String horarioRango;
  final String fechaServicio;

  Order({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.paqueteHoras,
    required this.frecuenciaServicio,
    required this.horarioRango,
    required this.fechaServicio,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      total: json['total'],
      status: json['status'],
      createdAt: json['created_at'],
      paqueteHoras: json['paquete_horas'],
      frecuenciaServicio: json['frecuencia_servicio'],
      horarioRango: json['horario'],
      fechaServicio: json['fecha_servicio'],
    );
  }
}
