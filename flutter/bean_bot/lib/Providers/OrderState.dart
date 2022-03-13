import 'package:flutter/material.dart';

class OrderState with ChangeNotifier {
  String _weightOrder = '';
  String _beanColor = 'Red Beans';
  String _currentOrder = 'no order';

  void setWeightOrder(String weight) {
    _weightOrder = weight;
    notifyListeners();
  }

  void setBeanColor(String color) {
    _beanColor = color;
    notifyListeners();
  }

  void setCurrentOrder(String currentOrder) {
    _currentOrder = currentOrder;
    notifyListeners();
  }

  String get getWeightOrder => _weightOrder;
  String get getBeanColor => _beanColor;
  String get getCurrentOrder => _currentOrder;
}
