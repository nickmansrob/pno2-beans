import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../Providers/MQTTAppState.dart';
import 'package:bean_bot/Providers/MQTTAppState.dart';
import 'package:provider/provider.dart';

// TODO: Delete check connection
// TODO: Make print IP work
// TODO: Investigate publishing

// weightListener for topic for currentWeight
// logListener for logs of the arduino

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);
  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  bool isSwitched = false;
  final _servoForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Menu'),
      ),
      body: ListView(children: [
        // Creates the connection indicator on top of the screen. \
        _buildConnectionStateText(
          _prepareStateMessageFrom(appState.getAppConnectionState),
          setColor(appState.getAppConnectionState),
        ),
        _buildManualOverrideState(appState.getAppConnectionState),
        _buildServoInput(),
        _buildMotorToggle(),
        _buildArduinoToggle(),
      ]),
    );
  }

  /////////////////////////// Widgets ///////////////////////////
  Widget _buildConnectionStateText(String status, Color color) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: color,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(status, textAlign: TextAlign.center),
              )),
        ),
      ],
    );
  }

  Widget _buildManualOverrideState(MQTTAppConnectionState connectionState) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                child: Text(
                  'Manual override',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 8, top: 8, right: 8, bottom: 0),
                  child: Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      if (!disableTextField(connectionState)) {
                        null;
                      } else {
                        setState(() {
                          isSwitched = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const Divider(
          indent: 8,
          endIndent: 8,
        ),
      ],
    );
  }

  Widget _buildMotorToggle() {
    return Container(
      foregroundDecoration: setGreyedOurBool(isSwitched),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                child: Text(
                  'Motors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isSwitched) {
                        null;
                      }
                    },
                    child: const Text('Toggle 1'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isSwitched) {
                        null;
                      }
                      // Respond to button press
                    },
                    child: const Text('Toggle 2'),
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            indent: 8,
            endIndent: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildServoInput() {
    return Container(
      foregroundDecoration: setGreyedOurBool(isSwitched),
      child: Form(
          key: _servoForm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisSize: MainAxisSize.max, children: const <Widget>[
                Padding(
                    padding:
                        EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
                    child: Text(
                      'Servos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: TextFormField(
                        enabled: isSwitched,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Degrees first',
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of degrees';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (!isSwitched) {
                            null;
                          }
                          // Respond to button press
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                indent: 8,
                endIndent: 8,
              ),
            ],
          )),
    );
  }

  Widget _buildArduinoToggle() {
    return Container(
      foregroundDecoration: setGreyedOurBool(isSwitched),
      child: Column(children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
              child: Text(
                'Arduino',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!isSwitched) {
                      null;
                    }
                    // Respond to button press
                  },
                  child: const Text('Reset'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!isSwitched) {
                      null;
                    }
                    // Respond to button press
                  },
                  child: const Text('Reconnect'),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!isSwitched) {
                      null;
                    }
                    // Respond to button press
                  },
                  child: const Text('Check connection'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!isSwitched) {
                      null;
                    }
                    // Respond to button press
                  },
                  child: const Text('Print IP'),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                child: const Text('Output'),
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.blue,
                  ),
                ),
              ),
            )
          ],
        ),
        const Divider(
          indent: 8,
          endIndent: 8,
        ),
      ]),
    );
  }

  
  /////////////////////////// Helper functions ///////////////////////////
  Color setColor(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return Colors.green;
      case MQTTAppConnectionState.connecting:
        return Colors.deepOrange;
      case MQTTAppConnectionState.disconnected:
        return Colors.red;
    }
  }

  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  // Function to disable textfields when not connected to the Arduino.
  bool disableTextField(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected ||
        state == MQTTAppConnectionState.connecting) {
      return false;
    } else {
      return true;
    }
  }
  BoxDecoration? setGreyedOurBool(boolean) {
    if (!boolean) {
      return const BoxDecoration(
        color: Colors.grey,
        backgroundBlendMode: BlendMode.saturation,
      );
    }
  }

  // Gives a greyed-out widget if app is not connected to the broker.
  BoxDecoration? setGreyedOut(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected ||
        state == MQTTAppConnectionState.connecting) {
      return const BoxDecoration(
        color: Colors.grey,
        backgroundBlendMode: BlendMode.saturation,
      );
    }
  }
}
