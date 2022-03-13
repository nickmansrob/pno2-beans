import 'package:flutter/material.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _weightText = '0';
  String _logText = '';
  String _hostIp = '';
  bool _isSwitched = false;

  void setReceivedLogText(String text) {
    _receivedText = text;
    _logText = _logText + '\n' + _receivedText;
    notifyListeners();
  }

  void deleteLogText() {
    _logText = '';
    notifyListeners();
  }

  void setReceivedWeightText(String text) {
    _receivedText = text;
    _weightText = _receivedText;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  void setHostIp(String ip) {
    _hostIp = ip;
    notifyListeners();
  }

  void setIsSwitched(bool value) {
    _isSwitched = value;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getLogText => _logText;
  String get getWeightText => _weightText;
  String get getHostIP => _hostIp;
  bool get getIsSwitched => _isSwitched;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}
