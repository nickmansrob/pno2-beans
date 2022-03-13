import 'package:flutter/material.dart';

class OrderState with ChangeNotifier {
  String _weightOrder = '';
  String _siloNumber = '';
  String _currentOrder = 'no order';

  void setWeightOrder(String weight) {
    _weightOrder = weight;
    notifyListeners();
  }

  void setSiloNumber(String color) {
    _siloNumber = color;
    notifyListeners();
  }

  void setCurrentOrder(String currentOrder) {
    _currentOrder = currentOrder;
    notifyListeners();
  }

  String get getWeightOrder => _weightOrder;
  String get getSiloNumber => _siloNumber;
  String get getCurrentOrder => _currentOrder;
}
