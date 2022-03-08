import 'package:flutter/material.dart';

class WeightInputState with ChangeNotifier {
  String _weight = '';
  String _color  = 'Red Beans';

  void setWeight(String weight) {
    _weight = weight;
  }
  void setColor(String color) {
    _color = color;
  }

  String get getWeight => _weight;
  String get getColor => _color;
}
