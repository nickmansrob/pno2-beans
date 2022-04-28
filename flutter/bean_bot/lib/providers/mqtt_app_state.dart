import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:flutter/material.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {

  /////////////////////////// Variables ///////////////////////////
  late MQTTManager _mqttManager;

  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '';

  String _firstOrderReceivedDone = '';
  String _secondOrderReceivedDone = '';
  String _firstOrderDone = '';
  String _secondOrderDone = '';
  String _firstOrderWeightText = '0';
  String _secondOrderWeightText = '0';

  String _logText = '';
  String _hostIp = '';
  bool _isSwitched = false;

  Color _firstColor = const Color.fromRGBO(0, 0, 0, 1);
  Color _secondColor = const Color.fromRGBO(0, 0, 0, 1);

  String _distance = "";
  String _weight = "";

  Color _colorDebug = const Color.fromRGBO(0, 0, 0, 1);
  String _orderMessage = '';
  bool _resetPressed = false;
  bool _restorePressed = false;
  String _appId = "BeanBotApp";

  /////////////////////////// Setters ///////////////////////////
  void setColorDebug(Color color) {
    _colorDebug = color;
    notifyListeners();
  }
  void setWeight(String weight) {
    _weight = weight;
    notifyListeners();
  }
  void setDistance(String distance) {
    _distance = distance;
    notifyListeners();
  }

  void setOrderMessage(String orderMessage) {
    _orderMessage = orderMessage;
    notifyListeners();
  }

  void setReceivedLogText(String text) {
    _receivedText = text;
    _logText = _logText + '\n' + _receivedText;
    notifyListeners();
  }

  void setFirstOrderReceivedDone(String done) {
    _firstOrderReceivedDone = done;
    notifyListeners();
  }

  void setSecondOrderReceivedDone(String done) {
    _secondOrderReceivedDone = done;
    notifyListeners();
  }

  void setFirstOderDone(String done) {
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

  void setFirstColor(Color color) {
    _firstColor = color;
    notifyListeners();
  }

  void setSecondColor(Color color) {
    _secondColor = color;
    notifyListeners();
  }

  void disposeFirstOrderAppState() {
    _firstOrderReceivedDone = '';
    _firstColor = const Color.fromRGBO(0, 0, 0, 1);
    _firstOrderWeightText = '0';
    _firstOrderDone = "";
    notifyListeners();
  }

  void disposeSecondOrderAppState() {
    _secondOrderReceivedDone = '';
    _secondColor = const Color.fromRGBO(0, 0, 0, 1);
    _secondOrderWeightText = '0';
    _secondOrderDone = "";
    notifyListeners();
  }

  void disposeAppState() {
    _firstOrderReceivedDone = '';
    _firstColor = const Color.fromRGBO(0, 0, 0, 1);
    _firstOrderWeightText = '0';
    _secondOrderReceivedDone = '';
    _secondColor = const Color.fromRGBO(0, 0, 0, 1);
    _secondOrderWeightText = '0';
    _firstOrderDone = '';
    _secondOrderDone = '';
    notifyListeners();
  }

  void setRestorePressed(bool pressed) {
    _restorePressed = pressed;
    notifyListeners();
  }

  void setResetPressed(bool pressed) {
    _resetPressed = pressed;
    notifyListeners();
  }

  void setAppId(String appId) {
    _appId = appId;
    notifyListeners();
  }

  /////////////////////////// Getters ///////////////////////////
  String get getWeight => _weight;
  String get getReceivedText => _receivedText;
  String get getFirstOrderReceivedDone => _firstOrderReceivedDone;
  String get getSecondOrderReceivedDone => _secondOrderReceivedDone;
  String get getFirstOrderDone => _firstOrderDone;
  String get getSecondOrderDone => _secondOrderDone;
  String get getLogText => _logText;
  String get getFirstOrderWeightText => _firstOrderWeightText;
  String get getSecondOrderWeightText => _secondOrderWeightText;
  String get getHostIP => _hostIp;
  Color get getSecondColor => _secondColor;
  Color get getFirstColor => _firstColor;
  Color get getColorDebug => _colorDebug;

  String get getOrderMessage => _orderMessage;
  bool get getIsSwitched => _isSwitched;
  bool get getRestorePressed => _restorePressed;
  bool get getResetPressed => _resetPressed;
  String get getAppId => _appId;
  String get getDistance => _distance;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
  MQTTManager get getMQTTManager => _mqttManager;
}
