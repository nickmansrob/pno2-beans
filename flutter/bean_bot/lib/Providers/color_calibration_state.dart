import 'package:flutter/cupertino.dart';

class ColorCalibrationState with ChangeNotifier {
  int _r = 0;
  int _g = 0;
  int _b = 0;
  int _calibrationsDone = 0;
  bool _startCalibration = false;
  String _calibrationSentMessage = 'start000000000';
  String _calibrationReceivedMessage = 'stop256256256';

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

  void incrementCalibrationsDone() {
    _calibrationsDone += 1;
    notifyListeners();
  }

  void setStartCalibration(value) {
    _startCalibration = value;
    notifyListeners();
  }

  void setCalibrationSentMessage(message) {
    _calibrationSentMessage = message;
    notifyListeners();
  }

  void setCalibrationReceivedMessage(message) {
    _calibrationReceivedMessage = message;
    notifyListeners();
  }

  int get get_r => _r;
  int get get_g => _g;
  int get get_b => _b;
  int get getCalibrationsDone => _calibrationsDone;
  bool get getStartCalibration => _startCalibration;
  String get getCalibrationSentMessage => _calibrationSentMessage;
  String get getCalibrationReceivedMessage => _calibrationReceivedMessage;
}