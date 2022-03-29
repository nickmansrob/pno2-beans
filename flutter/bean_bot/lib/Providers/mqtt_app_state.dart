import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:flutter/material.dart';


enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
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
  String _firstColor = 'not determined';
  String _secondColor = 'not determined';
  String _firstColorInt = '000000000';
  String _secondColorInt = '000000000';
  String _distance = "";
  
  Color _beanColor = const Color.fromRGBO(0, 0, 0, 1);
  String  _orderMessage = '';
  bool _resetPressed = false;
  bool _restorePressed = false;
  String _appId = "BeanBotApp";
  
  void setDistance(String distance) {
    _distance = distance;
  void setBeanColor(Color color) {
    _beanColor = color;
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

  void setFirstColor(String color) {
    _firstColor = color;
    notifyListeners();
  }

  void setSecondColor(String color) {
    _secondColor = color;
    notifyListeners();
  }

  void setFirstColorInt(String colorInt) {
    _firstColorInt = colorInt;
    notifyListeners();
  }

  void setSecondOrder(String colorInt) {
    _firstColorInt = colorInt;
    notifyListeners();
  }

  void disposeFirstOrderAppState() {
    _firstOrderReceivedDone = '';
    _firstColor = 'not determined';
    _firstOrderWeightText = '';
    _firstOrderDone = "";
    notifyListeners();
  }

  void disposeSecondOrderAppState() {
    _secondOrderReceivedDone = '';
    _secondColor = 'not determined';
    _secondOrderWeightText = '';
    _secondOrderDone = "";
    notifyListeners();
  }

  void disposeAppState() {
    _firstOrderReceivedDone = '';
    _firstColor = 'not determined';
    _firstOrderWeightText = '0';
    _secondOrderReceivedDone = '';
    _secondColor = 'not determined';
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

  String get getReceivedText => _receivedText;
  String get getFirstOrderReceivedDone => _firstOrderReceivedDone;
  String get getSecondOrderReceivedDone => _secondOrderReceivedDone;
  String get getFirstOrderDone => _firstOrderDone;
  String get getSecondOrderDone => _secondOrderDone;
  String get getLogText => _logText;
  String get getFirstOrderWeightText => _firstOrderWeightText;
  String get getSecondOrderWeightText => _secondOrderWeightText;
  String get getHostIP => _hostIp;
  String get getSecondColor => _secondColor;
  String get getFirstColor => _firstColor;
  String get getFirstColorInt => _firstColorInt;
  String get getSecondColorInt => _secondColorInt;
  Color get getBeanColor => _beanColor;
  String get getOrderMessage => _orderMessage;
  bool get getIsSwitched => _isSwitched;
  bool get getRestorePressed => _restorePressed;
  bool get getResetPressed => _resetPressed;
  String get getAppId => _appId;
  String get getDistance => _distance;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
  MQTTManager get getMQTTManager => _mqttManager;
}
