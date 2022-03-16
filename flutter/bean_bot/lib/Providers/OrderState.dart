import 'package:flutter/material.dart';


class OrderState with ChangeNotifier {
  String _firstWeightOrder = '';
  String _secondWeightOrder = '';
  String _weightOrder = '';
  String _siloNumber =  '';
  String _firstSiloNumber = '';
  String _secondSiloNumber = '';
  String _firstOrder = '';
  String _secondOrder = '';

  
  void setWeightOrder(String weight) {
    _weightOrder = weight;
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
    if (_secondWeightOrder == '' && _firstWeightOrder == '') {
      _firstWeightOrder = weight;
    }
    else if (_secondWeightOrder == '' && _firstWeightOrder != '') {
      _secondWeightOrder = weight;
    }
    notifyListeners();
  }

  void setSiloNumber(String siloNumber) {
    _siloNumber = siloNumber;
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
    }
    else {
      setSecondOrder(order);
    }
    notifyListeners();
  }

  String get getSiloNumber => _siloNumber;
  String get getFirstSiloNumber => _firstSiloNumber;
  String get getSecondSiloNumber => _secondSiloNumber;
  String get getFirstOrder => _firstOrder;
  String get getSecondOrder => _secondOrder;
  String get getFirstWeightOrder => _firstWeightOrder;
  String get getSecondWeightOrder => _secondWeightOrder;
  String get getWeightOrder => _weightOrder;
}
