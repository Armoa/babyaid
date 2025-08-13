import 'dart:convert';

import 'package:babyaid/model/cupon_model.dart';
import 'package:http/http.dart' as http;

Future<List<ProductoConCupon>> fetchProductosConCupon() async {
  final response = await http.get(
    Uri.parse(
      'https://helfer.flatzi.com/app/cupones/productos_con_cupones.php',
    ),
  );
  final List<dynamic> jsonList = jsonDecode(response.body);

  final productos = jsonList.map((e) => ProductoConCupon.fromJson(e)).toList();
  return productos;
}
