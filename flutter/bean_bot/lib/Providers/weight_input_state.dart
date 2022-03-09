import 'package:flutter/material.dart';

class OrderState with ChangeNotifier {
  String _weight = '';
  String _color  = 'Red Beans';
  String _currentWeight = '0';
  String _currentOrder = 'No order';

  void setWeight(String weight) {
    _weight = weight;
  }
  void setColor(String color) {
    _color = color;
  }

  void setCurrentOrder(String currentOrder) {
    _currentOrder  = currentOrder;
  }

  String get getWeight => _weight;
  String get getColor => _color;
  String get getCurrentWeight => _currentWeight;
  String get getCurrentOrder => _currentOrder;
}
