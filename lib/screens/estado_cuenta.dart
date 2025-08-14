import 'package:bebito/model/colors.dart';
import 'package:bebito/provider/auth_provider.dart' as local_auth_provider;
import 'package:bebito/provider/auth_provider.dart';
import 'package:bebito/services/fetch_order_detalles.dart';
import 'package:bebito/services/functions.dart';
import 'package:bebito/widget/title_appbar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// FORMATO DE HORARIO
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}

class EstadoCuenta extends StatefulWidget {
  const EstadoCuenta({super.key});

  @override
  State<EstadoCuenta> createState() => _EstadoCuentaState();
}

class _EstadoCuentaState extends State<EstadoCuenta> {
  Future<List<OrderDetalle>>? _orderDetallesFuture;
  int? _tileActivo;
  DateTime _currentMonth = DateTime.now();

  Map<String, Color> orderStatusColors = {
    'agendado': Colors.orange, // Pendiente
    'recurrente': Colors.blue, // En proceso
    'activo': Colors.teal, // En espera
    'finalizado': Colors.green, // Completado
    'cancelado': Colors.red, // Cancelado
    // 'refunded': Colors.purple, // Reembolsado
    // 'failed': Colors.grey, // Fallido
  };
  Color getStatusColor(String status) {
    return orderStatusColors[status] ?? Colors.black; // Color predeterminado
  }

  late local_auth_provider.AuthProvider authProvider;
  late int? userId;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() async {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUser(); // Asegura que SharedPreferences se lee
    final id = authProvider.user?.id;

    if (id != null) {
      setState(() {
        userId = id;
        _orderDetallesFuture = fetchOrderDetalles(id);
      });
    } else {
      print("El ID de usuario aún no está disponible");
    }
  }

  // Función para avanzar o retroceder el mes
  void _changeMonth(int monthsToAdd) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + monthsToAdd,
        1,
      );
      _tileActivo = null; // Cierra cualquier tile expandido al cambiar de mes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green,
      appBar: AppBar(toolbarHeight: 100, title: TitleAppbar()),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FutureBuilder<List<OrderDetalle>>(
            future: _orderDetallesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                final allDetalles = snapshot.data ?? [];

                // --- ESTA ES LA SECCIÓN QUE CAMBIA EN EL FILTRADO DEL BODY ---
                final filteredDetalles =
                    allDetalles.where((detalle) {
                      final orderDate = DateTime.parse(
                        detalle.order.fechaServicio,
                      );
                      final isCurrentMonth =
                          orderDate.year == _currentMonth.year &&
                          orderDate.month == _currentMonth.month;

                      // Filtra por el mes actual Y solo si el estado es 'agendado', 'recurrente' o 'cancelado'
                      final isSaldoRelatedStatus = [
                        'agendado',
                        'recurrente',
                        'cancelado',
                      ].contains(detalle.order.status);

                      return isCurrentMonth && isSaldoRelatedStatus;
                    }).toList();

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: FutureBuilder<List<OrderDetalle>>(
                        future: _orderDetallesFuture,
                        builder: (context, snapshot) {
                          int saldo = 0;
                          int serviciosPagados = 0;
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            final allDetalles = snapshot.data!;
                            // Calcula los saldos basados en los estados de TODOS los servicios
                            for (var detalle in allDetalles) {
                              switch (detalle.order.status) {
                                case 'agendado':
                                case 'recurrente':
                                case 'cancelado':
                                  saldo += detalle.order.total;
                                  break;
                                case 'activo':
                                case 'finalizado':
                                  serviciosPagados += detalle.order.total;
                                  break;
                              }
                            }
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize:
                                MainAxisSize
                                    .min, // Para que la columna ocupe el espacio mínimo necesario
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Saldo: ₲ ${numberFormat(saldo.toString())}',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Servicios Pagados: ₲ ${numberFormat(serviciosPagados.toString())}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Sliver para el selector de mes
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 0,
                        ),
                        child: Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                onPressed:
                                    () => _changeMonth(-1), // Retrocede un mes
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Text(
                                    DateFormat(
                                      'MMMM \'del\' yyyy',
                                      'es_PY',
                                    ).format(_currentMonth).capitalizeFirst(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed:
                                    () => _changeMonth(1), // Avanza un mes
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Contenido principal: lista de servicios o mensaje de "no hay datos"
                    if (filteredDetalles.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((
                          BuildContext context,
                          int index,
                        ) {
                          final detalle = filteredDetalles[index];
                          final order = detalle.order;
                          final personal = detalle.personal;

                          return Card(
                            elevation: 0,
                            child: ExpansionTile(
                              key: Key('tile_${order.id}'),
                              initiallyExpanded: _tileActivo == order.id,
                              onExpansionChanged: (expanded) {
                                setState(
                                  () =>
                                      _tileActivo = expanded ? order.id : null,
                                );
                              },

                              title: Text(
                                'Servicio #${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Iconsax.calendar_copy, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        DateFormat('d \'de\' MMMM y', 'es_PY')
                                            .format(
                                              DateTime.parse(order.createdAt),
                                            )
                                            .toString()
                                            .capitalizeFirst(),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Iconsax.clock_copy, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Paquete: ${order.paqueteHoras}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),

                                child: Text(
                                  '₲ ${numberFormat(order.total.toString())}',
                                  style: const TextStyle(
                                    color: AppColors.grayDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Fecha de solicitud: ${DateFormat('EEEE d MMMM y', 'es_PY').format(DateTime.parse(order.createdAt)).toString().capitalizeFirst()}',
                                      ),
                                      Text(
                                        'Fecha de servicio: ${DateFormat('EEEE d MMMM y', 'es_PY').format(DateTime.parse(order.fechaServicio)).toString().capitalizeFirst()}',
                                      ),
                                      Text('Horario: ${order.horarioRango}'),
                                      Text(
                                        'Frecuencia: ${order.frecuenciaServicio}',
                                      ),
                                      Text('Paquete: ${order.paqueteHoras}'),
                                      const Divider(height: 16),
                                      Text(
                                        'Personal asignado:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${personal.nombre} ${personal.apellido}',
                                      ),
                                      Text(
                                        'Calificación: ⭐ ${personal.calificacion.toStringAsFixed(1)}',
                                      ),
                                      Text(
                                        'Antigüedad: ${personal.antiguedad} años',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: filteredDetalles.length),
                      )
                    else
                      // Si no hay servicios para el mes seleccionado
                      // ${DateFormat('MMMM \'del\' yyyy', 'es_PY').format(_currentMonth).capitalizeFirst()}
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/box-pedidos.png',
                                  scale: 1.7,
                                ),
                              ),
                              Text(
                                "Aun no tienes Pagos en ${DateFormat('MMMM \'del\' yyyy', 'es_PY').format(_currentMonth).capitalizeFirst()}.",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
