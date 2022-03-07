import 'package:flutter/material.dart';
import 'package:bean_bot/Providers/MQTTAppState.dart';
import 'package:provider/provider.dart';

class LogPage extends StatelessWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Logs'),
        ),
        body: ListView(children: [
          _buildConnectionStateText(
            _prepareStateMessageFrom(Provider.of<MQTTAppState>(context).getAppConnectionState),
            setColor(Provider.of<MQTTAppState>(context).getAppConnectionState),),
          Container(
          child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Output',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )
              ]),
          margin:
              const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 40),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black),
          ),
        ),],),
      );

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
}
