import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:flutter/material.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  late MQTTManager _mqttManager;

  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _firstOrderDone = '';
  String _secondOrderDone = '';
  String _firstOrderWeightText = '0';
  String _secondOrderWeightText = '0';
  String _logText = '';
  String _hostIp = '';
  bool _isSwitched = false;
  String _firstColor = 'not determined';
  String _secondColor = 'not determined';

  void setReceivedLogText(String text) {
    _receivedText = text;
    _logText = _logText + '\n' + _receivedText;
    notifyListeners();
  }

  void setFirstOrderDone(String done) {
    _firstOrderDone = done;
    notifyListeners();
  }

  void setSecondOrderDone(String done) {
    _secondOrderDone = done;
    notifyListeners();
  }

  void setMQTTManger(MQTTManager manager) {
    _mqttManager = manager;
    notifyListeners();
  }

  void deleteLogText() {
    _logText = '';
    notifyListeners();
  }

  void setFirstOrderReceivedWeightText(String text) {
    _firstOrderWeightText = text;
    notifyListeners();
  }

  void setSecondOrderReceivedWeightText(String text) {
    _secondOrderWeightText = text;
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

  void setFirstColor(String color) {
    _firstColor = color;
    notifyListeners();
  }

  void setSecondColor(String color) {
    _secondColor = color;
    notifyListeners();
  }

  void disposeFirstOrderAppState() {
    _firstOrderDone = '';
    _firstColor = 'not determined';
    _firstOrderWeightText = '';
  }

  void disposeSecondOrderAppState() {
    _secondOrderDone = '';
    _secondColor = 'not determined';
    _secondOrderWeightText = '';
  }

  String get getReceivedText => _receivedText;
  String get getFirstOrderDone => _firstOrderDone;
  String get getSecondOrderDone => _secondOrderDone;
  String get getLogText => _logText;
  String get getFirstOrderWeightText => _firstOrderWeightText;
  String get getSecondOrderWeightText => _secondOrderWeightText;
  String get getHostIP => _hostIp;
  String get getSecondColor => _secondColor;
  String get getFirstColor => _firstColor;
  bool get getIsSwitched => _isSwitched;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
  MQTTManager get getMQTTManager => _mqttManager;
}
