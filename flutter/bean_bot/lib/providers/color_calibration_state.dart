import 'package:flutter/cupertino.dart';

class ColorCalibrationState with ChangeNotifier {
  /////////////////////////// Variables ///////////////////////////
  int _r = 0;
  int _g = 0;
  int _b = 0;
  int _calibrationsDone = 0;
  bool _startCalibration = false;
  String _calibrationSentMessage = 'start000000000';
  String _calibrationReceivedMessage = 'stop256256256';

  /////////////////////////// Setters ///////////////////////////
  void setR(int r) {
    _r = r;
    notifyListeners();
  }

  void setG(int g) {
    _g = g;
    notifyListeners();
  }

  void setB(int b) {
    _b = b;
    notifyListeners();
  }
  void resetCalibrationsDone() {
    _calibrationsDone = 0;
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

  /////////////////////////// Getters ///////////////////////////
  int get getR => _r;
  int get getG => _g;
  int get getB => _b;
  int get getCalibrationsDone => _calibrationsDone;
  bool get getStartCalibration => _startCalibration;
  String get getCalibrationSentMessage => _calibrationSentMessage;
  String get getCalibrationReceivedMessage => _calibrationReceivedMessage;
}
