import 'package:bebito/model/colors.dart';
import 'package:bebito/model/orders_model.dart';
import 'package:bebito/services/functions.dart';
import 'package:bebito/services/order_get_.dart';
import 'package:flutter/material.dart';

class MyOrders extends StatefulWidget {
  final int userId;

  const MyOrders({super.key, required this.userId});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  Map<String, Color> orderStatusColors = {
    'pendiente': Colors.orange, // Pendiente
    'procesando': Colors.blue, // En proceso
    'enviado': Colors.teal, // En espera
    'completado': Colors.green, // Completado
    'cancelado': Colors.red, // Cancelado
    // 'refunded': Colors.purple, // Reembolsado
    // 'failed': Colors.grey, // Fallido
  };
  Color getStatusColor(String status) {
    return orderStatusColors[status] ?? Colors.black; // Color predeterminado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueLight,
      appBar: AppBar(title: const Text("Mis pedidos")),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: FutureBuilder<List<Order>>(
            future: fetchOrders(widget.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final order = snapshot.data![index];
                    return Stack(
                      children: [
                        Positioned(
                          top: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              textAlign: TextAlign.center,
                              (order.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),

                        Card(
                          elevation: 0,
                          child: ListTile(
                            leading: const Icon(Icons.wallet_giftcard_outlined),
                            trailing: Container(
                              alignment: Alignment.center,
                              width: 64,
                              height: 26,
                              decoration: BoxDecoration(
                                color: getStatusColor(order.status),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(14),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  (order.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              'Pedido #${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${order.createdAt}\nTotal:  ₲.${numberFormat(order.total.toString())}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                return const Center(child: Text("No hay pedidos"));
              }
            },
          ),
        ),
      ),
    );
  }
}
