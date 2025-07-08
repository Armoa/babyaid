import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/card_model.dart';
import 'package:helfer/provider/cart_provider.dart';
import 'package:helfer/provider/cupon_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

Future<void> validarYAplicarCupon({
  required BuildContext context,
  required String codigo,
  required double total,
  required double totalOriginal,

  required void Function(Map<String, dynamic> cupon, double totalFinal)
  onSuccess,
  required void Function(String mensajeError) onError,
  required List<CartItem> cartItems,
}) async {
  final url = Uri.parse(
    'https://helfer.flatzi.com/app/cupones/validar_cupon_cliente.php',
  );

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'codigo': codigo}),
    );

    final data = jsonDecode(response.body);

    print('Respuesta del servidor: ${response.body}');

    if (response.statusCode == 200 && data['valido'] == true) {
      final cupon = data['cupon'];
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final descuento = calcularDescuento(
        cupon: data['cupon'],
        total: totalOriginal,
        cartItems: cartProvider.cartItems,
        context: context,
      );
      final totalFinal = total - descuento;

      onSuccess(cupon, totalFinal); // 👉 callback que actualiza el estado
    } else {
      onError(data['mensaje'] ?? 'Cupón inválido');
    }
  } catch (e) {
    onError('Ocurrió un error: $e');
  }
}

double calcularDescuento({
  required Map<String, dynamic> cupon,
  required double total,
  required List<CartItem> cartItems,
  required BuildContext context,
}) {
  final tipo = cupon['type'];
  final monto = double.tryParse(cupon['amount'].toString()) ?? 0.0;
  final tieneId = cupon.containsKey('id'); // Detectamos si viene de producto

  if (tipo == 'percentage') {
    return total * (monto / 100);
  } else if (tipo == 'fixed_cart') {
    return monto;
  } else if (tipo == 'fixed_product') {
    if (!tieneId) {
      // 👉 Cupón acumulado del cliente
      return monto;
    }

    // 👉 Cupón aplicado a productos específicos del carrito
    final cantidadProductosConCupon = cartItems
        .where(
          (item) =>
              Provider.of<CuponProvider>(
                context,
                listen: false,
              ).obtenerCuponDeProducto(item.id)?.id ==
              cupon['id'],
        )
        .fold(0, (sum, item) => sum + item.quantity);

    return monto * cantidadProductosConCupon;
  } else {
    return 0.0;
  }
}
