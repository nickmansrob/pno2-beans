import 'package:flutter/cupertino.dart';

class ColorCalibrationState with ChangeNotifier {
  int _r = 0;
  int _g = 0;
  int _b = 0;

  void set_r(int r) {
    _r = r;
    notifyListeners();
  }

  void set_g(int g) {
    _g = g;
    notifyListeners();
  }

  void set_b(int b) {
    _b = b;
    notifyListeners();
  }

  int get get_r => _r;
  int get get_g => _g;
  int get get_b => _b;
}