import 'package:bean_bot/providers/color_calibration_state.dart';
import 'package:bean_bot/providers/mqtt_app_state.dart';
import 'package:bean_bot/providers/order_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager with ChangeNotifier {
  // Private instance of client
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final OrderState _currentOrderState;
  final ColorCalibrationState _currentColorCalibrationState;
  final String _identifier;
  final String _host;
  final List _topicList;

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager(
      {required String host,
      required List topicList,
      required String identifier,
      required MQTTAppState state,
      required OrderState orderState,
      required ColorCalibrationState colorCalibrationState})
      : _identifier = identifier,
        _host = host,
        _topicList = topicList,
        _currentState = state,
        _currentOrderState = orderState,
        _currentColorCalibrationState = colorCalibrationState;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    _client!.onConnected = onConnected;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect() async {
    assert(_client != null);
    try {
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception {
      disconnect();
    }
  }

  void disconnect() {
    _client!.disconnect();
    _currentState.setIsSwitched(false);
    _currentState.disposeSecondOrderAppState();
    _currentOrderState.disposeSecondOrder();
  }

  void publish(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {}
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    for (var i = 0; i < _topicList.length; i++) {
      _client!.subscribe(_topicList[i], MqttQos.atLeastOnce);
    }

    _client!.updates!.listen(
      (List<MqttReceivedMessage<MqttMessage?>>? c) {
        // ignore: avoid_as
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

        // final MqttPublishMessage recMess = c![0].payload;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        switch (c[0].topic) {
          case 'logListener':
            _currentState.setReceivedLogText(pt);
            break;
          case 'firstWeightListener':
            if (pt == 'done') {
              _currentState.setFirstOrderReceivedDone(pt);
              _currentState.setFirstOderDone(pt);
              publish(_currentState.getOrderMessage, 'order2');
            }
            else if (double.tryParse(pt) != null) {
              _currentState.setFirstOrderReceivedWeightText(pt);
            }
            break;
          case 'secondWeightListener':
            if (pt == 'done') {
              _currentState.setSecondOrderReceivedDone(pt);
              _currentState.setSecondOrderDone(pt);
            }
            else if (double.tryParse(pt) != null) {
              _currentState.setSecondOrderReceivedWeightText(pt);
            }
            break;
          case 'firstColorListener':
            _currentState.setFirstColor(convertIntToColor(pt));
            _currentState.setFirstColorInt(pt);
            _currentState.setBeanColor(convertRGBtoColor(pt));
            break;
          case 'secondColorListener':
            _currentState.setSecondColor(convertIntToColor(pt));
            break;

            // This is deprecated by `firstWeightListener` and `secondWeightListener`.
            // Remains for backwards compatibility.
          case 'order1':
            if (pt == 'done') {
              _currentState.setFirstOrderReceivedDone(pt);
              _currentState.setFirstOderDone(pt);
              publish(_currentState.getOrderMessage, 'order2');
            }
            break;
          case 'order2':
            if (pt == 'done') {
              _currentState.setSecondOrderReceivedDone(pt);
              _currentState.setSecondOrderDone(pt);
            }
            break;
          case 'distanceListener':
            _currentState.setDistance(pt);

            break;
          case 'adminListener':
            if (pt == 'done_all') {
              _currentOrderState.disposeOrderState();
              _currentState.disposeAppState();
            } else if (pt == 'section_done') {
              if (_currentState.getIsSwitched == true) {
                publish('override', 'adminListener');
              } else if (_currentState.getResetPressed == true) {
                publish('reset', 'adminListener');
                _currentState.setResetPressed(false);
              } else if (_currentState.getRestorePressed == true) {
                publish('restore', 'adminListener');
                _currentState.setRestorePressed(false);
              } else {
                publish('proceed', 'adminListener');
              }
            }
            break;
          case 'colorCalibration':
            if (pt == 'start_calibration') {
              _currentColorCalibrationState.setStartCalibration(true);
              notifyListeners();
            } else if (pt.substring(0, 4) == 'stop') {
              _currentColorCalibrationState.setCalibrationReceivedMessage(pt);
              notifyListeners();
            }
            break;
        }
      },
    );
  }

  String convertIntToColor(String colorInt) {
    List intList = [
      int.parse(colorInt.substring(0, 3)),
      int.parse(colorInt.substring(3, 6)),
      int.parse(colorInt.substring(6, 9))
    ];
    if (intList[0] == 255 && intList[1] == 0 && intList[2] == 0) {
      return 'red';
    } else if (intList[0] == 255 && intList[1] == 255 && intList[2] == 255) {
      return 'white';
    } else if (intList[0] == 0 && intList[1] == 0 && intList[2] == 0) {
      return 'black';
    } else {
      return 'not determined';
    }
  }

  Color convertRGBtoColor(String colorInt) {
    List intList = [
      int.parse(colorInt.substring(0, 3)),
      int.parse(colorInt.substring(3, 6)),
      int.parse(colorInt.substring(6, 9))
    ];

    return Color.fromRGBO(intList[0], intList[1], intList[2], 1);
  }
}
