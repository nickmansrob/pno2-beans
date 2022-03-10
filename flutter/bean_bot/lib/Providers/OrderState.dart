import 'package:flutter/material.dart';

class OrderState with ChangeNotifier {
  String _weightOrder = '';
  String _color = 'Red Beans';
  String _currentOrder = 'no order';

  void setWeightOrder(String weight) {
    _weightOrder = weight;
    notifyListeners();
  }

  void setColor(String color) {
    _color = color;
    notifyListeners();
  }

  void setCurrentOrder(String currentOrder) {
    _currentOrder = currentOrder;
    notifyListeners();
  }

  String get getWeightOrder => _weightOrder;
  String get getColor => _color;
  String get getCurrentOrder => _currentOrder;
}
