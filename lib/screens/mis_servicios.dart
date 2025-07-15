import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helfer/model/colors.dart';
import 'package:helfer/provider/auth_provider.dart' as local_auth_provider;
import 'package:helfer/screens/home.dart';
import 'package:helfer/services/fetch_order_detalles.dart';
import 'package:helfer/services/functions.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// FORMATO DE HORARIO
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }
}

class MisServicios extends StatefulWidget {
  const MisServicios({super.key});

  @override
  State<MisServicios> createState() => _MisServiciosState();
}

class _MisServiciosState extends State<MisServicios> {
  late Future<List<OrderDetalle>> _orderDetallesFuture;
  int? _tileActivo;

  String _selectedStatus = 'agendado'; // Estado por defecto
  // Mapeo de estados internos a nombres de visualización para los botones
  final Map<String, String> _statusDisplayNames = {
    'agendado': 'Agendados',
    'recurrente': 'Recurrentes',
    'activo': 'Activos',
    'finalizado': 'Finalizados',
    'cancelado': 'Cancelados',
  };

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

    authProvider = Provider.of<local_auth_provider.AuthProvider>(
      context,
      listen: false,
    );
    userId = authProvider.user?.id;
    _orderDetallesFuture = fetchOrderDetalles(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueDark,
      appBar: AppBar(
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
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                        (Route<dynamic> route) => false,
                      );
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
              "Mis servicios",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 25),
          ],
        ),
      ),
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
                // Siempre construye el CustomScrollView para que los botones sean visibles
                // independientemente del estado de los datos.

                // Obtén los datos (vacíos si no hay, o los reales)
                final allDetalles = snapshot.data ?? [];

                // Filtra la lista de OrderDetalle según el estado seleccionado
                final filteredDetalles =
                    allDetalles.where((detalle) {
                      return detalle.order.status == _selectedStatus;
                    }).toList();

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Listado de Servicios",
                            style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Sliver para los botones de estado (SIEMPRE VISIBLE)
                    SliverToBoxAdapter(
                      child: Card(
                        child: Container(
                          height: 60, // Altura para la fila de botones
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _statusDisplayNames.length,
                            itemBuilder: (context, index) {
                              final statusKey = _statusDisplayNames.keys
                                  .elementAt(index);
                              final statusDisplayName = _statusDisplayNames
                                  .values
                                  .elementAt(index);
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(statusDisplayName),
                                  selected: _selectedStatus == statusKey,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedStatus = statusKey;
                                        _tileActivo =
                                            null; // Cierra cualquier ExpansionTile abierto
                                      });
                                    }
                                  },
                                  checkmarkColor: Colors.white,
                                  selectedColor: AppColors.blueDark,
                                  labelStyle: TextStyle(
                                    color:
                                        _selectedStatus == statusKey
                                            ? Colors.white
                                            : AppColors.blueDark,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 10)),

                    // Aquí manejamos si hay datos filtrados o si mostramos el mensaje
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
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(
                                  'https://helfer.flatzi.com/img/personal/${personal.foto}',
                                ),
                                child: ClipOval(
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/placeholder.jpg',
                                    image:
                                        'https://helfer.flatzi.com/img/personal/${personal.foto}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // CircleAvatar(
                              //   backgroundImage: NetworkImage(
                              //     'https://helfer.flatzi.com/img/personal/${personal.foto}',
                              //   ),
                              //   radius: 22,
                              // ),
                              title: Text(
                                'Servicio #${order.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Total: ₲ ${numberFormat(order.total.toString())}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(order.status),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  order.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                      // Si filteredDetalles está vacío, muestra este mensaje centrado
                      SliverFillRemaining(
                        hasScrollBody:
                            false, // Importante para centrar verticalmente
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
                                "Aun no tienes Servicios ${_statusDisplayNames[_selectedStatus]}.",
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
