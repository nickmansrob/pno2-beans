import 'package:flutter/material.dart';

class OrderState with ChangeNotifier {
  String _firstWeightOrder = '';
  String _secondWeightOrder = '';
  String _weightOrder = '';
  String _siloChoiceNumber = '';
  String _firstSiloNumber = '';
  String _secondSiloNumber = '';
  String _firstOrder = '';
  String _secondOrder = '';
  int _orderCount = 0;

  void setWeightOrder(String weight) {
    _weightOrder = weight;
    notifyListeners();
  }

  void incementOrderCount() {
    _orderCount++;
    notifyListeners();
  }

  void decrementOrderCount() {
    _orderCount--;
    notifyListeners();
  }

  void setFirstWeightOrder(String weight) {
    _firstWeightOrder = weight;
    notifyListeners();
  }

  void setSecondWeightOrder(String weight) {
    _secondWeightOrder = weight;
    notifyListeners();
  }

  void setBothWeightOrder(String weight) {
    if (_firstWeightOrder == '') {
      setFirstWeightOrder(weight);
    } else {
      setSecondWeightOrder(weight);
    }
    notifyListeners();
  }

  void setSiloChoiceNumber(String siloNumber) {
    _siloChoiceNumber = siloNumber;
    notifyListeners();
  }

  void setSiloNumber(String siloNumber) {
    if (_firstSiloNumber == '') {
      _firstSiloNumber = siloNumber;
    } else {
      _secondSiloNumber = siloNumber;
    }
    notifyListeners();
  }

  void setFirstSiloNumber(String siloNumber) {
    _firstSiloNumber = siloNumber;
    notifyListeners();
  }

  void setSecondSiloNumber(String siloNumber) {
    _secondSiloNumber = siloNumber;
    notifyListeners();
  }

  void setFirstOrder(String firstOrder) {
    _firstOrder = firstOrder;
    notifyListeners();
  }

  void setSecondOrder(String secondOrder) {
    _secondOrder = secondOrder;
    notifyListeners();
  }

  void setOrder(String order) {
    if (_firstOrder == '') {
      setFirstOrder(order);
    } else {
      setSecondOrder(order);
    }
    notifyListeners();
  }

  void disposeFirstOrder() {
    _firstSiloNumber = '';
    _firstWeightOrder = '';
    _firstOrder = '';
    notifyListeners();
  }

  void disposeSecondOrder() {
    _secondSiloNumber = '';
    _secondWeightOrder = '';
    _secondOrder = '';
    notifyListeners();
  }

  void disposeOrderState() {
    _firstSiloNumber = '';
    _firstWeightOrder = '';
    _firstOrder = '';
    _secondSiloNumber = '';
    _secondWeightOrder = '';
    _secondOrder = '';
    _orderCount = 0;
    _siloChoiceNumber = '';
    _weightOrder = '';
    notifyListeners();
  }

  String get getSiloChoiceNumber => _siloChoiceNumber;
  String get getFirstSiloNumber => _firstSiloNumber;
  String get getSecondSiloNumber => _secondSiloNumber;
  String get getFirstOrder => _firstOrder;
  String get getSecondOrder => _secondOrder;
  String get getFirstWeightOrder => _firstWeightOrder;
  String get getSecondWeightOrder => _secondWeightOrder;
  String get getWeightOrder => _weightOrder;
  int get getOrderCount => _orderCount;
}
