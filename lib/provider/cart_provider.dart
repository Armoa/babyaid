import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:helfer/model/card_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get totalDistinctItems => _cartItems.length;

  CartProvider() {
    _loadCartFromPrefs();
  }

  void addToCart(CartItem product, int quantity) {
    final index = _cartItems.indexWhere((item) => item.id == product.id);

    if (index != -1) {
      _cartItems[index].quantity += quantity;

      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
    } else if (quantity > 0) {
      _cartItems.add(product.copyWith(quantity: quantity));
    }

    notifyListeners();
    _saveCartToPrefs();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.id == productId);
    notifyListeners();
    _saveCartToPrefs();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    _saveCartToPrefs();
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedCart = jsonEncode(_cartItems.map((e) => e.toJson()).toList());
    await prefs.setString('cart', encodedCart);
  }

  Future<void> _loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      final List decoded = jsonDecode(cartString);
      _cartItems.clear();
      _cartItems.addAll(decoded.map((e) => CartItem.fromJson(e)));
      notifyListeners();
    }
  }
}
