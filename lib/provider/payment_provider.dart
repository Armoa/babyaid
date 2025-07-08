import 'package:flutter/material.dart';

class PaymentProvider with ChangeNotifier {
  String _selectedMethod = "/";

  String get selectedMethod => _selectedMethod;

  void updateMethod(String method) {
    _selectedMethod = method;
    notifyListeners(); // Notifica cambios al resto de la app
  }
}
