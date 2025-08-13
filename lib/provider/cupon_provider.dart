import 'package:babyaid/model/cupon_model.dart';
import 'package:babyaid/services/get_cupones.dart';
import 'package:flutter/material.dart';

class CuponProvider with ChangeNotifier {
  // 🔸 Lista de IDs para control rápido
  Set<int> _productosConCuponIds = {};

  // 🔸 Mapa para obtener detalles del cupón por producto
  Map<int, Cupon> _cuponesPorProducto = {};

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> cargarCuponesPorProducto() async {
    final datos = await fetchProductosConCupon();

    _productosConCuponIds = datos.map((e) => e.producto.id).toSet();
    _cuponesPorProducto = {
      for (var item in datos) item.producto.id: item.cupon,
    };

    _loaded = true;
    notifyListeners();
  }

  // 🔍 Saber si tiene cupón
  bool productoTieneCupon(int productId) {
    return _productosConCuponIds.contains(productId);
  }

  // 🧠 Obtener detalles del cupón
  Cupon? obtenerCuponDeProducto(int productId) {
    return _cuponesPorProducto[productId];
  }
}
