import 'package:bean_bot/Providers/MQTTAppState.dart';
import 'package:bean_bot/Providers/OrderState.dart';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTManager with ChangeNotifier {
  // Private instance of client
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final OrderState _currentOrderState;
  final String _identifier;
  final String _host;
  final String _topic1;
  final String _topic2;
  final String _topic3;
  final String _topic4;
  final String _topic5;

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager(
      {required String host,
        required String topic1,
        required String topic2,
        required String topic3,
        required String topic4,
        required String topic5,
        required String identifier,
         required MQTTAppState state,  required OrderState orderState})
      : _identifier = identifier,
        _host = host,
        _topic1 = topic1,
        _topic2 = topic2,
        _topic3 = topic3,
        _topic4 = topic4,
  _topic5 = topic5,
        _currentState = state,
        _currentOrderState = orderState;

  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    print('EXAMPLE::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect() async {
    assert(_client != null);
    try {
      print('EXAMPLE::Mosquitto start client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      print('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    print('Disconnected');
    _client!.disconnect();
    _currentState.setIsSwitched(false);
    _currentOrderState.setSiloNumber('');
    _currentOrderState.setFirstOrder('no order');
  }

  void publish(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    print('EXAMPLE::Mosquitto client connected....');
    _client!.subscribe(_topic1, MqttQos.atLeastOnce);
    _client!.subscribe(_topic2, MqttQos.atLeastOnce);
    _client!.subscribe(_topic3, MqttQos.atLeastOnce);
    _client!.subscribe(_topic4, MqttQos.atLeastOnce);
    _client!.subscribe(_topic5, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
      MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      switch(c[0].topic) {
        case 'logListener':
          _currentState.setReceivedLogText(pt);
          break;
        case 'firstWeightListener':
          _currentState.setFirstOrderReceivedWeightText(pt);
          break;
        case 'secondWeightListener':
          _currentState.setSecondOrderReceivedWeightText(pt);
          break;
      }

      print(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      print('');
    });
    print(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }
}
