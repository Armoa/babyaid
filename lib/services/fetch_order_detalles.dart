import 'dart:convert';

import 'package:babyaid/model/orders_model.dart';
import 'package:babyaid/model/personal_model.dart';
import 'package:http/http.dart' as http;

class OrderDetalle {
  final Order order;
  final PersonalModel personal;

  OrderDetalle({required this.order, required this.personal});
}

List<OrderDetalle> listaDetalle = [];

List<OrderDetalle> parseOrderDetalles(List<dynamic> responseJson) {
  List<OrderDetalle> detalles = [];
  for (final json in responseJson) {
    final order = Order.fromJson(json['order']);
    final personal = PersonalModel.fromJson(json['personal']);
    detalles.add(OrderDetalle(order: order, personal: personal));
  }
  return detalles;
}

Future<List<OrderDetalle>> fetchOrderDetalles(int userId) async {
  final url = Uri.parse(
    "https://helfer.flatzi.com/app/get_reservas.php?user_id=$userId",
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    print(response.body);

    // 👇 Aquí van las dos líneas que mencionás
    final List responseJson = jsonData['orders'];
    return parseOrderDetalles(responseJson);
  } else {
    throw Exception("Error al cargar pedidos con personal");
  }
}
