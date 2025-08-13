import 'dart:convert';

import 'package:babyaid/model/orders_model.dart';
import 'package:http/http.dart' as http;

Future<List<Order>> fetchOrders(int userId) async {
  final url = Uri.parse(
    "https://helfer.flatzi.com/app/get_reservas.php?user_id=$userId",
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    final List ordersJson = jsonData['orders'];
    return ordersJson.map((o) => Order.fromJson(o)).toList();
  } else {
    throw Exception("Error al cargar pedidos");
  }
}
